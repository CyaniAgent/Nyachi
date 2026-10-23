// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/failure_action.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/time_format.dart';
import '../application/note_detail_controller.dart';
import 'note_content.dart';
import 'note_media.dart';
import 'reaction_picker.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  const NoteDetailPage({required this.noteId, super.key});

  final String noteId;

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
  var _showCw = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(noteDetailControllerProvider(widget.noteId));
    final controller = ref.read(
      noteDetailControllerProvider(widget.noteId).notifier,
    );
    final note = state.note;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.noteDetail)),
      body: ReadableWidth(
        maxWidth: appMaxContentWidth,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(noteDetailControllerProvider(widget.noteId));
          },
          child: state.loading && note == null
              ? const Center(child: CircularProgressIndicator())
              : note == null
              ? ListView(
                  children: [
                    const SizedBox(height: 120),
                    Center(
                      child: Text(
                        state.error?.message(l10n) ?? l10n.loadFailed,
                      ),
                    ),
                    Center(
                      child: state.error == null
                          ? TextButton(
                              onPressed: () => ref.invalidate(
                                noteDetailControllerProvider(widget.noteId),
                              ),
                              child: Text(l10n.retry),
                            )
                          : FailureAction(
                              failure: state.error!,
                              onRetry: () => ref.invalidate(
                                noteDetailControllerProvider(widget.noteId),
                              ),
                            ),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (state.error != null)
                      Material(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          leading: const Icon(Icons.error_outline),
                          title: Text(state.error!.message(l10n)),
                        ),
                      ),
                    _Author(note: note),
                    const SizedBox(height: 12),
                    if (note.cw != null) ...[
                      Text(
                        note.cw!,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      TextButton(
                        onPressed: () => setState(() => _showCw = !_showCw),
                        child: Text(_showCw ? l10n.close : l10n.showContent),
                      ),
                    ],
                    if (note.cw == null || _showCw) ...[
                      if (note.text?.isNotEmpty == true)
                        NoteContent(
                          text: note.text!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      if (note.files?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: NoteMedia(
                            files: note.files!,
                            noteId: note.id,
                            interactive: true,
                          ),
                        ),
                      if (note.renote != null) ...[
                        const SizedBox(height: 12),
                        _EmbeddedNote(note: note.renote!),
                      ],
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '${compactCount(context, note.repliesCount)} ${l10n.reply}',
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${compactCount(context, note.renoteCount)} ${l10n.renote}',
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${compactCount(context, note.reactionCount)} ${l10n.reactions}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(
                            Icons.add_reaction_outlined,
                            size: 18,
                          ),
                          label: Text(l10n.react),
                          onPressed: state.mutating
                              ? null
                              : () async {
                                  final reaction = await showReactionPicker(
                                    context,
                                    note: note,
                                  );
                                  if (reaction != null) {
                                    await controller.toggleReaction(reaction);
                                  }
                                },
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.reply, size: 18),
                          label: Text(l10n.reply),
                          onPressed: () => openDetail(
                            context,
                            ComposeDetailLocation(note.id),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.repeat, size: 18),
                          label: Text(l10n.renote),
                          onPressed: state.mutating ? null : controller.renote,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      relativeTime(context, note.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Author extends StatelessWidget {
  const _Author({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => openDetail(context, UserDetailLocation(note.user.id)),
          child: CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(note.user.avatarUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.user.name ?? note.user.username,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '@${note.user.username}${note.user.host == null ? '' : '@${note.user.host}'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmbeddedNote extends StatelessWidget {
  const _EmbeddedNote({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: scheme.primary, width: 3)),
        borderRadius: BorderRadius.circular(8),
        color: scheme.surfaceContainerLow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.user.name ?? note.user.username,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (note.text?.isNotEmpty == true) NoteContent(text: note.text!),
            if (note.files?.isNotEmpty == true)
              NoteMedia(files: note.files!, noteId: note.id),
          ],
        ),
      ),
    );
  }
}
