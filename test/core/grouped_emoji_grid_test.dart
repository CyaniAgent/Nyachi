// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/ui/grouped_emoji_grid.dart';

EmojiSimple _emoji(String name, {String? category}) => EmojiSimple(
  aliases: const [],
  name: name,
  category: category,
  url: 'https://example.test/$name.png',
);

void main() {
  group('GroupedEmojiGrid.group', () {
    test('groups by category in first-appearance order', () {
      final groups = GroupedEmojiGrid.group([
        _emoji('a', category: 'Smileys'),
        _emoji('b', category: 'Nature'),
        _emoji('c', category: 'Smileys'),
      ]);

      expect(groups.keys.toList(), ['Smileys', 'Nature']);
      expect(groups['Smileys']!.map((e) => e.name), ['a', 'c']);
      expect(groups['Nature']!.map((e) => e.name), ['b']);
    });

    test('uncategorized emoji collect under the null key and render last', () {
      final groups = GroupedEmojiGrid.group([
        _emoji('loose'),
        _emoji('a', category: 'Smileys'),
        _emoji('alsoLoose'),
      ]);

      // The null group is moved to the end regardless of where it appeared.
      expect(groups.keys.last, isNull);
      expect(groups[null]!.map((e) => e.name), ['loose', 'alsoLoose']);
    });

    test('an empty category counts as uncategorized', () {
      final groups = GroupedEmojiGrid.group([_emoji('a', category: '')]);

      expect(groups.keys.single, isNull);
    });
  });

  testWidgets('the grid pins a sticky header per category', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GroupedEmojiGrid(
            emojis: [
              _emoji('a', category: 'Smileys'),
              _emoji('b', category: 'Nature'),
              _emoji('c'),
            ],
            onPick: (_) {},
            otherLabel: 'Other',
            crossAxisCount: 4,
          ),
        ),
      ),
    );

    expect(find.text('Smileys'), findsOneWidget);
    expect(find.text('Nature'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    // Sticky behaviour comes from a pinned persistent header, not a plain row.
    final headers = tester.widgetList<SliverPersistentHeader>(
      find.byType(SliverPersistentHeader),
    );
    expect(headers, hasLength(3));
    expect(headers.every((header) => header.pinned), isTrue);
  });
}
