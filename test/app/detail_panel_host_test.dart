// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nyachi/app/detail_panel/detail_location.dart';
import 'package:nyachi/app/detail_panel/open_detail.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/composer/application/composer_controller.dart';
import 'package:nyachi/features/shell/presentation/root_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('opens and closes a detail page from the feed', (tester) async {
    tester.view.physicalSize = const Size(1300, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
            GoRoute(
              path: '/home',
              builder: (context, _) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () =>
                        openDetail(context, const ComposeDetailLocation(null)),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/compose',
              builder: (_, _) =>
                  const Scaffold(body: Center(child: Text('full compose'))),
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
          composerSenderProvider.overrideWithValue(
            ({
              required text,
              cw,
              required visibility,
              required localOnly,
              replyId,
              fileIds = const [],
              pollChoices,
              pollMultiple = false,
              pollExpiresAt,
              reactionAcceptance,
              visibleUserIds = const [],
              scheduledAt,
            }) async {},
          ),
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

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Compose never enters the detail panel: it always opens a bottom sheet.
    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/home');
    expect(find.byIcon(Icons.send), findsOneWidget);
    expect(find.text('open'), findsOneWidget);
    expect(find.byKey(const Key('app-navigation-rail')), findsOneWidget);

    // Dismissing the sheet keeps the feed intact.
    await tester.tapAt(const Offset(400, 40));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.send), findsNothing);

    // The same bottom sheet is used on wide layouts.
    tester.view.physicalSize = const Size(1300, 800);
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.toString(), '/home');
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  testWidgets('opens a detail panel from the initial URL', (tester) async {
    tester.view.physicalSize = const Size(1300, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
      initialLocation: '/home?detail=%2Fcompose',
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              RootShell(uri: state.uri, child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, _) => const Scaffold(body: Text('feed')),
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
          composerSenderProvider.overrideWithValue(
            ({
              required text,
              cw,
              required visibility,
              required localOnly,
              replyId,
              fileIds = const [],
              pollChoices,
              pollMultiple = false,
              pollExpiresAt,
              reactionAcceptance,
              visibleUserIds = const [],
              scheduledAt,
            }) async {},
          ),
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

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/home?detail=%2Fcompose',
    );
    expect(find.text('feed'), findsOneWidget);
    // The composer follows the official layout: no title bar, the post
    // button and the hint text carry the surface instead.
    expect(find.text('Post'), findsOneWidget);
  });
}
