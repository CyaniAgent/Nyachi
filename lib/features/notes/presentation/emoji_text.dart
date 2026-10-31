// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/ui/network_image.dart';
import '../../notes/application/emoji_catalog.dart';

/// Renders a Misskey reaction or emoji shortcode.
///
/// Resolution order:
/// 1. [emojis] — the note's own `reactionEmojis` map, keyed by `name` or
///    `name@host`. This is the only correct source for emoji hosted on other
///    servers, because their URLs cannot be derived locally.
/// 2. The local instance catalogue, but only for local shortcodes.
///
/// Anything unresolved renders as plain text; a remote emoji is never guessed
/// from a URL pattern.
class EmojiText extends StatelessWidget {
  const EmojiText({
    required this.emoji,
    this.emojis,
    this.catalog,
    this.size = 18,
    this.suffix,
    super.key,
  });

  final String emoji;

  /// `reactionEmojis` from the note carrying this reaction.
  final Map<String, String>? emojis;

  /// Local instance emojis, used only when the note has no mapping.
  final List<EmojiSimple>? catalog;

  final double size;

  /// Rendered right after the emoji (reaction chips keep their layout).
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final name = shortcodeName(emoji);
    if (name == null) {
      return _row(Text(emoji, style: TextStyle(fontSize: size)));
    }
    final url = resolveUrl(emoji, emojis: emojis, catalog: catalog);
    if (url == null) {
      return _row(Text(name, style: TextStyle(fontSize: size * 0.8)));
    }
    return _row(
      NyachiImage(url: url, width: size, height: size, fit: BoxFit.contain),
    );
  }

  Widget _row(Widget child) {
    if (suffix == null) return child;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [child, const SizedBox(width: 4), suffix!],
    );
  }

  /// Resolves a reaction's image URL, or null when it cannot be known.
  ///
  /// Misskey writes a local custom-emoji reaction as `:name@.:` and omits it
  /// from `reactionEmojis`; bare `:name:` is the older form. Both mean "look it
  /// up on this instance", so [catalog] answers them. Only a reaction hosted on
  /// another server needs the [emojis] map.
  static String? resolveUrl(
    String raw, {
    Map<String, String>? emojis,
    List<EmojiSimple>? catalog,
  }) {
    final name = shortcodeName(raw);
    if (name == null) return null;
    final host = _host(raw);
    final local = host == null || host == '.';
    if (emojis != null) {
      final direct = local ? emojis[name] : emojis['$name@$host'];
      if (direct != null && direct.isNotEmpty) return direct;
      // Servers sometimes key remote emoji by bare name only.
      if (local) {
        final bare = emojis[name];
        if (bare != null && bare.isNotEmpty) return bare;
      }
    }
    // Local catalogue entries are URLs on this instance; use them only when the
    // shortcode is local, otherwise the name could collide with a remote one.
    if (local && catalog != null) {
      for (final emoji in catalog) {
        if (emoji.name == name || emoji.aliases.contains(name)) {
          return emoji.url;
        }
      }
    }
    return null;
  }

  /// Shortcode name without the colons/host, or the raw text for unicode.
  static String plainName(String raw) => shortcodeName(raw) ?? raw;

  static String? shortcodeName(String raw) {
    if (!raw.startsWith(':') || !raw.endsWith(':')) return null;
    final inner = raw.substring(1, raw.length - 1);
    if (inner.isEmpty) return null;
    return inner.contains('@') ? inner.split('@').first : inner;
  }

  /// Whether the reaction names a server other than this one.
  ///
  /// `@.` is Misskey's placeholder for the local instance, so it is not remote.
  static bool hasRemoteHost(String raw) {
    final host = _host(raw);
    return host != null && host != '.';
  }

  static String? _host(String raw) {
    if (!raw.startsWith(':') || !raw.endsWith(':')) return null;
    final inner = raw.substring(1, raw.length - 1);
    if (!inner.contains('@')) return null;
    final host = inner.split('@').last;
    return host.isEmpty ? null : host;
  }
}

/// Convenience wrapper that pulls the note's `reactionEmojis` and the local
/// catalogue so call sites stay short.
class NoteEmojiText extends ConsumerWidget {
  const NoteEmojiText({
    required this.emoji,
    required this.note,
    this.size = 18,
    this.suffix,
    super.key,
  });

  final String emoji;
  final Note note;
  final double size;
  final Widget? suffix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `:name@.:` is this instance, exactly like a bare `:name:`; only a
    // reaction naming another server must ignore the local catalogue.
    final localOnly =
        EmojiText.shortcodeName(emoji) != null &&
        !EmojiText.hasRemoteHost(emoji);
    return EmojiText(
      emoji: emoji,
      emojis: note.reactionEmojis,
      catalog: localOnly ? ref.watch(emojiCatalogProvider).value : null,
      size: size,
      suffix: suffix,
    );
  }
}
