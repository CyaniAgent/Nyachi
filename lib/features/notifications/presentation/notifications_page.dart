// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/ui/avatar.dart';
import '../../settings/application/app_settings.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/failure_action.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/scroll_edge_loader.dart';
import '../../../core/ui/time_format.dart';
import '../application/notification_list_controller.dart';
import '../domain/notification_copy.dart';

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
        child: ReadableWidth(
          centered: ref.watch(settingsControllerProvider).centerContent,
          child: Column(
            children: [
              _FilterBar(state: state, controller: controller),
              Expanded(child: _body(context, ref, state, controller)),
            ],
          ),
        ),
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
    return ScrollEdgeLoader(
      canLoad: () {
        final current = ref.read(notificationListControllerProvider);
        return current.hasMore && !current.loadingMore && !current.refreshing;
      },
      onEdge: controller.loadMore,
      child: ListView.separated(
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
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final Notification notification;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actor = notificationActor(notification);
    final note = notificationNote(notification);
    final label = notificationLabel(l10n, notification);
    return ListTile(
      leading: NyachiAvatar(
        url: actor?.avatarUrl,
        size: 40,
        fallback: Icon(notificationTypeIcon(notification)),
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Icon(
          notificationTypeIcon(notification),
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        actor?.name?.isNotEmpty == true ? '@${actor!.username} $label' : label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note?.text != null && note!.text!.isNotEmpty)
            Text(note.text!, maxLines: 2, overflow: TextOverflow.ellipsis),
          Text(relativeTime(context, notificationCreatedAt(notification))),
        ],
      ),
      onTap: note == null
          ? null
          : () => openDetail(context, NoteDetailLocation(note.id)),
    );
  }
}

/// The filter chips above the list: "All" plus one chip per event group.
/// Selecting a chip reloads the list from the server with that filter.
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.state, required this.controller});

  final NotificationListState state;
  final NotificationListController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filter = state.filter;
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(l10n.notificationsFilterAll),
              selected: filter == null,
              onSelected: (_) => unawaited(controller.applyFilter(null)),
            ),
          ),
          for (final entry in NotificationFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(switch (entry) {
                  NotificationFilter.mentions =>
                    l10n.notificationsFilterMentions,
                  NotificationFilter.reactions =>
                    l10n.notificationsFilterReactions,
                  NotificationFilter.boosts => l10n.notificationsFilterBoosts,
                  NotificationFilter.follows => l10n.notificationsFilterFollows,
                  NotificationFilter.system => l10n.notificationsFilterSystem,
                }),
                selected: filter == entry,
                onSelected: (_) => unawaited(controller.applyFilter(entry)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Icon for a notification's event class, kept consistent across the list.
IconData notificationTypeIcon(Notification notification) {
  return switch (notification) {
    NotificationMention() || NotificationReply() => Icons.alternate_email,
    NotificationChatRoomInvitationReceived() => Icons.chat_bubble_outline,
    NotificationReaction() ||
    NotificationReactionGrouped() => Icons.favorite_outline,
    NotificationPollEnded() => Icons.bar_chart,
    NotificationRenote() ||
    NotificationRenoteGrouped() ||
    NotificationQuote() => Icons.repeat,
    NotificationFollow() => Icons.person_add_alt_outlined,
    NotificationReceiveFollowRequest() => Icons.person_add_alt_outlined,
    NotificationFollowRequestAccepted() => Icons.how_to_reg_outlined,
    NotificationRoleAssigned() => Icons.workspace_premium_outlined,
    NotificationAchievementEarned() => Icons.emoji_events_outlined,
    NotificationExportCompleted() => Icons.file_download_outlined,
    NotificationLogin() || NotificationCreateToken() => Icons.key_outlined,
    NotificationApp() => Icons.apps_outlined,
    NotificationNote() || NotificationScheduledNotePosted() => Icons.notes,
    _ => Icons.notifications_outlined,
  };
}
