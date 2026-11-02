// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nyachi/core/ui/breakpoints.dart';
import 'package:nyachi/features/shell/presentation/branch_slide_container.dart';

Widget _branchPage(String label) => Scaffold(
  body: Column(
    children: [
      Text(label),
      TextField(key: Key('field-$label')),
    ],
  ),
);

GoRouter _router() => GoRouter(
  initialLocation: '/a',
  routes: [
    StatefulShellRoute(
      navigatorContainerBuilder: (context, navigationShell, children) =>
          BranchSlideContainer(
            navigationShell: navigationShell,
            children: children,
          ),
      builder: (context, state, navigationShell) => navigationShell,
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/a', builder: (_, _) => _branchPage('page-a')),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/b', builder: (_, _) => _branchPage('page-b')),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/c', builder: (_, _) => _branchPage('page-c')),
          ],
        ),
      ],
    ),
  ],
);

Future<void> _pump(
  WidgetTester tester,
  GoRouter router, {
  Size size = const Size(400, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

/// The slide translation applied to the branch showing [label].
FractionalTranslation? _translationOf(WidgetTester tester, String label) {
  final matches = tester.widgetList<FractionalTranslation>(
    find.ancestor(
      of: find.text(label, skipOffstage: false),
      matching: find.byType(FractionalTranslation),
    ),
  );
  return matches.isEmpty ? null : matches.first;
}

void main() {
  testWidgets(
    'branch switch keeps outgoing navigator alive during and after transition',
    (tester) async {
      final router = _router();
      await _pump(tester, router);

      await tester.enterText(find.byType(TextField), 'kept');
      await tester.pump();

      router.go('/b');
      // First pump rebuilds with the new index, second advances the clock.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Mid-transition: outgoing branch must still be in the tree.
      expect(find.text('page-a', skipOffstage: false), findsOneWidget);
      expect(find.text('page-b', skipOffstage: false), findsOneWidget);

      await tester.pumpAndSettle();
      // After the transition both visited branch navigators stay in the tree,
      // with the inactive one offstage (state-preserving).
      expect(find.text('page-a', skipOffstage: false), findsOneWidget);
      expect(find.text('page-b', skipOffstage: false), findsOneWidget);
      final pageAOffstage = tester
          .widgetList<Offstage>(
            find.ancestor(
              of: find.text('page-a', skipOffstage: false),
              matching: find.byType(Offstage),
            ),
          )
          .any((o) => o.offstage);
      expect(pageAOffstage, isTrue, reason: 'inactive branch is offstage');

      router.go('/a');
      await tester.pumpAndSettle();
      expect(find.text('page-a', skipOffstage: false), findsOneWidget);
      // State preserved across the tab switch.
      final editable = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('field-page-a')),
          matching: find.byType(EditableText),
        ),
      );
      expect(editable.controller.text, 'kept');
    },
  );

  testWidgets(
    'horizontal slide: 0 to 1 enters from the right, 1 to 0 from the left',
    (tester) async {
      final router = _router();
      await _pump(tester, router);

      router.go('/b');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 0 -> 1: incoming (page-b) starts on the trailing (right) edge,
      // outgoing (page-a) moves towards the leading (left) edge.
      final outgoing = _translationOf(tester, 'page-a')!.translation;
      final incoming = _translationOf(tester, 'page-b')!.translation;
      expect(outgoing.dx, lessThan(0), reason: 'outgoing slides left');
      expect(incoming.dx, greaterThan(0), reason: 'incoming from right');
      expect(outgoing.dy, 0);
      expect(incoming.dy, 0);

      await tester.pumpAndSettle();
      router.go('/a');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1 -> 0: directions flip.
      final outgoingBack = _translationOf(tester, 'page-b')!.translation;
      final incomingBack = _translationOf(tester, 'page-a')!.translation;
      expect(outgoingBack.dx, greaterThan(0), reason: 'outgoing slides right');
      expect(incomingBack.dx, lessThan(0), reason: 'incoming from left');

      await tester.pumpAndSettle();
    },
  );

  testWidgets('wide surface slides vertically', (tester) async {
    final router = _router();
    await _pump(tester, router, size: Size(kCompactBreakpoint + 100, 800));

    router.go('/b');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final outgoing = _translationOf(tester, 'page-a')!.translation;
    final incoming = _translationOf(tester, 'page-b')!.translation;
    // Index increases on wide (sidebar) screens: enter from the bottom.
    expect(incoming.dy, greaterThan(0), reason: 'vertical slide on wide');
    expect(outgoing.dy, lessThan(0));
    expect(incoming.dx, 0, reason: 'no horizontal movement on wide screens');
    expect(outgoing.dx, 0);

    await tester.pumpAndSettle();
  });

  testWidgets('first build does not animate', (tester) async {
    final router = _router();
    await _pump(tester, router);

    expect(find.byType(FractionalTranslation), findsNothing);
  });
}
