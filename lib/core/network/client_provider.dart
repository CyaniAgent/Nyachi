// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/session_controller.dart';
import '../storage/storage_providers.dart';

part 'client_provider.g.dart';

/// A Dio prepared for this platform, for `MisskeyClient` construction.
///
/// The SDK writes an unconditional `User-Agent` onto the dio it is handed
/// (misskey_dart_api `client.dart:33`), and browsers reject that as a
/// forbidden header: every request logs "Refused to set unsafe header" and
/// dio's CORS heuristic treats it as a preflight trigger. Removing it after
/// construction is the only place that works, so every client in the app is
/// built from this factory rather than a bare `Dio()`.
Dio createApiDio() {
  final dio = Dio();
  if (kIsWeb) dio.options.headers.remove('User-Agent');
  return dio;
}

@Riverpod(keepAlive: true)
MisskeyClient misskeyClient(Ref ref) {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) {
    throw StateError('No active account.');
  }
  final tokens = ref.watch(tokenStoreProvider);
  final client = MisskeyClient.fromHost(
    active.host,
    tokenProvider: () => tokens.read(active.id),
    dio: createApiDio(),
  );
  ref.onDispose(client.close);
  return client;
}
