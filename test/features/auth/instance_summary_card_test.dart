// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/features/auth/presentation/instance_summary_card.dart';

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

Future<void> _pump(WidgetTester tester, MetaLite meta) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(child: InstanceSummaryCard(meta: meta)),
      ),
    ),
  );
}

void main() {
  testWidgets('renders display name and every server rule', (tester) async {
    await _pump(tester, _meta());

    expect(find.text('Misskey Hub'), findsOneWidget);
    expect(find.textContaining('Be nice to each other'), findsOneWidget);
    expect(find.textContaining('No illegal content'), findsOneWidget);
    expect(find.text('Server rules'), findsOneWidget);
    expect(find.text('Instance links'), findsOneWidget);
  });

  testWidgets('renders ToS link row only when the field exists', (
    tester,
  ) async {
    final meta = _meta();
    await _pump(tester, meta);

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    // privacyPolicyUrl / impressumUrl are null in the fixture.
    expect(find.text('Privacy Policy'), findsNothing);
    expect(find.text('Impressum'), findsNothing);
  });

  testWidgets('shows placeholder when the instance publishes no rules', (
    tester,
  ) async {
    final meta = _MockMeta();
    when(() => meta.name).thenReturn(null);
    when(() => meta.iconUrl).thenReturn(null);
    when(() => meta.serverRules).thenReturn(const []);
    when(() => meta.tosUrl).thenReturn(null);
    when(() => meta.privacyPolicyUrl).thenReturn(null);
    when(() => meta.impressumUrl).thenReturn(null);
    await _pump(tester, meta);

    expect(find.text('Misskey'), findsOneWidget);
    expect(
      find.text('This instance has not published server rules'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });
}
