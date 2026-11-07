// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/storage/storage_providers.dart';
import 'notification_list_controller.dart';

part 'notification_unread.freezed.dart';
part 'notification_unread.g.dart';

@freezed
abstract class NotificationUnreadState with _$NotificationUnreadState {
  const factory NotificationUnreadState({
    @Default(false) bool unreadOnly,
    @Default(false) bool markingRead,

    /// Everything at or before this instant counts as read.
    ///
    /// The server keeps no per-notification read flag — `i/notifications`
    /// takes `markAsRead` as a side effect and returns no state — so this is
    /// the client's own record of the last "mark all read", persisted per
    /// account.
    DateTime? boundary,
    AppFailure? error,
  }) = _NotificationUnreadState;
}

/// The unread view, shared by every tab: it describes the account, not one
/// list, and moving the boundary must affect all of them at once.
@Riverpod(keepAlive: true)
class NotificationUnread extends _$NotificationUnread {
  static const _keyPrefix = 'notifications.readAt.';

  late String _key;

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  NotificationUnreadState build() {
    final active = ref.watch(sessionControllerProvider).active;
    if (active == null) throw StateError('No active account.');
    _key = '$_keyPrefix${active.id}';
    // Restoring writes state, which must not happen during build.
    unawaited(Future<void>.microtask(_restore));
    return const NotificationUnreadState();
  }

  void _restore() {
    try {
      final stored = _prefs.getInt(_key);
      if (stored != null) {
        state = state.copyWith(
          boundary: DateTime.fromMillisecondsSinceEpoch(stored),
        );
        return;
      }
      // A fresh account has no read history. Creating the boundary now is what
      // keeps the first visit from flagging the whole history as unread.
      final now = DateTime.now();
      state = state.copyWith(boundary: now);
      unawaited(() async {
        try {
          await _prefs.setInt(_key, now.millisecondsSinceEpoch);
        } catch (_) {
          // Persisting is best-effort; the in-memory boundary still applies.
        }
      }());
    } catch (_) {
      // A preference failure only disables the unread view.
    }
  }

  void setUnreadOnly(bool value) {
    if (state.unreadOnly == value) return;
    state = state.copyWith(unreadOnly: value);
  }

  /// Marks everything read on the server, then moves the boundary so every tab
  /// agrees.
  Future<bool> markAllRead() async {
    if (state.markingRead) return false;
    state = state.copyWith(markingRead: true, error: null);
    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead();
      final now = DateTime.now();
      try {
        await _prefs.setInt(_key, now.millisecondsSinceEpoch);
      } catch (_) {
        // The server-side read state is what matters.
      }
      state = state.copyWith(markingRead: false, boundary: now);
      ref.invalidate(notificationListControllerProvider);
      return true;
    } catch (error) {
      state = state.copyWith(markingRead: false, error: mapFailure(error));
      return false;
    }
  }
}
