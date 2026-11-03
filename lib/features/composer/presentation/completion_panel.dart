// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/network_image.dart';
import '../../explore/application/explore_controllers.dart';
import '../../notes/application/emoji_catalog.dart';
import '../application/mention_candidates.dart';
import '../domain/completion_trigger.dart';

/// One row of the inline completion panel.
class CompletionEntry {
  const CompletionEntry({
    required this.id,
    required this.label,
    required this.insert,
    this.detail,
    this.avatarUrl,
    this.emojiUrl,
  });

  /// Stable identity, used to deduplicate merged mention sources.
  final String id;
  final String label;

  /// What replaces the trigger token, trigger character included.
  final String insert;
  final String? detail;
  final String? avatarUrl;
  final String? emojiUrl;
}

/// Builds the candidate rows for [trigger].
///
/// Shared by the panel and by the host's key handling so both always see the
/// same list; reading providers here keeps the panel a pure renderer.
List<CompletionEntry> completionEntries(
  WidgetRef ref,
  CompletionTrigger trigger,
) {
  final query = trigger.query.toLowerCase();
  return switch (trigger.kind) {
    CompletionKind.mention => _mentionEntries(ref, query),
    CompletionKind.hashtag => _hashtagEntries(ref, query),
    CompletionKind.emoji => _emojiEntries(ref, query),
  };
}

List<CompletionEntry> _mentionEntries(WidgetRef ref, String query) {
  final local =
      ref.watch(mentionCandidatesProvider).value ?? const <MentionCandidate>[];
  // The remote source is a family provider with the query as its argument, so
  // it debounces and disposes on its own as the user keeps typing.
  final remote = ref.watch(remoteMentionCandidatesProvider(query)).value;

  final entries = <CompletionEntry>[];
  final seen = <String>{};
  for (final candidate in [...local, ...?remote]) {
    final matchesName = candidate.name?.toLowerCase().contains(query) ?? false;
    if (!candidate.username.toLowerCase().contains(query) && !matchesName) {
      continue;
    }
    if (!seen.add(candidate.id)) continue;
    final host = candidate.host;
    final handle = host == null
        ? '@${candidate.username}'
        : '@${candidate.username}@$host';
    entries.add(
      CompletionEntry(
        id: candidate.id,
        label: candidate.name ?? handle,
        detail: handle,
        insert: handle,
      ),
    );
    if (entries.length == 8) break;
  }
  return entries;
}

List<CompletionEntry> _hashtagEntries(WidgetRef ref, String query) {
  final trends = ref.watch(trendsProvider).value ?? const [];
  final tags = <String>{for (final item in trends) item.tag};
  return [
    for (final tag in tags)
      if (tag.toLowerCase().contains(query))
        CompletionEntry(id: tag, label: '#$tag', insert: '#$tag'),
  ];
}

List<CompletionEntry> _emojiEntries(WidgetRef ref, String query) {
  final catalog = ref.watch(emojiCatalogProvider).value ?? const [];
  final entries = <CompletionEntry>[];
  for (final emoji in catalog) {
    final matches =
        emoji.name.toLowerCase().contains(query) ||
        emoji.aliases.any((alias) => alias.toLowerCase().contains(query));
    if (!matches) continue;
    entries.add(
      CompletionEntry(
        id: emoji.name,
        label: ':${emoji.name}:',
        insert: ':${emoji.name}:',
        emojiUrl: emoji.url,
      ),
    );
    if (entries.length == 24) break;
  }
  return entries;
}

/// Inline candidate panel for `@`, `#` and `:emoji:` triggers.
///
/// Owns no text state: it reports the chosen [CompletionEntry] and the host
/// performs the replacement, keeping undo history and the controller in one
/// place.
class CompletionPanel extends ConsumerWidget {
  const CompletionPanel({
    required this.trigger,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final CompletionTrigger trigger;
  final int selectedIndex;
  final ValueChanged<CompletionEntry> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = completionEntries(ref, trigger);
    if (entries.isEmpty) return const SizedBox.shrink();
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return ListTile(
              dense: true,
              selected: index == selectedIndex % entries.length,
              leading: _Leading(entry: entry),
              title: Text(entry.label, overflow: TextOverflow.ellipsis),
              subtitle: entry.detail == null
                  ? null
                  : Text(entry.detail!, overflow: TextOverflow.ellipsis),
              onTap: () => onSelected(entry),
            );
          },
        ),
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.entry});

  final CompletionEntry entry;

  @override
  Widget build(BuildContext context) {
    final emojiUrl = entry.emojiUrl;
    if (emojiUrl != null) {
      return SizedBox(
        width: 24,
        height: 24,
        child: NyachiImage(url: emojiUrl, fit: BoxFit.contain),
      );
    }
    final avatarUrl = entry.avatarUrl;
    if (avatarUrl != null) {
      return CircleAvatar(radius: 12, backgroundImage: NetworkImage(avatarUrl));
    }
    return const SizedBox(width: 24, height: 24);
  }
}

/// Translates a key press into a panel action.
///
/// Returns true when the key was consumed so the host text field stops
/// handling it: arrows move the highlight, Tab accepts, Escape dismisses.
/// Enter is never consumed so the text field inserts a newline as usual.
bool handleCompletionKey({
  required KeyEvent event,
  required int entryCount,
  required int selectedIndex,
  required void Function(int index) onHighlight,
  required void Function(int index) onAccept,
  required VoidCallback onDismiss,
}) {
  if (entryCount == 0) return false;
  if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
  final key = event.logicalKey;
  if (key == LogicalKeyboardKey.arrowDown) {
    onHighlight((selectedIndex + 1) % entryCount);
    return true;
  }
  if (key == LogicalKeyboardKey.arrowUp) {
    onHighlight((selectedIndex - 1 + entryCount) % entryCount);
    return true;
  }
  if (key == LogicalKeyboardKey.tab) {
    onAccept(selectedIndex % entryCount);
    return true;
  }
  if (key == LogicalKeyboardKey.escape) {
    onDismiss();
    return true;
  }
  return false;
}
