// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart' hide Clip;

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/time_format.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/ui/avatar.dart';
import '../../composer/presentation/compose_sheet.dart';
import '../application/note_detail_controller.dart';
import '../application/note_providers.dart';
import 'reaction_chip.dart';
import 'emoji_text.dart';
import 'reaction_picker.dart';
import '../../../core/mfm/mfm_body.dart';
import 'note_media.dart';

class NoteCard extends ConsumerStatefulWidget {
  const NoteCard({required this.note, this.detailMode = false, super.key});

  final Note note;

  /// Detail mode shows the quoted renote inline and drops feed-only chrome.
  final bool detailMode;

  @override
  ConsumerState<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<NoteCard> {
  var _showCw = false;
  var _busy = false;

  /// Favorite/thread-mute state of the displayed note, fetched when the
  /// overflow menu opens; null until then (and on fetch failure), in which
  /// case the menu shows the default labels.
  ({bool isFavorited, bool isMutedThread})? _noteState;

  @override
  void didUpdateWidget(covariant NoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.id != widget.note.id) {
      _showCw = false;
      _noteState = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayed = widget.note.renote ?? widget.note;
    final override = ref.watch(noteOverridesProvider)[displayed.id];
    final note = override ?? displayed;
    final active = ref.watch(activeAccountProvider);
    final isRenote = widget.note.renote != null;
    final showContent = note.cw == null || _showCw;

    return Semantics(
      button: true,
      label:
          '${note.user.name?.isNotEmpty == true ? note.user.name! : note.user.username} '
          '${relativeTime(context, note.createdAt)}',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () =>
                  openDetail(context, UserDetailLocation(note.user.id)),
              child: NyachiAvatar(url: note.user.avatarUrl, size: 48),
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
                      MfmBody(
                        text: note.text!,
                        emojis: note.emojis,
                        detail: widget.detailMode,
                        style: widget.detailMode
                            ? Theme.of(context).textTheme.bodyLarge
                            : null,
                      ),
                    if (note.files?.isNotEmpty == true)
                      Padding(
                        padding: EdgeInsets.only(
                          top: widget.detailMode ? 12 : 8,
                        ),
                        child: NoteMedia(
                          files: note.files!,
                          noteId: note.id,
                          interactive: widget.detailMode,
                        ),
                      ),
                    if (widget.detailMode && note.renote != null) ...[
                      const SizedBox(height: 12),
                      _EmbeddedNote(note: note.renote!),
                    ],
                  ],
                  if (note.reactions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final entry in note.reactions.entries.take(4))
                          ReactionChip(
                            reaction: entry.key,
                            note: note,
                            count: entry.value,
                            selected: note.myReaction == entry.key,
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
                            showComposeSheet(context, replyId: note.id),
                      ),
                      _NoteAction(
                        icon: Icons.repeat,
                        value: note.renoteCount,
                        label: context.l10n.renote,
                        onTap: _busy ? null : () => _renote(note),
                      ),
                      _NoteAction(
                        icon: note.myReaction == null
                            ? Icons.add_reaction_outlined
                            : null,
                        emoji: note.myReaction,
                        note: note,
                        value: note.reactionCount,
                        label: note.myReaction == null
                            ? context.l10n.react
                            : context.l10n.removeReaction,
                        onTap: _busy
                            ? null
                            : note.myReaction == null
                            ? () => _pickReaction(note)
                            : () => _toggleReaction(note, note.myReaction!),
                        onLongPress: _busy ? null : () => _pickReaction(note),
                      ),
                      _NoteAction(
                        icon: Icons.article_outlined,
                        value: 0,
                        label: context.l10n.noteDetail,
                        onTap: () => _openDetail(note.id),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz),
                        tooltip: context.l10n.moreMenu,
                        onOpened: () => _loadMenuState(note),
                        onSelected: (value) => _onMenuSelected(value, note),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'copyLink',
                            child: Text(context.l10n.copyLink),
                          ),
                          PopupMenuItem(
                            value: 'favorite',
                            child: Text(
                              _noteState?.isFavorited == true
                                  ? context.l10n.unfavorite
                                  : context.l10n.favorite,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'memo',
                            child: Text(context.l10n.userMemo),
                          ),
                          PopupMenuItem(
                            value: 'muteThread',
                            child: Text(
                              _noteState?.isMutedThread == true
                                  ? context.l10n.unmuteThread
                                  : context.l10n.muteThread,
                            ),
                          ),
                          if (note.userId == active?.userId)
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(context.l10n.deleteNote),
                            ),
                          PopupMenuItem(
                            value: 'report',
                            child: Text(context.l10n.reportUser),
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
      ),
    );
  }

  void _openDetail(String id) {
    openDetail(context, NoteDetailLocation(id));
  }

  /// Applies a reaction change immediately.
  ///
  /// Re-tapping the current reaction removes it; picking a different one
  /// replaces it.
  Future<void> _toggleReaction(Note note, String reaction) async {
    if (_busy) return;
    final removing = note.myReaction == reaction;
    setState(() => _busy = true);
    try {
      final repository = ref.read(noteRepositoryProvider);
      final updated = removing
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

  Future<void> _loadMenuState(Note note) async {
    try {
      final state = await ref.read(noteRepositoryProvider).state(note.id);
      if (!mounted) return;
      setState(() => _noteState = state);
    } on Object {
      if (!mounted) return;
      // The state only chooses two menu labels; the menu stays usable.
      setState(() => _noteState = null);
    }
  }

  Future<void> _onMenuSelected(String value, Note note) async {
    switch (value) {
      case 'copyLink':
        await _copyLink(note);
      case 'favorite':
        await _toggleFavorite(note);
      case 'memo':
        await _editMemo(note);
      case 'muteThread':
        await _toggleThreadMute(note);
      case 'delete':
        await _deleteNote(note);
      case 'report':
        await _reportUser(note);
    }
  }

  /// Builds the shareable link on the note's origin instance; `url`/`uri`
  /// already are absolute for remote notes.
  Future<void> _copyLink(Note note) async {
    final host = note.user.host ?? ref.read(activeAccountProvider)?.host ?? '';
    final link = note.url ?? note.uri ?? 'https://$host/notes/${note.id}';
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.linkCopied)));
  }

  Future<void> _toggleFavorite(Note note) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final repository = ref.read(noteRepositoryProvider);
      if (_noteState?.isFavorited ?? false) {
        await repository.unfavorite(note.id);
      } else {
        await repository.favorite(note.id);
      }
      final state = await repository.state(note.id);
      if (!mounted) return;
      setState(() => _noteState = state);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleThreadMute(Note note) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final repository = ref.read(noteRepositoryProvider);
      final muted = !(_noteState?.isMutedThread ?? false);
      await repository.setThreadMuted(note.id, muted: muted);
      final state = await repository.state(note.id);
      if (!mounted) return;
      setState(() => _noteState = state);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editMemo(Note note) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    // The memo lives on the user detail; `Note.user` is a UserLite without
    // it, so fetch it here. An unreadable memo still allows writing one.
    try {
      controller.text =
          await ref.read(noteRepositoryProvider).userMemo(note.userId) ?? '';
    } on Object {
      controller.text = '';
    }
    if (!mounted) return;
    final memo = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.userMemo),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(hintText: l10n.memoHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (memo == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(noteRepositoryProvider)
          .updateMemo(userId: note.userId, memo: memo);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.memoSaved)));
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteNote(Note note) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(l10n.deleteNoteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(noteRepositoryProvider).delete(note.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.noteDeleted)));
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reportUser(Note note) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final comment = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.reportUser),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reportUserBody(note.user.username)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 4,
              decoration: InputDecoration(hintText: l10n.reportUserHint),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(l10n.report),
          ),
        ],
      ),
    );
    // The server requires a comment; an empty submission is a cancel.
    if (comment == null || comment.isEmpty || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(noteRepositoryProvider)
          .reportUser(userId: note.userId, comment: comment);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.reportSent)));
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _renote(Note note) async {
    if (_busy) return;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.renoteConfirmTitle),
        content: Text(l10n.renoteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
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
}

class _NoteAction extends StatelessWidget {
  const _NoteAction({
    this.icon,
    this.emoji,
    this.note,
    required this.value,
    required this.label,
    required this.onTap,
    this.onLongPress,
  }) : assert(
         icon != null || emoji != null,
         'a note action shows either an icon or a reaction',
       );

  final IconData? icon;

  /// The user's own reaction, rendered as itself. A heart icon would claim a
  /// reaction the user never picked, so the actual emoji is shown instead -
  /// unicode as text, custom emoji as its image.
  final String? emoji;
  final Note? note;
  final num value;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null)
                NoteEmojiText(emoji: emoji!, note: note!, size: 18)
              else
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

/// Quoted renote rendered inside the card body, used in detail mode.
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
            if (note.text?.isNotEmpty == true)
              MfmBody(text: note.text!, emojis: note.emojis),
            if (note.files?.isNotEmpty == true)
              NoteMedia(files: note.files!, noteId: note.id),
          ],
        ),
      ),
    );
  }
}
