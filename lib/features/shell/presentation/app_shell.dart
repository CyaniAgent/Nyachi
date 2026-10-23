// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/router_guards.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../settings/application/app_settings.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.navigationShell, this.children, super.key});

  final StatefulNavigationShell navigationShell;
  final List<Widget>? children;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watch(settingsControllerProvider).navConfig;
    final visible = config.order
        .where(config.visible.contains)
        .toList(growable: false);
    final current = AppTab.values[widget.navigationShell.currentIndex];
    if (shouldFallbackToHome(config, current)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.navigationShell.goBranch(AppTab.home.index);
      });
    }
    final width = MediaQuery.sizeOf(context).width;
    final body = widget.children == null
        ? widget.navigationShell
        : _AnimatedBranchContainer(
            currentIndex: widget.navigationShell.currentIndex,
            children: widget.children!,
          );
    final destinations = visible
        .map(
          (tab) => _Destination(
            tab: tab,
            icon: _icon(tab),
            label: _label(context, tab),
          ),
        )
        .toList(growable: false);

    if (width < 840) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: visible.indexOf(current).clamp(0, visible.length - 1),
          onDestinationSelected: (index) {
            widget.navigationShell.goBranch(visible[index].index);
          },
          destinations: destinations
              .map(
                (destination) => NavigationDestination(
                  icon: Icon(destination.icon),
                  label: destination.label,
                ),
              )
              .toList(growable: false),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: visible
                .indexOf(current)
                .clamp(0, visible.length - 1),
            onDestinationSelected: (index) {
              widget.navigationShell.goBranch(visible[index].index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: destinations
                .map(
                  (destination) => NavigationRailDestination(
                    icon: Icon(destination.icon),
                    label: Text(destination.label),
                  ),
                )
                .toList(growable: false),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
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

class _AnimatedBranchContainer extends StatelessWidget {
  const _AnimatedBranchContainer({
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var index = 0; index < children.length; index++)
          IgnorePointer(
            ignoring: index != currentIndex,
            child: TickerMode(
              enabled: index == currentIndex,
              child: AnimatedOpacity(
                opacity: index == currentIndex ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: AnimatedSlide(
                  offset: index == currentIndex
                      ? Offset.zero
                      : const Offset(0.015, 0),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: children[index],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Destination {
  const _Destination({
    required this.tab,
    required this.icon,
    required this.label,
  });

  final AppTab tab;
  final IconData icon;
  final String label;
}
