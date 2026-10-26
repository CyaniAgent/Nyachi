// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/auth/token_store.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTokenStore extends Fake implements TokenStore {
  final _tokens = <String, String>{};

  @override
  Future<String?> read(String accountId) async => _tokens[accountId];

  @override
  Future<void> write(String accountId, String token) async =>
      _tokens[accountId] = token;

  @override
  Future<void> delete(String accountId) async => _tokens.remove(accountId);
}

class _FailingAccountDao extends AccountDao {
  _FailingAccountDao(super.db);

  @override
  Future<void> upsert(LocalAccount account) async {
    throw Exception('disk full');
  }
}

class _MockMe extends Mock implements MeDetailed {}

MeDetailed _me(String id, String username) {
  final me = _MockMe();
  when(() => me.id).thenReturn(id);
  when(() => me.username).thenReturn(username);
  when(() => me.name).thenReturn(username);
  when(() => me.avatarUrl).thenReturn('https://example.test/$id.png');
  return me;
}

void main() {
  late AppDatabase db;
  late _FakeTokenStore tokens;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tokens = _FakeTokenStore();
  });

  tearDown(() async {
    await db.close();
  });

  Future<ProviderContainer> containerWith({AccountDao? accountDao}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        accountDaoProvider.overrideWithValue(accountDao ?? db.accountDao),
        cacheDaoProvider.overrideWithValue(db.cacheDao),
        draftDaoProvider.overrideWithValue(db.draftDao),
        tokenStoreProvider.overrideWithValue(tokens),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('addAccount failure rolls the written token back', () async {
    final container = await containerWith(accountDao: _FailingAccountDao(db));
    final controller = container.read(sessionControllerProvider.notifier);

    await expectLater(
      controller.addAccount('misskey.io', 'tok', _me('u1', 'alice')),
      throwsA(isA<Exception>()),
    );
    expect(await tokens.read('u1'), isNull);
  });

  test(
    'removeAccount deletes token, cache, draft, and the account row',
    () async {
      final container = await containerWith();
      final controller = container.read(sessionControllerProvider.notifier);

      final first = await controller.addAccount(
        'misskey.io',
        't1',
        _me('u1', 'alice'),
      );
      final second = await controller.addAccount(
        'misskey.io',
        't2',
        _me('u2', 'bob'),
      );
      await container.read(cacheDaoProvider).write(first.id, 'k', 'v1');
      await container.read(cacheDaoProvider).write(second.id, 'k', 'v2');
      await container
          .read(draftDaoProvider)
          .save(
            ComposerDraft(
              accountId: first.id,
              text: 'a',
              visibility: 'public',
              updatedAt: DateTime(2026),
            ),
          );

      expect(container.read(sessionControllerProvider).active?.id, second.id);
      await controller.removeAccount(first.id);

      expect(await tokens.read(first.id), isNull);
      expect(await tokens.read(second.id), 't2');
      expect(
        await container.read(cacheDaoProvider).read(first.id, 'k'),
        isNull,
      );
      expect(
        (await container.read(cacheDaoProvider).read(second.id, 'k'))?.payload,
        'v2',
      );
      expect(await container.read(draftDaoProvider).read(first.id), isNull);
      expect(
        (await container.read(accountDaoProvider).all()).map((a) => a.id),
        [second.id],
      );
      expect(container.read(sessionControllerProvider).active?.id, second.id);
    },
  );

  test('expireActiveAccount is idempotent', () async {
    final container = await containerWith();
    final controller = container.read(sessionControllerProvider.notifier);

    await controller.expireActiveAccount();
    expect(container.read(sessionControllerProvider).active, isNull);

    final account = await controller.addAccount(
      'misskey.io',
      't1',
      _me('u1', 'alice'),
    );
    expect(container.read(sessionControllerProvider).active?.id, account.id);

    await controller.expireActiveAccount();
    expect(await tokens.read(account.id), isNull);
    expect(container.read(sessionControllerProvider).active, isNull);

    await controller.expireActiveAccount();
    expect(container.read(sessionControllerProvider).active, isNull);
  });

  test(
    'switchAccount without a stored token throws SessionExpiredException',
    () async {
      final container = await containerWith();
      final controller = container.read(sessionControllerProvider.notifier);

      final first = await controller.addAccount(
        'misskey.io',
        't1',
        _me('u1', 'alice'),
      );
      final second = await controller.addAccount(
        'misskey.io',
        't2',
        _me('u2', 'bob'),
      );
      await tokens.delete(first.id);

      await expectLater(
        controller.switchAccount(first.id),
        throwsA(isA<SessionExpiredException>()),
      );
      expect(container.read(sessionControllerProvider).active?.id, second.id);
    },
  );
}
