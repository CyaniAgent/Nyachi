// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/network/instance_repository.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/settings/application/app_settings.dart';
import 'package:nyachi/features/settings/presentation/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        instanceInfoProvider.overrideWith(
          (ref) async => const InstanceInfo(
            name: 'example',
            themeColor: '#3f51b5',
            maxNoteTextLength: 3000,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppearanceSettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('accent options are labelled without a tooltip', (tester) async {
    tester.view.physicalSize = const Size(365 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pump(tester);

    // A swatch's name used to live in a tooltip only, which a touch user can
    // reach only by long-pressing: the labels must be on screen.
    final swatches = find.byType(Wrap);
    expect(
      find.descendant(of: swatches, matching: find.text('跟随系统')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: swatches, matching: find.text('跟随实例')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: swatches, matching: find.text('靛蓝')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('choosing the system colour persists it', (tester) async {
    await pump(tester);

    await tester.tap(
      find.descendant(of: find.byType(Wrap), matching: find.text('跟随系统')),
    );
    await tester.pumpAndSettle();

    expect(container.read(settingsControllerProvider).accentColor, 'system');
  });
}
