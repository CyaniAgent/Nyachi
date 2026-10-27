// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/features/timeline/application/home_stream_service.dart';

import '../../support/fixtures.dart';

class _FakeStreamingClient extends Fake implements MisskeyStreamingClient {
  final eventsController = StreamController<MisskeyStreamEvent>.broadcast();
  final notesController =
      StreamController<StreamingChannelEvent<Note>>.broadcast();
  var closeCount = 0;

  @override
  Stream<MisskeyStreamEvent> get events => eventsController.stream;

  @override
  Future<Stream<StreamingChannelEvent<T>>> subscribe<T>(
    StreamingChannel<T> channel,
  ) async => notesController.stream as Stream<StreamingChannelEvent<T>>;

  @override
  Future<void> close() async => closeCount++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'connects once; reconnect during flight does not double-connect',
    () => fakeAsync((async) {
      late _FakeStreamingClient client;
      var created = 0;
      final service = HomeStreamService(
        baseUri: Uri.parse('https://misskey.test'),
        tokenProvider: () async => 'token',
        clientFactory: ({required baseUri, required tokenProvider}) {
          created++;
          return client = _FakeStreamingClient();
        },
      );
      addTearDown(service.dispose);

      service.start();
      expect(service.status.value, HomeStreamStatus.connecting);

      // The first connect is still in flight; a reconnect request must be
      // dropped by the _connecting guard instead of building a second client.
      service.reconnect();
      async.elapse(const Duration(milliseconds: 10));
      expect(created, 1);

      client.eventsController.add(const MisskeyConnected(subscriptionId: 's1'));
      async.flushMicrotasks();
      expect(service.status.value, HomeStreamStatus.live);
    }),
  );

  test(
    'note events flow through to the notes stream',
    () => fakeAsync((async) {
      late _FakeStreamingClient client;
      final service = HomeStreamService(
        baseUri: Uri.parse('https://misskey.test'),
        tokenProvider: () async => 'token',
        clientFactory: ({required baseUri, required tokenProvider}) =>
            client = _FakeStreamingClient(),
      );
      addTearDown(service.dispose);

      final notes = <Note>[];
      final subscription = service.notes.listen(notes.add);
      addTearDown(subscription.cancel);

      service.start();
      async.elapse(const Duration(milliseconds: 10));
      client.eventsController.add(const MisskeyConnected(subscriptionId: 's1'));

      client.notesController.add(
        StreamingChannelEvent<Note>(
          subscriptionId: 's1',
          channel: 'homeTimeline',
          type: 'note',
          body: makeNote('n1'),
        ),
      );
      async.flushMicrotasks();
      expect(notes.map((n) => n.id), ['n1']);
    }),
  );

  test(
    'authentication errors expire the session and stop reconnecting',
    () => fakeAsync((async) {
      late _FakeStreamingClient client;
      var created = 0;
      var expired = 0;
      final service = HomeStreamService(
        baseUri: Uri.parse('https://misskey.test'),
        tokenProvider: () async => 'token',
        onSessionExpired: () {
          expired++;
        },
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
      expect(service.status.value, HomeStreamStatus.live);

      client.notesController.addError(
        MisskeyAuthenticationException('expired', statusCode: 401),
      );
      async.flushMicrotasks();
      async.elapse(const Duration(milliseconds: 1));

      expect(expired, 1);
      expect(service.status.value, HomeStreamStatus.offline);

      // The backoff timer never gets scheduled, so no second client appears.
      async.elapse(const Duration(minutes: 1));
      expect(created, 1);
    }),
  );

  test(
    'transport errors reconnect with backoff',
    () => fakeAsync((async) {
      late _FakeStreamingClient client;
      var created = 0;
      final service = HomeStreamService(
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
      expect(service.status.value, HomeStreamStatus.live);

      client.eventsController.add(
        MisskeyStreamError(MisskeyStreamingException('socket reset')),
      );
      async.flushMicrotasks();
      expect(service.status.value, HomeStreamStatus.reconnecting);

      async.elapse(const Duration(seconds: 1));
      expect(created, 2);
    }),
  );
}
