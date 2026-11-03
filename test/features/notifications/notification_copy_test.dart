// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/features/notifications/domain/notification_copy.dart';

import '../../support/fixtures.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('a mention copy names the actor and carries the note text', () {
    final note = makeNote('n1', text: 'hello there');
    final notification = NotificationMention(
      id: 'x1',
      createdAt: DateTime(2026),
      type: 'mention',
      user: makeUser('alice'),
      userId: 'alice',
      note: note,
    );

    final copy = notificationCopy(l10n, notification);

    expect(copy.title, '@alice mentioned you');
    expect(copy.body, 'hello there');
  });

  test('a follow copy has no body because no note is attached', () {
    final notification = NotificationFollow(
      id: 'x2',
      createdAt: DateTime(2026),
      type: 'follow',
      user: makeUser('bob'),
      userId: 'bob',
    );

    final copy = notificationCopy(l10n, notification);

    expect(copy.title, '@bob followed you');
    expect(copy.body, isEmpty);
  });

  test('the actor and note accessors agree with the copy', () {
    final note = makeNote('n1', text: 'quoted');
    final notification = NotificationQuote(
      id: 'x3',
      createdAt: DateTime(2027),
      type: 'quote',
      user: makeUser('carol'),
      userId: 'carol',
      note: note,
    );

    expect(notificationActor(notification)?.username, 'carol');
    expect(notificationNote(notification)?.id, 'n1');
    expect(notificationCreatedAt(notification), DateTime(2027));
  });
}
