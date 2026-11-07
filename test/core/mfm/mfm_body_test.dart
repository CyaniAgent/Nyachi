// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/mfm/mfm_body.dart';
import 'package:nyachi/core/mfm/mfm_document.dart';
import 'package:nyachi/core/mfm/mfm_motion.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The text a body actually renders, with embedded widgets flattened the way
/// Flutter's selection does it.
String _renderedText(WidgetTester tester) {
  final text = tester.widget<Text>(find.byType(Text).first);
  return text.textSpan!.toPlainText(includeSemanticsLabels: false);
}

/// The first span of the rendered paragraph.
TextSpan _rootSpan(WidgetTester tester) =>
    tester.widget<Text>(find.byType(Text).first).textSpan! as TextSpan;

Future<void> _pump(
  WidgetTester tester,
  String text, {
  Map<String, String>? emojis,
  bool detail = false,
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final shared = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(shared)],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MfmBody(text: text, emojis: emojis, detail: detail),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUp(MfmDocument.clearCacheForTest);

  testWidgets('a note body is selectable', (tester) async {
    await _pump(tester, 'hello world');

    expect(find.byType(SelectionArea), findsOneWidget);
    expect(_renderedText(tester), 'hello world');
  });

  testWidgets('links and hashtags stay real text', (tester) async {
    await _pump(tester, 'see https://example.test/a #tag');

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

    expect(_renderedText(tester), 'hi \uFFFC there');
  });

  testWidgets('bold text carries a bold style', (tester) async {
    await _pump(tester, '**hi**');

    final bold = _rootSpan(tester).children!
        .whereType<TextSpan>()
        .firstWhere((span) => span.text == 'hi');
    expect(bold.style?.fontWeight, FontWeight.bold);
  });

  testWidgets('italic is detected by runtime type', (tester) async {
    // mfm_parser labels MfmItalic with type "small"; only the runtime type
    // distinguishes it, so this guards the discriminator.
    await _pump(tester, '*hi*');

    final italic = _rootSpan(tester).children!
        .whereType<TextSpan>()
        .firstWhere((span) => span.text == 'hi');
    expect(italic.style?.fontStyle, FontStyle.italic);
  });

  testWidgets('an unknown function is shown as written', (tester) async {
    await _pump(tester, r'$[nope hi]');

    expect(_renderedText(tester), contains(r'$[nope hi]'));
  });

  testWidgets('x2 doubles the font size', (tester) async {
    await _pump(tester, r'$[x2 big]');

    final span = _rootSpan(tester).children!
        .whereType<TextSpan>()
        .firstWhere((span) => span.text == 'big');
    expect(span.style?.fontSize, greaterThan(28));
  });

  testWidgets('the timeline renders no motion widget', (tester) async {
    await _pump(tester, r'$[spin x]');

    // Default mode is detailOnly, so a timeline note stays static.
    expect(find.byType(MfmMotion), findsNothing);
    expect(_renderedText(tester), 'x');
  });

  testWidgets('a detail body animates', (tester) async {
    await _pump(tester, r'$[spin x]', detail: true);

    expect(find.byType(MfmMotion), findsOneWidget);
  });

  testWidgets('motion off keeps the words', (tester) async {
    await _pump(
      tester,
      r'$[spin x]',
      detail: true,
      prefs: {'mfm.motionMode': 'off'},
    );

    expect(find.byType(MfmMotion), findsNothing);
    expect(_renderedText(tester), 'x');
  });

  testWidgets('a code block keeps its layout', (tester) async {
    await _pump(tester, '```\nline one\nline two\n```');

    expect(find.text('line one\nline two'), findsOneWidget);
  });

  testWidgets('a quote keeps its content', (tester) async {
    await _pump(tester, '> quoted words');

    expect(find.textContaining('quoted words'), findsWidgets);
  });

  testWidgets('paragraphs and blocks are layout neighbours', (tester) async {
    await _pump(tester, 'intro\n\n> quoted');

    // A paragraph and a quote are separate widgets so the quote can carry its
    // own border, but both sit in the same scroll body.
    expect(find.textContaining('intro'), findsWidgets);
    expect(find.textContaining('quoted'), findsWidgets);
    expect(find.byType(Text).evaluate().length, greaterThanOrEqualTo(2));
  });

  test('a cross-block selection restores placeholders in block order', () {
    // Two paragraphs joined the way the selection sees them; the emoji lives
    // in the second one.
    const flattened = 'first\n\uFFFC second';
    expect(
      restoreEmojiPlaceholders(flattened, flattened, [
        (offset: 6, text: ':wave:'),
      ]),
      'first\n:wave: second',
    );
  });

  group('restoreEmojiPlaceholders', () {
    const flattened = 'hi \uFFFC there';

    test('a whole-note selection copies the shortcode', () {
      expect(
        restoreEmojiPlaceholders(flattened, flattened, [
          (offset: 3, text: ':wave:'),
        ]),
        'hi :wave: there',
      );
    });

    test('a partial selection containing the emoji copies the shortcode', () {
      expect(
        restoreEmojiPlaceholders('\uFFFC the', flattened, [
          (offset: 3, text: ':wave:'),
        ]),
        ':wave: the',
      );
    });

    test('a selection after the emoji is left alone', () {
      expect(
        restoreEmojiPlaceholders('there', flattened, [
          (offset: 3, text: ':wave:'),
        ]),
        'there',
      );
    });

    test('several emoji are each restored in order', () {
      const text = 'a\uFFFCb\uFFFCc';
      expect(
        restoreEmojiPlaceholders(text, text, [
          (offset: 1, text: ':one:'),
          (offset: 3, text: ':two:'),
        ]),
        'a:one:b:two:c',
      );
    });
  });
}
