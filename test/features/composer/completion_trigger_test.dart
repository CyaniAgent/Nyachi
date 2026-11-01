// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/features/composer/domain/completion_trigger.dart';

void main() {
  group('triggerAt', () {
    test('finds a mention token at the caret', () {
      const text = 'hello @ali';
      final trigger = triggerAt(text, text.length);
      expect(trigger, isNotNull);
      expect(trigger!.kind, CompletionKind.mention);
      expect(trigger.query, 'ali');
      expect(trigger.start, 6);
      expect(trigger.end, text.length);
    });

    test('finds a hashtag token', () {
      const text = 'tag #flut';
      final trigger = triggerAt(text, text.length)!;
      expect(trigger.kind, CompletionKind.hashtag);
      expect(trigger.query, 'flut');
      expect(trigger.start, 4);
    });

    test('finds an emoji shortcode token', () {
      const text = 'cute :blob';
      final trigger = triggerAt(text, text.length)!;
      expect(trigger.kind, CompletionKind.emoji);
      expect(trigger.query, 'blob');
    });

    test('does not open on a bare trigger character', () {
      expect(triggerAt('hello @', 7), isNull);
      expect(triggerAt('hello #', 7), isNull);
      expect(triggerAt('hello :', 7), isNull);
    });

    test('ignores a trigger glued to a preceding word', () {
      expect(triggerAt('mail@host', 9), isNull);
      expect(triggerAt('C#', 2), isNull);
      expect(triggerAt('10:30', 5), isNull);
    });

    test('stops at whitespace and further triggers', () {
      expect(triggerAt('hello @ali there', 16), isNull);
      expect(triggerAt('hello #a b', 11), isNull);
      // A second trigger starts its own token: the scan stops at a break.
      final second = triggerAt('#one #two', 9)!;
      expect(second.query, 'two');
    });

    test('rejects non-name characters inside an emoji shortcode', () {
      expect(triggerAt('a :b!', 6), isNull);
    });

    test('rejects a remote mention, which has two at-signs', () {
      expect(triggerAt('@user@host', 10), isNull);
    });

    test('returns null for a caret inside a closed token', () {
      const text = 'hello @ali world';
      expect(triggerAt(text, 6), isNull);
    });
  });

  group('CompletionTrigger.apply', () {
    test('replaces the token, keeps following text and the caret past it', () {
      const text = 'hi @ali there';
      final trigger = triggerAt(text, 7)!;
      final applied = trigger.apply(text, '@alice');
      // The existing space already separates, so no second one is added.
      expect(applied.text, 'hi @alice there');
      expect(applied.caret, 9);
      expect(applied.text.substring(0, applied.caret), 'hi @alice');
    });

    test('adds a separating space at the end of the input', () {
      const text = 'hi @ali';
      final trigger = triggerAt(text, 7)!;
      final applied = trigger.apply(text, '@alice');
      expect(applied.text, 'hi @alice ');
      expect(applied.caret, 10);
    });

    test('replaces an emoji token with its shortcode', () {
      const text = ':blo';
      final trigger = triggerAt(text, 4)!;
      final applied = trigger.apply(text, ':blobcat:');
      expect(applied.text, ':blobcat: ');
      expect(applied.caret, 10);
    });
  });
}
