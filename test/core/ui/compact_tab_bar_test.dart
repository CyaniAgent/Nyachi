// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/ui/compact_tab_bar.dart';

void main() {
  testWidgets('renders every home timeline label inside the viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1455, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const labels = ['Home', 'Local', 'Hybrid', 'Global'];
    await tester.pumpWidget(
      const MaterialApp(
        home: DefaultTabController(
          length: 4,
          child: Scaffold(body: CompactTabBar(labels: labels)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in labels) {
      final finder = find.text(label);
      expect(finder, findsOneWidget, reason: label);
      final rect = tester.getRect(finder);
      expect(rect.left, greaterThanOrEqualTo(0), reason: label);
      expect(rect.right, lessThanOrEqualTo(1455), reason: label);
    }
  });
}
