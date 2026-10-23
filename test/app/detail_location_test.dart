// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/app/detail_panel/detail_location.dart';

void main() {
  test('round-trips every detail location', () {
    final locations = <DetailLocation>[
      const NoteDetailLocation('n1'),
      const UserDetailLocation('u1'),
      const TagDetailLocation('foo bar'),
      const ComposeDetailLocation(null),
      const ComposeDetailLocation('n1'),
      const ChatUserDetailLocation('u1'),
      const ChatRoomDetailLocation('r1'),
      const SettingsDetailLocation(),
      const SettingsAccountsLocation(),
      const SettingsNavigationLocation(),
      const SettingsAppearanceLocation(),
      const SettingsAboutLocation(),
      const AddAccountLocation(),
    ];

    for (final location in locations) {
      final parsed = DetailLocation.parse(location.location);
      expect(parsed, location, reason: location.location);
      if (parsed != null) {
        expect(detailPathFor(parsed), location.location);
      }
    }
  });

  test('decodes encoded path parameters', () {
    expect(
      DetailLocation.parse('/tags/foo%20bar'),
      const TagDetailLocation('foo bar'),
    );
    expect(
      DetailLocation.parse('/notes/a%2Fb'),
      const NoteDetailLocation('a/b'),
    );
    expect(
      DetailLocation.parse('/compose?replyId=n%201'),
      const ComposeDetailLocation('n 1'),
    );
  });

  test('rejects non-detail and external locations', () {
    for (final value in [
      '',
      'login',
      '/login',
      '/',
      '/notes',
      '/notes/n1/extra',
      'https://example.test/notes/n1',
      '//example.test/notes/n1',
      '/unknown',
      '/settings/unknown',
      '/add-account/extra',
      '/notes/n1#fragment',
    ]) {
      expect(DetailLocation.parse(value), isNull, reason: value);
    }
  });
}
