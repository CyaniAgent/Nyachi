// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/network/error_mapper.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/features/notifications/application/notification_list_controller.dart';
import 'package:nyachi/features/notifications/domain/notification_repository.dart';

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

  @override
  Future<NotificationPage> fetchPage({String? untilId}) => fetch!(untilId);

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
  final container = ProviderContainer(
    overrides: [
      sessionControllerProvider.overrideWith(
        () => _FakeSessionController(_account()),
      ),
      notificationRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('hydrates cache then refreshes and writes back', () async {
    final repository = _FakeRepository(cached: [_notification('n1')]);
    final firstPage = Completer<NotificationPage>();
    repository.fetch = (_) => firstPage.future;
    final container = await _makeContainer(repository);

    final provider = notificationListControllerProvider;
    container.listen(provider, (_, _) {});
    container.read(provider);
    await pumpEventQueue();

    var state = container.read(provider);
    expect(state.items.map((n) => n.id), ['n1']);
    expect(state.usingCache, isTrue);

    firstPage.complete(
      NotificationPage(items: [_notification('n2')], hasMore: true),
    );
    await pumpEventQueue();

    state = container.read(provider);
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

      final provider = notificationListControllerProvider;
      container.listen(provider, (_, _) {});
      await container.read(provider.notifier).refresh();
      await pumpEventQueue(); // let build()'s hydrate settle as well

      final state = container.read(provider);
      expect(state.error?.kind, AppFailureKind.unknown);
      expect(state.refreshing, isFalse);
      expect(state.items.map((n) => n.id), ['n1']);
      expect(state.usingCache, isTrue);
    },
  );

  test('markAllRead calls the repository and refreshes', () async {
    final repository = _FakeRepository(cached: const []);
    var calls = 0;
    repository.fetch = (_) async {
      calls++;
      return NotificationPage(items: const [], hasMore: false);
    };
    final container = await _makeContainer(repository);

    final provider = notificationListControllerProvider;
    container.listen(provider, (_, _) {});
    await pumpEventQueue(); // let build()'s hydrate refresh settle first
    final callsAfterHydrate = calls;

    final ok = await container.read(provider.notifier).markAllRead();

    expect(ok, isTrue);
    expect(repository.marksRead, 1);
    expect(calls, callsAfterHydrate + 1);
  });
}
