// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/mfm/mfm_body.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/failure_action.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/scroll_edge_loader.dart';
import '../../../core/ui/time_format.dart';
import '../../settings/application/app_settings.dart';
import '../application/notification_list_controller.dart';
import '../application/notification_unread.dart';
import '../domain/notification_copy.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with SingleTickerProviderStateMixin {
  /// One tab per filter plus "all", in the order the tabs render.
  static const filters = <NotificationFilter?>[
    null,
    ...NotificationFilter.values,
  ];

  late final TabController _tabController = TabController(
    length: filters.length,
    vsync: this,
  );

  /// The visible tab. Tracked separately from the controller so the app bar's
  /// actions follow the tab without rebuilding on every animation frame.
  var _index = 0;

  @override
  void initState() {
    super.initState();
    // TabBarView has no page-changed callback; the controller's index is the
    // source of truth once a swipe settles.
    _tabController.addListener(() {
      if (_tabController.index != _index) {
        setState(() => _index = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unread = ref.watch(notificationUnreadProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          IconButton(
            tooltip: unread.unreadOnly
                ? l10n.notificationsShowAll
                : l10n.notificationsUnreadOnly,
            onPressed: () => ref
                .read(notificationUnreadProvider.notifier)
                .setUnreadOnly(!unread.unreadOnly),
            icon: Icon(
              unread.unreadOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
          ),
          IconButton(
            tooltip: l10n.markAllRead,
            onPressed: unread.markingRead
                ? null
                : () async {
                    final ok = await ref
                        .read(notificationUnreadProvider.notifier)
                        .markAllRead();
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          onTap: _select,
          tabs: [
            Tab(text: l10n.notificationsFilterAll),
            for (final filter in NotificationFilter.values)
              Tab(
                text: switch (filter) {
                  NotificationFilter.mentions =>
                    l10n.notificationsFilterMentions,
                  NotificationFilter.reactions =>
                    l10n.notificationsFilterReactions,
                  NotificationFilter.boosts => l10n.notificationsFilterBoosts,
                  NotificationFilter.follows => l10n.notificationsFilterFollows,
                  NotificationFilter.system => l10n.notificationsFilterSystem,
                },
              ),
          ],
        ),
      ),
      // A TabBarView rather than swapping the body by hand: swiping between
      // categories is the expected gesture, and it animates with the framework's
      // own page transition instead of an instant replacement.
      body: TabBarView(
        controller: _tabController,
        children: [
          for (final filter in filters) _NotificationsSurface(filter: filter),
        ],
      ),
    );
  }
}

/// One category's list. Each tab owns its own state, so two of them can be on
/// screen during a swipe.
class _NotificationsSurface extends ConsumerWidget {
  const _NotificationsSurface({required this.filter});

  final NotificationFilter? filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationListControllerProvider(filter));
    final controller = ref.read(
      notificationListControllerProvider(filter).notifier,
    );
    final unread = ref.watch(notificationUnreadProvider);
    final boundary = unread.boundary;
    // "Unread" is everything that arrived after the last mark-all-read; the
    // server exposes no per-notification read flag.
    final items = unread.unreadOnly && boundary != null
        ? state.items
              .where((item) => notificationCreatedAt(item).isAfter(boundary))
              .toList(growable: false)
        : state.items;

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ReadableWidth(
        centered: ref.watch(settingsControllerProvider).centerContent,
        child: _body(context, state, controller, items, unread.unreadOnly),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    NotificationListState state,
    NotificationListController controller,
    List<Notification> items,
    bool unreadOnly,
  ) {
    final l10n = context.l10n;
    if (state.initialLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(
              state.error?.message(l10n) ??
                  (unreadOnly
                      ? l10n.notificationsNoUnread
                      : l10n.emptyNotifications),
            ),
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
      canLoad: () => state.hasMore && !state.loadingMore && !state.refreshing,
      onEdge: controller.loadMore,
      child: ListView.separated(
        itemCount: items.length + 1,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == items.length) {
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
          return _NotificationTile(notification: items[index]);
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
    final rawActor = notificationActor(notification);
    // A server-raised row (`pollEnded`) carries a stand-in actor with no id;
    // showing "@ $label" for it would read as a person.
    final actor = rawActor != null && rawActor.id.isNotEmpty ? rawActor : null;
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
            MfmBody(text: note.text!, emojis: note.emojis, maxLines: 2),
          Text(relativeTime(context, notificationCreatedAt(notification))),
        ],
      ),
      onTap: note == null
          ? null
          : () => openDetail(context, NoteDetailLocation(note.id)),
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
    NotificationNote() => Icons.notes,
    NotificationScheduledNotePosted() ||
    NotificationScheduledNotePostFailed() => Icons.schedule,
    NotificationTest() => Icons.science_outlined,
    // A type newer than the SDK's spec: show it with a neutral mark rather
    // than dropping a real notification.
    NotificationUnknown() => Icons.notifications_none,
  };
}
