// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/cache/cache_manager.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/settings/presentation/cache_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('cache page lists kinds and clearing a kind drops its rows', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final account = LocalAccount(
      id: 'account',
      host: 'example.test',
      userId: 'u1',
      username: 'alice',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );
    await database.cacheDao.write('account', CacheManager.instanceMetaKey, 'x');
    await database.cacheDao.write('account', CacheManager.emojiCatalogKey, 'e');
    await database.cacheDao.write(
      'account',
      CacheManager.notificationsKey,
      '[]',
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appDatabaseProvider.overrideWithValue(database),
        activeAccountProvider.overrideWithValue(account),
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
          home: const Scaffold(body: SafeArea(child: CacheSettingsPage())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Instance info'), findsOneWidget);
    expect(find.text('Emoji catalogue'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Clear all caches'), findsOneWidget);
    expect(find.text('1 entry · 1 B'), findsNWidgets(2));
    expect(find.text('1 entry · 2 B'), findsOneWidget);

    final emojiRow = find.ancestor(
      of: find.text('Emoji catalogue'),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(
        of: emojiRow,
        matching: find.byIcon(Icons.delete_outline),
      ),
    );
    await tester.pumpAndSettle();

    // The confirm dialog clears only after pressing "Clear".
    await tester.tap(find.widgetWithText(TextButton, 'Clear'));
    await tester.pumpAndSettle();

    expect(
      await database.cacheDao.read('account', CacheManager.emojiCatalogKey),
      isNull,
    );
    expect(
      await database.cacheDao.read('account', CacheManager.notificationsKey),
      isNotNull,
    );
    expect(
      await database.cacheDao.read('account', CacheManager.instanceMetaKey),
      isNotNull,
    );

    // The list reloads: the emoji kind now reports no entries.
    expect(find.text('0 entries · 0 B'), findsOneWidget);
    expect(find.text('1 entry · 1 B'), findsOneWidget);
    expect(find.text('1 entry · 2 B'), findsOneWidget);
  });
}
