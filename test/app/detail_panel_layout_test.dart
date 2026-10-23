// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/app/detail_panel/resizable_detail_panel.dart';

void main() {
  testWidgets('shows the feed and resizes the panel', (tester) async {
    tester.view.physicalSize = const Size(1300, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var width = 480.0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ResizableDetailPanel(
                panel: const Center(child: Text('panel')),
                open: true,
                width: width,
                minWidth: 360,
                maxWidth: 900,
                onWidthChanged: (value) => setState(() => width = value),
                onWidthChangeEnd: (_) {},
                onResetWidth: () => setState(() => width = 480),
                onClosed: () {},
                child: const Center(child: Text('feed')),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('feed'), findsOneWidget);
    expect(find.text('panel'), findsOneWidget);

    await tester.drag(find.byKey(detailPanelHandleKey), const Offset(-40, 0));
    await tester.pumpAndSettle();
    expect(width, greaterThan(480));

    await tester.tap(find.byKey(detailPanelHandleKey));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(detailPanelHandleKey));
    await tester.pumpAndSettle();
    expect(width, 480);
  });

  testWidgets('does not open when the panel cannot fit', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResizableDetailPanel(
            panel: Center(child: Text('panel')),
            open: true,
            width: 480,
            minWidth: 360,
            maxWidth: 300,
            onWidthChanged: _ignore,
            onWidthChangeEnd: _ignore,
            onResetWidth: _ignoreVoid,
            onClosed: _ignoreVoid,
            child: Center(child: Text('feed')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('feed'), findsOneWidget);
    expect(find.text('panel'), findsNothing);
  });
}

void _ignore(double _) {}
void _ignoreVoid() {}
