// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/silent_fallback.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/storage/storage_providers.dart';
import '../domain/note_feed_repository.dart';
import '../domain/note_feed_source.dart';

final noteFeedRepositoryProvider =
    Provider.family<NoteFeedRepository, NoteFeedSource>((ref, source) {
      final active = ref.watch(sessionControllerProvider).active;
      if (active == null) {
        throw StateError('A note feed requires an active account.');
      }
      return MisskeyNoteFeedRepository(
        client: ref.watch(misskeyClientProvider),
        cache: ref.watch(cacheDaoProvider),
        accountId: active.id,
      );
    });

class MisskeyNoteFeedRepository implements NoteFeedRepository {
  MisskeyNoteFeedRepository({
    required this.client,
    required this.cache,
    required this.accountId,
  });

  final MisskeyClient client;
  final CacheDao cache;
  final String accountId;

  static const pageLimit = 20;
  static const cacheLimit = 50;

  @override
  Future<NotePage> fetchPage(NoteFeedSource source, {String? untilId}) async {
    final page = switch (source) {
      HomeTimelineSource(:final kind) => switch (kind) {
        HomeFeedKind.home => await client.notes.timelinePage(
          limit: pageLimit,
          untilId: untilId,
        ),
        HomeFeedKind.local => await client.notes.localTimelinePage(
          limit: pageLimit,
          untilId: untilId,
        ),
        HomeFeedKind.hybrid => await client.notes.hybridTimelinePage(
          limit: pageLimit,
          untilId: untilId,
        ),
        HomeFeedKind.global => await client.notes.globalTimelinePage(
          limit: pageLimit,
          untilId: untilId,
        ),
      },
      TagFeedSource(:final tag) => await client.notes.searchByTagPage(
        tag: tag,
        limit: pageLimit,
        untilId: untilId,
      ),
      UserNotesSource(:final userId) => await client.users.notesPage(
        userId: userId,
        limit: pageLimit,
        untilId: untilId,
      ),
      SearchNotesSource(:final query) => await client.notes.searchPage(
        query: query,
        limit: pageLimit,
        untilId: untilId,
      ),
    };
    final seen = <String>{};
    final items = page.items
        .where((note) => seen.add(note.id))
        .toList(growable: false);
    return NotePage(items: items, hasMore: page.hasMore);
  }

  @override
  Future<List<Note>> readCache(NoteFeedSource source) async {
    final cached = await cache.read(accountId, source.cacheKey);
    if (cached == null) return const [];
    try {
      final decoded = jsonDecode(cached.payload);
      if (decoded is! List) return const [];
      final notes = <Note>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          notes.add(Note.fromJson(item));
        } else if (item is Map) {
          notes.add(Note.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return notes.take(cacheLimit).toList(growable: false);
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('note_feed_repository.readCache', e);
      return const [];
    }
  }

  @override
  Future<void> writeCache(NoteFeedSource source, List<Note> notes) {
    final payload = jsonEncode(
      notes.take(cacheLimit).map((note) => note.toJson()).toList(),
    );
    return cache.write(accountId, source.cacheKey, payload);
  }
}
