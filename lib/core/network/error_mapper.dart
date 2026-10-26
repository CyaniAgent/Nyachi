// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

enum AppFailureKind { auth, rateLimit, server, network, storage, unknown }

class AppFailure {
  const AppFailure(this.kind, [this.cause]);

  final AppFailureKind kind;
  final Object? cause;
}

AppFailure mapFailure(Object error) {
  if (error is MisskeyAuthenticationException) {
    return AppFailure(AppFailureKind.auth, error);
  }
  if (error is MisskeyApiException) {
    final status = error.statusCode;
    if (status == 401 || status == 403) {
      return AppFailure(AppFailureKind.auth, error);
    }
    if (status == 429) {
      return AppFailure(AppFailureKind.rateLimit, error);
    }
    if (status != null && status >= 500) {
      return AppFailure(AppFailureKind.server, error);
    }
    if (status == null || _looksLikeNetwork(error.cause)) {
      return AppFailure(AppFailureKind.network, error);
    }
    return AppFailure(AppFailureKind.unknown, error);
  }
  if (error is MissingPluginException ||
      error is PlatformException ||
      error is UnsupportedError) {
    return AppFailure(AppFailureKind.storage, error);
  }
  if (error is TimeoutException || _looksLikeNetwork(error)) {
    return AppFailure(AppFailureKind.network, error);
  }
  return AppFailure(AppFailureKind.unknown, error);
}

bool _looksLikeNetwork(Object? error) {
  if (error == null) return false;
  final type = error.runtimeType.toString();
  return type.contains('SocketException') ||
      type.contains('DioException') ||
      type.contains('ClientException') ||
      type.contains('HandshakeException');
}
