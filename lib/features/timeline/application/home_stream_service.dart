// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/storage/storage_providers.dart';

part 'home_stream_service.g.dart';

enum HomeStreamStatus { idle, connecting, live, reconnecting, offline }

/// Builds the streaming client; overridable in tests.
typedef StreamingClientFactory = MisskeyStreamingClient Function({
  required Uri baseUri,
  required TokenProvider tokenProvider,
});

class HomeStreamService with WidgetsBindingObserver {
  HomeStreamService({
    required this.baseUri,
    required this.tokenProvider,
    this.onSessionExpired,
    this.clientFactory,
  });

  final Uri baseUri;
  final TokenProvider tokenProvider;

  /// Invoked when the stream fails with an authentication error: the session
  /// is expired and the stream stops reconnecting.
  final void Function()? onSessionExpired;

  /// Defaults to [MisskeyStreamingClient.new]; overridden in tests.
  final StreamingClientFactory? clientFactory;

  final _notes = StreamController<Note>.broadcast();
  final status = ValueNotifier<HomeStreamStatus>(HomeStreamStatus.idle);

  MisskeyStreamingClient? _client;
  StreamSubscription<StreamingChannelEvent<Note>>? _notesSubscription;
  StreamSubscription<MisskeyStreamEvent>? _eventsSubscription;
  Timer? _reconnectTimer;
  var _attempt = 0;
  var _disposed = false;
  var _foreground = true;
  var _closing = false;
  var _connecting = false;

  static const _backoff = [1, 2, 4, 8, 16, 30];

  Stream<Note> get notes => _notes.stream;

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
          ? HomeStreamStatus.connecting
          : HomeStreamStatus.reconnecting;
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
          status.value = HomeStreamStatus.live;
        }
      });
      try {
        final stream = await client
            .subscribe(const TimelineChannel(TimelineKind.home))
            .timeout(const Duration(seconds: 15));
        if (_disposed || _client != client) return;
        _notesSubscription = stream.listen(
          (event) {
            if (event.type == 'note' && !_notes.isClosed) {
              _notes.add(event.body);
            }
            if (event.type == 'connected') {
              _attempt = 0;
              status.value = HomeStreamStatus.live;
            }
          },
          onError: (Object e) {
            if (_handleFailure(mapFailure(e))) return;
            _scheduleReconnect();
          },
          onDone: _scheduleReconnect,
        );
      } catch (e) {
        if (_handleFailure(mapFailure(e))) return;
        _scheduleReconnect();
      }
    } finally {
      _connecting = false;
    }
  }

  /// Expires the session on authentication failures and stops reconnecting.
  /// Returns true when the failure was handled as an expired session.
  bool _handleFailure(AppFailure failure) {
    if (failure.kind != AppFailureKind.auth) return false;
    onSessionExpired?.call();
    _reconnectTimer?.cancel();
    status.value = HomeStreamStatus.offline;
    // Deferred: see the comment in _scheduleReconnect.
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
    // Deferred: canceling the event subscription from inside its own
    // callback defers the cancellation forever, stalling every later close.
    scheduleMicrotask(() {
      unawaited(_closeConnection().whenComplete(() => _closing = false));
    });
    if (_attempt >= 5) {
      status.value = HomeStreamStatus.offline;
      return;
    }
    final seconds = _backoff[_attempt.clamp(0, _backoff.length - 1)];
    _attempt++;
    status.value = HomeStreamStatus.reconnecting;
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      _closing = false;
      unawaited(_connect());
    });
  }

  Future<void> _closeConnection() async {
    // Cancellations are fire-and-forget: awaiting their completion futures
    // stalls every reconnect when a close is triggered from inside a stream
    // callback (broadcast cancellation defers until the dispatch ends).
    unawaited(_notesSubscription?.cancel());
    _notesSubscription = null;
    unawaited(_eventsSubscription?.cancel());
    _eventsSubscription = null;
    final client = _client;
    _client = null;
    await client?.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _foreground = false;
      _reconnectTimer?.cancel();
      unawaited(_closeConnection());
      status.value = HomeStreamStatus.offline;
    } else if (state == AppLifecycleState.resumed) {
      if (_disposed || _connecting || _closing) return;
      _foreground = true;
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
        if (!_notes.isClosed) unawaited(_notes.close());
        status.dispose();
      }),
    );
  }
}

@riverpod
HomeStreamService homeStream(Ref ref) {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) {
    throw StateError('Home streaming requires an active account.');
  }
  final client = ref.watch(misskeyClientProvider);
  final tokens = ref.watch(tokenStoreProvider);
  final service = HomeStreamService(
    baseUri: client.baseUri,
    tokenProvider: () => tokens.read(active.id),
    onSessionExpired: () =>
        ref.read(sessionControllerProvider.notifier).expireActiveAccount(),
  )..start();
  ref.onDispose(service.dispose);
  return service;
}
