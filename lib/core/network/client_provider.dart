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
/// (misskey_dart_api `client.dart:33`), during its own constructor — after any
/// caller could have removed it. Browsers reject that header: every request
/// logs "Refused to set unsafe header" and dio's CORS heuristic treats it as a
/// preflight trigger.
///
/// The strip therefore has to happen per request, in an interceptor: dio has
/// already merged the base headers into [RequestOptions] by then, so removing
/// it here is the last point before the browser adapter sets headers on the
/// XHR.
Dio createApiDio({bool stripUserAgent = kIsWeb}) {
  final dio = Dio();
  if (stripUserAgent) {
    // Also drop it from the base options so nothing re-merges it.
    dio.options.headers.remove('User-Agent');
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers.remove('User-Agent');
          handler.next(options);
        },
      ),
    );
  }
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
