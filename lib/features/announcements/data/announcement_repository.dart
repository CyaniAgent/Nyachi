// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/silent_fallback.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/storage/storage_providers.dart';

part 'announcement_repository.g.dart';

class AnnouncementRepository {
  AnnouncementRepository({
    required this.client,
    required this.cache,
    required this.accountId,
  });

  final MisskeyClient client;
  final CacheDao cache;
  final String accountId;

  static const _cacheKey = 'announcements';
  static const _ttl = Duration(hours: 12);

  /// Announcements change rarely, so a fresh cache is served without a network
  /// round trip; stale or missing cache falls through to the server and is
  /// rewritten. A failed request still returns whatever was cached.
  Future<List<Announcement>> list() async {
    final cached = await readCache();
    if (cached != null && cached.$2) return cached.$1;
    try {
      final announcements = await client.announcements.list(limit: 30);
      await cache.write(
        accountId,
        _cacheKey,
        jsonEncode([for (final item in announcements) item.toJson()]),
        updatedAt: DateTime.now(),
      );
      return announcements;
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('announcement_repository.list', e);
      return cached?.$1 ?? const [];
    }
  }

  /// Returns the cached list plus whether it is still within its TTL.
  Future<(List<Announcement>, bool)?> readCache() async {
    final row = await cache.read(accountId, _cacheKey);
    if (row == null) return null;
    try {
      final decoded = jsonDecode(row.payload);
      if (decoded is! List) return null;
      final items = [
        for (final item in decoded)
          if (item is Map)
            Announcement.fromJson(Map<String, dynamic>.from(item)),
      ];
      final fresh = DateTime.now().difference(row.updatedAt) <= _ttl;
      return (items, fresh);
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('announcement_repository.readCache', e);
      return null;
    }
  }

  /// Marks an announcement as read on the server.
  Future<void> markRead(String announcementId) async {
    try {
      await client.announcements.showValue(announcementId: announcementId);
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('announcement_repository.markRead', e);
    }
  }
}

/// Announcements for the active account, cached across restarts.
@Riverpod(keepAlive: true)
Future<List<Announcement>> announcements(Ref ref) async {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) return const [];
  return AnnouncementRepository(
    client: ref.watch(misskeyClientProvider),
    cache: ref.watch(cacheDaoProvider),
    accountId: active.id,
  ).list();
}

/// Unread announcements that should interrupt the user (`display: dialog`).
@Riverpod(keepAlive: true)
Future<List<Announcement>> pendingDialogAnnouncements(Ref ref) async {
  final all = await ref.watch(announcementsProvider.future);
  return all
      .where(
        (item) =>
            item.display == AnnouncementDisplay.dialog && item.isRead != true,
      )
      .toList();
}
