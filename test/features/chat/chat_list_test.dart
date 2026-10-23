// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/features/chat/application/chat_controllers.dart';

import '../../support/fixtures.dart';

ChatMessage message({
  required String id,
  required UserLite from,
  UserLite? to,
  String? text,
  DateTime? at,
}) {
  return ChatMessage(
    id: id,
    createdAt: at ?? DateTime(2026),
    fromUserId: from.id,
    fromUser: from,
    toUserId: to?.id,
    toUser: to,
    text: text,
    reactions: const [],
  );
}

void main() {
  test('derives one conversation per counterpart with the latest message', () {
    final alice = makeUser('alice');
    final bob = makeUser('bob');
    final carol = makeUser('carol');
    final messages = [
      message(id: '1', from: alice, to: bob, at: DateTime(2026, 1, 1)),
      message(id: '2', from: bob, to: alice, at: DateTime(2026, 1, 2)),
      message(id: '3', from: alice, to: carol, at: DateTime(2026, 1, 3)),
      message(id: '4', from: bob, to: alice, at: DateTime(2026, 1, 4)),
    ];

    final conversations = deriveConversations(messages, 'alice');

    expect(conversations, hasLength(2));
    expect(conversations.first.peer.id, 'bob');
    expect(conversations.first.latest.id, '4');
    expect(conversations.last.peer.id, 'carol');
    expect(conversations.last.latest.id, '3');
  });
}
