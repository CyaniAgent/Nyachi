// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nyachi/app/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/shell/presentation/app_shell.dart';
import 'package:nyachi/features/shell/presentation/root_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shell renders configured destination order', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.tabOrder': ['profile', 'home', 'explore', 'chat'],
      'settings.hiddenTabs': ['notifications'],
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShellChrome(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            onSettings: () {},
            onProfile: () {},
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final destinations = tester
        .widgetList<NavigationDestination>(find.byType(NavigationDestination))
        .map((destination) => destination.label)
        .toList(growable: false);
    expect(destinations, ['Profile', 'Home', 'Explore', 'Chat']);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('pushed detail routes keep the navigation rail', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final shellKey = GlobalKey<NavigatorState>();
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          navigatorKey: shellKey,
          builder: (context, state, child) =>
              RootShell(uri: state.uri, child: child),
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) =>
                  AppShell(navigationShell: navigationShell),
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/home',
                      builder: (_, _) => const Scaffold(body: Text('home')),
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/notes/:noteId',
              parentNavigatorKey: shellKey,
              builder: (_, _) => const Scaffold(body: Text('detail')),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    unawaited(router.push('/notes/1'));
    await tester.pumpAndSettle();

    expect(find.text('detail'), findsOneWidget);
    expect(find.byKey(const Key('app-navigation-rail')), findsOneWidget);
  });
}
