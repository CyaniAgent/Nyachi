// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart' hide Clip;

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/time_format.dart';
import '../../../core/network/error_mapper.dart';
import '../application/note_detail_controller.dart';
import '../data/note_repository.dart';
import 'reaction_picker.dart';
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
  var _busy = false;

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => openDetail(context, UserDetailLocation(note.user.id)),
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
                      child: GestureDetector(
                        onTap: () => openDetail(
                          context,
                          UserDetailLocation(note.user.id),
                        ),
                        child: Text(
                          note.user.name?.isNotEmpty == true
                              ? note.user.name!
                              : note.user.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
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
                    InkWell(
                      onTap: () => _openDetail(note.id),
                      child: Text(
                        ' · ${relativeTime(context, note.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                if (note.cw != null) ...[
                  const SizedBox(height: 4),
                  Text(note.cw!, style: Theme.of(context).textTheme.bodyMedium),
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
                        ActionChip(
                          label: Text(
                            '${_reactionLabel(entry.key)} ${compactCount(context, entry.value)}',
                          ),
                          onPressed: _busy
                              ? null
                              : () => _toggleReaction(note, entry.key),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    _NoteAction(
                      icon: Icons.chat_bubble_outline,
                      value: note.repliesCount,
                      label: context.l10n.reply,
                      onTap: () =>
                          openDetail(context, ComposeDetailLocation(note.id)),
                    ),
                    _NoteAction(
                      icon: Icons.repeat,
                      value: note.renoteCount,
                      label: context.l10n.renote,
                      onTap: _busy ? null : () => _renote(note),
                    ),
                    _NoteAction(
                      icon: Icons.add_reaction_outlined,
                      value: note.reactionCount,
                      label: context.l10n.react,
                      onTap: _busy ? null : () => _pickReaction(note),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz),
                      tooltip: context.l10n.noteDetail,
                      onSelected: (value) {
                        if (value == 'detail') _openDetail(note.id);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'detail',
                          child: Text(context.l10n.noteDetail),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(String id) {
    openDetail(context, NoteDetailLocation(id));
  }

  Future<void> _toggleReaction(Note note, String reaction) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final repository = ref.read(noteRepositoryProvider);
      final updated = note.myReaction == reaction
          ? await repository.unreact(note.id)
          : await repository.react(note.id, reaction);
      if (!mounted) return;
      ref.read(noteOverridesProvider.notifier).put(updated);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickReaction(Note note) async {
    final reaction = await showReactionPicker(context, note: note);
    if (reaction != null && mounted) await _toggleReaction(note, reaction);
  }

  Future<void> _renote(Note note) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final updated = await ref.read(noteRepositoryProvider).renote(note.id);
      if (!mounted) return;
      ref.read(noteOverridesProvider.notifier).put(updated);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mapFailure(error).message(context.l10n))),
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
        width: 48,
        height: 48,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.person_outline, size: 24),
          ),
        ),
      ),
    );
  }
}

class _NoteAction extends StatelessWidget {
  const _NoteAction({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final num value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              if (value > 0) ...[
                const SizedBox(width: 4),
                Text(compactCount(context, value)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
