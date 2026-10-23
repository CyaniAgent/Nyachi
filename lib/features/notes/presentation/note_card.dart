// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart' hide Clip;

import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/time_format.dart';
import '../application/note_detail_controller.dart';
import 'note_content.dart';
import 'note_media.dart';

class NoteCard extends ConsumerStatefulWidget {
  const NoteCard({required this.note, super.key});

  final Note note;

  @override
  ConsumerState<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<NoteCard> {
  var _showCw = false;

  @override
  void didUpdateWidget(covariant NoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.id != widget.note.id) _showCw = false;
  }

  @override
  Widget build(BuildContext context) {
    final displayed = widget.note.renote ?? widget.note;
    final override = ref.watch(noteOverridesProvider)[displayed.id];
    final note = override ?? displayed;
    final isRenote = widget.note.renote != null;
    final showContent = note.cw == null || _showCw;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/notes/${note.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.push('/users/${note.user.id}'),
                child: _NoteAvatar(url: note.user.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isRenote)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${widget.note.user.name ?? widget.note.user.username} ${context.l10n.renoted}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            note.user.name?.isNotEmpty == true
                                ? note.user.name!
                                : note.user.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '@${note.user.username}${note.user.host == null ? '' : '@${note.user.host}'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          ' · ${relativeTime(context, note.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (note.cw != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        note.cw!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => setState(() => _showCw = !_showCw),
                        child: Text(
                          showContent
                              ? context.l10n.close
                              : context.l10n.showContent,
                        ),
                      ),
                    ],
                    if (showContent) ...[
                      if (note.text?.isNotEmpty == true)
                        NoteContent(text: note.text!),
                      if (note.files?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: NoteMedia(files: note.files!, noteId: note.id),
                        ),
                    ],
                    if (note.reactions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final entry in note.reactions.entries.take(4))
                            Chip(
                              visualDensity: VisualDensity.compact,
                              label: Text(
                                '${_reactionLabel(entry.key)} ${compactCount(context, entry.value)}',
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Count(
                          icon: Icons.chat_bubble_outline,
                          value: note.repliesCount,
                        ),
                        _Count(icon: Icons.repeat, value: note.renoteCount),
                        _Count(
                          icon: Icons.favorite_border,
                          value: note.reactionCount,
                        ),
                      ],
                    ),
                  ],
                ),
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

class _NoteAvatar extends StatelessWidget {
  const _NoteAvatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 40,
        height: 40,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.person_outline, size: 20),
          ),
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.icon, required this.value});

  final IconData icon;
  final num value;

  @override
  Widget build(BuildContext context) {
    if (value == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(compactCount(context, value)),
        ],
      ),
    );
  }
}
