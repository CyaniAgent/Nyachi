// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/composer/presentation/compose_sheet.dart';
import '../../features/settings/application/app_settings.dart';
import 'detail_location.dart';
import 'detail_panel_coordinator.dart';
import 'detail_panel_scope.dart';

/// Opens [location] in the panel when the shell and width allow it.
void openDetail(BuildContext context, DetailLocation location) {
  final router = GoRouter.of(context);
  final coordinator = DetailPanelScope.maybeOf(context);
  if (coordinator == null) {
    router.push(location.location);
    return;
  }
  final breakpoint = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(settingsControllerProvider).detailBreakpoint;
  final path = router.routerDelegate.currentConfiguration.uri.path;
  final compose = location is ComposeDetailLocation ? location : null;
  if (compose != null) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < breakpoint) {
      unawaited(showComposeSheet(context, replyId: compose.replyId));
    } else {
      unawaited(showComposeDialog(context, replyId: compose.replyId));
    }
    return;
  }
  if (MediaQuery.sizeOf(context).width < breakpoint || !isTabRootPath(path)) {
    router.push(location.location);
    return;
  }
  switch (DetailPanelOriginScope.maybeOf(context)) {
    case DetailPanelOrigin.panel:
      coordinator.pushFromPanel(location);
    case DetailPanelOrigin.feed:
      coordinator.openFromFeed(location);
  }
}
