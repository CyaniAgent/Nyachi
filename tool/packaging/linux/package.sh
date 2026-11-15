#!/usr/bin/env bash
# Builds the Linux installers — deb, rpm and AppImage — from the Flutter
# bundle at build/linux/x64/release/bundle. Called by the Release workflow
# (.github/workflows/release.yml) after `flutter build linux --release`.
#
# Usage: package.sh <version> <output-dir>
#
# Tooling is downloaded and checksum-pinned:
#   - nfpm          versioned release; the sha256 is the one published in the
#                   release's own checksums.txt
#   - appimagetool  AppImageKit `continuous` release (there is no versioned
#                   build); its sha256 is pinned below. When upstream
#                   publishes a new continuous build this script fails on
#                   purpose — verify the new file, then update the pin.
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <version> <output-dir>" >&2
  exit 2
fi

VERSION="$1"
OUT="$2"

# tool/packaging/linux -> repository root, three levels up.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
BUNDLE="$ROOT/build/linux/x64/release/bundle"
DESKTOP="$ROOT/tool/packaging/linux/nyachi.desktop"
ICON="$ROOT/tool/packaging/linux/nyachi.png"

if [ ! -d "$BUNDLE" ]; then
  echo "error: $BUNDLE not found; run 'flutter build linux --release' first" >&2
  exit 1
fi

# A malformed desktop entry would ship silently into every package, so check
# it before anything is built (desktop-file-utils; validated in CI, optional
# for local runs outside a dpkg system).
if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "$DESKTOP"
fi

NFPM_VERSION="2.49.0"
NFPM_SHA256="2afaa5ffb5e3493402e31e7c67a5a1fb42133e3f66fc315ca0051934125561c7"
APPIMAGETOOL_SHA256="b90f4a8b18967545fda78a445b27680a1642f1ef9488ced28b65398f2be7add2"

TOOLS="$(mktemp -d)"
APPDIR="$(mktemp -d)"
trap 'rm -rf "$TOOLS" "$APPDIR"' EXIT

fetch() { # <url> <dest> <sha256>
  curl -fsSL --retry 3 -o "$2" "$1"
  if ! echo "$3  $2" | sha256sum -c - >/dev/null 2>&1; then
    echo "error: checksum mismatch for $1" >&2
    echo "  expected: $3" >&2
    echo "  actual:   $(sha256sum "$2" | awk '{print $1}')" >&2
    exit 1
  fi
}

fetch "https://github.com/goreleaser/nfpm/releases/download/v$NFPM_VERSION/nfpm_${NFPM_VERSION}_Linux_x86_64.tar.gz" \
  "$TOOLS/nfpm.tar.gz" "$NFPM_SHA256"
tar -xzf "$TOOLS/nfpm.tar.gz" -C "$TOOLS" nfpm

fetch "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" \
  "$TOOLS/appimagetool" "$APPIMAGETOOL_SHA256"
chmod +x "$TOOLS/appimagetool"

# ---------------------------------------------------------------------------
# Runtime dependencies
#
# The package dependency lists follow the bundle's real dynamic-link surface:
# every soname the bundle needs but does not itself provide is mapped to the
# package that owns it (deb, via dpkg -S on the build host) or expressed as a
# soname requirement (rpm, which resolves sonames on any distribution). A new
# plugin that links a new library therefore shows up in the metadata
# automatically, and a soname no package owns fails the release here instead
# of shipping a package that crashes at runtime.
#
# readelf prints localized descriptions ("Shared library: [...]"), so only the
# structural (NEEDED)/(SONAME) markers are matched, never the prose around
# them.
#
# EXCLUDE_SONAMES: link requirements that never resolve at runtime on the
# target machines. libjvm.so is one: it is needed only by libdartjni.so,
# which ships in the bundle but is never registered or loaded — the jni
# plugin is the Android FFI path and no Dart code imports package:jni.
EXCLUDE_SONAMES="libjvm.so"

sonames() { # <NEEDED|SONAME> — every such entry across the bundle's ELF files
  local kind="$1" f
  while IFS= read -r f; do
    readelf -d "$f" 2>/dev/null | grep -F "($kind)" | sed 's/.*\[//; s/\]//'
  done < <(find "$BUNDLE" -type f)
}

external_needed_sonames() { # sonames the bundle needs from the system
  sonames SONAME | sort -u > "$TOOLS/provided"
  sonames NEEDED | sort -u | grep -vxF -f "$TOOLS/provided" || true
}

deb_depends() {
  if [ -n "${NYACHI_DEB_DEPENDS:-}" ]; then
    echo "$NYACHI_DEB_DEPENDS"
    return
  fi
  if ! command -v dpkg >/dev/null 2>&1; then
    echo "error: dpkg is required to derive deb dependencies (set NYACHI_DEB_DEPENDS to override, e.g. for local testing)" >&2
    exit 1
  fi
  local soname pkg
  local -a pkgs=()
  while IFS= read -r soname; do
    [ -n "$soname" ] || continue
    case " $EXCLUDE_SONAMES " in *" $soname "*) continue ;; esac
    pkg="$(dpkg -S "*/$soname" 2>/dev/null | head -n1 | cut -d: -f1 || true)"
    if [ -z "$pkg" ]; then
      echo "error: no Debian package owns */$soname" >&2
      echo "error: if it is never needed at runtime, add it to EXCLUDE_SONAMES in tool/packaging/linux/package.sh" >&2
      exit 1
    fi
    pkgs+=("$pkg")
  done < <(external_needed_sonames)
  if [ "${#pkgs[@]}" -eq 0 ]; then
    echo "error: derived an empty deb dependency list; the readelf scan of $BUNDLE failed" >&2
    exit 1
  fi
  printf '%s\n' "${pkgs[@]}" | sort -u | paste -sd, -
}

rpm_depends() {
  if [ -n "${NYACHI_RPM_DEPENDS:-}" ]; then
    echo "$NYACHI_RPM_DEPENDS"
    return
  fi
  # "(64bit)" is rpm's x86_64 dependency qualifier; the Release workflow
  # builds this package for x86_64 only.
  local soname
  local -a reqs=()
  while IFS= read -r soname; do
    [ -n "$soname" ] || continue
    case " $EXCLUDE_SONAMES " in *" $soname "*) continue ;; esac
    reqs+=("$soname()(64bit)")
  done < <(external_needed_sonames)
  if [ "${#reqs[@]}" -eq 0 ]; then
    echo "error: derived an empty rpm dependency list; the readelf scan of $BUNDLE failed" >&2
    exit 1
  fi
  printf '%s\n' "${reqs[@]}" | sort -u | paste -sd, -
}

NYACHI_DEB_DEPENDS="$(deb_depends)"
NYACHI_RPM_DEPENDS="$(rpm_depends)"
export NYACHI_DEB_DEPENDS NYACHI_RPM_DEPENDS NYACHI_VERSION="$VERSION"
echo "deb Depends:  $NYACHI_DEB_DEPENDS"
echo "rpm Requires: $NYACHI_RPM_DEPENDS"

mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
cd "$ROOT"

"$TOOLS/nfpm" package --config tool/packaging/linux/nfpm.yaml --packager deb \
  --target "$OUT/nyachi-$VERSION-linux-x64.deb"
"$TOOLS/nfpm" package --config tool/packaging/linux/nfpm.yaml --packager rpm \
  --target "$OUT/nyachi-$VERSION-linux-x64.rpm"

# --- AppImage -------------------------------------------------------------
# AppDir layout: the whole bundle under usr/bin, so the binary's
# $ORIGIN-relative lib/ and data/ keep resolving next to it. The desktop
# file and icon follow the freedesktop.org layout appimagetool expects.
mkdir -p "$APPDIR/usr/bin" \
         "$APPDIR/usr/share/applications" \
         "$APPDIR/usr/share/icons/hicolor/256x256/apps"
cp -a "$BUNDLE/." "$APPDIR/usr/bin/"
# appimagetool only accepts the desktop file at the AppDir root (classic
# AppDir layout); the usr/share copy keeps the payload tree conventional.
cp "$DESKTOP" "$APPDIR/nyachi.desktop"
cp "$DESKTOP" "$APPDIR/usr/share/applications/nyachi.desktop"
cp "$ICON" "$APPDIR/usr/share/icons/hicolor/256x256/apps/nyachi.png"
cp "$ICON" "$APPDIR/nyachi.png"
ln -sf nyachi.png "$APPDIR/.DirIcon"

# CI runners have no FUSE; --appimage-extract-and-run unpacks to a temporary
# directory instead of mounting. ARCH names the target for appimagetool.
ARCH=x86_64 "$TOOLS/appimagetool" --appimage-extract-and-run \
  "$APPDIR" "$OUT/nyachi-$VERSION-x86_64.AppImage"

ls -lh "$OUT"
