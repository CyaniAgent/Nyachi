// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/grouped_emoji_grid.dart';
import '../application/emoji_catalog.dart';
import 'emoji_text.dart';

const defaultReactions = ['👍', '❤️', '😂', '🎉', '😮', '😢'];

Future<String?> showReactionPicker(BuildContext context, {required Note note}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReactionPicker(note: note),
  );
}

class _ReactionPicker extends ConsumerStatefulWidget {
  const _ReactionPicker({required this.note});

  final Note note;

  @override
  ConsumerState<_ReactionPicker> createState() => _ReactionPickerState();
}

class _ReactionPickerState extends ConsumerState<_ReactionPicker> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final emojis = ref.watch(emojiCatalogProvider);
    final existing = widget.note.reactions.keys.toList(growable: false);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.reactions,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (existing.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  children: [
                    for (final reaction in existing)
                      ActionChip(
                        // reactionEmojis is the only source for emoji hosted
                        // on other servers (`:name@host:`); without it those
                        // chips render as bare text.
                        label: EmojiText(
                          emoji: reaction,
                          emojis: widget.note.reactionEmojis,
                          size: 16,
                        ),
                        onPressed: () => Navigator.pop(context, reaction),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Wrap(
                spacing: 8,
                children: [
                  for (final reaction in defaultReactions)
                    ActionChip(
                      label: Text(reaction),
                      onPressed: () => Navigator.pop(context, reaction),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: context.l10n.search,
                ),
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: emojis.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.emojiCatalogLoadFailed,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => ref.invalidate(emojiCatalogProvider),
                          child: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  ),
                  data: (items) {
                    final filtered = items
                        .where(
                          (emoji) =>
                              _query.isEmpty ||
                              emoji.name.toLowerCase().contains(
                                _query.toLowerCase(),
                              ) ||
                              (emoji.category ?? '').toLowerCase().contains(
                                _query.toLowerCase(),
                              ),
                        )
                        .toList(growable: false);
                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(context.l10n.noSearchResults),
                      );
                    }
                    return GroupedEmojiGrid(
                      emojis: filtered,
                      crossAxisCount: 6,
                      otherLabel: context.l10n.emojiOther,
                      onPick: (emoji) =>
                          Navigator.pop(context, ':${emoji.name}:'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
