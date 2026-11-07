// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/network/error_mapper.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/notifications/application/notification_list_controller.dart';
import 'package:nyachi/features/notifications/application/notification_unread.dart';
import 'package:nyachi/features/notifications/domain/notification_repository.dart';
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
  _FakeRepository({this.cached = const []});

  List<Notification> cached;
  Future<NotificationPage> Function(String? untilId)? fetch;
  var writes = 0;
  var marksRead = 0;

  List<AccountNotificationsRequestIncludeTypesItem>? requestedTypes;

  @override
  Future<NotificationPage> fetchPage({
    String? untilId,
    List<AccountNotificationsRequestIncludeTypesItem>? includeTypes,
  }) {
    requestedTypes = includeTypes;
    return fetch!(untilId);
  }

  @override
  Future<List<Notification>> readCache() async => cached;

  @override
  Future<void> writeCache(List<Notification> notifications) async => writes++;

  @override
  Future<void> markAllAsRead() async => marksRead++;
}

LocalAccount _account() => LocalAccount(
  id: 'a1',
  host: 'misskey.io',
  userId: 'u1',
  username: 'alice',
  addedAt: DateTime(2026),
  lastUsedAt: DateTime(2026),
);

Notification _notification(String id) {
  final user = jsonDecode(jsonEncode(makeUser('u1').toJson()));
  final note = jsonDecode(jsonEncode(makeNote('note-$id').toJson()));
  return Notification.fromJson({
    'id': id,
    'type': 'reaction',
    'createdAt': '2026-01-01T00:00:00.000Z',
    'user': user,
    'userId': 'u1',
    'note': note,
    'reaction': '👍',
  });
}

Future<ProviderContainer> _makeContainer(_FakeRepository repository) async {
  SharedPreferences.setMockInitialValues({});
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
  return container;
}

/// The "All" tab.
final _all = notificationListControllerProvider(null);

void main() {
  test('hydrates cache then refreshes and writes back', () async {
    final repository = _FakeRepository(cached: [_notification('n1')]);
    final firstPage = Completer<NotificationPage>();
    repository.fetch = (_) => firstPage.future;
    final container = await _makeContainer(repository);

    container.listen(_all, (_, _) {});
    container.read(_all);
    await pumpEventQueue();

    var state = container.read(_all);
    expect(state.items.map((n) => n.id), ['n1']);
    expect(state.usingCache, isTrue);

    firstPage.complete(
      NotificationPage(items: [_notification('n2')], hasMore: true),
    );
    await pumpEventQueue();

    state = container.read(_all);
    expect(state.items.map((n) => n.id), ['n2']);
    expect(state.usingCache, isFalse);
    expect(state.initialLoading, isFalse);
    expect(state.error, isNull);
    expect(repository.writes, 1);
  });

  test(
    'refresh failure keeps cache-backed items and records the error',
    () async {
      final repository = _FakeRepository(cached: [_notification('n1')]);
      repository.fetch = (_) async => throw Exception('offline');
      final container = await _makeContainer(repository);

      container.listen(_all, (_, _) {});
      await container.read(_all.notifier).refresh();
      await pumpEventQueue(); // let build()'s hydrate settle as well

      final state = container.read(_all);
      expect(state.error?.kind, AppFailureKind.unknown);
      expect(state.refreshing, isFalse);
      expect(state.items.map((n) => n.id), ['n1']);
      expect(state.usingCache, isTrue);
    },
  );

  test('markAllRead calls the repository and refreshes every tab', () async {
    final repository = _FakeRepository(cached: const []);
    var calls = 0;
    repository.fetch = (_) async {
      calls++;
      return NotificationPage(items: const [], hasMore: false);
    };
    final container = await _makeContainer(repository);

    container.listen(_all, (_, _) {});
    await pumpEventQueue(); // let build()'s hydrate refresh settle first

    final ok = await container
        .read(notificationUnreadProvider.notifier)
        .markAllRead();
    await pumpEventQueue();

    expect(ok, isTrue);
    expect(repository.marksRead, 1);
    // Marking read invalidates the family, so the list reloads rather than
    // showing rows the server now considers read.
    expect(calls, greaterThan(1));
  });

  test('a pushed notification lands at the head without duplicating', () async {
    final repository = _FakeRepository(cached: [_notification('n1')]);
    repository.fetch = (_) async =>
        NotificationPage(items: [_notification('n1')], hasMore: false);
    final container = await _makeContainer(repository);

    container.listen(_all, (_, _) {});
    await pumpEventQueue();
    expect(container.read(_all).items.map((n) => n.id), ['n1']);

    final controller = container.read(_all.notifier);
    controller.prepend(_notification('live-1'));
    expect(container.read(_all).items.map((n) => n.id), ['live-1', 'n1']);

    // A reconnect replays the same push; the id guard keeps one row.
    controller.prepend(_notification('live-1'));
    expect(container.read(_all).items.map((n) => n.id), ['live-1', 'n1']);
  });

  test('a filtered tab requests only its own include types', () async {
    final repository = _FakeRepository();
    repository.fetch = (_) async =>
        NotificationPage(items: [_notification('m1')], hasMore: false);
    final container = await _makeContainer(repository);

    final mentions = notificationListControllerProvider(
      NotificationFilter.mentions,
    );
    container.listen(mentions, (_, _) {});
    await pumpEventQueue();

    expect(repository.requestedTypes, NotificationFilter.mentions.includeTypes);
    final state = container.read(mentions);
    expect(state.items.map((n) => n.id), ['m1']);
    expect(state.initialLoading, isFalse);
  });

  test('a filtered tab does not read the unfiltered cache', () async {
    // The cache holds the unfiltered feed; serving it to a filtered tab would
    // show rows it excluded.
    final repository = _FakeRepository(cached: [_notification('cached')]);
    repository.fetch = (_) async =>
        NotificationPage(items: const [], hasMore: false);
    final container = await _makeContainer(repository);

    final follows = notificationListControllerProvider(
      NotificationFilter.follows,
    );
    container.listen(follows, (_, _) {});
    await pumpEventQueue();

    final state = container.read(follows);
    expect(state.items, isEmpty);
    expect(state.usingCache, isFalse);
    expect(repository.writes, 0);
  });

  test('a filtered-out live arrival is not inserted', () async {
    final repository = _FakeRepository();
    repository.fetch = (_) async => NotificationPage(items: [], hasMore: false);
    final container = await _makeContainer(repository);

    final mentions = notificationListControllerProvider(
      NotificationFilter.mentions,
    );
    container.listen(mentions, (_, _) {});
    await pumpEventQueue();

    // A reaction does not belong in the mentions view; it stays on the server.
    container.read(mentions.notifier).prepend(_notification('r1'));
    expect(container.read(mentions).items, isEmpty);
  });

  test(
    'the read boundary starts at first use and moves on mark-all-read',
    () async {
      final repository = _FakeRepository();
      repository.fetch = (_) async =>
          NotificationPage(items: [], hasMore: false);
      final container = await _makeContainer(repository);

      container.listen(notificationUnreadProvider, (_, _) {});
      await pumpEventQueue();

      // A fresh account has no read history, so the boundary is created rather
      // than left null: otherwise every historical notification would show as
      // unread on the first visit.
      final initial = container.read(notificationUnreadProvider).boundary;
      expect(initial, isNotNull);
      expect(container.read(notificationUnreadProvider).unreadOnly, isFalse);

      await container.read(notificationUnreadProvider.notifier).markAllRead();
      await pumpEventQueue();

      final moved = container.read(notificationUnreadProvider).boundary!;
      expect(
        moved.isAfter(initial!) || moved.isAtSameMomentAs(initial),
        isTrue,
      );
      expect(repository.marksRead, 1);
    },
  );

  test('unreadOnly is a view switch, not a refetch', () async {
    final repository = _FakeRepository();
    var fetches = 0;
    repository.fetch = (_) async {
      fetches++;
      return NotificationPage(items: [_notification('n1')], hasMore: false);
    };
    final container = await _makeContainer(repository);

    container.listen(_all, (_, _) {});
    container.listen(notificationUnreadProvider, (_, _) {});
    await pumpEventQueue();
    final fetchesAfterLoad = fetches;

    container.read(notificationUnreadProvider.notifier).setUnreadOnly(true);
    await pumpEventQueue();

    // The server keeps no read state to filter on, so switching the view must
    // not cost a request.
    expect(container.read(notificationUnreadProvider).unreadOnly, isTrue);
    expect(fetches, fetchesAfterLoad);
  });
}
