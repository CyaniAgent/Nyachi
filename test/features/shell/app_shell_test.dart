// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/settings/application/app_settings.dart';
import 'package:nyachi/features/shell/presentation/app_sidebar.dart';
import 'package:nyachi/features/shell/presentation/app_shell.dart';
import 'package:nyachi/features/shell/presentation/root_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('bottom bar renders at most four configured destinations', (
    tester,
  ) async {
    // Legacy keys seed the bottom config; notifications hidden, so the bar
    // shows profile, home, explore, chat — four slots, not five.
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
            selectedTab: AppTab.home,
            onSelectTab: (_) {},
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
    expect(destinations, ['Me', 'Home', 'Discover', 'Chat']);
    expect(destinations, hasLength(lessThanOrEqualTo(4)));
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('default bottom config drops explore to keep four slots', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShellChrome(
            selectedTab: AppTab.home,
            onSelectTab: (_) {},
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
    expect(destinations, ['Home', 'Notifications', 'Chat', 'Me']);
  });

  testWidgets('wide windows render the persistent sidebar', (tester) async {
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

    // The sidebar survives pushed detail routes (it is shell chrome, not
    // branch content).
    expect(find.text('detail'), findsOneWidget);
    expect(find.text('Nyachi'), findsOneWidget);
  });

  testWidgets('collapsed sidebar keeps every destination reachable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // 900 is wide enough for the sidebar but below the auto-expand width, so
    // it starts collapsed.
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShellChrome(
            selectedTab: AppTab.home,
            onSelectTab: (_) {},
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Collapsed means icon-only, not empty: the tab icons and the feature
    // entries are all still there.
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byIcon(Icons.campaign_outlined), findsOneWidget);
    expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
  });

  testWidgets('drawer hamburger opens the shell drawer', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShellChrome(
            selectedTab: AppTab.home,
            onSelectTab: (_) {},
            child: Scaffold(
              appBar: AppBar(leading: const AppDrawerButton()),
              body: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // The drawer is a shell-level surface: it lists the tabs that are not on
    // the bottom bar, which is the whole point of the hamburger.
    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Discover'), findsWidgets);
  });

  testWidgets('hidden compose FAB does not take taps', (tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    var tapped = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShellChrome(
            selectedTab: AppTab.notifications,
            onSelectTab: (_) {},
            child: SizedBox.expand(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => tapped++,
                child: const ColoredBox(color: Color(0xFFFFFFFF)),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Where the FAB sits on home/profile: end-float, above the bottom bar.
    // Hidden, the tap has to reach the page underneath.
    await tester.tapAt(const Offset(556, 776));
    await tester.pump();
    expect(tapped, 1);
  });
}
