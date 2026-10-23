// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nyachi/app/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/shell/presentation/app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _page(String label) => Scaffold(body: Center(child: Text(label)));

GoRouter _router() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, _) => _page('home'))],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (_, _) => _page('notifications'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/explore', builder: (_, _) => _page('explore')),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/chat', builder: (_, _) => _page('chat'))],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', builder: (_, _) => _page('profile')),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets('shell renders configured destination order', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.tabOrder': ['profile', 'home', 'explore', 'chat'],
      'settings.hiddenTabs': ['notifications'],
    });
    final preferences = await SharedPreferences.getInstance();
    final router = _router();

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

    final destinations = tester
        .widgetList<NavigationDestination>(find.byType(NavigationDestination))
        .map((destination) => destination.label)
        .toList(growable: false);
    expect(destinations, ['Profile', 'Home', 'Explore', 'Chat']);
  });
}
