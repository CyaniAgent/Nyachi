// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

import '../../../core/ui/time_format.dart';
import 'emoji_text.dart';

/// One reaction counter.
///
/// Fixed height keeps unicode emoji, custom emoji images and counts on the
/// same baseline; [selected] marks the current user's own reaction without
/// relying on a check mark.
class ReactionChip extends StatelessWidget {
  const ReactionChip({
    required this.reaction,
    required this.count,
    required this.selected,
    required this.onPressed,
    this.emojis,
    super.key,
  });

  static const height = 32.0;

  final String reaction;
  final num count;
  final bool selected;
  final VoidCallback? onPressed;

  /// The note's `reactionEmojis`, required to render emoji hosted elsewhere.
  final Map<String, String>? emojis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected
        ? scheme.onSecondaryContainer
        : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: '${EmojiText.plainName(reaction)} ${compactCount(context, count)}',
      child: SizedBox(
        height: height,
        child: Material(
          color: selected
              ? scheme.secondaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(height / 2),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EmojiText(emoji: reaction, emojis: emojis, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    compactCount(context, count),
                    style: TextStyle(fontSize: 12, color: foreground),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
