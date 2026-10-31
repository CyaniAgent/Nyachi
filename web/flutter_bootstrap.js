// Custom flutter bootstrap for Nyachi.
//
// Identical to Flutter's generated bootstrap except that it does not pass
// service worker settings to the loader: Flutter's built-in service worker
// is an uninstaller stub, and PWA offline caching is provided by
// nyachi_service_worker.js, registered from index.html. Keep this file in
// sync with Flutter's bootstrap template when upgrading Flutter; the
// flutter-js and build-config placeholders are substituted by
// `flutter build web`. Because this file exists, the build adopts it
// verbatim instead of injecting service worker registration.

{{flutter_js}}
{{flutter_build_config}}
_flutter.loader.load();
