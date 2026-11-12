// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/network/instance_repository.dart';
import '../../../core/storage/storage_models.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../admin/data/admin_repository.dart';
import '../../settings/application/app_settings.dart';

/// Opens the shell drawer from a tab page's AppBar.
///
/// The drawer belongs to the shell scaffold, which is an ancestor of every tab
/// page; `Scaffold.of` from inside a page would find that page's own Scaffold
/// (no drawer) instead, so the opener is published through this scope.
class AppDrawerScope extends InheritedWidget {
  const AppDrawerScope({
    required this.openDrawer,
    required super.child,
    super.key,
  });

  final VoidCallback openDrawer;

  static void open(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<AppDrawerScope>()?.openDrawer();
  }

  @override
  bool updateShouldNotify(AppDrawerScope oldWidget) =>
      openDrawer != oldWidget.openDrawer;
}

/// Hamburger for the leading slot of tab-root AppBars.
class AppDrawerButton extends StatelessWidget {
  const AppDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      onPressed: () => AppDrawerScope.open(context),
      icon: const Icon(Icons.menu),
    );
  }
}

/// What both chrome presentations render: tab rows, then the feature
/// entries, with the account header and settings pinned by each shell.
class AppNavEntries {
  const AppNavEntries({
    required this.tabs,
    required this.selectedTab,
    required this.onSelectTab,
    required this.onOpenAnnouncements,
    required this.onOpenDrive,
    required this.onOpenAdmin,
    required this.onOpenSettings,
  });

  final List<AppTab> tabs;
  final AppTab selectedTab;
  final ValueChanged<AppTab> onSelectTab;
  final VoidCallback onOpenAnnouncements;
  final VoidCallback onOpenDrive;
  final VoidCallback onOpenAdmin;
  final VoidCallback onOpenSettings;

  IconData icon(AppTab tab) => switch (tab) {
    AppTab.home => Icons.home_outlined,
    AppTab.notifications => Icons.notifications_outlined,
    AppTab.explore => Icons.explore_outlined,
    AppTab.chat => Icons.chat_bubble_outline,
    AppTab.profile => Icons.person_outline,
  };

  String label(BuildContext context, AppTab tab) => switch (tab) {
    AppTab.home => context.l10n.home,
    AppTab.notifications => context.l10n.notifications,
    AppTab.explore => context.l10n.discover,
    AppTab.chat => context.l10n.chat,
    AppTab.profile => context.l10n.profile,
  };
}

/// Narrow-screen drawer: account switcher, then every tab in bottom-bar order
/// (including the ones the bottom bar hides) and the feature entries. Every
/// action closes the drawer before acting on the shell.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({required this.entries, super.key});

  final AppNavEntries entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void closeThen(VoidCallback action) {
      Navigator.of(context).pop();
      action();
    }

    final nav = AppNavEntries(
      tabs: entries.tabs,
      selectedTab: entries.selectedTab,
      onSelectTab: (tab) => closeThen(() => entries.onSelectTab(tab)),
      onOpenAnnouncements: () => closeThen(entries.onOpenAnnouncements),
      onOpenDrive: () => closeThen(entries.onOpenDrive),
      onOpenAdmin: () => closeThen(entries.onOpenAdmin),
      onOpenSettings: () => closeThen(entries.onOpenSettings),
    );
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            AccountHeader(
              onNavigate: (tab) => closeThen(() => entries.onSelectTab(tab)),
            ),
            const Divider(height: 16),
            NavEntryList(entries: nav),
          ],
        ),
      ),
    );
  }
}

/// Desktop sidebar. Collapsed it keeps the same entries as compact icons, so
/// every destination stays reachable in both states.
class AppSidebar extends ConsumerWidget {
  const AppSidebar({
    required this.entries,
    required this.collapsed,
    required this.onToggleCollapse,
    super.key,
  });

  final AppNavEntries entries;
  final bool collapsed;
  final VoidCallback onToggleCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final showMeAtTop = ref.watch(
      settingsControllerProvider.select((s) => s.showMeAtTop),
    );
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SafeArea(
        right: false,
        // One tree for both states: only the labels and the header swap, and
        // both cross-fade with the width so collapsing reads as one motion
        // instead of a subtree replacement.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Expanded: the account or brand block; collapsed: the expand
            // chevron. Both fade over the width change; the outgoing header is
            // removed immediately instead of lingering in a too-narrow pane,
            // so it never lays out below its minimum width.
            AnimatedSwitcher(
              duration: appSidebarAnimationDuration,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (current, previous) => current ?? previous.first,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: collapsed
                  ? IconButton(
                      key: const ValueKey('collapsed-header'),
                      tooltip: context.l10n.expand,
                      onPressed: onToggleCollapse,
                      icon: const Icon(Icons.chevron_right),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('expanded-header'),
                      child: showMeAtTop
                          ? AccountHeader(onNavigate: entries.onSelectTab)
                          : const SidebarBrandHeader(),
                    ),
            ),
            Expanded(
              child: NavEntryList(entries: entries, collapsed: collapsed),
            ),
            // One footer for both states: the same settings tile and toggle,
            // with the tile's label collapsing and the chevron flipping. No
            // subtree swap means no outgoing row has to lay out in a width it
            // was never sized for.
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: NavTile(
                      icon: Icons.settings_outlined,
                      label: context.l10n.settings,
                      collapsed: collapsed,
                      onTap: entries.onOpenSettings,
                    ),
                  ),
                  if (!collapsed)
                    IconButton(
                      tooltip: context.l10n.collapse,
                      onPressed: onToggleCollapse,
                      icon: const Icon(Icons.chevron_left),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tabs, then the feature entries. The admin row is gated here, once, by the
/// server-reported moderator role.
class NavEntryList extends ConsumerWidget {
  const NavEntryList({
    required this.entries,
    this.collapsed = false,
    super.key,
  });

  final AppNavEntries entries;
  final bool collapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canModerate = ref.watch(canModerateProvider).value ?? false;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final tab in entries.tabs)
            NavTile(
              icon: entries.icon(tab),
              label: entries.label(context, tab),
              selected: tab == entries.selectedTab,
              collapsed: collapsed,
              onTap: () => entries.onSelectTab(tab),
            ),
          const Divider(height: 16),
          NavTile(
            icon: Icons.campaign_outlined,
            label: context.l10n.announcements,
            collapsed: collapsed,
            onTap: entries.onOpenAnnouncements,
          ),
          NavTile(
            icon: Icons.cloud_outlined,
            label: context.l10n.drive,
            collapsed: collapsed,
            onTap: entries.onOpenDrive,
          ),
          if (canModerate)
            NavTile(
              icon: Icons.shield_outlined,
              label: context.l10n.adminHome,
              collapsed: collapsed,
              onTap: entries.onOpenAdmin,
            ),
        ],
      ),
    );
  }
}

class NavTile extends StatelessWidget {
  const NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.collapsed = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: selected
            ? theme.colorScheme.secondaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: ClipRect(
              child: Row(
                children: [
                  Icon(icon, size: 22, color: foreground),
                  // Expanded takes whatever is left — zero while collapsed — so
                  // the row adapts to every intermediate width the collapse
                  // animation passes through. The label fades and loses its
                  // inset on the same curve, which reads as one slide.
                  Expanded(
                    child: ClipRect(
                      child: AnimatedOpacity(
                        duration: appSidebarAnimationDuration,
                        curve: appSidebarAnimationCurve,
                        opacity: collapsed ? 0 : 1,
                        child: AnimatedPadding(
                          duration: appSidebarAnimationDuration,
                          curve: appSidebarAnimationCurve,
                          padding: EdgeInsets.only(left: collapsed ? 0 : 12),
                          child: Text(
                            label,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.clip,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: selected
                                  ? theme.colorScheme.onSecondaryContainer
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sidebar brand block: logo + app name, with the instance's display name
/// (falling back to the host) muted underneath.
class SidebarBrandHeader extends ConsumerWidget {
  const SidebarBrandHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final instance = ref.watch(instanceInfoProvider).value;
    final host = ref.watch(activeAccountProvider)?.host;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/brand/app_icon_full.png',
              width: 28,
              height: 28,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.appTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  instance?.name ?? host ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Active account row plus the multi-account switcher. Tapping the row opens
/// the profile tab; the chevron expands the account list.
class AccountHeader extends ConsumerStatefulWidget {
  const AccountHeader({required this.onNavigate, super.key});

  final ValueChanged<AppTab> onNavigate;

  @override
  ConsumerState<AccountHeader> createState() => _AccountHeaderState();
}

class _AccountHeaderState extends ConsumerState<AccountHeader> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(sessionControllerProvider);
    final active = session.active;
    final canSwitch = session.accounts.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: active == null
              ? null
              : () => widget.onNavigate(AppTab.profile),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                NyachiAvatar(
                  url: active?.avatarUrl,
                  size: 36,
                  showStatus: true,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        active?.displayName ??
                            active?.username ??
                            context.l10n.noAccounts,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (active != null)
                        Text(
                          '@${active.username}@${active.host}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (canSwitch)
                  IconButton(
                    tooltip: context.l10n.accounts,
                    onPressed: () => setState(() => _expanded = !_expanded),
                    icon: Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          for (final account in session.accounts)
            ListTile(
              dense: true,
              leading: NyachiAvatar(
                url: account.avatarUrl,
                size: 28,
                fallback: Text(account.username.characters.first),
              ),
              title: Text(
                account.displayName ?? account.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('@${account.username}@${account.host}'),
              trailing: account.id == session.active?.id
                  ? Icon(
                      Icons.check_circle,
                      size: 18,
                      color: theme.colorScheme.primary,
                    )
                  : null,
              onTap: account.id == session.active?.id
                  ? null
                  : () => _switch(context, ref, account),
              onLongPress: () => _remove(context, ref, account),
            ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.person_add_alt),
            title: Text(context.l10n.addAccount),
            onTap: () => openDetail(context, const AddAccountLocation()),
          ),
        ],
        const Divider(height: 1),
      ],
    );
  }
}

Future<void> _switch(
  BuildContext context,
  WidgetRef ref,
  LocalAccount account,
) async {
  try {
    await ref
        .read(sessionControllerProvider.notifier)
        .switchAccount(account.id);
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      GoRouter.of(context).go('/home');
    }
  } on SessionExpiredException {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.sessionExpired)));
    }
  }
}

Future<void> _remove(
  BuildContext context,
  WidgetRef ref,
  LocalAccount account,
) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.removeAccount),
      content: Text(l10n.removeAccountConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.remove),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await ref.read(sessionControllerProvider.notifier).removeAccount(account.id);
  if (!context.mounted) return;
  final active = ref.read(sessionControllerProvider).active;
  GoRouter.of(context).go(active == null ? '/login' : '/home');
}
