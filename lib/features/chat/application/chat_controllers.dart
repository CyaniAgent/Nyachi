// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/storage/storage_providers.dart';
import '../data/chat_repository.dart';
import '../domain/chat_models.dart';
import '../domain/chat_repository.dart';

part 'chat_controllers.freezed.dart';
part 'chat_controllers.g.dart';

@freezed
abstract class ChatListState with _$ChatListState {
  const factory ChatListState({
    @Default([]) List<ChatConversation> direct,
    @Default([]) List<ChatRoom> rooms,
    @Default(true) bool loading,
    AppFailure? error,
  }) = _ChatListState;
}

@Riverpod(keepAlive: true)
class ChatListController extends _$ChatListController {
  late ChatRepository _repository;
  late String _me;
  var _disposed = false;

  @override
  ChatListState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    final active = ref.watch(sessionControllerProvider).active;
    if (active == null) throw StateError('No active account.');
    _me = active.userId;
    _repository = MisskeyChatRepository(
      client: ref.watch(misskeyClientProvider),
      cache: ref.watch(cacheDaoProvider),
      accountId: active.id,
    );
    unawaited(Future<void>.microtask(refresh));
    return const ChatListState();
  }

  Future<void> refresh() async {
    if (_disposed) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final results = await Future.wait([
        _repository.history(),
        _repository.rooms(),
      ]);
      if (_disposed) return;
      final messages = results[0] as List<ChatMessage>;
      final rooms = results[1] as List<ChatRoom>;
      state = state.copyWith(
        direct: deriveConversations(messages, _me),
        rooms: rooms,
        loading: false,
        error: null,
      );
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(loading: false, error: mapFailure(error));
    }
  }
}

List<ChatConversation> deriveConversations(
  List<ChatMessage> messages,
  String me,
) {
  final byPeer = <String, ChatConversation>{};
  for (final message in messages) {
    final peer = message.fromUserId == me ? message.toUser : message.fromUser;
    if (peer == null || peer.id == me) continue;
    final existing = byPeer[peer.id];
    if (existing == null ||
        message.createdAt.isAfter(existing.latest.createdAt)) {
      byPeer[peer.id] = ChatConversation(peer: peer, latest: message);
    }
  }
  final result = byPeer.values.toList()
    ..sort((a, b) => b.latest.createdAt.compareTo(a.latest.createdAt));
  return result;
}

@freezed
abstract class ChatThreadState with _$ChatThreadState {
  const factory ChatThreadState({
    @Default([]) List<ChatMessageItem> items,
    UserDetailed? user,
    ChatRoom? room,
    @Default(true) bool loading,
    @Default(false) bool loadingOlder,
    @Default(true) bool hasMore,
    @Default(false) bool sending,
    @Default(false) bool usingCache,
    AppFailure? error,
  }) = _ChatThreadState;
}

@riverpod
class ChatThreadController extends _$ChatThreadController {
  late ChatTarget _target;
  late ChatRepository _repository;
  var _disposed = false;

  @override
  ChatThreadState build(ChatTarget target) {
    _target = target;
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    final active = ref.watch(sessionControllerProvider).active;
    if (active == null) throw StateError('No active account.');
    _repository = MisskeyChatRepository(
      client: ref.watch(misskeyClientProvider),
      cache: ref.watch(cacheDaoProvider),
      accountId: active.id,
    );
    unawaited(Future<void>.microtask(_load));
    return const ChatThreadState();
  }

  Future<void> _load() async {
    final cached = await _repository.threadCache(_target);
    if (_disposed) return;
    if (cached.isNotEmpty) {
      state = state.copyWith(items: cached, loading: false, usingCache: true);
    }
    await refresh();
    await _loadHeader();
  }

  Future<void> _loadHeader() async {
    try {
      switch (_target) {
        case ChatUserTarget(:final userId):
          final user = await _repository.userHeader(userId);
          if (!_disposed) state = state.copyWith(user: user);
        case ChatRoomTarget(:final roomId):
          final room = await _repository.roomHeader(roomId);
          if (!_disposed) state = state.copyWith(room: room);
      }
    } catch (_) {
      // A missing header must not block the conversation itself.
    }
  }

  Future<void> refresh() async {
    if (_disposed) return;
    try {
      final page = await _repository.thread(_target);
      if (_disposed) return;
      state = state.copyWith(
        items: page.items,
        loading: false,
        hasMore: page.hasMore,
        usingCache: false,
        error: null,
      );
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(
        loading: false,
        usingCache: state.items.isNotEmpty || state.usingCache,
        error: mapFailure(error),
      );
    }
  }

  Future<void> loadOlder() async {
    if (_disposed ||
        state.loadingOlder ||
        !state.hasMore ||
        state.items.isEmpty) {
      return;
    }
    state = state.copyWith(loadingOlder: true, error: null);
    try {
      final page = await _repository.thread(
        _target,
        untilId: state.items.first.id,
      );
      if (_disposed) return;
      final byId = {for (final item in state.items) item.id: item};
      for (final item in page.items) {
        byId[item.id] = item;
      }
      final merged = byId.values.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      state = state.copyWith(
        items: merged,
        loadingOlder: false,
        hasMore: page.hasMore,
        error: null,
      );
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(loadingOlder: false, error: mapFailure(error));
    }
  }

  Future<bool> send({
    required String text,
    Uint8List? attachment,
    String? attachmentName,
  }) async {
    if (state.sending) return false;
    final trimmed = text.trim();
    if (trimmed.isEmpty && attachment == null) return false;
    state = state.copyWith(sending: true, error: null);
    try {
      String? fileId;
      if (attachment != null) {
        final file = await _repository.upload(
          attachment,
          attachmentName ?? 'attachment',
        );
        fileId = file.id;
      }
      await _repository.send(
        _target,
        text: trimmed.isEmpty ? null : trimmed,
        fileId: fileId,
      );
      if (_disposed) return true;
      await refresh();
      if (!_disposed) state = state.copyWith(sending: false);
      return true;
    } catch (error) {
      if (!_disposed) {
        state = state.copyWith(sending: false, error: mapFailure(error));
      }
      return false;
    }
  }
}
