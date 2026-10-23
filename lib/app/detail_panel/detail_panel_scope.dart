// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';

import 'detail_panel_coordinator.dart';

class DetailPanelScope extends InheritedWidget {
  const DetailPanelScope({
    required this.coordinator,
    required super.child,
    super.key,
  });

  final DetailPanelCoordinator coordinator;

  static DetailPanelCoordinator? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DetailPanelScope>()
        ?.coordinator;
  }

  @override
  bool updateShouldNotify(DetailPanelScope oldWidget) =>
      coordinator != oldWidget.coordinator;
}

enum DetailPanelOrigin { feed, panel }

class DetailPanelOriginScope extends InheritedWidget {
  const DetailPanelOriginScope({
    required this.origin,
    required super.child,
    super.key,
  });

  final DetailPanelOrigin origin;

  static DetailPanelOrigin maybeOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<DetailPanelOriginScope>()
            ?.origin ??
        DetailPanelOrigin.feed;
  }

  @override
  bool updateShouldNotify(DetailPanelOriginScope oldWidget) =>
      origin != oldWidget.origin;
}
