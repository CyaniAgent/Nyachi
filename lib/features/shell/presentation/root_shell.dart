// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/detail_panel_coordinator.dart';
import '../../../app/detail_panel/detail_panel_host.dart';
import '../../../app/detail_panel/detail_panel_scope.dart';
import '../../../app/router/navigator_keys.dart';
import '../../../app/router/router_guards.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../settings/application/app_settings.dart';
import '../application/shell_navigation.dart';

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
    _coordinator ??= DetailPanelCoordinator(
      container: ProviderScope.containerOf(context, listen: false),
      router: GoRouter.of(context),
      initialUri: widget.uri,
    );
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
    final config = ref.watch(settingsControllerProvider).navConfig;
    final breakpoint = ref.watch(settingsControllerProvider).detailBreakpoint;
    final width = MediaQuery.sizeOf(context).width;
    _ensureCoordinator();
    _queueSync();
    final coordinator = _coordinator;
    return ValueListenableBuilder<StatefulNavigationShell?>(
      valueListenable: notifier,
      builder: (context, shell, _) {
        final currentIndex = shell?.currentIndex ?? AppTab.home.index;
        final current = AppTab.values[currentIndex];
        if (shell != null && shouldFallbackToHome(config, current)) {
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
        return DetailPanelScope(
          coordinator: coordinator,
          child: ShellChrome(
            selectedIndex: _selectedVisibleIndex(config, current),
            onDestinationSelected: (tab) => _select(shell, tab),
            onSettings: () {
              if (isTabRootPath(widget.uri.path) && width >= breakpoint) {
                coordinator.openFromFeed(const SettingsDetailLocation());
              } else {
                GoRouter.of(context).push('/settings');
              }
            },
            child: content,
          ),
        );
      },
    );
  }

  int _selectedVisibleIndex(NavConfig config, AppTab current) {
    final visible = config.order
        .where(config.visible.contains)
        .toList(growable: false);
    final index = visible.indexOf(current);
    return index < 0 ? 0 : index;
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

/// Sidebar/bottom-navigation chrome shared by [RootShell] and widget tests.
class ShellChrome extends ConsumerWidget {
  const ShellChrome({
    required this.child,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onSettings,
    super.key,
  });

  final Widget child;
  final int selectedIndex;
  final ValueChanged<AppTab> onDestinationSelected;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(settingsControllerProvider).navConfig;
    final visible = config.order
        .where(config.visible.contains)
        .toList(growable: false);
    final destinations = visible
        .map(
          (tab) => _Destination(icon: _icon(tab), label: _label(context, tab)),
        )
        .toList(growable: false);
    final width = MediaQuery.sizeOf(context).width;

    if (width < 840) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex.clamp(0, visible.length - 1),
          onDestinationSelected: (index) {
            onDestinationSelected(visible[index]);
          },
          destinations: [
            for (final destination in destinations)
              NavigationDestination(
                icon: Icon(destination.icon),
                label: destination.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _AppNavigationRail(
            extended: width >= 1200,
            destinations: destinations,
            visible: visible,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            onSettings: onSettings,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

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
    AppTab.explore => context.l10n.explore,
    AppTab.chat => context.l10n.chat,
    AppTab.profile => context.l10n.profile,
  };
}

class _AppNavigationRail extends StatelessWidget {
  const _AppNavigationRail({
    required this.extended,
    required this.destinations,
    required this.visible,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onSettings,
  });

  final bool extended;
  final List<_Destination> destinations;
  final List<AppTab> visible;
  final int selectedIndex;
  final ValueChanged<AppTab> onDestinationSelected;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('app-navigation-rail'),
      width: extended ? appSidebarWidth : appNavRailWidth,
      child: Column(
        children: [
          Expanded(
            child: NavigationRail(
              key: ValueKey<bool>(extended),
              selectedIndex: selectedIndex.clamp(0, destinations.length - 1),
              onDestinationSelected: (index) {
                onDestinationSelected(visible[index]);
              },
              extended: extended,
              labelType: NavigationRailLabelType.none,
              groupAlignment: -0.86,
              minWidth: appNavRailWidth,
              minExtendedWidth: appSidebarWidth,
              destinations: [
                for (final destination in destinations)
                  NavigationRailDestination(
                    icon: Tooltip(
                      message: destination.label,
                      child: Icon(destination.icon),
                    ),
                    label: Text(destination.label),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 4),
            child: IconButton(
              tooltip: context.l10n.settings,
              onPressed: onSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
