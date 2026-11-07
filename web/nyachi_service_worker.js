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
//   - fetch:    navigations and entry points (index.html, the bootstrap, the
//               compiled app) are network-first — a cached copy of those pins
//               the user to an old build, because Flutter emits `main.dart.js`
//               under a fixed name. Everything else is same-origin GET →
//               stale-while-revalidate.
//   - cross-origin (Misskey media, API): network passthrough, never cached
//   - activate: drop old cache versions

const CACHE = 'nyachi-web-v2';

const SHELL = [
  '/',
  'index.html',
  'flutter_bootstrap.js',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
];

// Files whose content decides which build runs. Serving these from cache is
// what makes a deploy invisible: the HTML and the bootstrap have byte-stable
// names, and `main.dart.js` is overwritten in place, so a cached copy keeps
// running code the server no longer has.
const NETWORK_FIRST = [
  'index.html',
  'flutter_bootstrap.js',
  'flutter.js',
  'main.dart.js',
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
        Promise.all(
          keys.filter((key) => key !== CACHE).map((key) => caches.delete(key)),
        ),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  const path = url.pathname.replace(/^.*\//, '');
  const networkFirst =
    request.mode === 'navigate' || NETWORK_FIRST.includes(path);

  event.respondWith(
    caches.open(CACHE).then(async (cache) => {
      const cached = await cache.match(request, { ignoreSearch: true });
      if (networkFirst) {
        try {
          const response = await fetch(request);
          if (response.ok) cache.put(request, response.clone());
          return response;
        } catch (_) {
          // Offline: the last build still starts.
          return cached || Response.error();
        }
      }
      // Runtime cache: serve from cache when present, refresh in background.
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

// Web Push.
//
// The server sends a JSON body with the notification title, body and the in-app
// route to open; anything unparsable still shows a generic notification rather
// than dropping the push silently.
self.addEventListener('push', (event) => {
  let payload = {};
  if (event.data) {
    try {
      payload = event.data.json();
    } catch (error) {
      payload = {body: event.data.text()};
    }
  }
  const title = payload.title || 'Nyachi';
  event.waitUntil(
    self.registration.showNotification(title, {
      body: payload.body || '',
      icon: 'icons/Icon-192.png',
      badge: 'icons/Icon-192.png',
      tag: payload.tag,
      data: {url: payload.url || '/'},
    }),
  );
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const target = (event.notification.data && event.notification.data.url) || '/';
  // Focus an existing tab when one is open; otherwise open a new one.
  event.waitUntil(
    self.clients.matchAll({type: 'window', includeUncontrolled: true}).then((tabs) => {
      for (const tab of tabs) {
        if (tab.url.startsWith(self.location.origin)) {
          tab.navigate(target);
          return tab.focus();
        }
      }
      return self.clients.openWindow(target);
    }),
  );
});
