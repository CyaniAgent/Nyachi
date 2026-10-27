// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/network/client_provider.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/notes/application/emoji_catalog.dart';

class _FakeSessionController extends SessionController {
  _FakeSessionController(this.account);

  final LocalAccount account;

  @override
  SessionState build() =>
      SessionState(accounts: [account], active: account, initialized: true);
}

class _FakeEmojiApi extends Fake implements EmojiApi {
  _FakeEmojiApi(this.listImpl);

  Future<EmojiListResponse> Function() listImpl;

  @override
  Future<EmojiListResponse> list({
    MisskeyHttpMethod? httpMethod,
    CancelToken? cancelToken,
  }) => listImpl();
}

class _FakeClient extends Fake implements MisskeyClient {
  _FakeClient(this.emoji);

  @override
  final EmojiApi emoji;
}

class _FakeCacheDao extends Fake implements CacheDao {
  final _payloads = <String, String>{};

  @override
  Future<CachedPayload?> read(String accountId, String key) async {
    final payload = _payloads['$accountId/$key'];
    if (payload == null) return null;
    return CachedPayload(payload: payload, updatedAt: DateTime(2026));
  }

  @override
  Future<void> write(
    String accountId,
    String key,
    String payload, {
    DateTime? updatedAt,
  }) async {
    _payloads['$accountId/$key'] = payload;
  }
}

LocalAccount _account() => LocalAccount(
  id: 'a1',
  host: 'misskey.io',
  userId: 'u1',
  username: 'alice',
  addedAt: DateTime(2026),
  lastUsedAt: DateTime(2026),
);

EmojiSimple _emoji(String name) =>
    EmojiSimple(aliases: const [], name: name, category: null, url: 'u/$name');

EmojiListResponse _response(List<EmojiSimple> emojis) =>
    EmojiListResponse(emojis: emojis);

ProviderContainer _makeContainer(
  MisskeyClient client,
  CacheDao cacheDao,
) {
  final container = ProviderContainer(
    overrides: [
      sessionControllerProvider.overrideWith(
        () => _FakeSessionController(_account()),
      ),
      misskeyClientProvider.overrideWithValue(client),
      cacheDaoProvider.overrideWithValue(cacheDao),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('first failed fetch falls back to the cached catalogue', () async {
    final cached = _response([_emoji('queued')]);
    final cacheDao = _FakeCacheDao();
    await cacheDao.write(
      'a1',
      'emoji',
      jsonEncode(cached.toJson()),
    );
    var calls = 0;
    final client = _FakeClient(
      _FakeEmojiApi(() async {
        calls++;
        throw Exception('network down');
      }),
    );
    final container = _makeContainer(client, cacheDao);

    // The provider must not surface the error state: it degrades to the cache.
    final result = await container.read(emojiCatalogProvider.future);
    expect(result.map((e) => e.name), ['queued']);
    expect(calls, 1);
  });

  test('first failed fetch without cache yields an empty catalogue', () async {
    final client = _FakeClient(
      _FakeEmojiApi(() async => throw Exception('network down')),
    );
    final container = _makeContainer(client, _FakeCacheDao());

    final result = await container.read(emojiCatalogProvider.future);
    expect(result, isEmpty);
  });

  test('scheduled retry after 30 seconds recovers the remote catalogue',
      () => fakeAsync((async) {
        final emojis = [_emoji('remote')];
        var calls = 0;
        final client = _FakeClient(
          _FakeEmojiApi(() async {
            calls++;
            if (calls == 1) {
              throw Exception('network down');
            }
            return _response(emojis);
          }),
        );
        final cacheDao = _FakeCacheDao();
        final container = _makeContainer(client, cacheDao);
        final updates = <List<String>>[];
        final subscription = container.listen(
          emojiCatalogProvider,
          (_, next) {
            if (next.hasValue) {
              updates.add(next.value!.map((e) => e.name).toList());
            }
          },
        );
        addTearDown(subscription.close);

        // First build fails and degrades to an empty catalogue.
        async.flushMicrotasks();
        expect(container.read(emojiCatalogProvider).value, isEmpty);
        expect(calls, 1);

        // The failure scheduled a retry; it must fire and recover.
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();
        expect(calls, 2);
        expect(container.read(emojiCatalogProvider).value, emojis);

        // The successful retry also refreshed the cache for next time.
        expect(cacheDao._payloads['a1/emoji'], isNotNull);
      }));

  test('successful fetch does not schedule a retry', () => fakeAsync((async) {
    var calls = 0;
    final client = _FakeClient(
      _FakeEmojiApi(() async {
        calls++;
        return _response([_emoji('ok')]);
      }),
    );
    final container = _makeContainer(client, _FakeCacheDao());
    container.listen(emojiCatalogProvider, (_, __) {});

    async.elapse(const Duration(milliseconds: 10));
    expect(container.read(emojiCatalogProvider).value, [ _emoji('ok') ]);

    // Well past the retry window: no extra client call may happen.
    async.elapse(const Duration(seconds: 35));
    expect(calls, 1);
  }));
}
