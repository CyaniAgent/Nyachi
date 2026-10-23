// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('account upsert reuses the host and user identity', () async {
    final first = LocalAccount(
      id: 'first-id',
      host: 'misskey.io',
      userId: 'u1',
      username: 'alice',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );
    await database.accountDao.upsert(first);

    final second = LocalAccount(
      id: 'second-id',
      host: 'misskey.io',
      userId: 'u1',
      username: 'alice-renamed',
      addedAt: DateTime(2027),
      lastUsedAt: DateTime(2027),
    );
    await database.accountDao.upsert(second);

    final accounts = await database.accountDao.all();
    expect(accounts, hasLength(1));
    expect(accounts.single.id, 'first-id');
    expect(accounts.single.username, 'alice-renamed');
  });

  test('cache entries are account scoped', () async {
    await database.cacheDao.write('a', 'timeline:home', '[1]');
    await database.cacheDao.write('b', 'timeline:home', '[2]');

    expect(
      (await database.cacheDao.read('a', 'timeline:home'))?.payload,
      '[1]',
    );
    expect(
      (await database.cacheDao.read('b', 'timeline:home'))?.payload,
      '[2]',
    );

    await database.cacheDao.deleteAccount('a');
    expect(await database.cacheDao.read('a', 'timeline:home'), isNull);
    expect(
      (await database.cacheDao.read('b', 'timeline:home'))?.payload,
      '[2]',
    );
  });

  test('removing account data clears cache and draft', () async {
    await database.cacheDao.write('a', 'notifications', '[]');
    await database.draftDao.save(
      ComposerDraft(
        accountId: 'a',
        text: 'hello',
        visibility: 'public',
        updatedAt: DateTime(2026),
      ),
    );

    await database.cacheDao.deleteAccount('a');
    await database.draftDao.deleteDraft('a');

    expect(await database.cacheDao.read('a', 'notifications'), isNull);
    expect(await database.draftDao.read('a'), isNull);
  });
}
