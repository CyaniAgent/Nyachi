// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/widgets.dart'
    show AppLifecycleState, WidgetsBinding, basicLocaleListResolution;
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/platform/residency.dart';
import '../../../core/storage/storage_providers.dart';
import '../../chat/domain/chat_models.dart';
import '../../settings/application/app_settings.dart';
import '../domain/notification_copy.dart';
import 'notification_list_controller.dart';
import 'realtime_service.dart';

part 'realtime_providers.g.dart';

/// The realtime connection for the signed-in account, or null when nobody is
/// signed in - the shell outlives a logout, so this must not throw.
///
/// One socket carries the `main` channel (notifications) plus a chat channel
/// per open thread, so opening a conversation never opens a second socket.
/// Kept alive: a notification arriving while the user is elsewhere still has
/// somewhere to land.
@Riverpod(keepAlive: true)
RealtimeService? realtimeService(Ref ref) {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) return null;
  final client = ref.watch(misskeyClientProvider);
  final tokens = ref.watch(tokenStoreProvider);

  final notifications = StreamController<JsonMap>.broadcast();
  final service = RealtimeService(
    baseUri: client.baseUri,
    tokenProvider: () => tokens.read(active.id),
    onSessionExpired: () =>
        ref.read(sessionControllerProvider.notifier).expireActiveAccount(),
    // While the Android foreground service is running, the socket must stay
    // open in the background or system notifications have no source.
    retainConnectionOnPause: () =>
        defaultTargetPlatform == TargetPlatform.android
        ? ref.read(residencyProvider).androidServiceRunning
        : false,
  )..start();

  final handle = service.join(
    'main-notifications',
    RealtimeSubscription<JsonMap>(
      channel: const MainChannel(),
      eventType: 'notification',
      events: notifications,
      // A fresh arrival means the unread badge changed even if this client
      // cannot see which note it refers to; refresh so the list matches.
      onConnected: () => unawaited(
        ref.read(notificationListControllerProvider(null).notifier).refresh(),
      ),
    ),
  );
  final pushed = notifications.stream.listen((body) {
    final notification = Notification.fromJson(body);
    ref
        .read(notificationListControllerProvider(null).notifier)
        .prepend(notification);
    // A system notification only makes sense when the user is not already
    // looking at the list; the in-app list is the same information.
    unawaited(_announce(ref, notification));
  });
  ref.onDispose(() {
    unawaited(pushed.cancel());
    unawaited(handle.cancel());
    service.dispose();
  });
  return service;
}

/// Raises a system notification for an event that arrived on the socket.
///
/// The text is built with the app's configured language rather than a widget
/// context, because a notification can arrive while the user is elsewhere or
/// while no screen is mounted at all.
///
/// Skipped while the app is in the foreground ([AppLifecycleState.resumed]):
/// the in-app list is on screen and a toast would only duplicate it. The tray
/// hidden state and Android background both announce.
Future<void> _announce(Ref ref, Notification notification) async {
  if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
    return;
  }
  final settings = ref.read(settingsControllerProvider);
  final requested = settings.localeCode == 'system'
      ? PlatformDispatcher.instance.locale
      : Locale(settings.localeCode);
  // The direct lookup throws for languages the app does not ship; resolve the
  // request against the supported list the same way MaterialApp does
  // (preferredLocales first, supportedLocales second).
  final locale = basicLocaleListResolution([
    requested,
  ], AppLocalizations.supportedLocales);
  final copy = notificationCopy(lookupAppLocalizations(locale), notification);
  await ref
      .read(residencyProvider)
      .showNotification(
        eventId: notification.id,
        title: copy.title,
        body: copy.body,
        category: notificationCategory(notification),
      );
}

/// Live messages for one chat thread.
///
/// A stream rather than a controller read: the thread controller owns its
/// list, and this only reports what arrived after the page opened.
@Riverpod(keepAlive: true)
Stream<ChatMessageItem> chatThreadStream(Ref ref, ChatTarget target) async* {
  final service = ref.watch(realtimeServiceProvider);
  // Signed out: no socket exists, so nothing will ever arrive.
  if (service == null) return;
  final raw = StreamController<JsonMap>.broadcast();
  final handle = service.join(
    'chat-${target.map(user: (t) => 'user-${t.userId}', room: (t) => 'room-${t.roomId}')}',
    RealtimeSubscription<JsonMap>(
      channel: RawChannel(
        target.map(user: (_) => 'chatUser', room: (_) => 'chatRoom'),
        params: target.map(
          user: (_) => null,
          room: (t) => {'roomId': t.roomId},
        ),
      ),
      eventType: 'message',
      events: raw,
    ),
  );
  ref.onDispose(() {
    unawaited(handle.cancel());
    unawaited(raw.close());
  });
  yield* raw.stream.map(
    (body) => ChatMessageItem(
      id: body['id'] as String,
      createdAt: DateTime.parse(body['createdAt'] as String),
      fromUserId: body['fromUserId'] as String,
      text: body['text'] as String?,
    ),
  );
}
