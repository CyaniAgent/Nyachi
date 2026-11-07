// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    @Default(false) bool markingRead,

    /// The active type tab; null shows every notification. An arriving event
    /// of a filtered-out type is held back from the list until the filter is
    /// lifted, not dropped: a later refresh reloads it from the server.
    NotificationFilter? filter,

    /// Shows only notifications newer than [readBoundary].
    @Default(false) bool unreadOnly,

    /// Everything at or before this instant counts as read. The server keeps
    /// no per-notification read flag — `i/notifications` takes `markAsRead`
    /// as a side effect and returns no state — so the boundary is this
    /// client's record of the last "mark all read", persisted per account.
    DateTime? readBoundary,
    AppFailure? error,
  }) = _NotificationListState;
}

/// Kept alive: the realtime service pushes notifications into this list even
/// when no screen is listening, so it must not be disposed between visits.
@Riverpod(keepAlive: true)
class NotificationListController extends _$NotificationListController {
  late NotificationRepository _repository;
  var _disposed = false;

  @override
  NotificationListState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    final active = ref.watch(sessionControllerProvider).active;
    if (active == null) throw StateError('No active account.');
    _repository = ref.watch(notificationRepositoryProvider);
    _readBoundaryKey = '$_readBoundaryKeyPrefix${active.id}';
    unawaited(Future<void>.microtask(_hydrate));
    return const NotificationListState();
  }

  static const _readBoundaryKeyPrefix = 'notifications.readAt.';
  late String _readBoundaryKey;

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  /// Reads the stored boundary, creating one at install time so an account
  /// that never pressed "mark all read" does not open with every historical
  /// notification flagged as unread.
  Future<DateTime> _loadBoundary() async {
    final stored = _prefs.getInt(_readBoundaryKey);
    if (stored != null) {
      return DateTime.fromMillisecondsSinceEpoch(stored);
    }
    final now = DateTime.now();
    await _prefs.setInt(_readBoundaryKey, now.millisecondsSinceEpoch);
    return now;
  }

  Future<void> _hydrate() async {
    final boundary = await _loadBoundary();
    if (_disposed) return;
    state = state.copyWith(readBoundary: boundary);
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

  /// Switches the unread-only view. Purely client-side: the server has no read
  /// state to ask about, so the list is not reloaded.
  void setUnreadOnly(bool value) {
    if (_disposed || state.unreadOnly == value) return;
    state = state.copyWith(unreadOnly: value);
  }

  Future<void> refresh() async {
    if (_disposed) return;
    final hadItems = state.items.isNotEmpty;
    final filterAtRequest = state.filter;
    state = state.copyWith(refreshing: true, error: null);
    try {
      final page = await _repository.fetchPage(
        includeTypes: filterAtRequest?.includeTypes,
      );
      if (_disposed) return;
      // Rapid chip taps can put two refreshes in flight; a response must not
      // land under a chip the user selected after it was requested.
      if (state.filter != filterAtRequest) return;
      state = state.copyWith(
        items: page.items,
        initialLoading: false,
        refreshing: false,
        hasMore: page.hasMore,
        usingCache: false,
        error: null,
      );
      // The cache holds the unfiltered feed: it is only written when the list
      // actually shows it, so lifting a filter cannot show filter-specific
      // rows as cache.
      if (state.filter == null) {
        await _repository.writeCache(page.items);
      }
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

  /// Inserts a notification pushed over the realtime stream.
  ///
  /// Sits at the head because the API returns newest first, and an id already
  /// present is dropped so a reconnect replay cannot duplicate a row. A
  /// filtered-out type is not inserted: the server still has it, and the
  /// next unfiltered refresh reloads it.
  void prepend(Notification notification) {
    if (_disposed) return;
    if (state.items.any((item) => item.id == notification.id)) return;
    if (_filterExcludes(notification)) return;
    state = state.copyWith(
      items: [notification, ...state.items],
      initialLoading: false,
    );
  }

  bool _filterExcludes(Notification notification) {
    final filter = state.filter;
    if (filter == null) return false;
    return !filter.accepts(notification);
  }

  /// Switches the type filter and reloads; the filtered view is always fresh
  /// from the server because the cache only stores the unfiltered feed.
  Future<void> applyFilter(NotificationFilter? filter) async {
    if (_disposed || state.filter == filter) return;
    state = state.copyWith(
      filter: filter,
      items: const [],
      hasMore: true,
      initialLoading: true,
      error: null,
    );
    await refresh();
  }

  Future<void> loadMore() async {
    if (_disposed ||
        state.loadingMore ||
        state.refreshing ||
        !state.hasMore ||
        state.items.isEmpty) {
      return;
    }
    final filterAtRequest = state.filter;
    state = state.copyWith(loadingMore: true, error: null);
    try {
      final page = await _repository.fetchPage(
        untilId: state.items.last.id,
        includeTypes: filterAtRequest?.includeTypes,
      );
      if (_disposed) return;
      if (state.filter != filterAtRequest) return;
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
      if (state.filter == null) {
        await _repository.writeCache(merged);
      }
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
      final now = DateTime.now();
      await _prefs.setInt(_readBoundaryKey, now.millisecondsSinceEpoch);
      if (_disposed) return true;
      state = state.copyWith(markingRead: false, readBoundary: now);
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
