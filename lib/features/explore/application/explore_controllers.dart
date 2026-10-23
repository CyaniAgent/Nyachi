// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/storage/storage_providers.dart';

part 'explore_controllers.freezed.dart';
part 'explore_controllers.g.dart';

@riverpod
Future<List<HashtagsTrendResponseItem>> trends(Ref ref) async {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) return const [];
  final client = ref.watch(misskeyClientProvider);
  final cache = ref.watch(cacheDaoProvider);
  const key = 'trends';
  try {
    final items = await client.hashtags.trend();
    await cache.write(
      active.id,
      key,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
    return items;
  } catch (_) {
    final cached = await cache.read(active.id, key);
    if (cached == null) return const [];
    try {
      final decoded = jsonDecode(cached.payload);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map(
            (item) => HashtagsTrendResponseItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }
}

@freezed
abstract class UserSearchState with _$UserSearchState {
  const factory UserSearchState({
    @Default([]) List<User> items,
    @Default(true) bool loading,
    @Default(false) bool loadingMore,
    @Default(true) bool hasMore,
    AppFailure? error,
  }) = _UserSearchState;
}

@riverpod
class UserSearchController extends _$UserSearchController {
  late final String _query;
  var _disposed = false;

  @override
  UserSearchState build(String query) {
    _query = query;
    ref.onDispose(() => _disposed = true);
    if (query.trim().isEmpty) {
      return const UserSearchState(loading: false, hasMore: false);
    }
    unawaited(Future<void>.microtask(_load));
    return const UserSearchState();
  }

  Future<void> _load() async {
    try {
      final items = await ref
          .read(misskeyClientProvider)
          .users
          .search(query: _query, limit: 20);
      if (_disposed) return;
      state = state.copyWith(
        items: items,
        loading: false,
        hasMore: items.length == 20,
        error: null,
      );
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(loading: false, error: mapFailure(error));
    }
  }

  Future<void> loadMore() async {
    if (_disposed || state.loadingMore || !state.hasMore) return;
    state = state.copyWith(loadingMore: true, error: null);
    try {
      final items = await ref
          .read(misskeyClientProvider)
          .users
          .search(query: _query, limit: 20, offset: state.items.length);
      if (_disposed) return;
      final seen = <String>{};
      final merged = [
        ...state.items,
        ...items,
      ].where((user) => seen.add(user.id)).toList(growable: false);
      state = state.copyWith(
        items: merged,
        loadingMore: false,
        hasMore: items.length == 20,
        error: null,
      );
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(loadingMore: false, error: mapFailure(error));
    }
  }
}
