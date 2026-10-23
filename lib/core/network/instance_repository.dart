// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/session_controller.dart';
import '../storage/app_database.dart';
import '../storage/storage_providers.dart';
import 'client_provider.dart';

part 'instance_repository.g.dart';

@immutable
class InstanceInfo {
  const InstanceInfo({
    required this.name,
    required this.themeColor,
    required this.maxNoteTextLength,
  });

  final String? name;
  final String? themeColor;
  final int maxNoteTextLength;
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
  static const _ttl = Duration(hours: 1);

  Future<InstanceInfo?> load() async {
    try {
      final meta = await client.meta.get();
      await cache.write(
        accountId,
        _cacheKey,
        jsonEncode(meta.toJson()),
        updatedAt: DateTime.now(),
      );
      return _fromMeta(meta);
    } catch (_) {
      final cached = await cache.read(accountId, _cacheKey);
      if (cached == null) return null;
      if (DateTime.now().difference(cached.updatedAt) > _ttl) {
        // Stale metadata is still better than failing the whole app.
        return _fromJson(cached.payload);
      }
      return _fromJson(cached.payload);
    }
  }

  InstanceInfo? _fromJson(String payload) {
    try {
      final json = jsonDecode(payload);
      if (json is! Map<String, dynamic>) return null;
      return _fromMeta(MetaLite.fromJson(json));
    } catch (_) {
      return null;
    }
  }

  InstanceInfo _fromMeta(MetaLite meta) {
    return InstanceInfo(
      name: meta.name,
      themeColor: meta.themeColor,
      maxNoteTextLength: meta.maxNoteTextLength.toInt(),
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
