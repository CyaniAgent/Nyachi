// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/silent_fallback.dart';
import '../../../core/storage/storage_providers.dart';

part 'emoji_catalog.g.dart';

@Riverpod(keepAlive: true)
Future<List<EmojiSimple>> emojiCatalog(Ref ref) async {
  // The provider is keepAlive: a failed fetch must not stick as an empty
  // catalogue for the whole session, so failures schedule a retry.
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
  const key = 'emoji';
  try {
    final response = await client.emoji.list();
    await cache.write(active.id, key, jsonEncode(response.toJson()));
    return response.emojis;
  } catch (e) {
    if (e is MisskeyAuthenticationException) rethrow;
    logSilentFallback('emoji_catalog.emojiCatalog', e);
    retrySoon();
    final cached = await cache.read(active.id, key);
    if (cached == null) return const [];
    try {
      final json = jsonDecode(cached.payload);
      if (json is Map<String, dynamic>) {
        return EmojiListResponse.fromJson(json).emojis;
      }
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('emoji_catalog.emojiCatalog.cache', e);
      retrySoon();
      return const [];
    }
    return const [];
  }
}
