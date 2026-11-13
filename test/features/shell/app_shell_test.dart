// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nyachi/app/detail_panel/detail_location.dart';
import 'package:nyachi/app/detail_panel/detail_panel_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/storage/storage_models.dart';
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

  testWidgets('the account card is one tap target across its whole row', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final account = LocalAccount(
      id: 'account',
      host: 'example.test',
      userId: 'u1',
      username: 'alice',
      displayName: 'Alice',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );

    var opened = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          activeAccountProvider.overrideWithValue(account),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 240,
              child: Column(
                children: [
                  SidebarUserPanel(
                    collapsed: false,
                    onOpenProfile: () => opened++,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The name is part of the card's tap target, not just the avatar.
    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();
    expect(opened, 1);
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
    expect(find.byIcon(Icons.home_outlined), findsWidgets);
    expect(find.byIcon(Icons.notifications_outlined), findsWidgets);
    expect(find.byIcon(Icons.chat_bubble_outline), findsWidgets);
    expect(find.byIcon(Icons.person_outline), findsWidgets);
    expect(find.byIcon(Icons.campaign_outlined), findsWidgets);
    expect(find.byIcon(Icons.cloud_outlined), findsWidgets);
  });

  testWidgets('collapsing the sidebar animates instead of jumping', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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

    Size sidebarSize() => tester.getSize(find.byType(AppSidebar));

    final expandedWidth = sidebarSize().width;
    expect(expandedWidth, greaterThan(200));

    await tester.tap(find.byTooltip('Collapse'));
    await tester.pump();
    // Mid-flight the pane is narrower than expanded but wider than collapsed:
    // that is the animation, not a subtree swap.
    await tester.pump(const Duration(milliseconds: 80));
    final midWidth = sidebarSize().width;
    expect(midWidth, lessThan(expandedWidth));
    expect(midWidth, greaterThan(80));

    await tester.pumpAndSettle();
    expect(sidebarSize().width, 80);
    // Every destination remains.
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    // The collapse state is announced by exactly one control, and it says what
    // the next tap does.
    expect(find.byTooltip('Expand'), findsOneWidget);
    expect(find.byTooltip('Collapse'), findsNothing);
  });

  testWidgets('wide layouts have no drawer button and no leading gap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Title'),
                leading: appBarDrawerLeading(context),
              ),
              body: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The sidebar is already on screen, so a hamburger would open nothing.
    expect(find.byIcon(Icons.menu), findsNothing);
    final titleLeft = tester.getTopLeft(find.text('Title')).dx;
    // No reserved leading slot: the title starts at the normal inset.
    expect(titleLeft, lessThan(40));
  });

  testWidgets('opening the detail panel collapses the sidebar', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The panel-collapse behavior is opt-in; the default keeps the pane
    // as it is and lets the panel take the room from the feed.
    SharedPreferences.setMockInitialValues({
      'layout.sidebarCollapseForPanel': true,
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

    Size sidebarSize() => tester.getSize(find.byType(AppSidebar));
    // Above the auto-breakpoint the pane starts expanded.
    expect(sidebarSize().width, greaterThan(80));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShellChrome)),
    );
    container
        .read(detailPanelControllerProvider.notifier)
        .replaceStack(NoteDetailLocation('n1'));
    await tester.pumpAndSettle();
    // The panel squeezed the content column: the pane collapsed to make room.
    expect(sidebarSize().width, 80);

    container.read(detailPanelControllerProvider.notifier).close();
    await tester.pumpAndSettle();
    // Closing restores the pre-panel state.
    expect(sidebarSize().width, greaterThan(80));
  });

  testWidgets('the detail panel keeps the sidebar expanded by default', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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

    Size sidebarSize() => tester.getSize(find.byType(AppSidebar));
    expect(sidebarSize().width, greaterThan(80));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShellChrome)),
    );
    container
        .read(detailPanelControllerProvider.notifier)
        .replaceStack(NoteDetailLocation('n1'));
    await tester.pumpAndSettle();
    // Opt-in is off: the pane keeps its width and the panel squeezes the
    // feed instead.
    expect(sidebarSize().width, greaterThan(80));
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
