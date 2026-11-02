// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Whether this build can register for Web Push.
///
/// Feature-detected rather than assumed: a secure context and a service worker
/// container are both required before the Push API is reachable.
bool get pushSupported =>
    web.window.isSecureContext &&
    web.window.navigator.serviceWorker.isDefinedAndNotNull;

/// Requests notification permission and subscribes the service worker.
///
/// Returns null when the user declined, the browser cannot subscribe, or the
/// instance offered no VAPID key - in every case there is nothing to register.
Future<PushSubscription?> register({required String vapidPublicKey}) async {
  final permission = (await web.Notification.requestPermission().toDart).toDart;
  if (permission != 'granted') return null;

  final registration = await web.window.navigator.serviceWorker.ready.toDart;
  final manager = registration.pushManager;
  final existing = await manager.getSubscription().toDart;
  final subscription =
      existing ??
      await manager
          .subscribe(
            web.PushSubscriptionOptionsInit(
              userVisibleOnly: true,
              applicationServerKey: _decodeKey(vapidPublicKey),
            ),
          )
          .toDart;
  final p256dh = subscription.getKey('p256dh');
  final auth = subscription.getKey('auth');
  if (p256dh == null || auth == null) return null;
  return PushSubscription(
    endpoint: subscription.endpoint,
    auth: _encodeKey(auth),
    p256dh: _encodeKey(p256dh),
  );
}

/// Drops the active push subscription, if any.
Future<void> unregister() async {
  final registration = await web.window.navigator.serviceWorker.ready.toDart;
  final subscription = await registration.pushManager.getSubscription().toDart;
  await subscription?.unsubscribe().toDart;
}

/// Base64url VAPID key to the buffer `applicationServerKey` expects.
JSArrayBuffer _decodeKey(String base64Url) {
  final padding = (4 - base64Url.length % 4) % 4;
  final normalized =
      '${base64Url.replaceAll('-', '+').replaceAll('_', '/')}${'=' * padding}';
  final binary = web.window.atob(normalized);
  final bytes = Uint8List(binary.length);
  for (var i = 0; i < binary.length; i++) {
    bytes[i] = binary.codeUnitAt(i);
  }
  return bytes.buffer.toJS;
}

/// A key buffer back to the base64url the server stores.
String _encodeKey(JSArrayBuffer buffer) {
  final bytes = buffer.toDart.asUint8List();
  final binary = String.fromCharCodes(bytes);
  return web.window
      .btoa(binary)
      .replaceAll('+', '-')
      .replaceAll('/', '_')
      .replaceAll('=', '');
}

/// A browser push subscription as the server expects it.
class PushSubscription {
  const PushSubscription({
    required this.endpoint,
    required this.auth,
    required this.p256dh,
  });

  /// The push service URL the browser assigned to this app.
  final String endpoint;

  /// Auth secret, base64url.
  final String auth;

  /// Public key, base64url (the `p256dh` component).
  final String p256dh;
}
