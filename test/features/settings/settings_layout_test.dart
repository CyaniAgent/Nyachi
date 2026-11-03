// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/features/settings/presentation/settings_page.dart';

LocalAccount _account() => LocalAccount(
  id: 'account',
  host: 'example.test',
  userId: 'me',
  username: 'alice',
  displayName: 'Alice',
  addedAt: DateTime(2026),
  lastUsedAt: DateTime(2026),
);

class _FakeSessionController extends SessionController {
  _FakeSessionController(this.account);

  final LocalAccount account;

  @override
  SessionState build() =>
      SessionState(accounts: [account], active: account, initialized: true);
}

Future<void> _pump(WidgetTester tester, Widget page) async {
  // The list is taller than the default test viewport; a taller surface keeps
  // every group rendered so the assertions see real rows.
  tester.view.physicalSize = const Size(900, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionControllerProvider.overrideWith(
          () => _FakeSessionController(_account()),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: page,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('settings groups server pages apart from app pages', (
    tester,
  ) async {
    await _pump(tester, const SettingsPage());

    expect(find.text('This server'), findsOneWidget);
    expect(find.text('App'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);

    // Server-owned pages live under the server group, not the app group.
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Drive space'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
  });

  testWidgets('the account header opens the account hub', (tester) async {
    await _pump(tester, const SettingsPage());
    // The header shows the active account and is the only route into the
    // account pages, so a user-scoped setting is never a top-level tile.
    expect(find.text('Alice'), findsOneWidget);
    // The header states what it leads to; the user-scoped pages themselves
    // live only behind it.
    expect(find.text('Account and server'), findsOneWidget);
    expect(find.text('Edit profile'), findsNothing);
    expect(find.text('Security'), findsNothing);
  });

  testWidgets('search filters the entries', (tester) async {
    await _pump(tester, const SettingsPage());

    await tester.enterText(find.byType(TextField), 'appear');
    await tester.pump();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Notifications'), findsNothing);
    expect(find.text('Cache management'), findsNothing);
  });

  testWidgets('the account hub owns the user-scoped pages', (tester) async {
    await _pump(tester, const AccountsSettingsPage());

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
  });
}
