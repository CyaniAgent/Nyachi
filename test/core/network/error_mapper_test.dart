// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/network/error_mapper.dart';

void main() {
  test('transport failures from the SDK are network errors', () {
    final failure = mapFailure(MisskeyApiException('connection failed'));
    expect(failure.kind, AppFailureKind.network);
  });

  test('http statuses map to auth, rate limit, and server', () {
    expect(
      mapFailure(MisskeyApiException('expired', statusCode: 401)).kind,
      AppFailureKind.auth,
    );
    expect(
      mapFailure(MisskeyApiException('slow down', statusCode: 429)).kind,
      AppFailureKind.rateLimit,
    );
    expect(
      mapFailure(MisskeyApiException('down', statusCode: 503)).kind,
      AppFailureKind.server,
    );
  });

  test('secure storage platform errors are storage errors', () {
    expect(
      mapFailure(
        PlatformException(code: 'unavailable', message: 'secure storage'),
      ).kind,
      AppFailureKind.storage,
    );
    expect(
      mapFailure(MissingPluginException('not implemented')).kind,
      AppFailureKind.storage,
    );
    expect(
      mapFailure(UnsupportedError('secure context required')).kind,
      AppFailureKind.storage,
    );
  });
}
