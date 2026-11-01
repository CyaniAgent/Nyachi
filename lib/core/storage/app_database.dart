// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

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

/// Multi-entry composer drafts. One row per draft; reply drafts are their
/// own entries. Only drafts with substantive content are ever written.
class LocalDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get replyId => text().nullable()();
  TextColumn get body => text().withDefault(const Constant(''))();
  TextColumn get cw => text().nullable()();
  TextColumn get visibility => text()();
  BoolColumn get localOnly => boolean().withDefault(const Constant(false))();
  TextColumn get reactionAcceptance => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();

  /// JSON list of drive file ids; null when the draft has no attachments.
  TextColumn get fileIds => text().nullable()();

  /// JSON list of poll choices; null when the draft has no poll.
  TextColumn get pollChoices => text().nullable()();
  BoolColumn get pollMultiple => boolean().withDefault(const Constant(false))();
  DateTimeColumn get pollExpiresAt => dateTime().nullable()();

  /// JSON list of user ids for the `specified` (direct message) visibility.
  TextColumn get visibleUserIds => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [Accounts, CacheEntries, LocalDrafts],
  daos: [AccountDao, CacheDao, LocalDraftsDao],
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // Pre-1.0 databases have no recorded shape to migrate from; rebuild
        // them instead of crashing on open (the drift default throws).
        await _rebuildAll(migrator);
        return;
      }
      if (from < 3) {
        // The single-slot drafts table becomes a multi-entry table with a
        // new shape; drafts are disposable, so it drops and starts fresh.
        await migrator.deleteTable('drafts');
        await migrator.createTable(localDrafts);
      }
    },
  );

  /// Drops every table and recreates it at the current shape, for databases
  /// whose recorded shape predates per-version migrations.
  Future<void> _rebuildAll(Migrator migrator) async {
    await customStatement('PRAGMA foreign_keys = OFF');
    for (final table in allTables) {
      await migrator.deleteTable(table.actualTableName);
    }
    await migrator.createAll();
  }
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

  /// Per-key aggregated row count and payload byte size, across accounts.
  Future<List<({String key, int entries, int bytes})>> statsByKey() {
    return customSelect(
          'SELECT cache_key, COUNT(*) AS entries, '
          'COALESCE(SUM(LENGTH(CAST(payload AS BLOB))), 0) AS bytes '
          'FROM cache_entries GROUP BY cache_key',
          readsFrom: {cacheEntries},
        )
        .map(
          (row) => (
            key: row.read<String>('cache_key'),
            entries: row.read<int>('entries'),
            bytes: row.read<int>('bytes'),
          ),
        )
        .get();
  }

  /// Deletes every entry stored under any of [keys], for all accounts.
  Future<void> deleteKeys(Iterable<String> keys) {
    final keyList = keys.toList();
    if (keyList.isEmpty) return Future.value();
    return (delete(cacheEntries)..where((t) => t.cacheKey.isIn(keyList))).go();
  }

  /// Deletes every cache entry regardless of kind.
  Future<void> deleteAllEntries() => delete(cacheEntries).go();
}

@DriftAccessor(tables: [LocalDrafts])
class LocalDraftsDao extends DatabaseAccessor<AppDatabase>
    with _$LocalDraftsDaoMixin {
  LocalDraftsDao(super.db);

  /// The account's drafts, newest first.
  Future<List<ComposerDraft>> list(String accountId) async {
    final rows =
        await (select(localDrafts)
              ..where((t) => t.accountId.equals(accountId))
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
            .get();
    return rows.map(_toDomain).toList(growable: false);
  }

  Future<void> save(ComposerDraft draft) {
    assert(draft.id != null, 'Local draft rows need an id.');
    return into(localDrafts).insertOnConflictUpdate(
      LocalDraftsCompanion.insert(
        id: draft.id!,
        accountId: draft.accountId,
        body: Value(draft.text),
        visibility: draft.visibility,
        replyId: Value(draft.replyId),
        cw: Value(draft.cw),
        localOnly: Value(draft.localOnly),
        reactionAcceptance: Value(draft.reactionAcceptance),
        scheduledAt: Value(draft.scheduledAt),
        fileIds: Value(
          draft.fileIds.isEmpty ? null : jsonEncode(draft.fileIds),
        ),
        pollChoices: Value(draft.pollChoices),
        pollMultiple: Value(draft.pollMultiple),
        pollExpiresAt: Value(draft.pollExpiresAt),
        visibleUserIds: Value(draft.visibleUserIds),
        updatedAt: draft.updatedAt,
      ),
    );
  }

  Future<void> deleteById(String id) {
    return (delete(localDrafts)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteAccount(String accountId) {
    return (delete(
      localDrafts,
    )..where((t) => t.accountId.equals(accountId))).go();
  }

  /// Keeps at most [keep] drafts per account, pruning the oldest.
  Future<void> prune(String accountId, {int keep = 50}) async {
    final rows = await list(accountId);
    for (final draft in rows.skip(keep)) {
      if (draft.id != null) await deleteById(draft.id!);
    }
  }

  ComposerDraft _toDomain(LocalDraft row) {
    return ComposerDraft(
      id: row.id,
      accountId: row.accountId,
      text: row.body,
      cw: row.cw,
      visibility: row.visibility,
      localOnly: row.localOnly,
      replyId: row.replyId,
      updatedAt: row.updatedAt,
      fileIds: _decodeStringList(row.fileIds) ?? const [],
      pollChoices: row.pollChoices,
      pollMultiple: row.pollMultiple,
      pollExpiresAt: row.pollExpiresAt,
      reactionAcceptance: row.reactionAcceptance,
      visibleUserIds: row.visibleUserIds,
      scheduledAt: row.scheduledAt,
    );
  }

  static List<String>? _decodeStringList(String? raw) {
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded.whereType<String>().toList();
    } catch (_) {
      return null;
    }
  }
}
