// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/detail_panel_controller.dart';
import '../../../app/detail_panel/detail_panel_coordinator.dart';
import '../../../app/detail_panel/detail_panel_host.dart';
import '../../../app/detail_panel/detail_panel_scope.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../app/router/back_navigation.dart';
import '../../../app/router/navigator_keys.dart';
import '../../../app/router/router_guards.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../admin/data/admin_repository.dart';
import '../../notifications/application/realtime_providers.dart';
import '../../settings/application/app_settings.dart';
import '../application/shell_navigation.dart';
import 'app_sidebar.dart';

/// Persistent navigation chrome above the authenticated shell navigator.
class RootShell extends ConsumerStatefulWidget {
  const RootShell({required this.uri, required this.child, super.key});

  final Uri uri;
  final Widget child;

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  DetailPanelCoordinator? _coordinator;
  ValueNotifier<DetailPanelCoordinator?>? _coordinatorNotifier;
  Uri? _syncedUri;

  double? _syncedWidth;
  int? _syncedBreakpoint;
  var _syncScheduled = false;
  bool? _snapInitialOpen;
  Uri? _pendingUri;
  double? _pendingWidth;
  int? _pendingBreakpoint;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureCoordinator();
    _snapInitialOpen ??= _initialUriOpensPanel();
    _queueSync();
  }

  @override
  void didUpdateWidget(covariant RootShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureCoordinator();
    if (oldWidget.uri != widget.uri) _queueSync();
  }

  void _ensureCoordinator() {
    if (_coordinator != null) return;
    final coordinator = DetailPanelCoordinator(
      container: ProviderScope.containerOf(context, listen: false),
      router: GoRouter.of(context),
      initialUri: widget.uri,
    );
    _coordinator = coordinator;
    final notifier = ref.read(detailPanelCoordinatorProvider);
    _coordinatorNotifier = notifier;
    notifier.value = coordinator;
  }

  @override
  void dispose() {
    // Back handling must not reach a coordinator whose shell is gone. `ref` is
    // unsafe here, so the notifier captured at creation is used instead.
    final notifier = _coordinatorNotifier;
    if (notifier != null && identical(notifier.value, _coordinator)) {
      notifier.value = null;
    }
    super.dispose();
  }

  bool _initialUriOpensPanel() {
    if (!isTabRootPath(widget.uri.path)) return false;
    final raw = widget.uri.queryParameters['detail'];
    if (raw == null) return false;
    if (DetailLocation.parse(raw) == null) return false;
    final width = MediaQuery.sizeOf(context).width;
    final breakpoint = ref.read(settingsControllerProvider).detailBreakpoint;
    return width >= breakpoint;
  }

  void _queueSync() {
    if (!mounted) return;
    final width = MediaQuery.sizeOf(context).width;
    final breakpoint = ref.read(settingsControllerProvider).detailBreakpoint;
    if (_syncedUri == widget.uri &&
        _syncedWidth == width &&
        _syncedBreakpoint == breakpoint) {
      return;
    }
    _pendingUri = widget.uri;
    _pendingWidth = width;
    _pendingBreakpoint = breakpoint;
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) return;
      final coordinator = _coordinator;
      final uri = _pendingUri;
      final pendingWidth = _pendingWidth;
      final pendingBreakpoint = _pendingBreakpoint;
      if (coordinator == null ||
          uri == null ||
          pendingWidth == null ||
          pendingBreakpoint == null) {
        return;
      }
      _syncedUri = uri;
      _syncedWidth = pendingWidth;
      _syncedBreakpoint = pendingBreakpoint;
      coordinator.syncFromUri(
        uri,
        width: pendingWidth,
        breakpoint: pendingBreakpoint,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(shellNavigationProvider);
    final settings = ref.watch(settingsControllerProvider);
    final breakpoint = settings.detailBreakpoint;
    final width = MediaQuery.sizeOf(context).width;
    // The back handler reads the panel stack, so the shell has to rebuild when
    // it opens or closes; otherwise the system back button keeps a stale
    // `canPop` and refuses to unwind the panel.
    ref.watch(detailPanelControllerProvider);
    // Holds the app's single realtime socket open: notifications and chat
    // channels arrive wherever the user is, not only on their own tabs.
    ref.watch(realtimeServiceProvider);
    _ensureCoordinator();
    _queueSync();
    final coordinator = _coordinator;
    return ValueListenableBuilder<StatefulNavigationShell?>(
      valueListenable: notifier,
      builder: (context, shell, _) {
        final currentIndex = shell?.currentIndex ?? AppTab.home.index;
        final current = AppTab.values[currentIndex];
        final wide = width >= kCompactBreakpoint;
        final fallbackConfig = wide
            ? settings.sidebarNavConfig
            : settings.navConfig;
        if (shell != null && shouldFallbackToHome(fallbackConfig, current)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            shell.goBranch(AppTab.home.index);
          });
        }
        final content = DetailPanelHost(
          coordinator: coordinator!,
          path: widget.uri.path,
          breakpoint: breakpoint,
          snapInitialOpen: _snapInitialOpen ?? false,
          child: widget.child,
        );
        final container = ProviderScope.containerOf(context, listen: false);
        return DetailPanelScope(
          coordinator: coordinator,
          child: PopScope(
            // Platform back must unwind panel and tab state before it may
            // leave the app; with nothing left it keeps the platform's own
            // behaviour, so back at a tab root still exits.
            canPop: !hasStateToUnwind(container, currentIndex: currentIndex),
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              unwindAppState(container, currentIndex: currentIndex);
            },
            child: ShellChrome(
              selectedTab: current,
              onSelectTab: (tab) => _select(shell, tab),
              child: content,
            ),
          ),
        );
      },
    );
  }

  void _select(StatefulNavigationShell? shell, AppTab tab) {
    _coordinator?.closeFromPanel();
    appShellNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    if (shell == null) {
      GoRouter.of(context).go(_tabLocation(tab));
      return;
    }
    shell.goBranch(tab.index);
  }

  String _tabLocation(AppTab tab) => switch (tab) {
    AppTab.home => '/home',
    AppTab.notifications => '/notifications',
    AppTab.explore => '/explore',
    AppTab.chat => '/chat',
    AppTab.profile => '/profile',
  };
}

/// Tabs rendered in the shell chrome for the given mode.
List<AppTab> shellVisibleTabs(NavConfig config) =>
    config.order.where(config.visible.contains).toList(growable: false);

/// Sidebar/bottom-navigation chrome shared by [RootShell] and widget tests.
class ShellChrome extends ConsumerStatefulWidget {
  const ShellChrome({
    required this.child,
    required this.selectedTab,
    required this.onSelectTab,
    super.key,
  });

  final Widget child;
  final AppTab selectedTab;
  final ValueChanged<AppTab> onSelectTab;

  @override
  ConsumerState<ShellChrome> createState() => _ShellChromeState();
}

class _ShellChromeState extends ConsumerState<ShellChrome> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Whether the wide rail shows its destination labels. The rail's own
  /// toggle button flips this.
  var _railExtended = true;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= kCompactBreakpoint;
    final child = widget.child;
    if (!wide) {
      return AppDrawerScope(
        openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        child: Scaffold(
          key: _scaffoldKey,
          body: child,
          // The drawer lists every tab in bottom-bar order: it is where the
          // tabs hidden from the bottom bar stay reachable.
          drawer: AppDrawer(
            entries: _entries(
              settings,
              widget.selectedTab,
              config: settings.navConfig,
              allTabs: true,
            ),
          ),
          bottomNavigationBar: _BottomBar(
            config: settings.navConfig,
            selectedTab: widget.selectedTab,
            onSelectTab: widget.onSelectTab,
          ),
          floatingActionButton: _ComposeFab(
            visibleTab: widget.selectedTab,
            covered: ref.watch(detailPanelControllerProvider).isOpen,
          ),
        ),
      );
    }
    // Wide: an extended rail. Collapsed it is the icon column; expanded it
    // carries the destination labels at the fixed narrow width. The feature
    // entries (announcements, drive, admin, settings) and the account card
    // are pinned at the rail's bottom, so nothing is one tap further away
    // than the other.
    return Scaffold(
      body: Row(
        children: [
          _DesktopRail(
            entries: _entries(settings, widget.selectedTab),
            selectedTab: widget.selectedTab,
            onSelectTab: widget.onSelectTab,
            onCompose: () =>
                openDetail(context, const ComposeDetailLocation(null)),
            extended: _railExtended,
            onToggleExtended: () =>
                setState(() => _railExtended = !_railExtended),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  /// [config] defaults to the sidebar's own tabs. The drawer passes the
  /// bottom config with [allTabs] so the tabs it hides stay one tap away.
  AppNavEntries _entries(
    AppSettings settings,
    AppTab selectedTab, {
    NavConfig? config,
    bool allTabs = false,
  }) {
    final source = config ?? settings.sidebarNavConfig;
    final tabs = allTabs
        ? source.order
        : source.order
              .where(source.visible.contains)
              .where((tab) => !(settings.showMeAtTop && tab == AppTab.profile))
              .toList(growable: false);
    return AppNavEntries(
      tabs: tabs,
      selectedTab: selectedTab,
      onSelectTab: widget.onSelectTab,
      onOpenProfile: () => widget.onSelectTab(AppTab.profile),
      onOpenAnnouncements: () =>
          openDetail(context, const AnnouncementsDetailLocation()),
      onOpenDrive: () => openDetail(context, const DriveDetailLocation()),
      onOpenAdmin: () => openDetail(context, const AdminHomeLocation()),
      onOpenSettings: () => openDetail(context, const SettingsDetailLocation()),
    );
  }
}

/// Wide-screen extended rail. Collapsed it is the icon column the rail
/// widget is designed for; expanded it carries the destination labels at the
/// fixed narrow width. The toggle button carries the two states (hamburger
/// while collapsed, menu-open while expanded). The compose FAB is the same
/// regular circular flat FAB in both states — it never shrinks. Feature
/// entries and the account card stay pinned at the bottom in both states.
class _DesktopRail extends ConsumerWidget {
  const _DesktopRail({
    required this.entries,
    required this.selectedTab,
    required this.onSelectTab,
    required this.onCompose,
    required this.extended,
    required this.onToggleExtended,
  });

  final AppNavEntries entries;
  final AppTab selectedTab;
  final ValueChanged<AppTab> onSelectTab;
  final VoidCallback onCompose;
  final bool extended;
  final VoidCallback onToggleExtended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final account = ref.watch(activeAccountProvider);
    final canModerate = ref.watch(canModerateProvider).value ?? false;
    final selectedIndex = entries.tabs.indexOf(selectedTab);
    Widget destinationIcon(AppTab tab, bool selected) {
      if (tab == AppTab.profile && account != null) {
        return NyachiAvatar(
          url: account.avatarUrl,
          size: 26,
          showStatus: true,
          statusRingColor: theme.colorScheme.surfaceContainerLow,
        );
      }
      return Icon(
        entries.icon(tab),
        size: 24,
        color: selected
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onSurfaceVariant,
      );
    }

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SafeArea(
        right: false,
        child: NavigationRail(
          selectedIndex: selectedIndex == -1 ? null : selectedIndex,
          labelType: NavigationRailLabelType.none,
          extended: extended,
          minExtendedWidth: appRailExtendedWidth,
          // The feature entries and the account card stay pinned at the
          // bottom in both states.
          trailingAtBottom: true,
          groupAlignment: -1,
          backgroundColor: Colors.transparent,
          leading: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The rail's toggle with a style per state: hamburger while
              // collapsed, menu-open while expanded.
              IconButton(
                tooltip: extended ? context.l10n.collapse : context.l10n.expand,
                onPressed: onToggleExtended,
                icon: Icon(extended ? Icons.menu_open : Icons.menu),
              ),
              const SizedBox(height: 12),
              _RailComposeFab(onPressed: onCompose),
            ],
          ),
          destinations: [
            for (final tab in entries.tabs)
              NavigationRailDestination(
                icon: destinationIcon(tab, false),
                selectedIcon: destinationIcon(tab, true),
                label: Text(entries.label(context, tab)),
              ),
          ],
          onDestinationSelected: (index) => onSelectTab(entries.tabs[index]),
          trailing: _RailTrailing(
            extended: extended,
            canModerate: canModerate,
            entries: entries,
          ),
        ),
      ),
    );
  }
}

/// The rail's trailing slot: feature entries and the account card pinned at
/// the bottom. Lives inside the rail's subtree so it can read the rail's
/// extended animation: the slot passes unbounded width constraints, so the
/// rows inside need the rail's own animated width — this box lerps between
/// the rail's collapsed width (its default 80) and the fixed extended width.
class _RailTrailing extends StatelessWidget {
  const _RailTrailing({
    required this.extended,
    required this.canModerate,
    required this.entries,
  });

  final bool extended;
  final bool canModerate;
  final AppNavEntries entries;

  @override
  Widget build(BuildContext context) {
    final animation = NavigationRail.extendedAnimation(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => SizedBox(
        width: lerpDouble(80, appRailExtendedWidth, animation.value)!,
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RailFeatureEntry(
            extended: extended,
            icon: Icons.campaign_outlined,
            label: context.l10n.announcements,
            tooltip: context.l10n.announcements,
            onTap: entries.onOpenAnnouncements,
          ),
          _RailFeatureEntry(
            extended: extended,
            icon: Icons.cloud_outlined,
            label: context.l10n.drive,
            tooltip: context.l10n.drive,
            onTap: entries.onOpenDrive,
          ),
          if (canModerate)
            _RailFeatureEntry(
              extended: extended,
              icon: Icons.shield_outlined,
              label: context.l10n.adminHome,
              tooltip: context.l10n.adminHome,
              onTap: entries.onOpenAdmin,
            ),
          const Divider(height: 16),
          _RailFeatureEntry(
            extended: extended,
            icon: Icons.settings_outlined,
            label: context.l10n.settings,
            tooltip: context.l10n.settings,
            onTap: entries.onOpenSettings,
          ),
          _RailAccountCard(
            extended: extended,
            onOpenProfile: entries.onOpenProfile,
          ),
        ],
      ),
    );
  }
}

/// One feature entry pinned in the rail's trailing slot. Rail destinations
/// must report a selection and these are not persistent selections, so they
/// live in the trailing slot where taps are free — laid out with the same
/// parts the framework's own extended destination row uses: the icon in its
/// 56 px circular indicator area, the label beside it in the destination
/// label style, and the destination bottom spacing, so the column reads as
/// one list.
class _RailFeatureEntry extends StatelessWidget {
  const _RailFeatureEntry({
    required this.extended,
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final bool extended;
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The destination icon sits in a 56 px circular indicator area; its
    // label uses the theme's bodyLarge like the rail's own labels.
    final iconPart = SizedBox(
      width: 56,
      height: 56,
      child: Icon(icon, size: 24, color: theme.colorScheme.onSurfaceVariant),
    );
    final label = Text(
      this.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: extended
                ? Row(
                    children: [
                      iconPart,
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: label,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  )
                : Center(child: iconPart),
          ),
        ),
      ),
    );
  }
}

/// The leading compose button: the same regular circular flat FAB in both
/// rail states — it never shrinks or morphs, so the rail's leading column
/// reads identically collapsed and expanded.
class _RailComposeFab extends StatelessWidget {
  const _RailComposeFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      tooltip: context.l10n.compose,
      onPressed: onPressed,
      elevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      child: const Icon(Icons.edit_outlined),
    );
  }
}

/// The account card pinned at the rail's bottom, the card refined for the
/// sidebar: a rounded, whole-row tap target (avatar + name + handle) when
/// expanded, the avatar alone when collapsed. Tapping anywhere switches to
/// the user's profile tab.
class _RailAccountCard extends ConsumerStatefulWidget {
  const _RailAccountCard({required this.extended, required this.onOpenProfile});

  final bool extended;
  final VoidCallback onOpenProfile;

  @override
  ConsumerState<_RailAccountCard> createState() => _RailAccountCardState();
}

class _RailAccountCardState extends ConsumerState<_RailAccountCard> {
  var _hovering = false;

  /// Below this the card falls back to the avatar alone: the full row needs
  /// room for the avatar, the gap and readable text.
  static const _fullCardMinWidth = 140.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(sessionControllerProvider);
    final account = session.active;
    final l10n = context.l10n;
    final avatar = NyachiAvatar(
      url: account?.avatarUrl,
      size: 36,
      showStatus: true,
    );
    // The bottom padding keeps the card off the very edge of the window in
    // both rail states.
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The rail, and every intermediate width the collapse animation
          // passes through, gets the avatar alone.
          if (!widget.extended || constraints.maxWidth < _fullCardMinWidth) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: Tooltip(
                    message: l10n.profile,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: widget.onOpenProfile,
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: widget.onOpenProfile,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hovering = true),
                  onExit: (_) => setState(() => _hovering = false),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
                                    l10n.noAccounts,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                              // Hovering slides the handle in over the
                              // status line, so the handle is readable
                              // without navigating anywhere.
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                layoutBuilder:
                                    (currentChild, previousChildren) => Stack(
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        ...previousChildren,
                                        ?currentChild,
                                      ],
                                    ),
                                transitionBuilder: (child, animation) {
                                  final incoming =
                                      child.key == ValueKey(_hovering);
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
                                      : l10n.online,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.config,
    required this.selectedTab,
    required this.onSelectTab,
  });

  final NavConfig config;
  final AppTab selectedTab;
  final ValueChanged<AppTab> onSelectTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = shellVisibleTabs(config);
    final account = ref.watch(activeAccountProvider);
    return NavigationBar(
      selectedIndex: visible
          .indexOf(selectedTab)
          .clamp(0, visible.isEmpty ? 0 : visible.length - 1),
      onDestinationSelected: (index) => onSelectTab(visible[index]),
      destinations: [
        for (final tab in visible)
          NavigationDestination(
            icon: tab == AppTab.profile
                ? NyachiAvatar(
                    url: account?.avatarUrl,
                    size: 28,
                    showStatus: true,
                    statusRingColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainer,
                  )
                : Icon(_icon(tab)),
            label: tab == AppTab.profile
                ? context.l10n.me
                : _label(context, tab),
          ),
      ],
    );
  }
}

/// Shell-level compose FAB: shown on the home and profile tabs, and hidden
/// while the detail panel covers the feed side. Hidden means both invisible
/// and untappable — a transparent FAB still swallows taps.
class _ComposeFab extends StatelessWidget {
  const _ComposeFab({required this.visibleTab, required this.covered});

  final AppTab visibleTab;

  /// The wide-screen detail panel is open over the feed area.
  final bool covered;

  @override
  Widget build(BuildContext context) {
    final onTab = visibleTab == AppTab.home || visibleTab == AppTab.profile;
    final visible = onTab && !covered;
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: visible ? Curves.easeOut : Curves.easeIn,
      scale: visible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: FloatingActionButton(
          onPressed: () =>
              openDetail(context, const ComposeDetailLocation(null)),
          child: const Icon(Icons.edit_outlined),
        ),
      ),
    );
  }
}

/// The bottom bar shares the sidebar's icons and labels so a tab reads the
/// same in both presentations.
IconData _icon(AppTab tab) => switch (tab) {
  AppTab.home => Icons.home_outlined,
  AppTab.notifications => Icons.notifications_outlined,
  AppTab.explore => Icons.explore_outlined,
  AppTab.chat => Icons.chat_bubble_outline,
  AppTab.profile => Icons.person_outline,
};

String _label(BuildContext context, AppTab tab) => switch (tab) {
  AppTab.home => context.l10n.home,
  AppTab.notifications => context.l10n.notifications,
  AppTab.explore => context.l10n.discover,
  AppTab.chat => context.l10n.chat,
  AppTab.profile => context.l10n.profile,
};
