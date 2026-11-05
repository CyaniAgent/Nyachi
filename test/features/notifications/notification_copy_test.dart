// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter/widgets.dart' show basicLocaleListResolution;
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/platform/residency.dart'
    show SystemNotificationCategory;
import 'package:nyachi/features/notifications/domain/notification_copy.dart';

import '../../support/fixtures.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('an unsupported system language falls back to the first supported', () {
    // The announce path resolves the device locale through this function; a
    // French device must land on en, never on a locale the lookup throws on.
    final resolved = basicLocaleListResolution(const [
      Locale('fr'),
    ], AppLocalizations.supportedLocales);
    expect(AppLocalizations.supportedLocales.contains(resolved), isTrue);
    expect(lookupAppLocalizations(resolved).localeName, 'en');
  });

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

  test('scheduled-post events route to the system category', () {
    final posted = Notification.fromJson({
      'id': 's1',
      'type': 'scheduledNotePosted',
      'createdAt': '2026-01-01T00:00:00.000Z',
      'note': jsonDecode(jsonEncode(makeNote('n9').toJson())),
    });
    final failed = Notification.fromJson({
      'id': 's2',
      'type': 'scheduledNotePostFailed',
      'createdAt': '2026-01-01T00:00:00.000Z',
      'noteDraft': {
        'id': 'd1',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'text': 'scheduled draft',
        'cw': null,
        'userId': 'u1',
        'user': jsonDecode(jsonEncode(makeUser('u1').toJson())),
        'replyId': null,
        'renoteId': null,
        'visibility': 'public',
        'visibleUserIds': const [],
        'fileIds': const [],
        'hashtag': null,
        'poll': null,
        'channelId': null,
        'localOnly': false,
        'reactionAcceptance': null,
        'scheduledAt': null,
        'isActuallyScheduled': true,
      },
    });

    expect(notificationCategory(posted), SystemNotificationCategory.system);
    expect(notificationCategory(failed), SystemNotificationCategory.system);
  });
}
