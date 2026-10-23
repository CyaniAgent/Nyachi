// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/storage/app_database.dart';
import '../domain/chat_models.dart';

abstract interface class ChatRepository {
  Future<List<ChatMessage>> history();

  Future<List<ChatRoom>> rooms();

  Future<ChatThreadResult> thread(ChatTarget target, {String? untilId});

  Future<List<ChatMessageItem>> threadCache(ChatTarget target);

  Future<UserDetailed?> userHeader(String userId);

  Future<ChatRoom?> roomHeader(String roomId);

  Future<void> send(ChatTarget target, {String? text, String? fileId});

  Future<DriveFile> upload(List<int> bytes, String fileName);
}

class MisskeyChatRepository implements ChatRepository {
  MisskeyChatRepository({
    required this.client,
    required this.cache,
    required this.accountId,
  });

  final MisskeyClient client;
  final CacheDao cache;
  final String accountId;

  static const _historyKey = 'chat:history';
  static const _roomsKey = 'chat:rooms';

  String _threadKey(ChatTarget target) => switch (target) {
    ChatUserTarget(:final userId) => 'chat:user:$userId',
    ChatRoomTarget(:final roomId) => 'chat:room:$roomId',
  };

  @override
  Future<List<ChatMessage>> history() async {
    try {
      final items = await client.chat.history(limit: 100);
      await cache.write(
        accountId,
        _historyKey,
        jsonEncode(items.map((message) => message.toJson()).toList()),
      );
      return items;
    } catch (_) {
      final cached = await cache.read(accountId, _historyKey);
      if (cached == null) return const [];
      try {
        final decoded = jsonDecode(cached.payload);
        if (decoded is! List) return const [];
        return decoded
            .whereType<Map>()
            .map(
              (item) => ChatMessage.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false);
      } catch (_) {
        return const [];
      }
    }
  }

  @override
  Future<List<ChatRoom>> rooms() async {
    try {
      final joined = await client.chat.roomsJoining(limit: 100);
      final owned = await client.chat.roomsOwned(limit: 100);
      final byId = <String, ChatRoom>{};
      for (final membership in joined) {
        final room = membership.room;
        if (room != null) byId[room.id] = room;
      }
      for (final room in owned) {
        byId[room.id] = room;
      }
      final items = byId.values.toList(growable: false);
      await cache.write(
        accountId,
        _roomsKey,
        jsonEncode(items.map((room) => room.toJson()).toList()),
      );
      return items;
    } catch (_) {
      final cached = await cache.read(accountId, _roomsKey);
      if (cached == null) return const [];
      try {
        final decoded = jsonDecode(cached.payload);
        if (decoded is! List) return const [];
        return decoded
            .whereType<Map>()
            .map((item) => ChatRoom.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false);
      } catch (_) {
        return const [];
      }
    }
  }

  @override
  Future<ChatThreadResult> thread(ChatTarget target, {String? untilId}) async {
    late final List<ChatMessageItem> items;
    late final bool hasMore;
    switch (target) {
      case ChatUserTarget(:final userId):
        final page = await client.chat.messagesUserTimelinePage(
          userId: userId,
          limit: 20,
          untilId: untilId,
        );
        items =
            page.items
                .map(
                  (message) => ChatMessageItem(
                    id: message.id,
                    createdAt: message.createdAt,
                    fromUserId: message.fromUserId,
                    text: message.text,
                    file: message.file,
                  ),
                )
                .toList()
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        hasMore = page.hasMore;
      case ChatRoomTarget(:final roomId):
        final page = await client.chat.messagesRoomTimelinePage(
          roomId: roomId,
          limit: 20,
          untilId: untilId,
        );
        items =
            page.items
                .map(
                  (message) => ChatMessageItem(
                    id: message.id,
                    createdAt: message.createdAt,
                    fromUserId: message.fromUserId,
                    fromUser: message.fromUser,
                    text: message.text,
                    file: message.file,
                  ),
                )
                .toList()
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        hasMore = page.hasMore;
    }
    await _writeThread(target, items, merge: untilId != null);
    return ChatThreadResult(items: items, hasMore: hasMore);
  }

  Future<void> _writeThread(
    ChatTarget target,
    List<ChatMessageItem> items, {
    required bool merge,
  }) async {
    var outgoing = items;
    if (merge) {
      final existing = await readThreadCache(target);
      final byId = {for (final item in existing) item.id: item};
      for (final item in items) {
        byId[item.id] = item;
      }
      outgoing = byId.values.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    await cache.write(
      accountId,
      _threadKey(target),
      jsonEncode(outgoing.map((item) => item.toJson()).toList()),
    );
  }

  @override
  Future<List<ChatMessageItem>> threadCache(ChatTarget target) =>
      readThreadCache(target);

  Future<List<ChatMessageItem>> readThreadCache(ChatTarget target) async {
    final cached = await cache.read(accountId, _threadKey(target));
    if (cached == null) return const [];
    try {
      final decoded = jsonDecode(cached.payload);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map(
            (item) => ChatMessageItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<UserDetailed?> userHeader(String userId) async {
    final key = 'user:$userId';
    try {
      final user = await client.users.showByUserId(userId: userId);
      await cache.write(accountId, key, jsonEncode(user.toJson()));
      return user;
    } catch (_) {
      final cached = await cache.read(accountId, key);
      if (cached == null) return null;
      try {
        final json = jsonDecode(cached.payload);
        if (json is Map<String, dynamic>) return UserDetailed.fromJson(json);
        if (json is Map) {
          return UserDetailed.fromJson(Map<String, dynamic>.from(json));
        }
      } catch (_) {
        return null;
      }
      return null;
    }
  }

  @override
  Future<ChatRoom?> roomHeader(String roomId) async {
    final key = 'chat:room:$roomId';
    try {
      final room = await client.chat.roomsShow(roomId: roomId);
      await cache.write(accountId, key, jsonEncode(room.toJson()));
      return room;
    } catch (_) {
      final cached = await cache.read(accountId, key);
      if (cached == null) return null;
      try {
        final json = jsonDecode(cached.payload);
        if (json is Map<String, dynamic>) return ChatRoom.fromJson(json);
        if (json is Map) {
          return ChatRoom.fromJson(Map<String, dynamic>.from(json));
        }
      } catch (_) {
        return null;
      }
      return null;
    }
  }

  @override
  Future<void> send(ChatTarget target, {String? text, String? fileId}) async {
    switch (target) {
      case ChatUserTarget(:final userId):
        await client.chat.messagesCreateToUser(
          toUserId: userId,
          text: text,
          fileId: fileId,
        );
      case ChatRoomTarget(:final roomId):
        await client.chat.messagesCreateToRoom(
          toRoomId: roomId,
          text: text,
          fileId: fileId,
        );
    }
  }

  @override
  Future<DriveFile> upload(List<int> bytes, String fileName) {
    return client.drive.filesCreate(file: bytes, fileName: fileName);
  }
}
