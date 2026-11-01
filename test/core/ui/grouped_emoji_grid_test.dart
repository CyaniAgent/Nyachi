// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/ui/grouped_emoji_grid.dart';

EmojiSimple _emoji(String name, String? category) => EmojiSimple(
  aliases: const [],
  name: name,
  category: category,
  url: 'https://example.test/$name.png',
);

Widget _app(List<EmojiSimple> emojis, {List<EmojiSimple>? picked}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 400,
        child: GroupedEmojiGrid(
          emojis: emojis,
          crossAxisCount: 6,
          otherLabel: 'Other',
          onPick: (emoji) => picked?.add(emoji),
        ),
      ),
    ),
  );
}

void main() {
  test('grouping keeps first-appearance order with uncategorized last', () {
    final groups = GroupedEmojiGrid.group([
      _emoji('a', 'art'),
      _emoji('b', null),
      _emoji('c', 'food'),
      _emoji('d', ''),
      _emoji('e', 'art'),
    ]);

    expect(groups.keys.toList(), ['art', 'food', null]);
    expect(groups['art'], hasLength(2));
    expect(groups[null], hasLength(2));
  });

  testWidgets('renders one sticky header per category and an other group', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app([
        _emoji('cat', 'art'),
        _emoji('smile', 'face'),
        _emoji('misc', null),
      ]),
    );
    await tester.pump();

    expect(find.text('art'), findsOneWidget);
    expect(find.text('face'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    // Empty categories are not rendered.
    expect(find.text('food'), findsNothing);
  });

  testWidgets('tapping an emoji hands it to onPick', (tester) async {
    final picked = <EmojiSimple>[];
    await tester.pumpWidget(_app([_emoji('cat', 'art')], picked: picked));
    await tester.pump();

    await tester.tap(find.byTooltip('cat'));
    await tester.pump();

    expect(picked.single.name, 'cat');
  });
}
