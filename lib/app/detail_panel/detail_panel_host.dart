// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import 'detail_location.dart';
import 'detail_panel_controller.dart';
import 'detail_panel_coordinator.dart';
import 'detail_panel_scope.dart';
import 'resizable_detail_panel.dart';

class DetailPanelHost extends ConsumerStatefulWidget {
  const DetailPanelHost({
    required this.child,
    required this.coordinator,
    required this.path,
    required this.breakpoint,
    required this.snapInitialOpen,
    super.key,
  });

  final Widget child;
  final DetailPanelCoordinator coordinator;
  final String path;
  final int breakpoint;
  final bool snapInitialOpen;

  @override
  ConsumerState<DetailPanelHost> createState() => _DetailPanelHostState();
}

class _DetailPanelHostState extends ConsumerState<DetailPanelHost> {
  static const _rootKey = ValueKey<String>('detail-panel-root');

  final _navigatorKey = GlobalKey<NavigatorState>();
  var _popPending = false;
  var _fallbackPending = false;
  late bool _snapPending;

  @override
  void initState() {
    super.initState();
    _snapPending = widget.snapInitialOpen;
  }

  ValueKey<String> _pageKey(DetailLocation location, int index) =>
      ValueKey<String>('detail-panel:${location.location}#$index');

  @override
  Widget build(BuildContext context) {
    if (!isTabRootPath(widget.path)) return widget.child;
    final state = ref.watch(detailPanelControllerProvider);
    final windowWidth = MediaQuery.sizeOf(context).width;
    final breakpoint = widget.breakpoint;
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : windowWidth;
        final maxWidth = math.min(
          appDetailPanelMaxWidth,
          available - appFeedMinWidth,
        );
        final canOpen = maxWidth >= appDetailPanelMinWidth;
        final shouldOpen = state.isOpen && windowWidth >= breakpoint && canOpen;
        final snapOpen = _snapPending && state.isOpen;
        if (state.isOpen) _snapPending = false;
        if (state.isOpen && !shouldOpen) {
          _scheduleFallback(state.top);
        }
        final stack = state.stack;
        final panel = stack.isEmpty
            ? null
            : Navigator(
                key: _navigatorKey,
                pages: [
                  const MaterialPage<void>(
                    key: _rootKey,
                    child: SizedBox.shrink(),
                  ),
                  for (var index = 0; index < stack.length; index++)
                    MaterialPage<void>(
                      key: _pageKey(stack[index], index),
                      name: stack[index].location,
                      child: DetailPanelOriginScope(
                        origin: DetailPanelOrigin.panel,
                        child: stack[index].build(context),
                      ),
                    ),
                ],
                onDidRemovePage: _onDidRemovePage,
              );
        return DetailPanelOriginScope(
          origin: DetailPanelOrigin.feed,
          child: ResizableDetailPanel(
            panel: panel,
            open: shouldOpen,
            snapOpen: snapOpen,
            width: state.width,
            minWidth: appDetailPanelMinWidth,
            maxWidth: math.max(appDetailPanelMinWidth, maxWidth),
            onWidthChanged: (width) {
              ref.read(detailPanelControllerProvider.notifier).setWidth(width);
            },
            onWidthChangeEnd: (width) {
              final controller = ref.read(
                detailPanelControllerProvider.notifier,
              );
              controller.setWidth(width);
              unawaited(controller.persistWidth());
            },
            onResetWidth: () {
              final controller = ref.read(
                detailPanelControllerProvider.notifier,
              );
              controller.resetWidth();
              unawaited(controller.persistWidth());
            },
            onClosed: () {},
            child: widget.child,
          ),
        );
      },
    );
  }

  void _scheduleFallback(DetailLocation? top) {
    if (top == null || _fallbackPending) return;
    _fallbackPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fallbackPending = false;
      if (!mounted || !isTabRootPath(widget.path)) return;
      if (MediaQuery.sizeOf(context).width >= widget.breakpoint) return;
      final current = ref.read(detailPanelControllerProvider).top;
      if (current == null) return;
      widget.coordinator.downgradeToFullPage(current);
    });
  }

  void _onDidRemovePage(Page<Object?> page) {
    if (page.key == _rootKey || _popPending) return;
    final state = ref.read(detailPanelControllerProvider);
    final top = state.top;
    if (top == null) return;
    if (page.key != _pageKey(top, state.stack.length - 1)) return;
    _popPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _popPending = false;
      if (!mounted) return;
      final current = ref.read(detailPanelControllerProvider);
      final currentTop = current.top;
      if (currentTop == null) return;
      if (page.key != _pageKey(currentTop, current.stack.length - 1)) return;
      widget.coordinator.popFromPanel();
    });
  }
}
