import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nyachi/src/core/navigation/navigation.dart';
import 'package:nyachi/src/core/navigation/navigation_element.dart';
import 'root_navigation_drawer.dart';

class ResponsiveShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ResponsiveShell({required this.navigationShell, super.key});

  @override
  ConsumerState<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends ConsumerState<ResponsiveShell> {
  bool _isTransitioning = false;
  Timer? _transitionTimer;

  @override
  void dispose() {
    _transitionTimer?.cancel();
    super.dispose();
  }

  void _onRootSelected(int index, dynamic navigationSettings) {
    setState(() => _isTransitioning = true);
    _transitionTimer?.cancel();
    _transitionTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isTransitioning = false);
    });

    int branchIndex = NavigationService.mapDisplayIndexToBranchIndex(
      index,
      navigationSettings,
    );
    widget.navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationSettingsAsync = ref.watch(navigationSettingsProvider);

    return navigationSettingsAsync.when(
      loading: () => const Scaffold(body: SizedBox.shrink()),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
      data: (navigationSettings) {
        final rootItemElements = navigationSettings.elements
            .where(
              (element) =>
                  element.type == NavigationElementType.item &&
                  element is NavigationItemElement &&
                  element.item.isEnabled &&
                  element.item.id != 'me',
            )
            .cast<NavigationItemElement>()
            .toList();

        final rootItems = rootItemElements.map((e) => e.item).toList();

        if (rootItems.isEmpty) {
          return Scaffold(
            body: Center(child: Text('navigation_no_items'.tr())),
          );
        }

        int selectedRootIndex = NavigationService.mapBranchIndexToDisplayIndex(
          widget.navigationShell.currentIndex,
          navigationSettings,
        );

        final bool isMeSelected =
            widget.navigationShell.currentIndex ==
            NavigationService.getBranchIndexForItem('me');

        if (isMeSelected || selectedRootIndex >= rootItems.length) {
          selectedRootIndex = -1;
        }

        return Scaffold(
          key: rootScaffoldKey,
          drawer: RootNavigationDrawer(
            selectedRootIndex: selectedRootIndex,
            onRootSelected: (index) =>
                _onRootSelected(index, navigationSettings),
          ),
          body: ExcludeSemantics(
            excluding: _isTransitioning,
            child: widget.navigationShell,
          ),
        );
      },
    );
  }
}
