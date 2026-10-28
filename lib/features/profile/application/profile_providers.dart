// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/silent_fallback.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/storage/storage_providers.dart';

part 'profile_providers.g.dart';

class ProfileRepository {
  ProfileRepository({
    required this.client,
    required this.cache,
    required this.accountId,
  });

  final MisskeyClient client;
  final CacheDao cache;
  final String accountId;

  /// Profiles change rarely; a fresh cache avoids a round trip on every open,
  /// while a stale one still renders instantly and refreshes behind it.
  static const _userTtl = Duration(minutes: 10);

  Future<UserDetailed?> user(String userId) async {
    final key = 'user:$userId';
    final cached = await cache.read(accountId, key);
    if (cached != null &&
        DateTime.now().difference(cached.updatedAt) <= _userTtl) {
      final parsed = _readPayload(cached.payload);
      if (parsed != null) return parsed;
    }
    try {
      final user = await client.users.showByUserId(userId: userId);
      await cache.write(accountId, key, jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('profile_providers.user', e);
      return _read(key);
    }
  }

  Future<UserDetailed?> me() async {
    final key = 'me:$accountId';
    try {
      final user = await client.account.me();
      await cache.write(accountId, key, jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('profile_providers.me', e);
      return _read(key);
    }
  }

  Future<UserDetailed?> _read(String key) async {
    final cached = await cache.read(accountId, key);
    if (cached == null) return null;
    return _readPayload(cached.payload);
  }

  UserDetailed? _readPayload(String payload) {
    try {
      final json = jsonDecode(payload);
      if (json is Map<String, dynamic>) return UserDetailed.fromJson(json);
      if (json is Map) {
        return UserDetailed.fromJson(Map<String, dynamic>.from(json));
      }
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('profile_providers.readCache', e);
      return null;
    }
    return null;
  }
}

@riverpod
Future<UserDetailed?> userProfile(Ref ref, String userId) async {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) return null;
  return ProfileRepository(
    client: ref.watch(misskeyClientProvider),
    cache: ref.watch(cacheDaoProvider),
    accountId: active.id,
  ).user(userId);
}

@Riverpod(keepAlive: true)
Future<UserDetailed?> currentUser(Ref ref) async {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) return null;
  return ProfileRepository(
    client: ref.watch(misskeyClientProvider),
    cache: ref.watch(cacheDaoProvider),
    accountId: active.id,
  ).me();
}
