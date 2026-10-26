// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/features/notes/presentation/emoji_text.dart';

EmojiSimple _local(String name, String url, {List<String> aliases = const []}) {
  return EmojiSimple(name: name, category: null, aliases: aliases, url: url);
}

void main() {
  group('EmojiText.resolveUrl', () {
    test('uses the note map for a remote emoji instead of guessing a URL', () {
      final url = EmojiText.resolveUrl(
        ':blobcat@remote.example:',
        emojis: const {
          'blobcat@remote.example': 'https://remote.example/emoji/blobcat.webp',
        },
      );
      expect(url, 'https://remote.example/emoji/blobcat.webp');
    });

    test('resolves a local shortcode from the note map', () {
      final url = EmojiText.resolveUrl(
        ':nyachi:',
        emojis: const {'nyachi': 'https://local.example/emoji/nyachi.webp'},
      );
      expect(url, 'https://local.example/emoji/nyachi.webp');
    });

    test('falls back to the local catalogue only for local shortcodes', () {
      final catalog = [
        _local('nyachi', 'https://local.example/emoji/nyachi.webp'),
      ];
      expect(
        EmojiText.resolveUrl(':nyachi:', catalog: catalog),
        'https://local.example/emoji/nyachi.webp',
      );
      // A remote shortcode must never be resolved from the local catalogue,
      // even when the bare name matches.
      expect(
        EmojiText.resolveUrl(':nyachi@remote.example:', catalog: catalog),
        isNull,
      );
    });

    test('a remote emoji stays unresolved when the note has no mapping', () {
      expect(
        EmojiText.resolveUrl(
          ':blobcat@remote.example:',
          emojis: const {'other': 'https://x/y.webp'},
        ),
        isNull,
      );
    });

    test('unicode reactions are not shortcodes', () {
      expect(EmojiText.resolveUrl('👍'), isNull);
      expect(EmojiText.plainName('👍'), '👍');
    });

    test('resolves aliases from the local catalogue', () {
      final catalog = [
        _local(
          'nyachi',
          'https://local.example/emoji/nyachi.webp',
          aliases: ['nyacchi'],
        ),
      ];
      expect(
        EmojiText.resolveUrl(':nyacchi:', catalog: catalog),
        'https://local.example/emoji/nyachi.webp',
      );
    });
  });
}
