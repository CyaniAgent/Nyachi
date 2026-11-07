// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/session_controller.dart';
import '../cache/cache_manager.dart';
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
    this.draftsSupported = false,
    this.serviceWorkerEnabled = false,
    this.version,
  });

  final String? name;
  final String? themeColor;
  final int maxNoteTextLength;

  /// Whether the server renders URL previews (`enableUrlPreview` in meta).
  final bool urlPreviewEnabled;

  /// Whether `notes/drafts/*` exists, i.e. server-side drafts and scheduled
  /// posts work. Probed once and cached, because meta has no flag for it.
  final bool draftsSupported;

  /// Whether the server runs a web push service worker (`enableServiceWorker`
  /// in meta). Gates the push settings entry, which is useless without it.
  final bool serviceWorkerEnabled;

  /// Server version string, kept for diagnostics.
  final String? version;

  InstanceInfo copyWith({
    bool? urlPreviewEnabled,
    bool? draftsSupported,
    bool? serviceWorkerEnabled,
  }) {
    return InstanceInfo(
      name: name,
      themeColor: themeColor,
      maxNoteTextLength: maxNoteTextLength,
      urlPreviewEnabled: urlPreviewEnabled ?? this.urlPreviewEnabled,
      draftsSupported: draftsSupported ?? this.draftsSupported,
      serviceWorkerEnabled: serviceWorkerEnabled ?? this.serviceWorkerEnabled,
      version: version,
    );
  }

  // Value equality is load-bearing: [instanceInfo] compares a background
  // refresh against the cached value and re-invalidates itself when they
  // differ. Without this, every refresh looked like a change and the provider
  // rebuilt forever — two requests per rebuild, for as long as the app ran.
  @override
  bool operator ==(Object other) =>
      other is InstanceInfo &&
      other.name == name &&
      other.themeColor == themeColor &&
      other.maxNoteTextLength == maxNoteTextLength &&
      other.urlPreviewEnabled == urlPreviewEnabled &&
      other.draftsSupported == draftsSupported &&
      other.serviceWorkerEnabled == serviceWorkerEnabled &&
      other.version == version;

  @override
  int get hashCode => Object.hash(
    name,
    themeColor,
    maxNoteTextLength,
    urlPreviewEnabled,
    draftsSupported,
    serviceWorkerEnabled,
    version,
  );
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

  // Canonical keys live on [CacheManager] so settings-side bulk clears can
  // never drift from what this repository writes.
  static const _cacheKey = CacheManager.instanceMetaKey;
  static const _probeKey = CacheManager.instanceMetaProbeKey;

  /// Instance metadata barely changes, so the cache never expires: it is
  /// served immediately and refreshed in the background by [refresh].
  Future<InstanceInfo?> load() async {
    final cached = await readCache();
    if (cached != null) return cached;
    return refresh();
  }

  /// Reads the persisted metadata without touching the network.
  Future<InstanceInfo?> readCache() async {
    final row = await cache.read(accountId, _cacheKey);
    if (row == null) return null;
    final info = _fromJson(row.payload);
    if (info == null) return null;
    final probe = await cache.read(accountId, _probeKey);
    return info.copyWith(draftsSupported: probe?.payload == '1');
  }

  /// Fetches metadata from the server and rewrites the cache.
  ///
  /// Falls back to whatever is cached when the request fails; a stale value is
  /// better than losing the theme colour and the text limit.
  Future<InstanceInfo?> refresh() async {
    final cached = await readCache();
    try {
      final meta = await client.meta.get();
      final info = _fromMeta(meta);
      await cache.write(
        accountId,
        _cacheKey,
        jsonEncode(meta.toJson()),
        updatedAt: DateTime.now(),
      );
      final supported = await _probeScheduledNotes();
      await cache.write(
        accountId,
        _probeKey,
        supported ? '1' : '0',
        updatedAt: DateTime.now(),
      );
      return info.copyWith(draftsSupported: supported);
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('instance_repository.refresh', e);
      return cached;
    }
  }

  /// Probes `notes/drafts/count` once to learn whether the server can queue
  /// scheduled notes. The endpoint is read-only and cheap; a 404 or any other
  /// failure means the feature is unavailable.
  Future<bool> _probeScheduledNotes() async {
    try {
      await client.notes.draftsCount();
      return true;
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('instance_repository.scheduledNotesProbe', e);
      return false;
    }
  }

  InstanceInfo? _fromJson(String payload) {
    try {
      final json = jsonDecode(payload);
      if (json is! Map<String, dynamic>) return null;
      return _fromMeta(MetaLite.fromJson(json));
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('instance_repository.fromJson', e);
      return null;
    }
  }

  InstanceInfo _fromMeta(MetaLite meta) {
    return InstanceInfo(
      name: meta.name,
      themeColor: meta.themeColor,
      maxNoteTextLength: meta.maxNoteTextLength.toInt(),
      // The meta model exposes this capability as `enableUrlPreview`.
      urlPreviewEnabled: meta.enableUrlPreview,
      serviceWorkerEnabled: meta.enableServiceWorker,
      version: meta.version,
    );
  }
}

/// Serves the cached instance metadata immediately and refreshes it in the
/// background, so the theme colour and text limit are available on the very
/// first frame and follow the server when it changes.
@Riverpod(keepAlive: true)
Future<InstanceInfo?> instanceInfo(Ref ref) async {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) return null;
  final repository = InstanceRepository(
    client: ref.watch(misskeyClientProvider),
    cache: ref.watch(cacheDaoProvider),
    accountId: active.id,
  );
  final cached = await repository.readCache();
  if (cached != null) {
    // Refresh in the background; failures keep the cached value.
    unawaited(() async {
      final fresh = await repository.refresh().catchError((_) => null);
      if (fresh != null && fresh != cached) {
        ref.invalidateSelf();
      }
    }());
    return cached;
  }
  return repository.refresh();
}
