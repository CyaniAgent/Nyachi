// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../core/ui/failure_action.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/time_format.dart';
import '../application/notification_list_controller.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(notificationListControllerProvider);
    final controller = ref.read(notificationListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          IconButton(
            tooltip: l10n.markAllRead,
            onPressed: state.markingRead
                ? null
                : () async {
                    final ok = await controller.markAllRead();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? l10n.allRead : l10n.errorGeneric),
                      ),
                    );
                  },
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: _body(context, ref, state, controller),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    NotificationListState state,
    NotificationListController controller,
  ) {
    final l10n = context.l10n;
    if (state.initialLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(state.error?.message(l10n) ?? l10n.emptyNotifications),
          ),
          if (state.error != null)
            Center(
              child: FailureAction(
                failure: state.error!,
                onRetry: controller.refresh,
              ),
            ),
        ],
      );
    }
    return ListView.separated(
      itemCount: state.items.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          if (state.loadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.hasMore) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: TextButton(
                  onPressed: controller.loadMore,
                  child: Text(l10n.loadMore),
                ),
              ),
            );
          }
          if (state.error != null) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: FailureAction(
                  failure: state.error!,
                  onRetry: controller.refresh,
                ),
              ),
            );
          }
          return const SizedBox(height: 24);
        }
        return _NotificationTile(notification: state.items[index]);
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final Notification notification;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actor = _actor(notification);
    final note = _note(notification);
    return ListTile(
      leading: actor == null
          ? const CircleAvatar(child: Icon(Icons.notifications_outlined))
          : CircleAvatar(backgroundImage: NetworkImage(actor.avatarUrl)),
      title: Text(
        actor?.name?.isNotEmpty == true
            ? '@${actor!.username} ${_label(l10n, notification)}'
            : _label(l10n, notification),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note?.text != null && note!.text!.isNotEmpty)
            Text(note.text!, maxLines: 2, overflow: TextOverflow.ellipsis),
          Text(relativeTime(context, _createdAt(notification))),
        ],
      ),
      onTap: note == null ? null : () => context.push('/notes/${note.id}'),
    );
  }

  String _label(AppLocalizations l10n, Notification notification) {
    return switch (notification) {
      NotificationNote() => l10n.notificationNote,
      NotificationMention() => l10n.notificationMention,
      NotificationReply() => l10n.notificationReply,
      NotificationRenote() => l10n.notificationRenote,
      NotificationQuote() => l10n.notificationQuote,
      NotificationReaction() => l10n.notificationReaction,
      NotificationPollEnded() => l10n.notificationPollEnded,
      NotificationFollow() => l10n.notificationFollow,
      NotificationReceiveFollowRequest() =>
        l10n.notificationReceiveFollowRequest,
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

  UserLite? _actor(Notification notification) {
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

  Note? _note(Notification notification) {
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

  DateTime _createdAt(Notification notification) {
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
}
