// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:misskey_dart_api/misskey_dart_api.dart';

UserLite makeUser(String id, {String? name}) {
  return UserLite(
    id: id,
    name: name ?? id,
    username: id,
    host: null,
    avatarUrl: 'https://example.test/$id.png',
    avatarBlurhash: null,
    avatarDecorations: const [],
    emojis: const {},
    onlineStatus: OnlineStatus.unknown,
  );
}

Note makeNote(
  String id, {
  DateTime? createdAt,
  String? text = 'hello',
  UserLite? user,
}) {
  return Note(
    id: id,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
    text: text,
    userId: (user ?? makeUser('u1')).id,
    user: user ?? makeUser('u1'),
    visibility: NoteVisibility.public,
    reactionAcceptance: null,
    reactionEmojis: const {},
    reactions: const {},
    reactionCount: 0,
    renoteCount: 0,
    repliesCount: 0,
  );
}
