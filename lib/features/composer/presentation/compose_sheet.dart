// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/instance_repository.dart';
import '../../../core/ui/failure_action.dart';
import '../../../core/ui/l10n_ext.dart';
import '../application/composer_controller.dart';

/// Opens the composer in a modal bottom sheet (mobile/narrow layouts).
Future<void> showComposeSheet(BuildContext context, {String? replyId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: ComposerBody(replyId: replyId, showHandle: true),
    ),
  );
}

/// Opens the composer in a centered dialog (desktop/wide layouts).
Future<void> showComposeDialog(BuildContext context, {String? replyId}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Theme.of(dialogContext).colorScheme.surfaceContainer,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ComposerBody(replyId: replyId, showHandle: false),
      ),
    ),
  );
}

class ComposerBody extends ConsumerStatefulWidget {
  const ComposerBody({
    required this.replyId,
    required this.showHandle,
    super.key,
  });

  final String? replyId;
  final bool showHandle;

  @override
  ConsumerState<ComposerBody> createState() => _ComposerBodyState();
}

class _ComposerBodyState extends ConsumerState<ComposerBody> {
  final _text = TextEditingController();
  final _cw = TextEditingController();
  var _hasCw = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = ref.read(composerControllerProvider(widget.replyId));
    if (_text.text.isEmpty && state.text.isNotEmpty) {
      _text.text = state.text;
    }
    if (state.cw != null && !_hasCw) {
      _hasCw = true;
      _cw.text = state.cw!;
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _cw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = composerControllerProvider(widget.replyId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final max =
        ref.watch(instanceInfoProvider).value?.maxNoteTextLength ?? 3000;
    ref.listen(provider, (previous, next) {
      if (_text.text != next.text) {
        _text.value = TextEditingValue(
          text: next.text,
          selection: TextSelection.collapsed(offset: next.text.length),
        );
      }
      if (next.cw != null && !_hasCw) {
        setState(() {
          _hasCw = true;
          _cw.text = next.cw!;
        });
      }
    });
    final canPost =
        !state.posting &&
        state.text.trim().isNotEmpty &&
        state.text.runes.length <= max;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        widget.showHandle ? 8 : 16,
        16,
        12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showHandle)
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          if (state.restored)
            Material(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.restore),
                title: Text(l10n.draftRestored),
                trailing: IconButton(
                  tooltip: l10n.deleteDraft,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    controller.deleteDraft();
                    _text.clear();
                    _cw.clear();
                  },
                ),
              ),
            ),
          if (state.error != null)
            Material(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.error_outline),
                title: Text(
                  state.error!.message(l10n),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: FailureAction(
                  failure: state.error!,
                  onRetry: () => controller.post(),
                ),
              ),
            ),
          if (widget.replyId != null)
            ReplyPreviewCard(noteId: widget.replyId!),
          if (_hasCw)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _cw,
                autofocus: true,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: l10n.contentWarningHint,
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: controller.setCw,
              ),
            ),
          TextField(
            controller: _text,
            autofocus: !_hasCw,
            minLines: 3,
            maxLines: 8,
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: controller.setText,
          ),
          const Divider(height: 1),
          Row(
            children: [
              IconButton(
                tooltip: l10n.contentWarning,
                onPressed: () {
                  setState(() {
                    _hasCw = !_hasCw;
                    if (!_hasCw) {
                      _cw.clear();
                      controller.setCw(null);
                    }
                  });
                },
                icon: Icon(
                  _hasCw
                      ? Icons.warning_amber_rounded
                      : Icons.warning_amber_outlined,
                ),
              ),
              Flexible(
                child: _VisibilityMenu(
                  visibility: state.visibility,
                  onSelected: controller.setVisibility,
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Tooltip(
                        message: l10n.localOnly,
                        child: Text(
                          l10n.localOnly,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    Switch(
                      value: state.localOnly,
                      onChanged: controller.setLocalOnly,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                l10n.characterCount(state.text.runes.length),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: l10n.post,
                onPressed: canPost
                    ? () async {
                        final ok = await controller.post();
                        if (ok && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    : null,
                icon: state.posting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisibilityMenu extends StatelessWidget {
  const _VisibilityMenu({required this.visibility, required this.onSelected});

  final NotesCreateRequestVisibility visibility;
  final ValueChanged<NotesCreateRequestVisibility> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopupMenuButton<NotesCreateRequestVisibility>(
      initialValue: visibility,
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: NotesCreateRequestVisibility.public,
          child: Text(l10n.visibilityPublic),
        ),
        PopupMenuItem(
          value: NotesCreateRequestVisibility.home,
          child: Text(l10n.visibilityHome),
        ),
        PopupMenuItem(
          value: NotesCreateRequestVisibility.followers,
          child: Text(l10n.visibilityFollowers),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              switch (visibility) {
                NotesCreateRequestVisibility.public => Icons.public_outlined,
                NotesCreateRequestVisibility.home => Icons.home_outlined,
                NotesCreateRequestVisibility.followers =>
                  Icons.lock_outline,
                _ => Icons.public_outlined,
              },
              size: 20,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                switch (visibility) {
                  NotesCreateRequestVisibility.public => l10n.visibilityPublic,
                  NotesCreateRequestVisibility.home => l10n.visibilityHome,
                  NotesCreateRequestVisibility.followers =>
                    l10n.visibilityFollowers,
                  _ => l10n.visibilityPublic,
                },
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact preview of the note being replied to. Shared by the sheet and the
/// panel/page composer.
class ReplyPreviewCard extends ConsumerWidget {
  const ReplyPreviewCard({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(composerReplyNoteProvider(noteId));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (note) {
        if (note == null) return const SizedBox.shrink();
        final user = note.user;
        final body = note.cw ?? note.text ?? '';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.name ?? user.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (note.cw != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          context.l10n.contentWarning,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    if (body.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
