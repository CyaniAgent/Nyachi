// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/ui/l10n_ext.dart';
import 'emoji_text.dart';

class NoteContent extends StatelessWidget {
  const NoteContent({required this.text, this.emojis, this.style, super.key});

  final String text;

  /// The note's `emojis` map — the authoritative source for custom emoji,
  /// including those hosted on remote instances.
  final Map<String, String>? emojis;

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final effective = style ?? Theme.of(context).textTheme.bodyLarge;
    final linkStyle = effective?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );
    final pattern = RegExp(
      r'https?://[^\s]+|#[^\s#]+|:[A-Za-z0-9_+-]+(?:@[^\s:]+)?:',
    );
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final token = match.group(0)!;
      if (token.startsWith(':')) {
        final url = EmojiText.resolveUrl(token, emojis: emojis);
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: url == null
                ? Text(token, style: effective)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: EmojiText(emoji: token, emojis: emojis, size: 18),
                  ),
          ),
        );
      } else {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: token.startsWith('#')
                  ? () => openDetail(
                      context,
                      TagDetailLocation(token.substring(1)),
                    )
                  : () => _open(context, token),
              child: Text(token, style: linkStyle, softWrap: true),
            ),
          ),
        );
      }
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return Text.rich(
      TextSpan(style: effective, children: spans),
      softWrap: true,
    );
  }

  Future<void> _open(BuildContext context, String token) async {
    final uri = Uri.tryParse(token);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.externalLinkFailed)));
    }
  }
}
