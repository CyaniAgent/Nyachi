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

  LocalAccount account(String id) => LocalAccount(
    id: id,
    host: 'misskey.io',
    userId: 'user-$id',
    username: id,
    addedAt: DateTime(2026),
    lastUsedAt: DateTime(2026),
  );

  test(
    'account deletion clears row, cache, and draft for that account only',
    () async {
      await database.accountDao.upsert(account('a'));
      await database.accountDao.upsert(account('b'));
      await database.cacheDao.write('a', 'timeline:home', '[1]');
      await database.cacheDao.write('b', 'timeline:home', '[2]');
      await database.draftDao.save(
        ComposerDraft(
          accountId: 'a',
          text: 'a-draft',
          visibility: 'public',
          updatedAt: DateTime(2026),
        ),
      );
      await database.draftDao.save(
        ComposerDraft(
          accountId: 'b',
          text: 'b-draft',
          visibility: 'public',
          updatedAt: DateTime(2026),
        ),
      );

      // Mirrors SessionController.removeAccount's four-way cleanup chain.
      await database.accountDao.deleteAccount('a');
      await database.cacheDao.deleteAccount('a');
      await database.draftDao.deleteDraft('a');

      expect(await database.accountDao.byId('a'), isNull);
      expect(await database.accountDao.byId('b'), isNotNull);
      expect(await database.cacheDao.read('a', 'timeline:home'), isNull);
      expect(
        (await database.cacheDao.read('b', 'timeline:home'))?.payload,
        '[2]',
      );
      expect(await database.draftDao.read('a'), isNull);
      expect((await database.draftDao.read('b'))?.text, 'b-draft');
    },
  );

  test('account deletion is idempotent', () async {
    await database.accountDao.upsert(account('a'));
    await database.accountDao.deleteAccount('a');

    await database.accountDao.deleteAccount('a');
    expect(await database.accountDao.all(), isEmpty);
  });
}
