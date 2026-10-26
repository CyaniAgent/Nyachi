// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../settings/application/app_settings.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/failure_action.dart';
import '../../../core/ui/network_image.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/time_format.dart';
import '../application/note_detail_controller.dart';
import 'note_card.dart';
import 'note_content.dart';

class NoteDetailPage extends ConsumerStatefulWidget {
  const NoteDetailPage({required this.noteId, super.key});

  final String noteId;

  @override
  ConsumerState<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends ConsumerState<NoteDetailPage> {
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
        centered: ref.watch(settingsControllerProvider).centerContent,
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
                    NoteCard(note: note, detailMode: true),
                    const Divider(height: 24),
                    _RepliesSection(
                      state: state,
                      controller: controller,
                      onRetry: () => ref.invalidate(
                        noteDetailControllerProvider(widget.noteId),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RepliesSection extends StatelessWidget {
  const _RepliesSection({
    required this.state,
    required this.controller,
    required this.onRetry,
  });

  final NoteDetailState state;
  final NoteDetailController controller;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (state.repliesLoading && state.replies.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (state.repliesError != null && state.replies.isEmpty) {
      return Center(
        child: Column(
          children: [
            Text(state.repliesError!.message(l10n)),
            FailureAction(failure: state.repliesError!, onRetry: onRetry),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.replies.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.noReplies),
            ),
          )
        else
          for (final reply in state.replies) _ReplyTile(note: reply),
        if (state.repliesHasMore)
          Center(
            child: TextButton(
              onPressed: state.repliesLoadingMore
                  ? null
                  : controller.loadMoreReplies,
              child: Text(l10n.loadOlder),
            ),
          ),
      ],
    );
  }
}

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: () => openDetail(context, NoteDetailLocation(note.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () =>
                  openDetail(context, UserDetailLocation(note.user.id)),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: nyachiImageProvider(note.user.avatarUrl),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          note.user.name ?? note.user.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '@${note.user.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        relativeTime(context, note.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (note.cw?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        note.cw!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    )
                  else if (note.text?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: NoteContent(
                        text: note.text!,
                        emojis: note.emojis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        compactCount(context, note.repliesCount),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.repeat,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        compactCount(context, note.renoteCount),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.add_reaction_outlined,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        compactCount(context, note.reactionCount),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (note.repliesCount > 0) ...[
                        const SizedBox(width: 12),
                        Text(
                          '${compactCount(context, note.repliesCount)} ${l10n.reply}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
