# Packaging

Installer formats shipped by the Release workflow
(`.github/workflows/release.yml`) on top of the plain platform bundles:

| Platform | Files | Built by |
|---|---|---|
| Linux | `nyachi-<v>-linux-x64.deb`, `.rpm`, `nyachi-<v>-x86_64.AppImage` | `linux/package.sh` (nfpm + appimagetool) |
| Windows | `nyachi-<v>-windows-x64-setup.exe` | `windows/nyachi.iss` (Inno Setup 6, preinstalled on the runner) |
| macOS | `nyachi-<v>-macos-arm64.dmg` | inline `hdiutil` in the workflow |

`<v>` is the release tag without the leading `v`.

## Linux

```sh
flutter build linux --release
tool/packaging/linux/package.sh 2.1.0-beta.8 out
```

`package.sh` downloads nfpm (versioned, sha256 from its checksums.txt) and
appimagetool (AppImageKit `continuous`, sha256 pinned in the script) and
verifies both before use. Runtime dependencies are derived from the bundle's
actual `readelf` link surface: deb dependencies are mapped through `dpkg -S`
on the build host, rpm dependencies through soname requirements. Outside a
dpkg-based system the deb list can be passed explicitly for testing:

```sh
NYACHI_DEB_DEPENDS=... NYACHI_RPM_DEPENDS=... tool/packaging/linux/package.sh <v> out
```

The glibc floor is the build distro's: the workflow builds Linux on
`ubuntu-24.04`, so the packages require glibc 2.39+ (Ubuntu 24.04, Debian 13,
Fedora 40+). Lower the build image in the workflow to widen that reach.

The AppImage assumes the host provides GTK 3 and libmpv, exactly like the deb
and rpm — it is not a fully self-contained image.

## Windows

`windows/nyachi.iss` packages `build/windows/x64/runner/Release` into a
per-user installer (no UAC prompt; `{localappdata}\Nyachi`). The `AppId` GUID
identifies the product to Windows and must never change.

## Icon provenance

The packaged icons are derived from the brand mark so every installer shows
the same artwork as the app:

```sh
magick assets/brand/app_icon_full.png -resize 256x256 tool/packaging/linux/nyachi.png
magick assets/brand/app_icon_full.png -define icon:auto-resize=256,128,64,48,32,16 tool/packaging/windows/nyachi.ico
```

Re-run these after changing `assets/brand/app_icon_full.png`.
