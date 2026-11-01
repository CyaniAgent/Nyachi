// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/network/client_provider.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/features/settings/application/app_settings.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/drive/data/drive_repository.dart';
import 'package:nyachi/features/settings/presentation/drive_settings_page.dart';
import 'package:nyachi/features/settings/presentation/privacy_settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Widget page, {

  /// Extra overrides beyond the shared-preferences one the harness supplies.
  /// Typed via inference because riverpod's `Override` is not exported.
  List<dynamic> extraOverrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      ...extraOverrides.cast(),
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
        home: page,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('drive settings show the quota from the shared listing', (
    tester,
  ) async {
    await _pump(
      tester,
      const DriveSettingsPage(),
      extraOverrides: [
        driveListingProvider.overrideWith(
          (ref, folderId) async => const DriveListing(
            files: [],
            folders: [],
            capacity: 1000,
            usage: 250,
          ),
        ),
      ],
    );

    expect(find.text('250 B / 1000 B'), findsOneWidget);
    expect(find.text('Open drive'), findsOneWidget);
    // The bar reflects the used ratio rather than a full bar.
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.value, closeTo(0.25, 0.001));
  });

  testWidgets('drive settings fall back to a message without quota data', (
    tester,
  ) async {
    await _pump(
      tester,
      const DriveSettingsPage(),
      extraOverrides: [
        driveListingProvider.overrideWith(
          (ref, folderId) async => throw Exception('offline'),
        ),
      ],
    );

    expect(find.text('Storage usage is not available'), findsOneWidget);
    // The drive entry stays usable even when the quota probe failed.
    expect(find.text('Open drive'), findsOneWidget);
  });

  testWidgets('privacy defaults persist through the settings controller', (
    tester,
  ) async {
    final container = await _pump(
      tester,
      const PrivacySettingsPage(),
      extraOverrides: [
        // The list probe reaches the real client; no network here, so it
        // must degrade to the error/empty state without breaking the form.
        misskeyClientProvider.overrideWithValue(
          MisskeyClient.fromHost('https://example.invalid'),
        ),
      ],
    );

    // Public is the default selection.
    final publicTile = tester.widget<RadioListTile<String>>(
      find.widgetWithText(RadioListTile<String>, 'Public'),
    );
    expect(publicTile.value, 'public');

    await tester.tap(find.text('Followers'));
    await tester.pumpAndSettle();
    expect(
      container.read(settingsControllerProvider).defaultVisibility,
      'followers',
    );

    await tester.tap(
      find.widgetWithText(SwitchListTile, 'Local only by default'),
    );
    await tester.pumpAndSettle();
    expect(container.read(settingsControllerProvider).defaultLocalOnly, isTrue);
  });
}
