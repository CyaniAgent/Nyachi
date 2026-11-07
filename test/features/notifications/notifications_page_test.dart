// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/notifications/application/notification_list_controller.dart';
import 'package:nyachi/features/notifications/domain/notification_repository.dart';
import 'package:nyachi/features/notifications/presentation/notifications_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fixtures.dart';

class _FakeSessionController extends SessionController {
  _FakeSessionController(this.account);

  final LocalAccount account;

  @override
  SessionState build() =>
      SessionState(accounts: [account], active: account, initialized: true);
}

class _FakeRepository implements NotificationRepository {
  _FakeRepository({this.items = const []});

  List<Notification> items;
  List<AccountNotificationsRequestIncludeTypesItem>? requestedTypes;

  @override
  Future<NotificationPage> fetchPage({
    String? untilId,
    List<AccountNotificationsRequestIncludeTypesItem>? includeTypes,
  }) async {
    requestedTypes = includeTypes;
    return NotificationPage(items: items, hasMore: false);
  }

  @override
  Future<List<Notification>> readCache() async => const [];

  @override
  Future<void> writeCache(List<Notification> notifications) async {}

  @override
  Future<void> markAllAsRead() async {}
}

LocalAccount _account() => LocalAccount(
  id: 'a1',
  host: 'misskey.io',
  userId: 'u1',
  username: 'alice',
  addedAt: DateTime(2026),
  lastUsedAt: DateTime(2026),
);

Notification _notification(String id, {required DateTime createdAt}) {
  final user = jsonDecode(jsonEncode(makeUser('u1').toJson()));
  final note = jsonDecode(jsonEncode(makeNote('note-$id').toJson()));
  return Notification.fromJson({
    'id': id,
    'type': 'reaction',
    'createdAt': createdAt.toUtc().toIso8601String(),
    'user': user,
    'userId': 'u1',
    'note': note,
    'reaction': '👍',
  });
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  _FakeRepository repository,
) async {
  SharedPreferences.setMockInitialValues({
    // A boundary in the past: everything the repository returns is newer, so
    // the unread view has something to show.
    'notifications.readAt.a1': DateTime.utc(2025).millisecondsSinceEpoch,
  });
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      sessionControllerProvider.overrideWith(
        () => _FakeSessionController(_account()),
      ),
      notificationRepositoryProvider.overrideWithValue(repository),
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
        home: const NotificationsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('categories are tabs, and a tab asks for its types', (
    tester,
  ) async {
    final repository = _FakeRepository();
    await _pump(tester, repository);

    // Six tabs: All plus one per event group.
    expect(find.byType(Tab), findsNWidgets(6));
    expect(find.byType(FilterChip), findsNothing);

    await tester.tap(find.text('Reactions'));
    await tester.pumpAndSettle();

    expect(
      repository.requestedTypes,
      NotificationFilter.reactions.includeTypes,
    );
  });

  testWidgets('swiping moves to the next category', (tester) async {
    final repository = _FakeRepository();
    await _pump(tester, repository);

    // The tabs are a TabBarView, so the gesture the platform expects works and
    // the change animates instead of replacing the body.
    await tester.drag(find.byType(TabBarView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(repository.requestedTypes, NotificationFilter.mentions.includeTypes);
    expect(find.byType(TabBarView), findsOneWidget);
  });

  testWidgets('the unread toggle narrows the list without refetching', (
    tester,
  ) async {
    final repository = _FakeRepository(
      items: [
        _notification('new', createdAt: DateTime.utc(2026, 3)),
        _notification('old', createdAt: DateTime.utc(2024)),
      ],
    );
    await _pump(tester, repository);
    expect(find.byType(ListTile), findsNWidgets(2));

    await tester.tap(find.byTooltip('Unread only'));
    await tester.pumpAndSettle();

    // Only the one newer than the stored boundary survives.
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.byTooltip('Show all'), findsOneWidget);
  });
}
