// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/network/github_contributors.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/core/update/app_version.dart';
import 'package:nyachi/features/settings/presentation/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpAbout(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appVersionProvider.overrideWith((ref) async => '2.0.0-beta.9'),
        availableReleaseProvider.overrideWith((ref) async => null),
        githubContributorsProvider.overrideWith((ref) async => const []),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AboutSettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('About page keeps its contributor entry', (tester) async {
    await pumpAbout(tester);
    // The roster is a top-level destination of its own; losing the entry from
    // About leaves it unreachable, because nothing else links to it.
    expect(find.text('Contributors'), findsOneWidget);
  });

  testWidgets('About page shows the real version, not a placeholder', (
    tester,
  ) async {
    await pumpAbout(tester);
    expect(find.text('Version 2.0.0-beta.9'), findsOneWidget);
    expect(find.textContaining('0.1.0'), findsNothing);
  });

  testWidgets('About page is about the app, not the instance', (tester) async {
    await pumpAbout(tester);
    // Instance announcements belong to the account's server.
    expect(find.text('Instance announcements'), findsNothing);
    expect(find.text('Announcements'), findsNothing);
  });
}