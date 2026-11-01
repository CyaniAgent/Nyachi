# Changelog

All notable changes to Nyachi. Versions follow [Semantic Versioning](https://semver.org/);
a `-beta.N` suffix marks a pre-release from the `develop` line.

## [2.0.0-beta.9] - 2026-11-01

### Codename

Baka

### Back navigation

- Back now undoes one layer of whatever is actually open, and means the same
  thing for the platform back button, the browser's back button and the
  on-screen arrows: full-screen views close first, then one detail-panel entry
  at a time, then pushed pages, then a non-timeline tab returns to the timeline.
- At the timeline with nothing open, back keeps the platform's own behaviour:
  Android and desktop close the app, and the browser leaves the page rather than
  navigating away mid-session.
- The wide-screen detail panel could not be closed with back at all before; it
  is state rather than a route, so it is now unwound explicitly.

### Custom emoji reactions

- A reaction using one of the instance's own custom emoji did not render.
  Misskey writes those as `:name@.:` and omits them from the note's
  `reactionEmojis`, and all three render paths read any `@host` as remote. `@.`
  now resolves against the local catalogue, while a genuinely remote host still
  resolves against the note's own emoji list.

### Appearance

- New "System color" accent that follows the platform's Material You palette,
  alongside instance color and the fixed swatches.
- Accent swatches show their labels and no longer rely on tooltips, so the
  choice is readable at every width, including in the first-run wizard.

### Fixed

- The lock file resolved against a local mirror, which made CI's
  `git diff --exit-code` guard fail on every run and blocked releases.
- `dynamic_color` was registered for Windows but not for Linux or macOS, so
  following the system palette did nothing on those platforms.

## [2.0.0-beta.8] - 2026-10-31

- Added a WebAssembly web build (`main.dart.wasm` alongside a JS fallback) and
  ship it next to the JavaScript archive, so browsers with WasmGC get the faster
  build.

## [2.0.0-beta.7] - 2026-10-31

- Linux releases build on Ubuntu 24.04 LTS, keeping the published binary's glibc
  floor at the oldest supported LTS.
- Stayed on the stable `flutter_inappwebview` line, which avoids the mandatory
  WPE WebKit runtime the 6.2 betas required on Linux.
- Fixed Android release builds under AGP 9, where the bundled plugin still asks
  for the disallowed `proguard-android.txt`; the transitional opt-out lives in
  `android/gradle.properties` and is dropped at AGP 10.

## [2.0.0-beta.6] - 2026-10-31

Tagged but never published; its changes shipped in beta.7.

Earlier beta numbers (4 and 5) were attempted during the AGP 9 and Linux
webview work, never got a tag, and left nothing behind: no build was published
under them, so they are not listed.

## [2.0.0-beta.3] - 2026-10-28

- Composer rebuilt on the official Misskey post layout.
- Announcements surface as timeline banners and dialog pop-ups.
- Instance metadata is cached, and its capabilities are probed at runtime.

## [2.0.0-beta.2] - 2026-10-27

- Tag-driven release channels with a rehearsal mode, and macOS SPM disabled for
  the release build.
- PWA support with offline caching.