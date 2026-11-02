// SPDX-License-Identifier: AGPL-3.0-or-later

library;

import 'dart:async';

/// Web Push registration, implemented only for the web target.
///
/// Kept behind a conditional export so non-web builds carry no stub: on a
/// non-web platform push is not a thing these helpers can do, and the caller
/// checks [pushSupported] before offering it.

/// Whether this build can register for Web Push.
bool get pushSupported => false;

/// Requests notification permission and subscribes the service worker.
///
/// Returns the push endpoint and its keys, or null when the user declined,
/// the browser has no push support, or the subscription failed.
Future<PushSubscription?> register({required String vapidPublicKey}) async =>
    throw UnsupportedError('Web Push is only available on the web target.');

/// Drops the active push subscription, if any.
Future<void> unregister() async {}

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
