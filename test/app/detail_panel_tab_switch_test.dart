// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nyachi/app/detail_panel/detail_location.dart';
import 'package:nyachi/app/detail_panel/open_detail.dart';
import 'package:nyachi/app/detail_panel/detail_panel_coordinator.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/shell/presentation/app_shell.dart';
import 'package:nyachi/features/shell/presentation/root_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A detail page opened in the wide-screen panel, then the tab is switched
/// away and back. This mirrors the real router: one ShellRoute hosting
/// RootShell around a StatefulShellRoute with two branches.
void main() {
  testWidgets('panel survives switching tabs and back', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final account = LocalAccount(
      id: 'account',
      host: 'example.test',
      userId: 'u1',
      username: 'alice',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
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
                      builder: (_, _) => const _HomePage(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/notifications',
                      builder: (_, _) =>
                          const _PlainPage(title: 'Notifications'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/explore',
                      builder: (_, _) => const _PlainPage(title: 'Discover'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/chat',
                      builder: (_, _) => const _ChatPage(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/profile',
                      builder: (_, _) => const _PlainPage(title: 'Profile'),
                    ),
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
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          appDatabaseProvider.overrideWithValue(database),
          activeAccountProvider.overrideWithValue(account),
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open detail'));
    await tester.pumpAndSettle();
    expect(find.text('About'), findsWidgets);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('full-page detail survives tab switch and back (narrow)', (
    tester,
  ) async {
    // Below the detail breakpoint the panel downgrades to a pushed full page;
    // switching tabs from there and returning must not throw.
    tester.view.physicalSize = const Size(700, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final account = LocalAccount(
      id: 'account',
      host: 'example.test',
      userId: 'u1',
      username: 'alice',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
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
                      builder: (_, _) => const _HomePage(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/notifications',
                      builder: (_, _) =>
                          const _PlainPage(title: 'Notifications'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/explore',
                      builder: (_, _) => const _PlainPage(title: 'Discover'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/chat',
                      builder: (_, _) => const _ChatPage(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/profile',
                      builder: (_, _) => const _PlainPage(title: 'Profile'),
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/settings/about',
              builder: (_, _) =>
                  const Scaffold(body: Center(child: Text('detail page'))),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          appDatabaseProvider.overrideWithValue(database),
          activeAccountProvider.overrideWithValue(account),
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open detail'));
    await tester.pumpAndSettle();
    expect(find.text('detail page'), findsOneWidget);
    expect(tester.takeException(), isNull);

    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('panel open, tap another tab in the shell, come back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final account = LocalAccount(
      id: 'account',
      host: 'example.test',
      userId: 'u1',
      username: 'alice',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
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
                      builder: (_, _) => const _HomePage(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/notifications',
                      builder: (_, _) =>
                          const _PlainPage(title: 'Notifications'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/explore',
                      builder: (_, _) => const _PlainPage(title: 'Discover'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/chat',
                      builder: (_, _) => const _ChatPage(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/profile',
                      builder: (_, _) => const _PlainPage(title: 'Profile'),
                    ),
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
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          appDatabaseProvider.overrideWithValue(database),
          activeAccountProvider.overrideWithValue(account),
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open detail'));
    await tester.pumpAndSettle();
    expect(find.text('About'), findsWidgets);

    // Sidebar entry: this is the shell's own onSelectTab path, which closes
    // the panel and switches branch in one tap.
    await tester.tap(find.text('Chat').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Home').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('a second page pushed inside the panel survives tab switch', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final account = LocalAccount(
      id: 'account',
      host: 'example.test',
      userId: 'u1',
      username: 'alice',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appDatabaseProvider.overrideWithValue(database),
        activeAccountProvider.overrideWithValue(account),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
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
                      builder: (_, _) => const _HomePage(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/notifications',
                      builder: (_, _) =>
                          const _PlainPage(title: 'Notifications'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/explore',
                      builder: (_, _) => const _PlainPage(title: 'Discover'),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/chat',
                      builder: (_, _) => const _ChatPage(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/profile',
                      builder: (_, _) => const _PlainPage(title: 'Profile'),
                    ),
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

    await tester.tap(find.text('open detail'));
    await tester.pumpAndSettle();
    expect(find.text('About'), findsWidgets);

    // A second page inside the panel, the way one detail page links onward.
    final coordinator = container.read(detailPanelCoordinatorProvider).value!;
    coordinator.pushFromPanel(const SettingsNavigationLocation());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chat').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home').first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: TextButton(
          onPressed: () => openDetail(context, const SettingsAboutLocation()),
          child: const Text('open detail'),
        ),
      ),
    );
  }
}

class _ChatPage extends StatelessWidget {
  const _ChatPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Chat')));
  }
}

class _PlainPage extends StatelessWidget {
  const _PlainPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)));
  }
}
