// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/auth/application/anonymous_meta.dart';
import 'package:nyachi/features/auth/presentation/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockMeta extends Mock implements MetaLite {}

MetaLite _meta() {
  final meta = _MockMeta();
  when(() => meta.name).thenReturn('Misskey Hub');
  when(() => meta.iconUrl).thenReturn(null);
  when(() => meta.serverRules)
      .thenReturn(['Be nice to each other', 'No illegal content']);
  when(() => meta.tosUrl).thenReturn('https://example.test/tos');
  when(() => meta.privacyPolicyUrl).thenReturn(null);
  when(() => meta.impressumUrl).thenReturn(null);
  return meta;
}

Future<void> _pumpPage(WidgetTester tester, {MetaLite? meta}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        if (meta != null)
          anonymousMetaProvider('misskey.io')
              .overrideWith((ref) => Future<MetaLite>.value(meta)),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginPage(),
      ),
    ),
  );
}

FilledButton _miAuthButton(WidgetTester tester) => tester.widget<FilledButton>(
  find.widgetWithText(FilledButton, 'Continue with MiAuth'),
);

void main() {
  testWidgets('login page renders MiAuth and manual token controls', (
    tester,
  ) async {
    await _pumpPage(tester);

    expect(find.text('Continue with MiAuth'), findsOneWidget);
    expect(find.text('Instance host'), findsOneWidget);

    await tester.tap(find.text('Use an access token'));
    await tester.pumpAndSettle();
    expect(find.text('Access token'), findsOneWidget);
  });

  testWidgets('instance card renders after host commit and gates login', (
    tester,
  ) async {
    await _pumpPage(tester, meta: _meta());

    // Buttons are disabled before any host or consent exists.
    expect(_miAuthButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'misskey.io');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // Anonymous meta loaded: compact card shows the display name only.
    expect(find.text('Misskey Hub'), findsOneWidget);
    expect(find.textContaining('Be nice'), findsNothing);

    // Host committed but no consent yet: still disabled.
    expect(_miAuthButton(tester).onPressed, isNull);

    // App-level consent, then instance-level consent.
    // Only the checkbox toggles consent now (text is inert).
    final checkboxes = find.byType(Checkbox);
    await tester.ensureVisible(checkboxes.first);
    await tester.pumpAndSettle();
    await tester.tap(checkboxes.first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(checkboxes.at(1));
    await tester.pumpAndSettle();
    await tester.tap(checkboxes.at(1));
    await tester.pumpAndSettle();

    expect(_miAuthButton(tester).onPressed, isNotNull);
  });
}
