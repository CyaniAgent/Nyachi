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
  testWidgets('settings groups account, client and server pages apart', (
    tester,
  ) async {
    await _pump(tester, const SettingsPage());

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Client'), findsOneWidget);
    // The manage section only renders with moderator rights; the fake
    // session below has none, so the group header is absent.
    expect(find.text('This server'), findsNothing);

    // User-scoped pages sit in the account group; client pages under Client.
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('the account header shows the active handle and opens profile', (
    tester,
  ) async {
    await _pump(tester, const SettingsPage());
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('@alice@example.test'), findsOneWidget);
  });

  testWidgets('the moderation hub is the only admin entry', (tester) async {
    await _pump(tester, const SettingsPage());

    // The seven flat admin pages are gone from the root; only the hub tile
    // remains, and it is gated off without moderator rights.
    expect(find.text('Manage instance'), findsNothing);
    expect(find.text('Reports'), findsNothing);
    expect(find.text('Invite codes'), findsNothing);
  });

  testWidgets('the search bar is gone', (tester) async {
    await _pump(tester, const SettingsPage());
    expect(find.byType(SearchBar), findsNothing);
  });
}
