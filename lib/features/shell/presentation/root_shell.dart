// SPDX-License-Identifier: AGPL-3.0-or-later

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

  /// Collapsed state of the desktop sidebar for this session. Seeded from the
  /// window width while auto-collapse is on; a manual toggle wins afterwards.
  bool? _collapsedOverride;

  /// True while the sidebar edge is being dragged; disables the width tween so
  /// the pane tracks the pointer exactly instead of lagging behind it.
  var _draggingWidth = false;

  /// The detail-panel open state the sidebar last reconciled against.
  var _panelWasOpen = false;

  /// The sidebar's collapse override as it was when the panel opened,
  /// restored when the panel closes.
  bool? _savedOverride;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= kCompactBreakpoint;
    final child = widget.child;
    // While the detail panel is open the content column is squeezed. By
    // default the sidebar keeps its state and the panel takes the room from
    // the feed; when the user turned the panel-collapse option on, the pane
    // folds for the panel and restores on close. Either way the feed keeps
    // its minimum: when the window is too narrow for both, the panel wins.
    if (wide && settings.sidebarCollapseForPanel) {
      final panelOpen = ref.watch(detailPanelControllerProvider).isOpen;
      if (panelOpen != _panelWasOpen) {
        _panelWasOpen = panelOpen;
        if (panelOpen) {
          _savedOverride = _collapsedOverride;
          _collapsedOverride = true;
        } else {
          _collapsedOverride = _savedOverride;
        }
      }
    }
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
    final autoCollapse =
        settings.sidebarAutoCollapse && width < appSidebarAutoBreakpoint;
    final collapsed = _collapsedOverride ?? autoCollapse;
    final targetWidth = collapsed
        ? appSidebarCollapsedWidth
        : settings.sidebarWidth;
    return Scaffold(
      body: Row(
        children: [
          // Animated so the collapse toggle and the auto switch at the
          // breakpoint read as one motion. During a width drag the target
          // changes every frame, and an animation there would lag the cursor,
          // so the tween is skipped while dragging.
          AnimatedContainer(
            duration: _draggingWidth
                ? Duration.zero
                : appSidebarAnimationDuration,
            curve: appSidebarAnimationCurve,
            width: targetWidth,
            child: AppSidebar(
              entries: _entries(settings, widget.selectedTab),
              collapsed: collapsed,
              onToggleCollapse: () =>
                  setState(() => _collapsedOverride = !collapsed),
            ),
          ),
          if (!collapsed)
            SidebarResizeHandle(
              width: settings.sidebarWidth,
              onDragStateChanged: (dragging) =>
                  setState(() => _draggingWidth = dragging),
              onChanged: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .setSidebarWidthLive(value),
              onCommit: (value) => ref
                  .read(settingsControllerProvider.notifier)
                  .setSidebarWidth(value),
            ),
          Expanded(child: child),
        ],
      ),
      floatingActionButton: _ComposeFab(
        visibleTab: widget.selectedTab,
        covered: ref.watch(detailPanelControllerProvider).isOpen,
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

/// Drag handle between the sidebar and the content column. Deltas accumulate
/// locally and are written once when the gesture ends, so a drag does not
/// touch preferences on every frame.
class SidebarResizeHandle extends StatefulWidget {
  const SidebarResizeHandle({
    required this.width,
    required this.onChanged,
    required this.onCommit,
    required this.onDragStateChanged,
    super.key,
  });

  final double width;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onCommit;

  /// Lets the shell disable its width tween for the duration of the drag.
  final ValueChanged<bool> onDragStateChanged;

  @override
  State<SidebarResizeHandle> createState() => _SidebarResizeHandleState();
}

class _SidebarResizeHandleState extends State<SidebarResizeHandle> {
  double? _dragWidth;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) {
          _dragWidth = widget.width;
          widget.onDragStateChanged(true);
        },
        onHorizontalDragUpdate: (details) {
          final current = _dragWidth;
          if (current == null) return;
          final next = (current + details.delta.dx).clamp(
            appSidebarMinWidth,
            appSidebarMaxWidth,
          );
          _dragWidth = next;
          widget.onChanged(next);
        },
        onHorizontalDragEnd: (_) => _finishDrag(),
        onHorizontalDragCancel: _finishDrag,
        child: SizedBox(
          width: 8,
          height: double.infinity,
          child: Center(
            child: SizedBox(
              width: 1,
              height: double.infinity,
              child: ColoredBox(color: Theme.of(context).dividerColor),
            ),
          ),
        ),
      ),
    );
  }

  void _finishDrag() {
    final value = _dragWidth;
    _dragWidth = null;
    widget.onDragStateChanged(false);
    if (value != null) widget.onCommit(value);
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
