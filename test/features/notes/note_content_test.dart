// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/features/notes/presentation/note_content.dart';

/// The text a note body actually renders, with embedded widgets flattened the
/// way Flutter's selection does it.
String _renderedText(WidgetTester tester) {
  final text = tester.widget<Text>(find.byType(Text));
  return text.textSpan!.toPlainText(includeSemanticsLabels: false);
}

Future<void> _pump(
  WidgetTester tester,
  String text, {
  Map<String, String>? emojis,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: NoteContent(text: text, emojis: emojis),
      ),
    ),
  );
}

void main() {
  testWidgets('a note body is selectable', (tester) async {
    await _pump(tester, 'hello world');

    // Without this wrapper the note cannot be copied at all.
    expect(find.byType(SelectionArea), findsOneWidget);
    expect(_renderedText(tester), 'hello world');
  });

  testWidgets('links and hashtags stay real text', (tester) async {
    await _pump(tester, 'see https://example.test/a #tag');

    // They used to be embedded widgets, which the selection flattens to
    // U+FFFC — so copying a note produced garbage instead of the URL.
    expect(_renderedText(tester), 'see https://example.test/a #tag');
  });

  testWidgets('custom emoji renders as an image but stays one character', (
    tester,
  ) async {
    await _pump(
      tester,
      'hi :wave: there',
      emojis: {'wave': 'https://example.test/wave.png'},
    );

    // One placeholder character stands in for the image.
    expect(_renderedText(tester), 'hi \uFFFC there');
  });

  group('restoreEmojiPlaceholders', () {
    const flattened = 'hi \uFFFC there';

    test('a whole-note selection copies the shortcode', () {
      expect(
        restoreEmojiPlaceholders(flattened, flattened, [
          (offset: 3, shortcode: ':wave:'),
        ]),
        'hi :wave: there',
      );
    });

    test('a partial selection containing the emoji copies the shortcode', () {
      expect(
        restoreEmojiPlaceholders('\uFFFC the', flattened, [
          (offset: 3, shortcode: ':wave:'),
        ]),
        ':wave: the',
      );
    });

    test('a selection after the emoji is left alone', () {
      expect(
        restoreEmojiPlaceholders('there', flattened, [
          (offset: 3, shortcode: ':wave:'),
        ]),
        'there',
      );
    });

    test('several emoji are each restored in order', () {
      const text = 'a\uFFFCb\uFFFCc';
      expect(
        restoreEmojiPlaceholders(text, text, [
          (offset: 1, shortcode: ':one:'),
          (offset: 3, shortcode: ':two:'),
        ]),
        'a:one:b:two:c',
      );
    });
  });
}
