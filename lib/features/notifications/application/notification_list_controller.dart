// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/storage/storage_providers.dart';

part 'notification_list_controller.freezed.dart';
part 'notification_list_controller.g.dart';

class NotificationPage {
  const NotificationPage({required this.items, required this.hasMore});

  final List<Notification> items;
  final bool hasMore;
}

abstract interface class NotificationRepository {
  Future<NotificationPage> fetchPage({String? untilId});

  Future<List<Notification>> readCache();

  Future<void> writeCache(List<Notification> notifications);

  Future<void> markAllAsRead();
}

class MisskeyNotificationRepository implements NotificationRepository {
  MisskeyNotificationRepository({
    required this.client,
    required this.cache,
    required this.accountId,
  });

  final MisskeyClient client;
  final CacheDao cache;
  final String accountId;

  static const _cacheKey = 'notifications';

  @override
  Future<NotificationPage> fetchPage({String? untilId}) async {
    final page = await client.account.notificationsPage(
      limit: 20,
      untilId: untilId,
      markAsRead: false,
    );
    return NotificationPage(items: page.items, hasMore: page.hasMore);
  }

  @override
  Future<List<Notification>> readCache() async {
    final cached = await cache.read(accountId, _cacheKey);
    if (cached == null) return const [];
    try {
      final decoded = jsonDecode(cached.payload);
      if (decoded is! List) return const [];
      final result = <Notification>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          result.add(Notification.fromJson(item));
        } else if (item is Map) {
          result.add(Notification.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return result;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> writeCache(List<Notification> notifications) {
    return cache.write(
      accountId,
      _cacheKey,
      jsonEncode(notifications.take(50).map((n) => n.toJson()).toList()),
    );
  }

  @override
  Future<void> markAllAsRead() => client.notifications.markAllAsRead();
}

@freezed
abstract class NotificationListState with _$NotificationListState {
  const factory NotificationListState({
    @Default([]) List<Notification> items,
    @Default(true) bool initialLoading,
    @Default(false) bool refreshing,
    @Default(false) bool loadingMore,
    @Default(true) bool hasMore,
    @Default(false) bool usingCache,
    @Default(false) bool markingRead,
    AppFailure? error,
  }) = _NotificationListState;
}

@riverpod
class NotificationListController extends _$NotificationListController {
  late NotificationRepository _repository;
  var _disposed = false;

  @override
  NotificationListState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    final active = ref.watch(sessionControllerProvider).active;
    if (active == null) throw StateError('No active account.');
    _repository = MisskeyNotificationRepository(
      client: ref.watch(misskeyClientProvider),
      cache: ref.watch(cacheDaoProvider),
      accountId: active.id,
    );
    unawaited(Future<void>.microtask(_hydrate));
    return const NotificationListState();
  }

  Future<void> _hydrate() async {
    final cached = await _repository.readCache();
    if (_disposed) return;
    if (cached.isNotEmpty) {
      state = state.copyWith(
        items: cached,
        initialLoading: false,
        usingCache: true,
      );
    }
    await refresh();
  }

  Future<void> refresh() async {
    if (_disposed) return;
    final hadItems = state.items.isNotEmpty;
    state = state.copyWith(refreshing: true, error: null);
    try {
      final page = await _repository.fetchPage();
      if (_disposed) return;
      state = state.copyWith(
        items: page.items,
        initialLoading: false,
        refreshing: false,
        hasMore: page.hasMore,
        usingCache: false,
        error: null,
      );
      await _repository.writeCache(page.items);
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(
        initialLoading: false,
        refreshing: false,
        usingCache: hadItems || state.usingCache,
        error: mapFailure(error),
      );
    }
  }

  Future<void> loadMore() async {
    if (_disposed ||
        state.loadingMore ||
        state.refreshing ||
        !state.hasMore ||
        state.items.isEmpty) {
      return;
    }
    state = state.copyWith(loadingMore: true, error: null);
    try {
      final page = await _repository.fetchPage(untilId: state.items.last.id);
      if (_disposed) return;
      final seen = <String>{};
      final merged = [
        ...state.items,
        ...page.items,
      ].where((item) => seen.add(item.id)).toList(growable: false);
      state = state.copyWith(
        items: merged,
        loadingMore: false,
        hasMore: page.hasMore,
        error: null,
      );
      await _repository.writeCache(merged);
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(loadingMore: false, error: mapFailure(error));
    }
  }

  Future<bool> markAllRead() async {
    if (state.markingRead) return false;
    state = state.copyWith(markingRead: true, error: null);
    try {
      await _repository.markAllAsRead();
      if (_disposed) return true;
      state = state.copyWith(markingRead: false);
      await refresh();
      return true;
    } catch (error) {
      if (!_disposed) {
        state = state.copyWith(markingRead: false, error: mapFailure(error));
      }
      return false;
    }
  }
}
