// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nyachi/app/detail_panel/detail_location.dart';
import 'package:nyachi/app/detail_panel/detail_panel_controller.dart';
import 'package:nyachi/app/detail_panel/detail_panel_coordinator.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('panel URL updates replace history and close on tab switch', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        for (final path in [
          '/home',
          '/notifications',
          '/explore',
          '/chat',
          '/profile',
        ])
          GoRoute(
            path: path,
            builder: (_, _) => Scaffold(body: Text(path)),
          ),
        GoRoute(
          path: '/notes/:id',
          builder: (_, _) => const Scaffold(body: Text('note')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    final coordinator = DetailPanelCoordinator(
      container: container,
      router: router,
      initialUri: router.routerDelegate.currentConfiguration.uri,
    );
    DetailPanelState state() => container.read(detailPanelControllerProvider);
    String uri() => router.routerDelegate.currentConfiguration.uri.toString();

    coordinator.openFromFeed(const NoteDetailLocation('n1'));
    await tester.pumpAndSettle();
    expect(uri(), '/home?detail=%2Fnotes%2Fn1');
    expect(state().top, const NoteDetailLocation('n1'));
    expect(router.canPop(), isFalse);

    coordinator.pushFromPanel(const UserDetailLocation('u1'));
    await tester.pumpAndSettle();
    expect(uri(), '/home?detail=%2Fusers%2Fu1');
    expect(state().stack.length, 2);

    coordinator.popFromPanel();
    await tester.pumpAndSettle();
    expect(uri(), '/home?detail=%2Fnotes%2Fn1');
    coordinator.popFromPanel();
    await tester.pumpAndSettle();
    expect(state().isOpen, isFalse);
    expect(uri(), '/home');

    coordinator.openFromFeed(const NoteDetailLocation('n1'));
    coordinator.pushFromPanel(const UserDetailLocation('u1'));
    coordinator.openFromFeed(const TagDetailLocation('tag'));
    await tester.pumpAndSettle();
    expect(state().stack, [const TagDetailLocation('tag')]);

    router.go('/notifications');
    await tester.pumpAndSettle();
    coordinator.syncFromUri(
      router.routerDelegate.currentConfiguration.uri,
      width: 1300,
      breakpoint: 1200,
    );
    expect(state().isOpen, isFalse);

    router.go('/home?detail=%2Flogin');
    await tester.pumpAndSettle();
    coordinator.syncFromUri(
      router.routerDelegate.currentConfiguration.uri,
      width: 1300,
      breakpoint: 1200,
    );
    await tester.pumpAndSettle();
    expect(uri(), '/home');
    expect(state().isOpen, isFalse);
  });

  testWidgets('deep link below breakpoint becomes a full page', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/home?detail=%2Fnotes%2Fn1',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/notes/:id',
          builder: (_, _) => const Scaffold(body: Text('note')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    final coordinator = DetailPanelCoordinator(
      container: container,
      router: router,
      initialUri: router.routerDelegate.currentConfiguration.uri,
    );
    coordinator.syncFromUri(
      router.routerDelegate.currentConfiguration.uri,
      width: 1000,
      breakpoint: 1200,
    );
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/notes/n1',
    );
    expect(container.read(detailPanelControllerProvider).isOpen, isFalse);
    expect(find.text('note'), findsOneWidget);
  });
}
