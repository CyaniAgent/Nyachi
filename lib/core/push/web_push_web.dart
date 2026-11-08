// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Whether this build can reach the browser's Push API.
///
/// Feature-detected rather than assumed: a secure context and a service worker
/// container are both required before the Push API is reachable.
bool get pushSupported =>
    web.window.isSecureContext &&
    web.window.navigator.serviceWorker.isDefinedAndNotNull;

/// The subscription the browser already holds, or null when there is none.
///
/// Reading an existing subscription does not ask the user for anything — the
/// page only ever inspects what is there, because registering a new one is not
/// something a token-authenticated client can put to use: the server refuses
/// `sw/register` outright.
Future<PushSubscription?> currentSubscription() async {
  final registration = await web.window.navigator.serviceWorker.ready.toDart;
  final subscription = await registration.pushManager.getSubscription().toDart;
  if (subscription == null) return null;
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
Future<void> dropSubscription() async {
  final registration = await web.window.navigator.serviceWorker.ready.toDart;
  final subscription = await registration.pushManager.getSubscription().toDart;
  await subscription?.unsubscribe().toDart;
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

/// A browser push subscription as the server stores it.
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
