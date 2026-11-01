// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/cache/cache_manager.dart';
import 'package:nyachi/core/storage/app_database.dart';

void main() {
  late AppDatabase database;
  late CacheManager manager;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    manager = CacheManager(database.cacheDao);
  });

  tearDown(() => database.close());

  test('stats aggregate per kind across accounts and keys', () async {
    await database.cacheDao.write('a', CacheManager.instanceMetaKey, 'x');
    await database.cacheDao.write('b', CacheManager.instanceMetaProbeKey, '1');
    await database.cacheDao.write('a', CacheManager.emojiCatalogKey, 'emoji');
    // Feed snapshots are not a managed kind and must not be reported.
    await database.cacheDao.write('a', 'timeline:home', '[]');

    final stats = await manager.statsAll();

    expect(stats[CacheKind.instanceMeta]!.entries, 2);
    expect(stats[CacheKind.instanceMeta]!.bytes, 2);
    expect(stats[CacheKind.emojiCatalog]!.entries, 1);
    expect(stats[CacheKind.emojiCatalog]!.bytes, 'emoji'.length);
    expect(stats[CacheKind.notifications]!.entries, 0);
    expect(stats[CacheKind.notifications]!.bytes, 0);
  });

  test('entryCount and byteSize report a single kind', () async {
    await database.cacheDao.write('a', CacheManager.notificationsKey, 'hello');

    expect(await manager.entryCount(CacheKind.notifications), 1);
    expect(await manager.byteSize(CacheKind.notifications), 'hello'.length);
  });

  test('clear removes only that kind', () async {
    await database.cacheDao.write('a', CacheManager.instanceMetaKey, 'x');
    await database.cacheDao.write('a', CacheManager.emojiCatalogKey, 'e');
    await database.cacheDao.write('a', 'timeline:home', '[]');

    await manager.clear(CacheKind.instanceMeta);

    expect(
      await database.cacheDao.read('a', CacheManager.instanceMetaKey),
      isNull,
    );
    expect(
      await database.cacheDao.read('a', CacheManager.emojiCatalogKey),
      isNotNull,
    );
    expect(await database.cacheDao.read('a', 'timeline:home'), isNotNull);
  });

  test('clearAll wipes every cache entry', () async {
    await database.cacheDao.write('a', CacheManager.emojiCatalogKey, 'e');
    await database.cacheDao.write('a', 'timeline:home', '[]');

    await manager.clearAll();

    expect(
      await database.cacheDao.read('a', CacheManager.emojiCatalogKey),
      isNull,
    );
    expect(await database.cacheDao.read('a', 'timeline:home'), isNull);
  });
}
