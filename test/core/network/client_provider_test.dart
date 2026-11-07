// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/network/client_provider.dart';

/// Records the headers dio actually hands to the HTTP layer.
class _CapturingAdapter implements HttpClientAdapter {
  Map<String, dynamic>? headers;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    headers = Map<String, dynamic>.from(options.headers);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'the prepared dio strips the User-Agent before the adapter runs',
    () async {
      final dio = createApiDio(stripUserAgent: true);
      // The SDK sets this in its own constructor, which is why the strip cannot
      // happen when the dio is created.
      dio.options.headers['User-Agent'] = 'nyachi/1.0';
      final adapter = _CapturingAdapter();
      dio.httpClientAdapter = adapter;

      await dio.get<void>('/api/meta');

      expect(adapter.headers!.containsKey('User-Agent'), isFalse);
      expect(
        adapter.headers!.keys.map((k) => k.toLowerCase()),
        isNot(contains('user-agent')),
      );
    },
  );

  test('native keeps the User-Agent the SDK set', () async {
    final dio = createApiDio(stripUserAgent: false);
    dio.options.headers['User-Agent'] = 'nyachi/1.0';
    final adapter = _CapturingAdapter();
    dio.httpClientAdapter = adapter;

    await dio.get<void>('/api/meta');

    expect(adapter.headers!['User-Agent'], 'nyachi/1.0');
  });
}
