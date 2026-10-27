// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
import '../../notes/application/emoji_catalog.dart';

/// Returns a `:shortcode:` for the emoji the user picked, or null on dismiss.
Future<String?> showEmojiInsertSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _EmojiInsertSheet(),
  );
}

class _EmojiInsertSheet extends ConsumerStatefulWidget {
  const _EmojiInsertSheet();

  @override
  ConsumerState<_EmojiInsertSheet> createState() => _EmojiInsertSheetState();
}

class _EmojiInsertSheetState extends ConsumerState<_EmojiInsertSheet> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final catalog = ref.watch(emojiCatalogProvider).value ?? const [];
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? catalog
        : catalog
              .where(
                (emoji) =>
                    emoji.name.toLowerCase().contains(query) ||
                    emoji.aliases.any(
                      (alias) => alias.toLowerCase().contains(query),
                    ),
              )
              .toList();
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.insertEmoji,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(l10n.noResults))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 56,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemBuilder: (context, index) {
                        final emoji = filtered[index];
                        return Tooltip(
                          message: emoji.name,
                          child: InkWell(
                            onTap: () =>
                                Navigator.of(context).pop(':${emoji.name}:'),
                            child: Center(
                              child: NyachiImage(
                                url: emoji.url,
                                width: 32,
                                height: 32,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
