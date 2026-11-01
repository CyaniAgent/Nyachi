// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/ui/scroll_edge_loader.dart';

void main() {
  Widget app({
    required int items,
    required int loads,
    required List<int> calls,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ScrollEdgeLoader(
          canLoad: () => calls.length < loads,
          onEdge: () async {
            calls.add(calls.length);
            await Future<void>.delayed(const Duration(milliseconds: 10));
          },
          child: ListView.builder(
            itemCount: items,
            itemBuilder: (context, index) =>
                SizedBox(height: 200, child: Text('item $index')),
          ),
        ),
      ),
    );
  }

  testWidgets('scrolling near the edge triggers one load', (tester) async {
    final calls = <int>[];
    await tester.pumpWidget(app(items: 10, loads: 1, calls: calls));
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(calls, hasLength(1));
  });

  testWidgets('the gate stops further loads', (tester) async {
    final calls = <int>[];
    await tester.pumpWidget(app(items: 10, loads: 1, calls: calls));
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(calls, hasLength(1));
  });

  testWidgets('a scroll far from the edge does not trigger', (tester) async {
    final calls = <int>[];
    await tester.pumpWidget(app(items: 40, loads: 1, calls: calls));
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(calls, isEmpty);
  });
}
