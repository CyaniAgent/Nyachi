// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'storage_models.dart';

part 'app_database.g.dart';

class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get host => text()();
  TextColumn get userId => text()();
  TextColumn get username => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get lastUsedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {host, userId},
  ];
}

class CacheEntries extends Table {
  TextColumn get accountId => text()();
  TextColumn get cacheKey => text()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {accountId, cacheKey};
}

class Drafts extends Table {
  TextColumn get accountId => text()();
  TextColumn get body => text()();
  TextColumn get cw => text().nullable()();
  TextColumn get visibility => text()();
  BoolColumn get localOnly => boolean().withDefault(const Constant(false))();
  TextColumn get replyId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {accountId};
}

@DriftDatabase(
  tables: [Accounts, CacheEntries, Drafts],
  daos: [AccountDao, CacheDao, DraftDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open()
    : super(
        driftDatabase(
          name: 'nyachi',
          web: DriftWebOptions(
            sqlite3Wasm: _assetUri('sqlite3.wasm'),
            driftWorker: _assetUri('drift_worker.js'),
          ),
        ),
      );

  static Uri _assetUri(String name) => Uri.base.resolve(name);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      // Pre-1.0 destructive fallback: rebuild local tables (cache + accounts)
      // on any schema bump instead of crashing on open (drift default throws).
      // Replace with per-version migrations once schema v2 ships.
      await customStatement('PRAGMA foreign_keys = OFF');
      for (final table in allTables) {
        await migrator.deleteTable(table.actualTableName);
      }
      await migrator.createAll();
    },
  );
}

@DriftAccessor(tables: [Accounts])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  AccountDao(super.db);

  Future<List<LocalAccount>> all() async {
    final rows = await (select(
      accounts,
    )..orderBy([(t) => OrderingTerm.desc(t.lastUsedAt)])).get();
    return rows.map(_toDomain).toList(growable: false);
  }

  Future<LocalAccount?> byId(String id) async {
    final row = await (select(
      accounts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Future<LocalAccount?> byHostAndUser(String host, String userId) async {
    final row =
        await (select(accounts)
              ..where((t) => t.host.equals(host) & t.userId.equals(userId)))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Future<void> upsert(LocalAccount account) async {
    final existing = await byHostAndUser(account.host, account.userId);
    await into(accounts).insertOnConflictUpdate(
      AccountsCompanion.insert(
        id: existing?.id ?? account.id,
        host: account.host,
        userId: account.userId,
        username: account.username,
        displayName: Value(account.displayName),
        avatarUrl: Value(account.avatarUrl),
        addedAt: existing?.addedAt ?? account.addedAt,
        lastUsedAt: account.lastUsedAt,
      ),
    );
  }

  Future<void> touch(String id, DateTime at) {
    return (update(accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(lastUsedAt: Value(at)),
    );
  }

  Future<void> deleteAccount(String id) {
    return (delete(accounts)..where((t) => t.id.equals(id))).go();
  }

  LocalAccount _toDomain(Account row) {
    return LocalAccount(
      id: row.id,
      host: row.host,
      userId: row.userId,
      username: row.username,
      displayName: row.displayName,
      avatarUrl: row.avatarUrl,
      addedAt: row.addedAt,
      lastUsedAt: row.lastUsedAt,
    );
  }
}

@DriftAccessor(tables: [CacheEntries])
class CacheDao extends DatabaseAccessor<AppDatabase> with _$CacheDaoMixin {
  CacheDao(super.db);

  Future<CachedPayload?> read(String accountId, String key) async {
    final row =
        await (select(cacheEntries)..where(
              (t) => t.accountId.equals(accountId) & t.cacheKey.equals(key),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return CachedPayload(payload: row.payload, updatedAt: row.updatedAt);
  }

  Future<void> write(
    String accountId,
    String key,
    String payload, {
    DateTime? updatedAt,
  }) {
    final now = updatedAt ?? DateTime.now();
    return into(cacheEntries).insertOnConflictUpdate(
      CacheEntriesCompanion.insert(
        accountId: accountId,
        cacheKey: key,
        payload: payload,
        updatedAt: now,
      ),
    );
  }

  Future<void> deleteKey(String accountId, String key) {
    return (delete(
          cacheEntries,
        )..where((t) => t.accountId.equals(accountId) & t.cacheKey.equals(key)))
        .go();
  }

  Future<void> deleteAccount(String accountId) {
    return (delete(
      cacheEntries,
    )..where((t) => t.accountId.equals(accountId))).go();
  }
}

@DriftAccessor(tables: [Drafts])
class DraftDao extends DatabaseAccessor<AppDatabase> with _$DraftDaoMixin {
  DraftDao(super.db);

  Future<ComposerDraft?> read(String accountId) async {
    final row = await (select(
      drafts,
    )..where((t) => t.accountId.equals(accountId))).getSingleOrNull();
    if (row == null) return null;
    return ComposerDraft(
      accountId: row.accountId,
      text: row.body,
      cw: row.cw,
      visibility: row.visibility,
      localOnly: row.localOnly,
      replyId: row.replyId,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> save(ComposerDraft draft) {
    return into(drafts).insertOnConflictUpdate(
      DraftsCompanion.insert(
        accountId: draft.accountId,
        body: draft.text,
        cw: Value(draft.cw),
        visibility: draft.visibility,
        localOnly: Value(draft.localOnly),
        replyId: Value(draft.replyId),
        updatedAt: draft.updatedAt,
      ),
    );
  }

  Future<void> deleteDraft(String accountId) {
    return (delete(drafts)..where((t) => t.accountId.equals(accountId))).go();
  }
}
