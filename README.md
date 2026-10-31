# Nyachi

Nyachi is a Misskey client for Android, iOS, Windows, macOS, Linux, and the web.
The rewrite on `develop` replaces the archived 1.3.4 app. The legacy snapshot at
`archive/legacy-1.3.4` is reference-only and is not used as rewrite input.

## Status

- Foundation and first vertical slice implemented: MiAuth/token multi-account
  login, Home/Local/Hybrid/Global timelines with Home streaming, notes,
  reactions, renotes, replies, composer drafts, notifications, explore/search,
  tags, profiles, and 1:1/room chat with text and media.
- First-run OOBE wizard (language, compliance, sign-in, appearance) shipped;
  the in-app brand mark doubles as the launcher icon on every platform.
- Pre-releases are cut from `develop` version tags; the `Prerelease` workflow
  builds split-per-ABI APKs, an AAB, and desktop bundles automatically.
  Releases are infrequent by policy — only when the maintainer calls for one.

## Requirements

- Flutter 3.47.7 / Dart 3.13.5.
- Drift web assets are committed under `web/`.
- Linux desktop also needs the platform libraries used by
  `flutter_secure_storage`, `file_picker`, and `media_kit`.

## Setup and run

```sh
flutter pub get
flutter gen-l10n
dart run build_runner build
flutter run -d chrome        # or -d windows
```

Generated Riverpod, Freezed, Drift, JSON, and typed-route files are committed.
Do not add `*.g.dart` or `*.freezed.dart` to `.gitignore`. See
[docs/CODEGEN.md](docs/CODEGEN.md).

## Verification

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

CI runs the same steps after regenerating code and requires a clean
`git diff --exit-code`. PWA offline caching does not use Flutter's built-in
service worker — it is an uninstaller stub since 3.47 (official deprecation,
flutter/flutter#156910) and the build emits it as a dead, never-registered
file. The live worker is `web/nyachi_service_worker.js`, registered from
`web/index.html` through the custom `web/flutter_bootstrap.js`, which the
build adopts verbatim when present. On Flutter versions containing
flutter/flutter#194785 the same worker can instead be provided as
`web/flutter_service_worker.js` directly.

## Web notes

Releases ship two web archives: `web` (JavaScript) and `web-wasm`
(WebAssembly, with a JavaScript fallback for browsers that cannot run it).
Both contain the same application.

`web/sqlite3.wasm` and `web/drift_worker.js` must be served with the app. Serve
`sqlite3.wasm` as `application/wasm`. COOP/COEP headers are recommended but not
required; Drift falls back to IndexedDB/FileSystem storage. Private/incognito
browsing may reduce or disable persistence.

Tokens use platform secure storage. On the web that is browser storage, not an
OS keychain; it requires a secure context (`https://` or `localhost`). If the
browser blocks storage or the page is served over plain HTTP on a LAN address,
account saving fails with a visible storage error. No token is written to Drift,
SharedPreferences, logs, or exceptions.

## Documentation

- [User guide](docs/USER_GUIDE.md) — first-run wizard, sign-in, compliance
- [Architecture](docs/ARCHITECTURE.md)
- [Style guide](docs/STYLE_GUIDE.md)
- [Code generation](docs/CODEGEN.md)
- [Foundation ADR](docs/adr/0001-foundation.md)

## License and copyright

- Code license: GNU Affero General Public License v3.0 or later
  (`AGPL-3.0-or-later`). See [LICENSE](LICENSE).
- Copyright: Copyright (C) 2026 AyaxYuna.
- Third-party components and assets: see [ATTRIBUTIONS.md](ATTRIBUTIONS.md).
- Project name and marks: see [TRADEMARK.md](TRADEMARK.md).

## Contributing

External contributions require a Contributor License Agreement (CLA):

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CLA.md](CLA.md) (individual contributors)
- [CLA-CORPORATE.md](CLA-CORPORATE.md) (company/employer contributions)

For security issues, use GitHub Security Advisories and do not publish
vulnerability details in a public issue: [SECURITY.md](SECURITY.md).

## Legal

- [TERMS.md](TERMS.md): terms of use
- [PRIVACY.md](PRIVACY.md): privacy policy
- [TRADEMARK.md](TRADEMARK.md): name and mark usage policy
- [GOVERNANCE.md](GOVERNANCE.md): maintainers, branches, and releases

These documents are the project's governing policies.

## Branch model

| Branch | Purpose |
|---|---|
| `main` | Legacy history line; stable release line after the rewrite |
| `develop` | Rewrite integration branch |
| `feature/*` | Feature branches from `develop` |
| `fix/*` | Fix branches from `develop` |
| `release/*` | Release stabilization branches from `develop` |
| `archive/*` | Read-only historical snapshots |

Flow: `feature/*` / `fix/*` → `develop` → `release/*` → `main`.
