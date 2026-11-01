// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/session_controller.dart';
import '../storage/storage_providers.dart';

part 'client_provider.g.dart';

@Riverpod(keepAlive: true)
MisskeyClient misskeyClient(Ref ref) {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) {
    throw StateError('No active account.');
  }
  final tokens = ref.watch(tokenStoreProvider);
  final dio = Dio();
  final client = MisskeyClient.fromHost(
    active.host,
    tokenProvider: () => tokens.read(active.id),
    dio: dio,
  );
  if (kIsWeb) {
    // Browsers refuse script-set User-Agent (a forbidden header name per the
    // Fetch spec): XHR silently ignores it and logs "Refused to set unsafe
    // header" for every request, so the SDK's unconditional User-Agent
    // (misskey_dart_api client.dart) is dead weight on web. dio's CORS
    // heuristic additionally flags it as a preflight trigger — a false
    // positive per the spec (forbidden headers are stripped first), but it
    // produces console noise on every request. Strip it on web, keep it on
    // native. Revisit if/when the SDK handles web itself.
    dio.options.headers.remove('User-Agent');
  }
  ref.onDispose(client.close);
  return client;
}
