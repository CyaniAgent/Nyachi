# Third-Party Components and Assets

Nyachi uses or may use the following third-party assets. Only assets actually
distributed in a release need to be listed here. Update this file when assets
are added or removed during the rewrite.

## Audio

- Source: Misskey project resources and historical CyaniAgent resources.
- License: GNU Affero General Public License v3.0 (AGPL-3.0).
- Copyright: Misskey Development Team and CyaniAgent.
- Note: if the rewrite does not use these audio files, remove them from release
  artifacts; if they are reused, keep this notice.

## Icons

- Source: Misskey Icons.
- License: Creative Commons Attribution 4.0 International (CC BY 4.0) and
  AGPL-3.0.
- Copyright: Misskey Development Team.
- Link: https://creativecommons.org/licenses/by/4.0/

## Fonts

- **JetBrains Mono**: SIL Open Font License 1.1.
- **MiSans**: MiSans Font License Agreement.
- Keep the actual license texts with the release artifacts or repository
  license files.

## Dart / Flutter dependencies

Dart/Flutter dependency licenses are generated with `dart_pubspec_licenses`.
Before a release, run:

```bash
dart run dart_pubspec_licenses:generate
```

Confirm the generated file covers every dependency actually bundled.

## Other

- "Misskey", "Flarum", "Flutter", "GitHub", and other names and marks belong to
  their respective owners.
- This file does not challenge or grant any third-party rights.
- If you find an attribution or license error, contact the maintainer through a
  GitHub Issue.
