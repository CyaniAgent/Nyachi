// SPDX-License-Identifier: AGPL-3.0-or-later

library;

import 'dart:async';

/// Browser push subscription helpers, implemented only on the web target.
///
/// Nyachi cannot register a browser push subscription: the server endpoint
/// (`sw/register`) is `secure: true`, which in Misskey means the instance's own
/// session — every token-authenticated client, MiAuth included, is refused.
/// What remains is inspecting and removing a subscription an earlier build
/// created, which is what these helpers do; `unregister` on the server side is
/// credential-free, so it stays reachable.

/// Whether this build can reach the browser's Push API.
bool get pushSupported => false;

/// The subscription the browser already holds, or null when there is none.
Future<PushSubscription?> currentSubscription() async => null;

/// Drops the active push subscription, if any.
Future<void> dropSubscription() async {}

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
