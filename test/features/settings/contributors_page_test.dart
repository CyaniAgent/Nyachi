// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/network/github_contributors.dart';
import 'package:nyachi/features/settings/presentation/contributors_page.dart';

void main() {
  const entries = [
    Contributor(
      login: 'AyaxYuna',
      avatarUrl: 'https://example.test/a.png',
      htmlUrl: 'https://example.test/AyaxYuna',
      contributions: 205,
    ),
    Contributor(
      login: 'SakuraCake',
      avatarUrl: 'https://example.test/s.png',
      htmlUrl: 'https://example.test/SakuraCake',
      contributions: 156,
    ),
  ];

  Future<ProviderContainer> pump(
    WidgetTester tester,
    List<Contributor> data,
  ) async {
    final container = ProviderContainer(
      overrides: [githubContributorsProvider.overrideWith((ref) async => data)],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ContributorsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('lists every contributor with counts and avatars', (
    tester,
  ) async {
    await pump(tester, entries);

    expect(find.text('AyaxYuna'), findsOneWidget);
    expect(find.text('SakuraCake'), findsOneWidget);
    expect(find.text('205 contributions'), findsOneWidget);
    expect(find.text('156 contributions'), findsOneWidget);
    expect(find.byType(ClipOval), findsNWidgets(2));
    // Rows are tappable (profiles open externally; not asserted here).
    final tile = tester.widget<ListTile>(find.byType(ListTile).first);
    expect(tile.onTap, isNotNull);
  });

  testWidgets('shows a placeholder when the roster is empty', (tester) async {
    await pump(tester, const []);

    expect(find.text('No contributors yet'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('error state offers a retry', (tester) async {
    final container = ProviderContainer(
      overrides: [
        githubContributorsProvider.overrideWith(
          (ref) async => throw StateError('offline'),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ContributorsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    container.dispose();
  });
}
