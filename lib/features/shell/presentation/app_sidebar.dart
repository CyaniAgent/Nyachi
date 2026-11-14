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
import '../../../core/ui/breakpoints.dart';
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

/// Leading slot for a tab-root AppBar.
///
/// Narrow screens get the drawer hamburger. Wide screens already have the
/// persistent sidebar, so this returns null: a control that cannot open
/// anything would be announced to assistive tech and would still make the
/// AppBar reserve leading space for it.
Widget? appBarDrawerLeading(BuildContext context) {
  if (MediaQuery.sizeOf(context).width >= kCompactBreakpoint) return null;
  return const AppDrawerButton();
}

/// Hamburger for the leading slot of tab-root AppBars. Only built when a
/// drawer actually exists; see [appBarDrawerLeading].
class AppDrawerButton extends StatelessWidget {
  const AppDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Square constraints: a bare IconButton in the leading slot can be
    // stretched wider than tall by the toolbar, and the circular M3
    // highlight renders as an ellipse.
    return IconButton(
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      onPressed: () => AppDrawerScope.open(context),
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.standard,
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
    required this.onOpenProfile,
    required this.onOpenAnnouncements,
    required this.onOpenDrive,
    required this.onOpenAdmin,
    required this.onOpenSettings,
  });

  final List<AppTab> tabs;
  final AppTab selectedTab;
  final ValueChanged<AppTab> onSelectTab;
  final VoidCallback onOpenProfile;
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
      onOpenProfile: () => closeThen(entries.onOpenProfile),
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
            DrawerNavList(entries: nav),
          ],
        ),
      ),
    );
  }
}

/// The drawer's navigation list: the same destinations as the desktop
/// sidebar's expanded menu, rendered as full-width rows for touch.
class DrawerNavList extends StatelessWidget {
  const DrawerNavList({required this.entries, super.key});

  final AppNavEntries entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final tab in entries.tabs)
          NavRow(
            icon: entries.icon(tab),
            label: entries.label(context, tab),
            selected: tab == entries.selectedTab,
            onTap: () => entries.onSelectTab(tab),
          ),
        NavRow(
          icon: Icons.campaign_outlined,
          label: context.l10n.announcements,
          onTap: entries.onOpenAnnouncements,
        ),
        NavRow(
          icon: Icons.cloud_outlined,
          label: context.l10n.drive,
          onTap: entries.onOpenDrive,
        ),
        NavRow(
          icon: Icons.settings_outlined,
          label: context.l10n.settings,
          onTap: entries.onOpenSettings,
        ),
      ],
    );
  }
}

/// Compact icon button for the sidebar footer row, so the account card keeps
/// the rest of the width.
class _FooterIconButton extends StatelessWidget {
  const _FooterIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      icon: Icon(icon, size: 20),
    );
  }
}

/// One full-width navigation row: icon + label with the selected pill.
/// Shared by the drawer and the expanded desktop sidebar.
class NavRow extends StatelessWidget {
  const NavRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = selected
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 22, color: fg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: selected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Desktop sidebar.
///
/// Expanded it is a nav menu: full-width rows like the drawer's, at the
/// width a menu needs. Collapsed to 80 px it becomes a [NavigationRail]:
/// the icon column the rail widget is designed for. Each state uses the
/// widget built for that shape.
class AppSidebar extends ConsumerWidget {
  const AppSidebar({
    required this.entries,
    required this.collapsed,
    required this.showToggle,
    required this.onToggleCollapse,
    super.key,
  });

  final AppNavEntries entries;
  final bool collapsed;

  /// Whether the expand/collapse button is offered at all. Hidden, the pane
  /// stays expanded; `ShellChrome` guarantees that.
  final bool showToggle;
  final VoidCallback onToggleCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final showMeAtTop = ref.watch(
      settingsControllerProvider.select((s) => s.showMeAtTop),
    );
    final canModerate = ref.watch(canModerateProvider).value ?? false;
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SafeArea(
        right: false,
        child: collapsed
            ? _CollapsedSidebar(
                entries: entries,
                canModerate: canModerate,
                showToggle: showToggle,
                onToggleCollapse: onToggleCollapse,
              )
            : _ExpandedSidebar(
                entries: entries,
                canModerate: canModerate,
                showMeAtTop: showMeAtTop,
                showToggle: showToggle,
                onToggleCollapse: onToggleCollapse,
              ),
      ),
    );
  }
}

/// The expanded nav menu: header block, scrollable row list, pinned footer.
class _ExpandedSidebar extends StatelessWidget {
  const _ExpandedSidebar({
    required this.entries,
    required this.canModerate,
    required this.showMeAtTop,
    required this.showToggle,
    required this.onToggleCollapse,
  });

  final AppNavEntries entries;
  final bool canModerate;
  final bool showMeAtTop;
  final bool showToggle;
  final VoidCallback onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          duration: appSidebarAnimationDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (current, previous) => current ?? previous.first,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(
            key: const ValueKey('expanded-header'),
            child: showMeAtTop
                ? AccountHeader(onNavigate: entries.onSelectTab)
                : const SidebarBrandHeader(),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final tab in entries.tabs)
                  NavRow(
                    icon: entries.icon(tab),
                    label: entries.label(context, tab),
                    selected: tab == entries.selectedTab,
                    onTap: () => entries.onSelectTab(tab),
                  ),
                const Divider(height: 16),
                NavRow(
                  icon: Icons.campaign_outlined,
                  label: context.l10n.announcements,
                  onTap: entries.onOpenAnnouncements,
                ),
                NavRow(
                  icon: Icons.cloud_outlined,
                  label: context.l10n.drive,
                  onTap: entries.onOpenDrive,
                ),
                if (canModerate)
                  NavRow(
                    icon: Icons.shield_outlined,
                    label: context.l10n.adminHome,
                    onTap: entries.onOpenAdmin,
                  ),
              ],
            ),
          ),
        ),
        // The pinned footer: the account card with settings and the collapse
        // toggle beside it, all visible without scrolling.
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Every width between 80 and 240 is on screen while the pane
              // tweens. Below this the two buttons would not fit next to the
              // card, and the rail (which owns that range once settled) has
              // its own entries, so the card shrinks to its avatar.
              final showButtons = constraints.maxWidth >= 140;
              return Row(
                children: [
                  Expanded(
                    child: SidebarUserPanel(
                      collapsed: !showButtons,
                      onOpenProfile: entries.onOpenProfile,
                    ),
                  ),
                  if (showButtons) ...[
                    _FooterIconButton(
                      tooltip: context.l10n.settings,
                      icon: Icons.settings_outlined,
                      onPressed: entries.onOpenSettings,
                    ),
                    if (showToggle)
                      _FooterIconButton(
                        tooltip: context.l10n.collapse,
                        icon: Icons.chevron_left,
                        onPressed: onToggleCollapse,
                      ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// The collapsed rail: icon column for the tabs, with the account avatar and
/// the expand toggle pinned in the rail's trailing slot.
class _CollapsedSidebar extends StatelessWidget {
  const _CollapsedSidebar({
    required this.entries,
    required this.canModerate,
    required this.showToggle,
    required this.onToggleCollapse,
  });

  final AppNavEntries entries;
  final bool canModerate;
  final bool showToggle;
  final VoidCallback onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: entries.tabs.indexOf(entries.selectedTab),
      labelType: NavigationRailLabelType.none,
      // Without this the trailing slot follows the destinations instead of
      // sitting at the bottom, so the feature icons and the account would
      // ride up under the tabs.
      trailingAtBottom: true,
      leading: const SidebarBrandMark(),
      groupAlignment: -1,
      destinations: [
        for (final tab in entries.tabs)
          NavigationRailDestination(
            icon: Icon(entries.icon(tab), size: 22),
            selectedIcon: Icon(entries.icon(tab), size: 22),
            label: Text(entries.label(context, tab)),
          ),
      ],
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The feature entries as icon-only rows: rail destinations must
          // report a selection and these are not persistent selections, so
          // they live in the trailing slot where taps are free.
          _RailIconTile(
            icon: Icons.campaign_outlined,
            tooltip: context.l10n.announcements,
            onTap: entries.onOpenAnnouncements,
          ),
          _RailIconTile(
            icon: Icons.cloud_outlined,
            tooltip: context.l10n.drive,
            onTap: entries.onOpenDrive,
          ),
          if (canModerate)
            _RailIconTile(
              icon: Icons.shield_outlined,
              tooltip: context.l10n.adminHome,
              onTap: entries.onOpenAdmin,
            ),
          const Divider(height: 16),
          // Settings sits with the account card, the way the expanded footer
          // puts it beside the card.
          _RailIconTile(
            icon: Icons.settings_outlined,
            tooltip: context.l10n.settings,
            onTap: entries.onOpenSettings,
          ),
          SidebarUserPanel(
            collapsed: true,
            onOpenProfile: entries.onOpenProfile,
          ),
          // Without the toggle the pane never collapses, so there is nothing
          // for this button to bring back.
          if (showToggle)
            IconButton(
              tooltip: context.l10n.expand,
              onPressed: onToggleCollapse,
              icon: const Icon(Icons.chevron_right),
            ),
        ],
      ),
      onDestinationSelected: (index) =>
          entries.onSelectTab(entries.tabs[index]),
    );
  }
}

/// Icon-only tile for the collapsed rail's trailing column: a square tap
/// target with a tooltip, matching the rail's icon look.
class _RailIconTile extends StatelessWidget {
  const _RailIconTile({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The icon is the only content, so the tooltip carries the name for
    // pointers and assistive tech alike.
    return Tooltip(
      message: tooltip,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  icon,
                  size: 22,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Account card pinned to the sidebar's footer: a rounded, whole-row tap
/// target (avatar + name + handle). Collapsed to the rail it is the avatar
/// alone. Tapping anywhere on the row opens the profile.
class SidebarUserPanel extends ConsumerStatefulWidget {
  const SidebarUserPanel({
    required this.collapsed,
    required this.onOpenProfile,
    super.key,
  });

  final bool collapsed;
  final VoidCallback onOpenProfile;

  @override
  ConsumerState<SidebarUserPanel> createState() => _SidebarUserPanelState();
}

class _SidebarUserPanelState extends ConsumerState<SidebarUserPanel> {
  final _menuController = MenuController();
  var _hovering = false;

  /// Below this the card falls back to the avatar alone: the sidebar width
  /// tweens between 80 and 240, and the full row needs room for the avatar,
  /// the gap and readable text — minus the settings and collapse buttons the
  /// footer keeps beside it.
  static const _fullCardMinWidth = 140.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(sessionControllerProvider);
    final account = session.active;
    final canSwitch = session.accounts.length > 1;
    final l10n = context.l10n;
    final avatar = NyachiAvatar(
      url: account?.avatarUrl,
      size: 36,
      showStatus: true,
    );
    // The official menu anchor handles the geometry this card needs: the
    // card sits at the bottom of the window, so the menu flips above it,
    // grows upward, and closes on outside taps.
    return MenuAnchor(
      controller: _menuController,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          theme.colorScheme.surfaceContainer,
        ),
        elevation: const WidgetStatePropertyAll(4),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 6),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(220, 0)),
        maximumSize: const WidgetStatePropertyAll(Size(260, double.infinity)),
      ),
      menuChildren: _accountMenuItems(context, session),
      builder: (context, controller, child) {
        void openMenu() {
          if (account != null) controller.open();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // The rail, and every intermediate width the collapse animation
            // passes through, gets the avatar alone.
            if (widget.collapsed || constraints.maxWidth < _fullCardMinWidth) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: Tooltip(
                      message: canSwitch ? l10n.accounts : l10n.profile,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: openMenu,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: avatar,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return _fullCard(
              context,
              theme,
              account,
              avatar,
              canSwitch,
              openMenu,
            );
          },
        );
      },
    );
  }

  /// The card's menu: every signed-in account to switch to, then the current
  /// account's profile.
  List<Widget> _accountMenuItems(BuildContext context, SessionState session) {
    final theme = Theme.of(context);
    final canSwitch = session.accounts.length > 1;
    return [
      if (canSwitch)
        for (final account in session.accounts)
          MenuItemButton(
            leadingIcon: NyachiAvatar(
              url: account.avatarUrl,
              size: 24,
              fallback: Text(account.username.characters.first),
            ),
            trailingIcon: account.id == session.active?.id
                ? Icon(
                    Icons.check_circle,
                    size: 18,
                    color: theme.colorScheme.primary,
                  )
                : null,
            onPressed: account.id == session.active?.id
                ? null
                : () => _switch(context, ref, account),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  account.displayName ?? account.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '@${account.username}@${account.host}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      MenuItemButton(
        leadingIcon: const Icon(Icons.person_outline, size: 20),
        onPressed: widget.onOpenProfile,
        child: Text(context.l10n.profile),
      ),
    ];
  }

  Widget _fullCard(
    BuildContext context,
    ThemeData theme,
    LocalAccount? account,
    Widget avatar,
    bool canSwitch,
    VoidCallback openMenu,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: account == null ? null : openMenu,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  avatar,
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          account?.displayName ??
                              account?.username ??
                              context.l10n.noAccounts,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                        // Hovering slides the handle in over the status
                        // line, so the handle is readable without opening
                        // anything.
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          layoutBuilder: (currentChild, previousChildren) =>
                              Stack(
                                alignment: Alignment.centerLeft,
                                children: [...previousChildren, ?currentChild],
                              ),
                          transitionBuilder: (child, animation) {
                            final incoming = child.key == ValueKey(_hovering);
                            final position = incoming
                                ? Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(animation)
                                : Tween<Offset>(
                                    begin: const Offset(0, -1),
                                    end: Offset.zero,
                                  ).animate(animation);
                            return ClipRect(
                              child: SlideTransition(
                                position: position,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            _hovering && account != null
                                ? '@${account.username}'
                                : context.l10n.online,
                            key: ValueKey(_hovering),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (canSwitch)
                    Icon(
                      Icons.unfold_more,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
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

/// Brand mark shown in the collapsed rail's leading slot: the app icon
/// alone, so the pane still identifies the app without a label.
class SidebarBrandMark extends StatelessWidget {
  const SidebarBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'assets/brand/app_icon_full.png',
            width: 28,
            height: 28,
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
