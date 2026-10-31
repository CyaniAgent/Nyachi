// SPDX-License-Identifier: AGPL-3.0-or-later

// Nyachi web service worker.
//
// Flutter's built-in PWA service worker was deprecated and reduced to an
// uninstaller stub (flutter build web generates a worker whose only job is
// to unregister old caches), so offline/installable support is provided
// here instead. Registered from web/index.html; build with
// `--pwa-strategy=none` so the stub never competes for this scope.
//
// Strategy:
//   - install:  precache the app shell (entry points and icons)
//   - fetch:    same-origin GET → stale-while-revalidate (offline keeps the
//               last cached app; online visits refresh in the background)
//   - cross-origin (Misskey media, API): network passthrough, never cached
//   - activate: drop old cache versions

const CACHE = 'nyachi-web-v1';

const SHELL = [
  '/',
  'index.html',
  'flutter_bootstrap.js',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(CACHE)
      .then((cache) => cache.addAll(SHELL))
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(keys.filter((key) => key !== CACHE).map((key) => caches.delete(key))),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  // Runtime cache: serve from cache when present, refresh in background.
  event.respondWith(
    caches.open(CACHE).then(async (cache) => {
      const cached = await cache.match(request, { ignoreSearch: true });
      const network = fetch(request)
        .then((response) => {
          if (response.ok) cache.put(request, response.clone());
          return response;
        })
        .catch(() => cached);
      return cached || network;
    }),
  );
});
