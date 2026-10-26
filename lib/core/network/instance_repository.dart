// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/session_controller.dart';
import '../storage/app_database.dart';
import '../storage/storage_providers.dart';
import 'client_provider.dart';
import 'silent_fallback.dart';

part 'instance_repository.g.dart';

@immutable
class InstanceInfo {
  const InstanceInfo({
    required this.name,
    required this.themeColor,
    required this.maxNoteTextLength,
    this.urlPreviewEnabled = false,
  });

  final String? name;
  final String? themeColor;
  final int maxNoteTextLength;

  /// Whether the server renders URL previews (`urlPreviewEnabled` in meta).
  /// Absent field means the server has no preview support, so this stays false.
  final bool urlPreviewEnabled;
}

class InstanceRepository {
  InstanceRepository({
    required this.client,
    required this.cache,
    required this.accountId,
  });

  final MisskeyClient client;
  final CacheDao cache;
  final String accountId;

  static const _cacheKey = 'meta';
  static const _ttl = Duration(hours: 6);

  /// Returns cached metadata immediately while it is still fresh, so opening
  /// the app does not wait on the network for instance info.
  Future<InstanceInfo?> load() async {
    final cached = await cache.read(accountId, _cacheKey);
    if (cached != null) {
      final flag = await cache.read(accountId, _previewKey);
      _cachedPreviewFlag = flag?.payload == '1';
      if (DateTime.now().difference(cached.updatedAt) <= _ttl) {
        final parsed = _fromJson(cached.payload);
        if (parsed != null) return parsed;
      }
    }
    try {
      final previewEnabled = await _loadUrlPreviewFlag();
      final meta = await client.meta.get();
      await cache.write(
        accountId,
        _cacheKey,
        jsonEncode(meta.toJson()),
        updatedAt: DateTime.now(),
      );
      await cache.write(
        accountId,
        _previewKey,
        previewEnabled ? '1' : '0',
        updatedAt: DateTime.now(),
      );
      return _fromMeta(meta, urlPreviewEnabled: previewEnabled);
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('instance_repository.load', e);
      // Stale metadata is still better than failing the whole app.
      return cached == null ? null : _fromJson(cached.payload);
    }
  }

  static const _previewKey = 'meta.urlPreview';

  /// Reads `urlPreviewEnabled` from the raw meta payload.
  ///
  /// The typed `MetaLite` model does not expose it, so this falls back to the
  /// generic map channel. Servers without URL preview support omit the flag.
  Future<bool> _loadUrlPreviewFlag() async {
    try {
      final map = await client.postMap('meta', body: const <String, Object?>{});
      return map['urlPreviewEnabled'] == true;
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('instance_repository.urlPreview', e);
      return false;
    }
  }

  /// Flag read alongside the cached payload; refreshed by [load].
  bool _cachedPreviewFlag = false;

  InstanceInfo? _fromJson(String payload) {
    try {
      final json = jsonDecode(payload);
      if (json is! Map<String, dynamic>) return null;
      return _fromMeta(
        MetaLite.fromJson(json),
        urlPreviewEnabled: _cachedPreviewFlag,
      );
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('instance_repository.fromJson', e);
      return null;
    }
  }

  InstanceInfo _fromMeta(MetaLite meta, {bool urlPreviewEnabled = false}) {
    return InstanceInfo(
      name: meta.name,
      themeColor: meta.themeColor,
      maxNoteTextLength: meta.maxNoteTextLength.toInt(),
      urlPreviewEnabled: urlPreviewEnabled,
    );
  }
}

@Riverpod(keepAlive: true)
Future<InstanceInfo?> instanceInfo(Ref ref) async {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) return null;
  final repository = InstanceRepository(
    client: ref.watch(misskeyClientProvider),
    cache: ref.watch(cacheDaoProvider),
    accountId: active.id,
  );
  return repository.load();
}
