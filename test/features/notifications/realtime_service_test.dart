// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/features/notifications/application/realtime_service.dart';

class _FakeStreamingClient extends Fake implements MisskeyStreamingClient {
  final eventsController = StreamController<MisskeyStreamEvent>.broadcast();
  final subscribed = <String>[];
  final channels = <StreamController<StreamingChannelEvent<JsonMap>>>{};
  var closeCount = 0;

  @override
  Stream<MisskeyStreamEvent> get events => eventsController.stream;

  @override
  Future<Stream<StreamingChannelEvent<T>>> subscribe<T>(
    StreamingChannel<T> channel,
  ) async {
    subscribed.add(channel.name);
    final controller = StreamController<StreamingChannelEvent<JsonMap>>();
    channels.add(controller);
    return controller.stream as Stream<StreamingChannelEvent<T>>;
  }

  @override
  Future<void> close() async => closeCount++;
}

/// Emits one event on the most recently subscribed channel.
void _emit(
  _FakeStreamingClient client, {
  required String type,
  required JsonMap body,
}) {
  client.channels.last.add(
    StreamingChannelEvent<JsonMap>(
      subscriptionId: 's1',
      channel: 'main',
      type: type,
      body: body,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('delivers only the configured event type to its stream', () {
    fakeAsync((async) {
      late _FakeStreamingClient client;
      final received = <JsonMap>[];
      final events = StreamController<JsonMap>.broadcast();
      final listen = events.stream.listen(received.add);
      addTearDown(listen.cancel);

      final service = RealtimeService(
        baseUri: Uri.parse('https://misskey.test'),
        tokenProvider: () async => 'token',
        clientFactory: ({required baseUri, required tokenProvider}) =>
            client = _FakeStreamingClient(),
      );
      addTearDown(service.dispose);

      service.join(
        'main',
        RealtimeSubscription<JsonMap>(
          channel: const MainChannel(),
          eventType: 'notification',
          events: events,
        ),
      );
      service.start();
      async.elapse(const Duration(milliseconds: 10));
      async.flushMicrotasks();

      // Noise on the same channel must not reach the notification stream.
      _emit(client, type: 'note', body: {'id': 'n1'});
      async.flushMicrotasks();
      expect(received, isEmpty);

      _emit(client, type: 'notification', body: {'id': 'a1'});
      async.flushMicrotasks();
      expect(received.map((body) => body['id']), ['a1']);
    });
  });

  test('a channel joined while live subscribes without a new connection', () {
    fakeAsync((async) {
      late _FakeStreamingClient client;
      var created = 0;
      final events = StreamController<JsonMap>.broadcast();
      final service = RealtimeService(
        baseUri: Uri.parse('https://misskey.test'),
        tokenProvider: () async => 'token',
        clientFactory: ({required baseUri, required tokenProvider}) {
          created++;
          return client = _FakeStreamingClient();
        },
      );
      addTearDown(service.dispose);

      service.start();
      async.elapse(const Duration(milliseconds: 10));
      async.flushMicrotasks();
      client.eventsController.add(const MisskeyConnected(subscriptionId: 's1'));
      async.flushMicrotasks();
      expect(service.status.value, RealtimeStatus.live);

      service.join(
        'chat',
        RealtimeSubscription<JsonMap>(
          channel: const RawChannel('chatRoom', params: {'roomId': 'r1'}),
          eventType: 'message',
          events: events,
        ),
      );
      async.elapse(const Duration(milliseconds: 10));
      async.flushMicrotasks();

      expect(client.subscribed, ['chatRoom']);
      expect(created, 1);
    });
  });

  test('canceling a join leaves the channel on the next connect', () {
    fakeAsync((async) {
      final clients = <_FakeStreamingClient>[];
      final events = StreamController<JsonMap>.broadcast();
      final service = RealtimeService(
        baseUri: Uri.parse('https://misskey.test'),
        tokenProvider: () async => 'token',
        clientFactory: ({required baseUri, required tokenProvider}) {
          final client = _FakeStreamingClient();
          clients.add(client);
          return client;
        },
      );
      addTearDown(service.dispose);

      final handle = service.join(
        'chat',
        RealtimeSubscription<JsonMap>(
          channel: const RawChannel('chatUser'),
          eventType: 'message',
          events: events,
        ),
      );
      service.start();
      async.elapse(const Duration(milliseconds: 10));
      async.flushMicrotasks();
      expect(clients.single.subscribed, ['chatUser']);

      unawaited(handle.cancel());
      async.flushMicrotasks();
      expect(events.isClosed, isTrue);

      // The reconnect builds a fresh client, and the canceled channel is not
      // joined on it: leaving must survive a new connection.
      service.reconnect();
      async.elapse(const Duration(seconds: 2));
      async.flushMicrotasks();
      expect(clients.length, 2);
      expect(clients.last.subscribed, isEmpty);
    });
  });

  test('authentication errors expire the session and stop reconnecting', () {
    fakeAsync((async) {
      late _FakeStreamingClient client;
      var created = 0;
      var expired = 0;
      final events = StreamController<JsonMap>.broadcast();
      final service = RealtimeService(
        baseUri: Uri.parse('https://misskey.test'),
        tokenProvider: () async => 'token',
        onSessionExpired: () => expired++,
        clientFactory: ({required baseUri, required tokenProvider}) {
          created++;
          return client = _FakeStreamingClient();
        },
      );
      addTearDown(service.dispose);

      service.join(
        'main',
        RealtimeSubscription<JsonMap>(
          channel: const MainChannel(),
          eventType: 'notification',
          events: events,
        ),
      );
      service.start();
      async.elapse(const Duration(milliseconds: 10));
      async.flushMicrotasks();
      client.eventsController.add(const MisskeyConnected(subscriptionId: 's1'));
      async.flushMicrotasks();
      expect(service.status.value, RealtimeStatus.live);

      client.channels.last.addError(
        MisskeyAuthenticationException('expired', statusCode: 401),
      );
      async.flushMicrotasks();
      async.elapse(const Duration(milliseconds: 1));

      expect(expired, 1);
      expect(service.status.value, RealtimeStatus.offline);
      // The backoff timer never gets scheduled, so no second client appears.
      async.elapse(const Duration(minutes: 1));
      expect(created, 1);
    });
  });
}
