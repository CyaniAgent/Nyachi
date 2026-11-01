// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import 'network_image.dart';

/// Custom emoji rendered as groups by `category` with sticky group headers.
///
/// Both emoji surfaces (the reaction picker and the composer insert sheet)
/// render through this widget so grouping and cell geometry stay identical.
/// Uncategorized emoji share one group at the end, labelled with
/// [otherLabel].
class GroupedEmojiGrid extends StatelessWidget {
  const GroupedEmojiGrid({
    super.key,
    required this.emojis,
    required this.onPick,
    required this.otherLabel,
    this.crossAxisCount,
    this.maxCrossAxisExtent,
    this.padding,
  }) : assert(
         (crossAxisCount == null) != (maxCrossAxisExtent == null),
         'Provide exactly one of crossAxisCount or maxCrossAxisExtent.',
       );

  final List<EmojiSimple> emojis;
  final ValueChanged<EmojiSimple> onPick;
  final String otherLabel;
  final int? crossAxisCount;
  final double? maxCrossAxisExtent;
  final EdgeInsetsGeometry? padding;

  /// Category → emojis, in first-appearance order; the null key collects
  /// uncategorized emoji and renders last.
  @visibleForTesting
  static Map<String?, List<EmojiSimple>> group(List<EmojiSimple> emojis) {
    final groups = <String?, List<EmojiSimple>>{};
    for (final emoji in emojis) {
      final category = emoji.category == null || emoji.category!.isEmpty
          ? null
          : emoji.category;
      groups.putIfAbsent(category, () => []).add(emoji);
    }
    final other = groups.remove(null);
    if (other != null) groups[null] = other;
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = group(emojis);
    return CustomScrollView(
      slivers: [
        if (padding != null) SliverPadding(padding: padding!),
        for (final entry in groups.entries) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _EmojiHeaderDelegate(
              entry.key ?? otherLabel,
              color: Theme.of(context).colorScheme,
              textTheme: Theme.of(context).textTheme,
            ),
          ),
          SliverGrid(
            gridDelegate: maxCrossAxisExtent != null
                ? SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: maxCrossAxisExtent!,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  )
                : SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount!,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final emoji = entry.value[index];
              return _EmojiCell(emoji: emoji, onPick: onPick);
            }, childCount: entry.value.length),
          ),
        ],
      ],
    );
  }
}

class _EmojiHeaderDelegate extends SliverPersistentHeaderDelegate {
  _EmojiHeaderDelegate(
    this.label, {
    required this.color,
    required this.textTheme,
  });

  final String label;
  final ColorScheme color;
  final TextTheme textTheme;

  static const _extent = 36.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: _extent,
      color: color.surface,
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.titleSmall,
      ),
    );
  }

  @override
  double get maxExtent => _extent;

  @override
  double get minExtent => _extent;

  @override
  bool shouldRebuild(_EmojiHeaderDelegate oldDelegate) =>
      oldDelegate.label != label;
}

class _EmojiCell extends StatelessWidget {
  const _EmojiCell({required this.emoji, required this.onPick});

  final EmojiSimple emoji;
  final ValueChanged<EmojiSimple> onPick;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: emoji.name,
      child: InkWell(
        onTap: () => onPick(emoji),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: NyachiImage(url: emoji.url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
