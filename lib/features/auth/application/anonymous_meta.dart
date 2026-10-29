// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';

part 'anonymous_meta.g.dart';

/// Public instance metadata fetched without credentials. Serves the login
/// page and the OOBE wizard before any account exists, so compliance
/// surfaces (rules, ToS links) can render before sign-in.
///
/// [host] should already be normalized via [normalizeHost] (that value also
/// keys the provider family cache); the provider normalizes defensively
/// before building the client.
@Riverpod(keepAlive: true)
Future<MetaLite> anonymousMeta(Ref ref, String host) async {
  final client = MisskeyClient.fromHost(
    normalizeHost(host),
    authMode: MisskeyAuthMode.none,
  );
  ref.onDispose(client.close);
  return client.meta.get();
}
