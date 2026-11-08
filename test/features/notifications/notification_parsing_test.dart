// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/features/notifications/application/notification_list_controller.dart';

import '../../support/fixtures.dart';

Map<String, dynamic> _user() =>
    jsonDecode(jsonEncode(makeUser('u1').toJson())) as Map<String, dynamic>;

Map<String, dynamic> _note(String id) =>
    jsonDecode(jsonEncode(makeNote(id).toJson())) as Map<String, dynamic>;

void main() {
  test('a server-raised notification without an actor still parses', () {
    // The server sends `pollEnded` with `user: null` — nobody did it, the poll
    // simply closed. The generated model requires a UserLite, so the decoder
    // used to throw and the whole page failed.
    final page = parseNotificationPage([
      {
        'id': 'p1',
        'type': 'pollEnded',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'user': null,
        'userId': null,
        'note': _note('note-p1'),
      },
    ]);

    expect(page.items, hasLength(1));
    expect(page.items.single.id, 'p1');
  });

  test('a notification type newer than the SDK spec is kept', () {
    final page = parseNotificationPage([
      {
        'id': 'x1',
        'type': 'somethingNew',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'user': _user(),
        'userId': 'u1',
        'note': _note('note-x1'),
      },
      {
        'id': 'r1',
        'type': 'reaction',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'user': _user(),
        'userId': 'u1',
        'note': _note('note-r1'),
        'reaction': '👍',
      },
    ]);

    // The row is kept as an unknown variant instead of failing the page: the
    // SDK decodes anything its pinned spec does not describe.
    expect(page.items.map((item) => item.id), ['x1', 'r1']);
    expect(page.items.first, isA<NotificationUnknown>());
  });

  test('user containers the server omits are filled in', () {
    final user = _user()
      ..remove('avatarDecorations')
      ..remove('emojis')
      ..remove('onlineStatus');

    final page = parseNotificationPage([
      {
        'id': 'r2',
        'type': 'reaction',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'user': user,
        'userId': 'u1',
        'note': _note('note-r2'),
        'reaction': '👍',
      },
    ]);

    expect(page.items, hasLength(1));
  });

  test(
    'a page of unknown rows still reports pagination from the raw count',
    () {
      final rows = [
        for (var i = 0; i < 20; i++)
          {
            'id': 'u$i',
            'type': 'alsoNew',
            'createdAt': '2026-01-01T00:00:00.000Z',
          },
      ];

      // Nothing parsed, but the server did fill a page, so the list must not
      // conclude it reached the end.
      expect(parseNotificationPage(rows).hasMore, isTrue);
    },
  );
}
