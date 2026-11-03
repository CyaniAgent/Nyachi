// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/l10n/app_localizations.dart';

/// Short human description of a notification's event, shared by the in-app
/// list and the system notification so the two never drift apart.
String notificationLabel(AppLocalizations l10n, Notification notification) {
  return switch (notification) {
    NotificationNote() => l10n.notificationNote,
    NotificationMention() => l10n.notificationMention,
    NotificationReply() => l10n.notificationReply,
    NotificationRenote() => l10n.notificationRenote,
    NotificationQuote() => l10n.notificationQuote,
    NotificationReaction() => l10n.notificationReaction,
    NotificationPollEnded() => l10n.notificationPollEnded,
    NotificationFollow() => l10n.notificationFollow,
    NotificationReceiveFollowRequest() => l10n.notificationReceiveFollowRequest,
    NotificationFollowRequestAccepted() =>
      l10n.notificationFollowRequestAccepted,
    NotificationRoleAssigned() => l10n.notificationRoleAssigned,
    NotificationChatRoomInvitationReceived() =>
      l10n.notificationChatRoomInvitation,
    NotificationAchievementEarned() => l10n.notificationAchievement,
    NotificationExportCompleted() => l10n.notificationExportCompleted,
    NotificationLogin() => l10n.notificationLogin,
    NotificationCreateToken() => l10n.notificationCreateToken,
    NotificationApp() => l10n.notificationApp,
    NotificationReactionGrouped() => l10n.notificationGroupedReaction,
    NotificationRenoteGrouped() => l10n.notificationGroupedRenote,
    _ => l10n.notificationGeneric,
  };
}

/// The user an event is about, when the event names one.
UserLite? notificationActor(Notification notification) {
  return switch (notification) {
    NotificationNote(:final user) => user,
    NotificationMention(:final user) => user,
    NotificationReply(:final user) => user,
    NotificationRenote(:final user) => user,
    NotificationQuote(:final user) => user,
    NotificationReaction(:final user) => user,
    NotificationPollEnded(:final user) => user,
    NotificationFollow(:final user) => user,
    NotificationReceiveFollowRequest(:final user) => user,
    NotificationFollowRequestAccepted(:final user) => user,
    NotificationRenoteGrouped(:final users) =>
      users.isEmpty ? null : users.first,
    NotificationReactionGrouped(:final reactions) =>
      reactions.isEmpty ? null : reactions.first.user,
    _ => null,
  };
}

/// The note an event points at, when it points at one.
Note? notificationNote(Notification notification) {
  return switch (notification) {
    NotificationNote(:final note) => note,
    NotificationMention(:final note) => note,
    NotificationReply(:final note) => note,
    NotificationRenote(:final note) => note,
    NotificationQuote(:final note) => note,
    NotificationReaction(:final note) => note,
    NotificationPollEnded(:final note) => note,
    NotificationScheduledNotePosted(:final note) => note,
    NotificationReactionGrouped(:final note) => note,
    NotificationRenoteGrouped(:final note) => note,
    _ => null,
  };
}

/// Title and body for a system notification about [notification].
///
/// The title names the actor and what they did; the body carries the note text
/// when the event has one, so the toast alone is readable without the app.
({String title, String body}) notificationCopy(
  AppLocalizations l10n,
  Notification notification,
) {
  final actor = notificationActor(notification);
  final label = notificationLabel(l10n, notification);
  final title = actor == null ? label : '@${actor.username} $label';
  final note = notificationNote(notification);
  return (title: title, body: note?.text ?? '');
}

/// When the event happened.
DateTime notificationCreatedAt(Notification notification) {
  return switch (notification) {
    NotificationNote(:final createdAt) => createdAt,
    NotificationMention(:final createdAt) => createdAt,
    NotificationReply(:final createdAt) => createdAt,
    NotificationRenote(:final createdAt) => createdAt,
    NotificationQuote(:final createdAt) => createdAt,
    NotificationReaction(:final createdAt) => createdAt,
    NotificationPollEnded(:final createdAt) => createdAt,
    NotificationScheduledNotePosted(:final createdAt) => createdAt,
    NotificationScheduledNotePostFailed(:final createdAt) => createdAt,
    NotificationFollow(:final createdAt) => createdAt,
    NotificationReceiveFollowRequest(:final createdAt) => createdAt,
    NotificationFollowRequestAccepted(:final createdAt) => createdAt,
    NotificationRoleAssigned(:final createdAt) => createdAt,
    NotificationChatRoomInvitationReceived(:final createdAt) => createdAt,
    NotificationAchievementEarned(:final createdAt) => createdAt,
    NotificationExportCompleted(:final createdAt) => createdAt,
    NotificationLogin(:final createdAt) => createdAt,
    NotificationCreateToken(:final createdAt) => createdAt,
    NotificationApp(:final createdAt) => createdAt,
    NotificationReactionGrouped(:final createdAt) => createdAt,
    NotificationRenoteGrouped(:final createdAt) => createdAt,
    NotificationTest(:final createdAt) => createdAt,
  };
}
