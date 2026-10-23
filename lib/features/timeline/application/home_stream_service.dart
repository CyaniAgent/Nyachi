// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/storage/storage_providers.dart';

part 'home_stream_service.g.dart';

enum HomeStreamStatus { idle, connecting, live, reconnecting, offline }

class HomeStreamService with WidgetsBindingObserver {
  HomeStreamService({required this.baseUri, required this.tokenProvider});

  final Uri baseUri;
  final TokenProvider tokenProvider;

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

  static const _backoff = [1, 2, 4, 8, 16, 30];

  Stream<Note> get notes => _notes.stream;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    unawaited(_connect());
  }

  Future<void> _connect() async {
    if (_disposed || _closing || !_foreground) return;
    _reconnectTimer?.cancel();
    status.value = _attempt == 0
        ? HomeStreamStatus.connecting
        : HomeStreamStatus.reconnecting;
    await _closeConnection();
    final client = MisskeyStreamingClient(
      baseUri: baseUri,
      tokenProvider: tokenProvider,
    );
    _client = client;
    _eventsSubscription = client.events.listen((event) {
      if (event is MisskeyStreamError) {
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
        onError: (Object _) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void reconnect() {
    if (_disposed || _closing) return;
    _attempt = 0;
    _reconnectTimer?.cancel();
    unawaited(_connect());
  }

  void _scheduleReconnect() {
    if (_disposed || _closing || !_foreground) return;
    if (_reconnectTimer?.isActive ?? false) return;
    _closing = true;
    unawaited(_closeConnection().whenComplete(() => _closing = false));
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
    _closing = true;
    await _notesSubscription?.cancel();
    _notesSubscription = null;
    await _eventsSubscription?.cancel();
    _eventsSubscription = null;
    final client = _client;
    _client = null;
    await client?.close();
    _closing = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _foreground = false;
      _reconnectTimer?.cancel();
      unawaited(_closeConnection());
      status.value = HomeStreamStatus.offline;
    } else if (state == AppLifecycleState.resumed) {
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
  )..start();
  ref.onDispose(service.dispose);
  return service;
}
