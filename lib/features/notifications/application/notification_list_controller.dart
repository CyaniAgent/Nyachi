// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/network/silent_fallback.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/storage/storage_providers.dart';
import '../domain/notification_repository.dart';
import '../domain/notification_copy.dart';

part 'notification_list_controller.freezed.dart';
part 'notification_list_controller.g.dart';

class MisskeyNotificationRepository implements NotificationRepository {
  MisskeyNotificationRepository({
    required this.client,
    required this.cache,
    required this.accountId,
  });

  final MisskeyClient client;
  final CacheDao cache;
  final String accountId;

  static const _cacheKey = CacheManager.notificationsKey;

  @override
  Future<NotificationPage> fetchPage({
    String? untilId,
    List<AccountNotificationsRequestIncludeTypesItem>? includeTypes,
  }) async {
    final page = await client.account.notificationsPage(
      limit: 20,
      untilId: untilId,
      markAsRead: false,
      includeTypes: includeTypes,
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
    } catch (e) {
      if (e is MisskeyAuthenticationException) rethrow;
      logSilentFallback('notification_list_controller.readCache', e);
      return const [];
    }
  }

  @override
  Future<void> writeCache(List<Notification> notifications) async {
    // The cache is an optimisation: a row the SDK cannot serialise must not
    // fail the refresh that produced it. Only the unfiltered list is cached,
    // which is why such a failure used to surface as "everything fails on All,
    // other tabs are fine".
    try {
      await cache.write(
        accountId,
        _cacheKey,
        jsonEncode(notifications.take(50).map((n) => n.toJson()).toList()),
      );
    } catch (error) {
      logSilentFallback('notification_list_controller.writeCache', error);
    }
  }

  @override
  Future<void> markAllAsRead() => client.notifications.markAllAsRead();
}

/// A type filter for the notifications list.
///
/// The user-facing groups bundle API types by meaning: "Mentions" covers
/// mentions, replies and chat invitations, because all three address the
/// reader directly; "system" keeps the server noise. `null` means no filter.
enum NotificationFilter {
  mentions('mentions'),
  reactions('reactions'),
  boosts('boosts'),
  follows('follows'),
  system('system');

  const NotificationFilter(this.groupId);

  /// Stable id for persisting the selected chip.
  final String groupId;

  /// The API type names this filter requests.
  List<AccountNotificationsRequestIncludeTypesItem> get includeTypes =>
      switch (this) {
        NotificationFilter.mentions => const [
          AccountNotificationsRequestIncludeTypesItem.mention,
          AccountNotificationsRequestIncludeTypesItem.reply,
          AccountNotificationsRequestIncludeTypesItem
              .chatRoomInvitationReceived,
        ],
        NotificationFilter.reactions => const [
          AccountNotificationsRequestIncludeTypesItem.reaction,
          AccountNotificationsRequestIncludeTypesItem.pollEnded,
        ],
        NotificationFilter.boosts => const [
          AccountNotificationsRequestIncludeTypesItem.renote,
          AccountNotificationsRequestIncludeTypesItem.quote,
        ],
        NotificationFilter.follows => const [
          AccountNotificationsRequestIncludeTypesItem.follow,
          AccountNotificationsRequestIncludeTypesItem.receiveFollowRequest,
          AccountNotificationsRequestIncludeTypesItem.followRequestAccepted,
        ],
        NotificationFilter.system => const [
          AccountNotificationsRequestIncludeTypesItem.roleAssigned,
          AccountNotificationsRequestIncludeTypesItem.achievementEarned,
          AccountNotificationsRequestIncludeTypesItem.exportCompleted,
          AccountNotificationsRequestIncludeTypesItem.login,
          AccountNotificationsRequestIncludeTypesItem.createToken,
          AccountNotificationsRequestIncludeTypesItem.app,
          AccountNotificationsRequestIncludeTypesItem.scheduledNotePosted,
          AccountNotificationsRequestIncludeTypesItem.scheduledNotePostFailed,
        ],
      };

  /// Whether a live-arriving notification belongs to this view; grouped
  /// variants carry the same API type name as their single-event twins.
  bool accepts(Notification notification) {
    final name = notificationTypeName(notification);
    return name != null && includeTypes.any((type) => type.name == name);
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) throw StateError('No active account.');
  return MisskeyNotificationRepository(
    client: ref.watch(misskeyClientProvider),
    cache: ref.watch(cacheDaoProvider),
    accountId: active.id,
  );
});

@freezed
abstract class NotificationListState with _$NotificationListState {
  const factory NotificationListState({
    @Default([]) List<Notification> items,
    @Default(true) bool initialLoading,
    @Default(false) bool refreshing,
    @Default(false) bool loadingMore,
    @Default(true) bool hasMore,
    @Default(false) bool usingCache,
    AppFailure? error,
  }) = _NotificationListState;
}

/// One list per filter, keyed by it. Each tab swipes in with its own state, so
/// two tabs can be on screen at once during the gesture — a single shared
/// controller could only ever hold one.
///
/// Kept alive: the realtime service pushes notifications into the unfiltered
/// list even when no screen is listening.
@Riverpod(keepAlive: true)
class NotificationListController extends _$NotificationListController {
  late NotificationRepository _repository;
  var _disposed = false;

  /// `null` is the "All" tab: it owns the cache and receives live events.
  @override
  NotificationListState build(NotificationFilter? filter) {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    final active = ref.watch(sessionControllerProvider).active;
    if (active == null) throw StateError('No active account.');
    _repository = ref.watch(notificationRepositoryProvider);
    unawaited(Future<void>.microtask(_hydrate));
    return const NotificationListState();
  }

  Future<void> _hydrate() async {
    // Only the unfiltered feed is cached; a filtered tab always asks the
    // server, because the cache holds rows it excluded.
    if (filter == null) {
      final cached = await _repository.readCache();
      if (_disposed) return;
      if (cached.isNotEmpty) {
        state = state.copyWith(
          items: cached,
          initialLoading: false,
          usingCache: true,
        );
      }
    }
    await refresh();
  }

  Future<void> refresh() async {
    if (_disposed) return;
    final hadItems = state.items.isNotEmpty;
    state = state.copyWith(refreshing: true, error: null);
    try {
      final page = await _repository.fetchPage(
        includeTypes: filter?.includeTypes,
      );
      if (_disposed) return;
      state = state.copyWith(
        items: page.items,
        initialLoading: false,
        refreshing: false,
        hasMore: page.hasMore,
        usingCache: false,
        error: null,
      );
      if (filter == null) {
        await _repository.writeCache(page.items);
      }
    } catch (error) {
      // The user-facing failure is deliberately generic (mapped below), so the
      // console is the only place the underlying cause shows up. Printed in
      // release too: this is a real error, not a silent fallback.
      debugPrint(
        '[notifications] refresh failed: ${error.runtimeType}: $error',
      );
      if (_disposed) return;
      state = state.copyWith(
        initialLoading: false,
        refreshing: false,
        usingCache: hadItems || state.usingCache,
        error: mapFailure(error),
      );
    }
  }

  /// Inserts a notification pushed over the realtime stream.
  ///
  /// Sits at the head because the API returns newest first, and an id already
  /// present is dropped so a reconnect replay cannot duplicate a row. A
  /// filtered-out type is not inserted: the server still has it, and the next
  /// refresh of that tab reloads it.
  void prepend(Notification notification) {
    if (_disposed) return;
    if (state.items.any((item) => item.id == notification.id)) return;
    if (filter != null && !filter!.accepts(notification)) return;
    state = state.copyWith(
      items: [notification, ...state.items],
      initialLoading: false,
    );
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
      final page = await _repository.fetchPage(
        untilId: state.items.last.id,
        includeTypes: filter?.includeTypes,
      );
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
      if (filter == null) {
        await _repository.writeCache(merged);
      }
    } catch (error) {
      debugPrint(
        '[notifications] load more failed: ${error.runtimeType}: $error',
      );
      if (_disposed) return;
      state = state.copyWith(loadingMore: false, error: mapFailure(error));
    }
  }
}
