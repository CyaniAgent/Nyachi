// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/features/auth/presentation/instance_detail_page.dart';
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

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool scrollable = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: scrollable ? SingleChildScrollView(child: child) : child,
      ),
    ),
  );
}

void main() {
  test('resolveInstanceLink keeps absolute links and resolves paths', () {
    final meta = _MockMeta();
    when(() => meta.uri).thenReturn('https://example.test');

    expect(
      resolveInstanceLink(meta, 'https://other.tld/terms').toString(),
      'https://other.tld/terms',
    );
    expect(
      resolveInstanceLink(meta, '/terms').toString(),
      'https://example.test/terms',
    );
    expect(resolveInstanceLink(meta, ''), isNull);
  });

  testWidgets('summary card shows only the title and opens details', (
    tester,
  ) async {
    await _pump(tester, InstanceSummaryCard(meta: _meta()));

    // Title is enough on the surface; rules and links live on the detail page.
    expect(find.text('Misskey Hub'), findsOneWidget);
    expect(find.textContaining('Be nice'), findsNothing);
    expect(find.text('Server rules'), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.text('Misskey Hub'));
    await tester.pumpAndSettle();
    expect(find.byType(InstanceDetailPage), findsOneWidget);
  });

  testWidgets('detail page lists every rule and existing links only', (
    tester,
  ) async {
    await _pump(tester, InstanceDetailPage(meta: _meta()), scrollable: false);

    expect(find.text('Misskey Hub'), findsOneWidget); // AppBar title
    expect(find.textContaining('Be nice to each other'), findsOneWidget);
    expect(find.textContaining('No illegal content'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    // privacyPolicyUrl / impressumUrl are null in the fixture.
    expect(find.text('Privacy Policy'), findsNothing);
    expect(find.text('Impressum'), findsNothing);
  });

  testWidgets('detail page shows disabled rows for empty link fields', (
    tester,
  ) async {
    // Real case: some instances declare the section with `tosUrl: ''`.
    final meta = _MockMeta();
    when(() => meta.name).thenReturn('Misskey Hub');
    when(() => meta.iconUrl).thenReturn(null);
    when(() => meta.serverRules).thenReturn(const ['Be nice']);
    when(() => meta.tosUrl).thenReturn('');
    when(() => meta.privacyPolicyUrl).thenReturn('');
    when(() => meta.impressumUrl).thenReturn('');
    await _pump(tester, InstanceDetailPage(meta: meta), scrollable: false);

    // Rows render instead of vanishing, but are not tappable.
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Impressum'), findsOneWidget);
    final tosTile = tester.widget<ListTile>(find.byType(ListTile).first);
    expect(tosTile.onTap, isNull);
  });

  testWidgets('detail page shows placeholder when no rules are published', (
    tester,
  ) async {
    final meta = _MockMeta();
    when(() => meta.name).thenReturn(null);
    when(() => meta.iconUrl).thenReturn(null);
    when(() => meta.serverRules).thenReturn(const []);
    when(() => meta.tosUrl).thenReturn(null);
    when(() => meta.privacyPolicyUrl).thenReturn(null);
    when(() => meta.impressumUrl).thenReturn(null);
    await _pump(tester, InstanceDetailPage(meta: meta), scrollable: false);

    expect(find.text('Misskey'), findsOneWidget);
    expect(
      find.text('This instance has not published server rules'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });
}
