// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/app/l10n/app_localizations.dart';
import 'package:nyachi/features/auth/presentation/login_page.dart';

void main() {
  testWidgets('login page renders MiAuth and manual token controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginPage(),
        ),
      ),
    );

    expect(find.text('Continue with MiAuth'), findsOneWidget);
    expect(find.text('Instance host'), findsOneWidget);

    await tester.tap(find.text('Use an access token'));
    await tester.pumpAndSettle();
    expect(find.text('Access token'), findsOneWidget);
  });
}
