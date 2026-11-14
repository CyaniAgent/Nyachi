// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/notifications/application/realtime_providers.dart';
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

  testWidgets('wide windows render the extended-capable rail', (tester) async {
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

    // The rail survives pushed detail routes (it is shell chrome, not
    // branch content). Extended by default: destination labels are on and
    // the feature entries read as rows.
    expect(find.text('detail'), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.byTooltip('Collapse'), findsOneWidget);
    expect(find.byIcon(Icons.menu_open), findsOneWidget);
    // The compose fab is extended, and the feature entries are rows.
    expect(find.text('Compose'), findsOneWidget);
    expect(find.text('Announcements'), findsOneWidget);
    expect(find.text('Drive'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Collapsing swaps the toggle to its other style and the compose fab to
    // its circle; the destination labels stay mounted, hidden by the rail's
    // own transition. The feature entries collapse to icon tiles.
    await tester.tap(find.byTooltip('Collapse'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Expand'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.text('Compose'), findsNothing);
    expect(find.byTooltip('Announcements'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);

    // Expanding brings the labels and rows back.
    await tester.tap(find.byTooltip('Expand'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.byTooltip('Collapse'), findsOneWidget);
  });

  testWidgets('the rail account chip opens the account menu and switches', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final alice = LocalAccount(
      id: 'alice',
      host: 'example.test',
      userId: 'u1',
      username: 'alice',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );
    final bob = LocalAccount(
      id: 'bob',
      host: 'other.test',
      userId: 'u2',
      username: 'bob',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        sessionControllerProvider.overrideWith(
          () => _FakeSession(
            SessionState(
              accounts: [alice, bob],
              active: alice,
              initialized: true,
            ),
          ),
        ),
        // A signed-in session would open a socket with retry timers.
        realtimeServiceProvider.overrideWith((ref) => null),
      ],
    );
    addTearDown(container.dispose);
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
                    GoRoute(path: '/home', builder: (_, _) => const Scaffold()),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // On a wide window the account chip's menu is the switcher: it lists
    // both accounts, and switching reaches the session.
    await tester.tap(find.text('alice'));
    await tester.pumpAndSettle();
    expect(find.text('@bob@other.test'), findsOneWidget);

    await tester.tap(find.text('@bob@other.test'));
    await tester.pumpAndSettle();

    expect(container.read(sessionControllerProvider).active?.id, 'bob');
  });

  testWidgets('the extended rail lists tabs and feature entries', (
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

    // One labelled destination per visible sidebar tab, the feature entries
    // as rows, and the extended compose fab — nothing lives in an overlay.
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsWidgets);
    expect(find.byIcon(Icons.notifications_outlined), findsWidgets);
    expect(find.byIcon(Icons.chat_bubble_outline), findsWidgets);
    expect(find.text('Announcements'), findsOneWidget);
    expect(find.text('Drive'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Compose'), findsOneWidget);
    expect(find.byTooltip('Collapse'), findsOneWidget);
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

    // The rail is already on screen, so a hamburger in the AppBar would open
    // nothing.
    expect(find.byIcon(Icons.menu), findsNothing);
    final titleLeft = tester.getTopLeft(find.text('Title')).dx;
    // No reserved leading slot: the title starts at the normal inset.
    expect(titleLeft, lessThan(40));
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

/// Session controller that records a switch instead of touching storage, so
/// the account card's menu can be exercised without a database. The id it was
/// asked to switch to is left in `state`.
class _FakeSession extends SessionController {
  _FakeSession(this._initial);

  final SessionState _initial;

  @override
  SessionState build() => _initial;

  @override
  Future<void> switchAccount(String id) async {
    final target = _initial.accounts.firstWhere((account) => account.id == id);
    state = state.copyWith(active: target);
  }
}
