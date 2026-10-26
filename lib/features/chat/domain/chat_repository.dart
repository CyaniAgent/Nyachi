// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:misskey_dart_api/misskey_dart_api.dart';

import 'chat_models.dart';

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
