#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Runs the checks CI runs, before pushing. Catches the two failures that only
# ever surfaced in CI:
#
#   - generated sources out of date (CI: `git diff --exit-code`), and
#   - a lock file resolved against a mirror, which CI rewrites wholesale.
#
# Usage: tool/preflight.sh
set -euo pipefail

cd "$(dirname "$0")/.."

# The mirror URL is only valid on a machine behind it; CI always resolves
# against pub.dev, so anything committed must too.
export PUB_HOSTED_URL=https://pub.dev
export FLUTTER_STORAGE_BASE_URL=https://storage.googleapis.com

echo "==> pub get"
flutter pub get >/dev/null

echo "==> generated sources"
flutter gen-l10n >/dev/null
dart run build_runner build >/dev/null
if ! git diff --quiet -- lib; then
  echo "FAIL: generated sources are stale; commit them:" >&2
  git diff --stat -- lib >&2
  exit 1
fi

echo "==> mirror-free lock"
if grep -q "pub.flutter-io.cn" pubspec.lock; then
  echo "FAIL: pubspec.lock points at the mirror; rerun with PUB_HOSTED_URL=https://pub.dev" >&2
  exit 1
fi

echo "==> format"
dart format --output=none --set-exit-if-changed lib test

echo "==> analyze"
flutter analyze

echo "==> test"
flutter test

echo "preflight OK"