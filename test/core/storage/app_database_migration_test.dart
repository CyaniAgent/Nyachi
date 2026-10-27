// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';

/// Stands in for a future schema bump: one version above the shipped schema
/// against a database file created at the current version, which forces the
/// onUpgrade path to run.
class _FutureSchemaDatabase extends AppDatabase {
  _FutureSchemaDatabase(super.executor);

  @override
  int get schemaVersion => super.schemaVersion + 1;
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('nyachi-migration');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('schema bump rebuilds local tables instead of crashing', () async {
    final file = File('${tempDir.path}/db.sqlite');
    final first = AppDatabase(NativeDatabase(file));
    await first.accountDao.upsert(
      LocalAccount(
        id: 'a1',
        host: 'misskey.io',
        userId: 'u1',
        username: 'alice',
        addedAt: DateTime(2026),
        lastUsedAt: DateTime(2026),
      ),
    );
    await first.cacheDao.write('a1', 'timeline:home', '[1]');
    await first.close();

    final second = _FutureSchemaDatabase(NativeDatabase(file));
    final accounts = await second.accountDao.all();
    expect(accounts, isEmpty);

    await second.cacheDao.write('a1', 'timeline:home', '[2]');
    expect((await second.cacheDao.read('a1', 'timeline:home'))?.payload, '[2]');
    await second.close();
  });

  test('reopening at the same version keeps data', () async {
    final file = File('${tempDir.path}/db.sqlite');
    final first = AppDatabase(NativeDatabase(file));
    await first.cacheDao.write('a1', 'key', 'value');
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    expect((await second.cacheDao.read('a1', 'key'))?.payload, 'value');
    await second.close();
  });
}
