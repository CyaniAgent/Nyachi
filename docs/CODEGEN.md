# Code Generation

Nyachi commits generated code. Generated files are part of normal review; CI
regenerates them and rejects a dirty tree.

## Commands

```sh
flutter gen-l10n
dart run build_runner build
dart format lib test
```

`build_runner` generates Riverpod providers, Freezed models, JSON helpers, the
Drift database/DAOs, and typed `go_router` routes. Do not enable
`--delete-conflicting-outputs`; the project targets Dart 3.13.

## Generated files

- `*.g.dart`: Riverpod, JSON, Drift, and route helpers.
- `*.freezed.dart`: immutable models and unions.
- `lib/core/l10n/app_localizations*.dart`: ARB output (ARB sources stay in `lib/app/l10n/`).
- `lib/core/storage/app_database.g.dart`: Drift schema and DAOs.
- `lib/app/router/routes.g.dart`: typed route data and `$appRoutes`.

These files are NOT tracked. They are deterministic: the same sources produce
the same bytes, and CI regenerates them before analyzing and testing, so a
fresh clone must run the two generation commands before `flutter analyze` or
`flutter test` (`tool/preflight.sh` does this automatically).
`analysis_options.yaml` excludes them from linting; formatting still applies.

## Drift web assets

`web/sqlite3.wasm` and `web/drift_worker.js` are copied from the matching
`drift 2.35.2` package/release and committed. The web database resolves them
against `Uri.base` before opening. Serve `sqlite3.wasm` as `application/wasm`; COOP/COEP headers are
recommended but not required because Drift falls back to IndexedDB/FileSystem
storage.
