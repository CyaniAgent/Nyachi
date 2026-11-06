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

// The splash lives in index.html and covers the blank page until Flutter has
// painted. Removing it on the loader's first-frame callback keeps the swap
// seamless; a timeout guarantees the page is never left covered when the
// engine fails to start.
function hideSplash() {
  const splash = document.getElementById('nyachi-splash');
  if (!splash) return;
  splash.classList.add('nyachi-splash-hidden');
  setTimeout(() => splash.remove(), 300);
}

_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    hideSplash();
  },
});

// If the engine never starts, do not keep the user behind a splash forever.
setTimeout(hideSplash, 20000);
