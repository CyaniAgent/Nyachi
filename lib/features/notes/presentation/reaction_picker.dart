// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/ui/l10n_ext.dart';
import '../application/emoji_catalog.dart';

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
        child: SingleChildScrollView(
          child: Column(
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
                        label: Text(_reactionLabel(reaction)),
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
              emojis.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const SizedBox.shrink(),
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
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                        ),
                    itemBuilder: (context, index) {
                      final emoji = filtered[index];
                      return InkWell(
                        onTap: () => Navigator.pop(context, ':${emoji.name}:'),
                        child: Tooltip(
                          message: emoji.name,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Image.network(
                              emoji.url,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _reactionLabel(String reaction) {
    if (reaction.startsWith(':') && reaction.endsWith(':')) {
      return reaction.substring(1, reaction.length - 1);
    }
    return reaction;
  }
}
