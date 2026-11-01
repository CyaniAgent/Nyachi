// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/silent_fallback.dart';
import '../../../core/storage/storage_providers.dart';

part 'mention_candidates.g.dart';

/// The minimal user shape autocomplete needs; independent of the SDK models so
/// a cached snapshot stays readable across SDK model changes.
typedef MentionCandidate = ({
  String id,
  String username,
  String? host,
  String? name,
});

/// Accounts the user follows, cached for offline and instant completion.
///
/// Fetched once per session (the provider is keepAlive) because the followings
/// list changes slowly and a mention panel must open without a request.
@Riverpod(keepAlive: true)
Future<List<MentionCandidate>> mentionCandidates(Ref ref) async {
  var disposed = false;
  ref.onDispose(() => disposed = true);
  void retrySoon() {
    Future<void>.delayed(const Duration(seconds: 30), () {
      if (!disposed) ref.invalidateSelf();
    });
  }

  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) return const [];
  final client = ref.watch(misskeyClientProvider);
  final cache = ref.watch(cacheDaoProvider);
  const key = CacheManager.followingsKey;

  List<MentionCandidate> decode(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((raw) {
          final map = Map<String, dynamic>.from(raw);
          return (
            id: map['id'] as String,
            username: map['username'] as String,
            host: map['host'] as String?,
            name: map['name'] as String?,
          );
        })
        .toList(growable: false);
  }

  try {
    final followings = await client.users.followingByUserId(
      userId: active.id,
      limit: 100,
    );
    final candidates = <MentionCandidate>[
      for (final following in followings)
        if (following.followee != null)
          (
            id: following.followee!.id,
            username: following.followee!.username,
            host: following.followee!.host,
            name: following.followee!.name,
          ),
    ];
    await cache.write(
      active.id,
      key,
      jsonEncode([
        for (final candidate in candidates)
          {
            'id': candidate.id,
            'username': candidate.username,
            'host': candidate.host,
            'name': candidate.name,
          },
      ]),
    );
    return candidates;
  } catch (e) {
    if (e is MisskeyAuthenticationException) rethrow;
    logSilentFallback('mention_candidates.mentionCandidates', e);
    retrySoon();
    final cached = await cache.read(active.id, key);
    if (cached == null) return const [];
    try {
      return decode(cached.payload);
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('mention_candidates.mentionCandidates.cache', e);
      retrySoon();
      return const [];
    }
  }
}

/// Remote user results for a mention query, merged in after two characters.
///
/// Kept separate from [mentionCandidates] so the local list never waits on a
/// request and so a failed search degrades to local matches only.
@riverpod
Future<List<MentionCandidate>> remoteMentionCandidates(
  Ref ref,
  String query,
) async {
  final trimmed = query.trim();
  if (trimmed.length < 2) return const [];
  // Debounce: typing quickly replaces the provider argument, and disposing the
  // previous listenable cancels this delay.
  var disposed = false;
  ref.onDispose(() => disposed = true);
  await Future<void>.delayed(const Duration(milliseconds: 250));
  if (disposed) return const [];
  try {
    final users = await ref
        .read(misskeyClientProvider)
        .users
        .search(query: trimmed, limit: 10);
    return [
      for (final user in users)
        (
          id: user.id,
          username: user.username,
          host: user.host,
          name: user.name,
        ),
    ];
  } catch (e) {
    if (e is MisskeyAuthenticationException) rethrow;
    logSilentFallback('mention_candidates.remoteMentionCandidates', e);
    return const [];
  }
}
