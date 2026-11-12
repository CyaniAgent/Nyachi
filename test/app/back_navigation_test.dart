// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nyachi/app/detail_panel/detail_location.dart';
import 'package:nyachi/app/detail_panel/detail_panel_controller.dart';
import 'package:nyachi/app/detail_panel/detail_panel_coordinator.dart';
import 'package:nyachi/app/detail_panel/open_detail.dart';
import 'package:nyachi/app/router/back_navigation.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/composer/application/composer_controller.dart';
import 'package:nyachi/features/settings/application/app_settings.dart';
import 'package:nyachi/features/shell/application/shell_navigation.dart';
import 'package:nyachi/features/shell/presentation/app_shell.dart';
import 'package:nyachi/features/shell/presentation/root_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Shell = ({ProviderContainer container, GoRouter router});

/// Builds the real shell — `RootShell` for the panel wiring and `AppShell` for
/// the branch navigator — around a two-tab route table.
Future<Shell> pumpShell(WidgetTester tester) async {
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
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      appDatabaseProvider.overrideWithValue(database),
      activeAccountProvider.overrideWithValue(account),
      composerSenderProvider.overrideWithValue(_noopComposerSender),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => RootShell(
          uri: state.uri,
          child: AppShell(navigationShell: navigationShell),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, _) => Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () =>
                          openDetail(context, const NoteDetailLocation('n1')),
                      child: const Text('open note'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (_, _) =>
                    const Scaffold(body: Text('notifications tab')),
              ),
            ],
          ),
        ],
      ),
      // A page pushed above the shell, like /search. Back from it must land
      // back on the tab, not exit the app.
      GoRoute(
        path: '/search',
        builder: (_, _) => const Scaffold(body: Text('search page')),
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
  return (container: container, router: router);
}

Future<void> _noopComposerSender({
  required String text,
  String? cw,
  required Object visibility,
  required bool localOnly,
  String? replyId,
  List<String> fileIds = const [],
  List<String>? pollChoices,
  bool pollMultiple = false,
  DateTime? pollExpiresAt,
  Object? reactionAcceptance,
  List<String> visibleUserIds = const [],
  DateTime? scheduledAt,
}) async {}

/// Delivers the platform back intent the way Android and desktop do.
Future<void> pressSystemBack(WidgetTester tester) async {
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      const MethodCall('popRoute'),
    ),
    (_) {},
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('back from a page pushed above the shell returns to the tab', (
    tester,
  ) async {
    final shell = await pumpShell(tester);
    final router = shell.router;

    unawaited(router.push('/search'));
    await tester.pumpAndSettle();
    expect(find.text('search page'), findsOneWidget);

    await pressSystemBack(tester);

    // The search page is gone and the app is still on its tab; before the
    // PopScope guard this back exited the app instead of popping the page.
    expect(find.text('search page'), findsNothing);
    expect(find.text('open note'), findsOneWidget);
  });

  testWidgets('back closes the detail panel before anything else', (
    tester,
  ) async {
    final shell = await pumpShell(tester);
    final container = shell.container;

    await tester.tap(find.text('open note'));
    await tester.pumpAndSettle();
    expect(container.read(detailPanelControllerProvider).isOpen, isTrue);

    await pressSystemBack(tester);

    expect(container.read(detailPanelControllerProvider).isOpen, isFalse);
  });

  testWidgets('back unwinds one panel layer at a time', (tester) async {
    final shell = await pumpShell(tester);
    final container = shell.container;
    final coordinator = container.read(detailPanelCoordinatorProvider).value!;

    coordinator.openFromFeed(const NoteDetailLocation('n1'));
    coordinator.pushFromPanel(const UserDetailLocation('u1'));
    await tester.pumpAndSettle();
    expect(container.read(detailPanelControllerProvider).stack.length, 2);

    await pressSystemBack(tester);

    final state = container.read(detailPanelControllerProvider);
    expect(state.stack.length, 1);
    expect(state.isOpen, isTrue);
  });

  testWidgets('back from a tab returns to home instead of leaving the app', (
    tester,
  ) async {
    final shell = await pumpShell(tester);
    final container = shell.container;
    final notifier = container.read(shellNavigationProvider);

    notifier.value!.goBranch(1);
    await tester.pumpAndSettle();
    expect(notifier.value!.currentIndex, 1);

    await pressSystemBack(tester);

    expect(notifier.value!.currentIndex, AppTab.home.index);
    expect(container.read(detailPanelControllerProvider).isOpen, isFalse);
  });

  testWidgets('a tab root with nothing open lets the platform own the exit', (
    tester,
  ) async {
    final shell = await pumpShell(tester);

    // No page, dialog, panel or tab left to unwind: `canPop` stays true so the
    // platform keeps its own exit behaviour instead of being swallowed.
    expect(unwindAppState(shell.container, currentIndex: 0), isFalse);
    expect(hasStateToUnwind(shell.container, currentIndex: 0), isFalse);
  });
}
