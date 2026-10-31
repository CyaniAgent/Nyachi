// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/features/notes/presentation/emoji_text.dart';

void main() {
  const catalogue = [
    EmojiSimple(
      aliases: [],
      name: 'soukamo',
      category: null,
      url: 'https://files.example.test/soukamo.png',
    ),
    EmojiSimple(
      aliases: ['lol'],
      name: 'lmao',
      category: null,
      url: 'https://files.example.test/lmao.png',
    ),
  ];

  group('local reactions resolve from the instance catalogue', () {
    // Misskey marks a reaction on this instance's own emoji with `@.` and keeps
    // it out of reactionEmojis, so the catalogue is the only source. Treating
    // it as a remote shortcode left every such reaction as plain text.
    test(':name@.: uses the catalogue', () {
      expect(
        EmojiText.resolveUrl(':soukamo@.:', catalog: catalogue),
        'https://files.example.test/soukamo.png',
      );
    });

    test('a bare :name: uses the catalogue', () {
      expect(
        EmojiText.resolveUrl(':soukamo:', catalog: catalogue),
        'https://files.example.test/soukamo.png',
      );
    });

    test('an alias resolves to the same emoji', () {
      expect(
        EmojiText.resolveUrl(':lol@.:', catalog: catalogue),
        'https://files.example.test/lmao.png',
      );
    });

    test('the catalogue wins when reactionEmojis has no entry', () {
      expect(
        EmojiText.resolveUrl(':soukamo@.:', emojis: const {}),
        isNull,
        reason: 'without a catalogue the URL cannot be known',
      );
    });
  });

  group('remote reactions need the note map', () {
    test(':name@host: resolves from reactionEmojis', () {
      expect(
        EmojiText.resolveUrl(
          ':muri@misskey.io:',
          emojis: const {
            'muri@misskey.io': 'https://media.example.test/muri.png',
          },
        ),
        'https://media.example.test/muri.png',
      );
    });

    test('the local catalogue never answers a remote shortcode', () {
      expect(
        EmojiText.resolveUrl(':soukamo@other.test:', catalog: catalogue),
        isNull,
        reason: 'a local name must not stand in for another server\'s emoji',
      );
    });

    test('hasRemoteHost separates @. from a real host', () {
      expect(EmojiText.hasRemoteHost(':soukamo@.:'), isFalse);
      expect(EmojiText.hasRemoteHost(':soukamo:'), isFalse);
      expect(EmojiText.hasRemoteHost(':muri@misskey.io:'), isTrue);
      expect(EmojiText.hasRemoteHost('👍'), isFalse);
    });
  });
}
