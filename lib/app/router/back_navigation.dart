// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/application/app_settings.dart';
import '../../features/shell/application/shell_navigation.dart';
import '../detail_panel/detail_panel_controller.dart';
import '../detail_panel/detail_panel_coordinator.dart';

/// Whether back has app state left to unwind at [currentIndex].
///
/// Pages, dialogs and sheets are popped by go_router and the navigator on their
/// own; what is left is the wide-layout detail panel and the selected tab, which
/// are state rather than routes. The tab index is passed in because the shell
/// holds it, so callers stay reactive to branch changes.
///
/// The panel coordinator is published by the shell through a provider because
/// back handling lives above the widget that owns the panel scope.
bool hasStateToUnwind(
  ProviderContainer container, {
  required int currentIndex,
}) {
  if (container.read(detailPanelControllerProvider).isOpen) {
    return container.read(detailPanelCoordinatorProvider).value != null;
  }
  return currentIndex != AppTab.home.index;
}

/// Unwinds one layer: the detail panel first, then the selected tab.
///
/// Returns true when a layer was unwound.
bool unwindAppState(ProviderContainer container, {required int currentIndex}) {
  if (container.read(detailPanelControllerProvider).isOpen) {
    final coordinator = container.read(detailPanelCoordinatorProvider).value;
    if (coordinator != null) {
      coordinator.popFromPanel();
      return true;
    }
  }
  if (currentIndex != AppTab.home.index) {
    final shell = container.read(shellNavigationProvider).value;
    if (shell != null) {
      shell.goBranch(AppTab.home.index);
      return true;
    }
  }
  return false;
}
