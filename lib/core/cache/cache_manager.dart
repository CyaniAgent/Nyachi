// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/app_database.dart';
import '../storage/storage_providers.dart';

part 'cache_manager.g.dart';

/// Kinds of locally persisted caches shown and managed in settings.
enum CacheKind { instanceMeta, emojiCatalog, notifications, followings }

/// Aggregated size information for one [CacheKind].
typedef CacheKindStats = ({int entries, int bytes});

/// Single owner of the canonical cache keys and of bulk cache maintenance.
///
/// Repositories read the key constants from here when they write entries, so
/// a bulk clear can never drift from what was written. The manager never
/// touches payloads: per-account reads and writes stay on [CacheDao].
class CacheManager {
  CacheManager(this._dao);

  final CacheDao _dao;

  /// Instance metadata and its `notes/drafts` capability probe.
  static const instanceMetaKey = 'meta';
  static const instanceMetaProbeKey = 'meta.scheduledNotes';
  static const emojiCatalogKey = 'emoji';
  static const notificationsKey = 'notifications';

  /// Following list, used as the local mention-candidate source.
  static const followingsKey = 'followings';

  static const Map<CacheKind, List<String>> _keysByKind = {
    CacheKind.instanceMeta: [instanceMetaKey, instanceMetaProbeKey],
    CacheKind.emojiCatalog: [emojiCatalogKey],
    CacheKind.notifications: [notificationsKey],
    CacheKind.followings: [followingsKey],
  };

  CacheKind? _kindForKey(String key) {
    for (final entry in _keysByKind.entries) {
      if (entry.value.contains(key)) return entry.key;
    }
    return null;
  }

  /// Entry count and byte size for every kind, across all accounts.
  ///
  /// Keys that belong to no kind (e.g. feed snapshots) are not reported;
  /// they are still wiped by [clearAll].
  Future<Map<CacheKind, CacheKindStats>> statsAll() async {
    final rows = await _dao.statsByKey();
    final result = {
      for (final kind in CacheKind.values) kind: const (entries: 0, bytes: 0),
    };
    for (final (:key, :entries, :bytes) in rows) {
      final kind = _kindForKey(key);
      if (kind == null) continue;
      final current = result[kind]!;
      result[kind] = (
        entries: current.entries + entries,
        bytes: current.bytes + bytes,
      );
    }
    return result;
  }

  Future<int> entryCount(CacheKind kind) async => (await _stats(kind)).entries;

  Future<int> byteSize(CacheKind kind) async => (await _stats(kind)).bytes;

  Future<CacheKindStats> _stats(CacheKind kind) async =>
      (await statsAll())[kind]!;

  /// Deletes every cached payload of [kind], for all accounts.
  Future<void> clear(CacheKind kind) => _dao.deleteKeys(_keysByKind[kind]!);

  /// Deletes all cache entries, including kinds without settings entry.
  Future<void> clearAll() => _dao.deleteAllEntries();
}

@Riverpod(keepAlive: true)
CacheManager cacheManager(Ref ref) =>
    CacheManager(ref.watch(appDatabaseProvider).cacheDao);
