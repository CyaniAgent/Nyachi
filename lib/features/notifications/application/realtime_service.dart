// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/error_mapper.dart';

enum RealtimeStatus { idle, connecting, live, reconnecting, offline }

/// Builds the streaming client; overridable in tests.
typedef RealtimeClientFactory = MisskeyStreamingClient Function({
  required Uri baseUri,
  required TokenProvider tokenProvider,
});

/// One typed subscription on top of the shared connection.
///
/// [channel] is the Misskey channel to join and [eventType] the event within
/// it whose body is delivered; everything else on that channel (such as the
/// `connected` marker) is reported through [onConnected] instead of the body
/// stream.
class RealtimeSubscription<T> {
  const RealtimeSubscription({
    required this.channel,
    required this.eventType,
    required this.events,
    this.onConnected,
  });

  final StreamingChannel<T> channel;
  final String eventType;
  final StreamController<T> events;
  final void Function()? onConnected;
}

/// A single authenticated websocket carrying several channel subscriptions.
///
/// Mirrors [HomeStreamService]'s connection discipline - one client, backoff
/// on transport errors, no reconnect on an expired session, and a pause when
/// the app leaves the foreground - but fans out to any number of channels so
/// notifications and chat share one socket instead of one per feature.
class RealtimeService with WidgetsBindingObserver {
  RealtimeService({
    required this.baseUri,
    required this.tokenProvider,
    this.onSessionExpired,
    this.clientFactory,
    this.retainConnectionOnPause,
  });

  final Uri baseUri;
  final TokenProvider tokenProvider;

  /// Invoked when the stream fails with an authentication error.
  final void Function()? onSessionExpired;
  final RealtimeClientFactory? clientFactory;

  /// When it returns true, the [AppLifecycleState.paused] close is skipped and
  /// the socket keeps running in the background - the Android foreground
  /// service holds the process, so background notifications stay deliverable.
  /// Null or false keeps the default pause-when-backgrounded discipline.
  final bool Function()? retainConnectionOnPause;

  /// Channels joined on the current connection, keyed by a caller-chosen id so
  /// a late joiner can be added and removed while the socket stays open.
  final _subscriptions = <String, RealtimeSubscription<Object?>>{};

  final status = ValueNotifier<RealtimeStatus>(RealtimeStatus.idle);

  MisskeyStreamingClient? _client;
  final _channelSubscriptions =
      <StreamSubscription<StreamingChannelEvent<Object?>>>[];
  StreamSubscription<MisskeyStreamEvent>? _eventsSubscription;
  Timer? _reconnectTimer;
  var _attempt = 0;
  var _disposed = false;
  var _foreground = true;
  var _closing = false;
  var _connecting = false;

  static const _backoff = [1, 2, 4, 8, 16, 30];

  void start() {
    WidgetsBinding.instance.addObserver(this);
    unawaited(_connect());
  }

  Future<void> _connect() async {
    if (_disposed || _closing || _connecting || !_foreground) return;
    _connecting = true;
    try {
      _reconnectTimer?.cancel();
      status.value = _attempt == 0
          ? RealtimeStatus.connecting
          : RealtimeStatus.reconnecting;
      await _closeConnection();
      final client =
          clientFactory?.call(baseUri: baseUri, tokenProvider: tokenProvider) ??
          MisskeyStreamingClient(
            baseUri: baseUri,
            tokenProvider: tokenProvider,
          );
      _client = client;
      _eventsSubscription = client.events.listen((event) {
        if (event is MisskeyStreamError) {
          if (_handleFailure(mapFailure(event.error))) return;
          _scheduleReconnect();
        } else if (event is MisskeyDisconnected) {
          _scheduleReconnect();
        } else if (event is MisskeyConnected) {
          _attempt = 0;
          status.value = RealtimeStatus.live;
        }
      });
      for (final entry in _subscriptions.entries) {
        await _subscribeOne(client, entry.key, entry.value);
        // A close during setup leaves the client stale; stop rather than
        // subscribing the remaining channels on a dead connection.
        if (_disposed || _client != client) return;
      }
    } finally {
      _connecting = false;
    }
  }

  Future<void> _subscribeOne(
    MisskeyStreamingClient client,
    String id,
    RealtimeSubscription<Object?> subscription,
  ) async {
    try {
      final stream = await client
          .subscribe(subscription.channel)
          .timeout(const Duration(seconds: 15));
      if (_disposed || _client != client) return;
      _channelSubscriptions.add(
        stream.listen(
          (event) {
            if (event.type == subscription.eventType &&
                !subscription.events.isClosed) {
              subscription.events.add(event.body);
            }
            if (event.type == 'connected') {
              subscription.onConnected?.call();
              _attempt = 0;
              status.value = RealtimeStatus.live;
            }
          },
          onError: (Object e) {
            if (_handleFailure(mapFailure(e))) return;
            _scheduleReconnect();
          },
          onDone: _scheduleReconnect,
        ),
      );
    } catch (e) {
      if (_handleFailure(mapFailure(e))) return;
      _scheduleReconnect();
    }
  }

  /// Joins [subscription] under [id], joining it immediately when the socket
  /// is already live; otherwise the next connect picks it up.
  ///
  /// Returns a handle that leaves the channel again and cancels the body
  /// stream, so a closed thread stops receiving without disturbing the rest.
  StreamSubscription<void> join(
    String id,
    RealtimeSubscription<Object?> subscription,
  ) {
    _subscriptions[id] = subscription;
    final client = _client;
    if (client != null && !_disposed) {
      unawaited(_subscribeOne(client, id, subscription));
    }
    return _JoinHandle(this, id, subscription);
  }

  void _leave(String id) {
    _subscriptions.remove(id);
  }

  /// Expires the session on authentication failures and stops reconnecting.
  bool _handleFailure(AppFailure failure) {
    if (failure.kind != AppFailureKind.auth) return false;
    onSessionExpired?.call();
    _reconnectTimer?.cancel();
    status.value = RealtimeStatus.offline;
    scheduleMicrotask(() => unawaited(_closeConnection()));
    return true;
  }

  void reconnect() {
    if (_disposed || _closing || _connecting) return;
    _attempt = 0;
    _reconnectTimer?.cancel();
    unawaited(_connect());
  }

  void _scheduleReconnect() {
    if (_disposed || _closing || !_foreground) return;
    if (_reconnectTimer?.isActive ?? false) return;
    _closing = true;
    // Deferred: canceling the event subscription from inside its own callback
    // defers the cancellation forever, stalling every later close.
    scheduleMicrotask(() {
      unawaited(_closeConnection().whenComplete(() => _closing = false));
    });
    if (_attempt >= 5) {
      status.value = RealtimeStatus.offline;
      return;
    }
    final seconds = _backoff[_attempt.clamp(0, _backoff.length - 1)];
    _attempt++;
    status.value = RealtimeStatus.reconnecting;
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      _closing = false;
      unawaited(_connect());
    });
  }

  Future<void> _closeConnection() async {
    // Cancellations are fire-and-forget: awaiting them stalls every reconnect
    // when a close is triggered from inside a stream callback.
    for (final subscription in _channelSubscriptions) {
      unawaited(subscription.cancel());
    }
    _channelSubscriptions.clear();
    unawaited(_eventsSubscription?.cancel());
    _eventsSubscription = null;
    final client = _client;
    _client = null;
    await client?.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // The Android foreground service holds the process and the notification
      // path needs this socket; closing here would defeat it.
      if (retainConnectionOnPause?.call() == true) return;
      _foreground = false;
      _reconnectTimer?.cancel();
      unawaited(_closeConnection());
      status.value = RealtimeStatus.offline;
    } else if (state == AppLifecycleState.resumed) {
      if (_disposed || _connecting || _closing) return;
      _foreground = true;
      // A retained background connection is still live; only reconnect when
      // the pause actually closed the socket.
      if (_client != null) return;
      _attempt = 0;
      unawaited(_connect());
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _reconnectTimer?.cancel();
    unawaited(
      _closeConnection().whenComplete(() {
        for (final subscription in _subscriptions.values) {
          if (!subscription.events.isClosed) {
            unawaited(subscription.events.close());
          }
        }
        status.dispose();
      }),
    );
  }
}

/// Revokes one [RealtimeService.join]; canceling leaves the channel.
class _JoinHandle implements StreamSubscription<void> {
  _JoinHandle(this._service, this._id, this._subscription);

  final RealtimeService _service;
  final String _id;
  final RealtimeSubscription<Object?> _subscription;
  var _cancelled = false;

  @override
  Future<void> cancel() async {
    if (_cancelled) return;
    _cancelled = true;
    _service._leave(_id);
    if (!_subscription.events.isClosed) {
      unawaited(_subscription.events.close());
    }
  }

  @override
  void onData(void Function(void data)? handleData) {}

  @override
  void onError(Function? handleError) {}

  @override
  void onDone(void Function()? handleDone) {}

  @override
  void pause([Future<void>? resumeSignal]) {}

  @override
  void resume() {}

  @override
  bool get isPaused => false;

  @override
  Future<E> asFuture<E>([E? futureValue]) async => futureValue as E;
}
