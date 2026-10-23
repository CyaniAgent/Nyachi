// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

part 'chat_models.freezed.dart';

@freezed
sealed class ChatTarget with _$ChatTarget {
  const factory ChatTarget.user(String userId) = ChatUserTarget;
  const factory ChatTarget.room(String roomId) = ChatRoomTarget;
}

class ChatMessageItem {
  const ChatMessageItem({
    required this.id,
    required this.createdAt,
    required this.fromUserId,
    this.fromUser,
    this.text,
    this.file,
  });

  final String id;
  final DateTime createdAt;
  final String fromUserId;
  final UserLite? fromUser;
  final String? text;
  final DriveFile? file;

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) {
    final file = json['file'];
    final user = json['fromUser'];
    return ChatMessageItem(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fromUserId: json['fromUserId'] as String,
      fromUser: user is Map
          ? UserLite.fromJson(Map<String, dynamic>.from(user))
          : null,
      text: json['text'] as String?,
      file: file is Map
          ? DriveFile.fromJson(Map<String, dynamic>.from(file))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'fromUserId': fromUserId,
    if (fromUser != null) 'fromUser': fromUser!.toJson(),
    if (text != null) 'text': text,
    if (file != null) 'file': file!.toJson(),
  };
}

class ChatConversation {
  const ChatConversation({required this.peer, required this.latest});

  final UserLite peer;
  final ChatMessage latest;
}

class ChatThreadResult {
  const ChatThreadResult({required this.items, required this.hasMore});

  final List<ChatMessageItem> items;
  final bool hasMore;
}
