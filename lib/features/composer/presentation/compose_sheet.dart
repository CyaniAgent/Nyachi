// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/network/instance_repository.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/ui/failure_action.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
import '../../drive/data/drive_repository.dart';
import '../../notes/application/emoji_catalog.dart';
import '../../notes/presentation/note_content.dart';
import '../application/composer_controller.dart';
import 'compose_page.dart';
import 'emoji_insert_sheet.dart';
import 'recipient_picker.dart';

/// Opens the composer in a modal bottom sheet.
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

/// The shared composer, laid out like the official Misskey composer: a header
/// row (close, avatar, visibility, local-only, more, post), the reply quote,
/// the text area with optional poll/preview, and a bottom toolbar.
class ComposerBody extends ConsumerStatefulWidget {
  const ComposerBody({
    required this.replyId,
    required this.showHandle,
    this.expandContent = false,
    this.onClose,
    super.key,
  });

  final String? replyId;
  final bool showHandle;

  /// Fills the surface with the text area (full-page layout).
  final bool expandContent;

  /// Called after a successful post.
  final VoidCallback? onClose;

  @override
  ConsumerState<ComposerBody> createState() => _ComposerBodyState();
}

class _ComposerBodyState extends ConsumerState<ComposerBody> {
  final _text = TextEditingController();
  final _cw = TextEditingController();
  var _hasCw = false;
  var _uploading = 0;

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
      } else if (next.cw == null && _hasCw) {
        setState(() {
          _hasCw = false;
          _cw.clear();
        });
      }
    });

    return Padding(
      padding: EdgeInsets.fromLTRB(16, widget.showHandle ? 8 : 16, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ComposerHeader(
            replyId: widget.replyId,
            state: state,
            controller: controller,
            canPost: controller.canPost(),
            showHandle: widget.showHandle,
            onPosted: widget.onClose,
            onClearText: () {
              _text.clear();
              _cw.clear();
              setState(() => _hasCw = false);
            },
          ),
          if (state.restored) _RestoredBanner(controller: controller),
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
          if (widget.replyId != null) ReplyPreviewCard(noteId: widget.replyId!),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.visibility ==
                      NotesCreateRequestVisibility.specified)
                    _RecipientChips(state: state, controller: controller),
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
                    minLines: widget.expandContent ? 10 : 4,
                    maxLines: null,
                    autofocus: !_hasCw,
                    decoration: InputDecoration(
                      hintText: l10n.composerHint,
                      border: InputBorder.none,
                    ),
                    onChanged: controller.setText,
                  ),
                  if (state.showPoll)
                    _PollEditor(state: state, controller: controller),
                  if (state.showPreview) _PreviewCard(state: state),
                  if (state.fileIds.isNotEmpty)
                    _AttachmentChips(state: state, controller: controller),
                  if (state.scheduledAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.scheduledFor(
                                MaterialLocalizations.of(context)
                                    .formatFullDate(state.scheduledAt!),
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          TextButton(
                            onPressed: () => controller.setScheduledAt(null),
                            child: Text(l10n.scheduleRemove),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          _ComposerToolbar(
            state: state,
            controller: controller,
            uploading: _uploading,
            onPickImages: () => _attach(FileType.image),
            onPickFiles: () => _attach(FileType.any),
            onToggleCw: () {
              setState(() {
                _hasCw = !_hasCw;
                if (!_hasCw) {
                  _cw.clear();
                  controller.setCw(null);
                }
              });
            },
            onInsert: (snippet) {
              final selection = _text.selection;
              final base = _text.text;
              final offset = selection.isValid
                  ? selection.baseOffset.clamp(0, base.length)
                  : base.length;
              final next = base.replaceRange(offset, offset, snippet);
              _text.value = TextEditingValue(
                text: next,
                selection: TextSelection.collapsed(
                  offset: offset + snippet.length,
                ),
              );
              controller.setText(next);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _attach(FileType type) async {
    final provider = composerControllerProvider(widget.replyId);
    final controller = ref.read(provider.notifier);
    if (ref.read(provider).showPoll) return;
    final picked = await FilePicker.pickFiles(type: type);
    if (picked.isEmpty || !mounted) return;
    setState(() => _uploading += picked.length);
    final drive = ref.read(driveRepositoryProvider);
    try {
      for (final file in picked) {
        final bytes = await file.readAsBytes();
        final uploaded = await drive.upload(bytes: bytes, fileName: file.name);
        controller.addFileId(uploaded.id);
        if (mounted) setState(() => _uploading -= 1);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _uploading = 0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapFailure(error).message(context.l10n))),
        );
      }
    }
  }
}

class _RestoredBanner extends StatelessWidget {
  const _RestoredBanner({required this.controller});

  final ComposerController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.restore),
        title: Text(l10n.draftRestored),
        trailing: IconButton(
          tooltip: l10n.deleteDraft,
          icon: const Icon(Icons.delete_outline),
          onPressed: controller.deleteDraft,
        ),
      ),
    );
  }
}

/// Header row: close, avatar, visibility, local-only, more, post.
class _ComposerHeader extends ConsumerWidget {
  const _ComposerHeader({
    required this.replyId,
    required this.state,
    required this.controller,
    required this.canPost,
    required this.showHandle,
    required this.onPosted,
    required this.onClearText,
  });

  final String? replyId;
  final ComposerState state;
  final ComposerController controller;
  final bool canPost;
  final bool showHandle;
  final VoidCallback? onPosted;
  final VoidCallback onClearText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final account = ref.watch(activeAccountProvider);
    final limit =
        ref.watch(instanceInfoProvider).value?.maxNoteTextLength ?? 3000;
    final used = state.text.runes.length;

    return Row(
      children: [
        IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        NyachiAvatar(url: account?.avatarUrl, size: 32),
        const SizedBox(width: 4),
        Flexible(
          child: _VisibilityMenu(
            visibility: state.visibility,
            onSelected: (value) async {
              if (value == NotesCreateRequestVisibility.specified) {
                final picked = await showRecipientPicker(
                  context,
                  preselected: state.visibleUserIds,
                );
                if (picked == null) return;
                for (final id in state.visibleUserIds) {
                  controller.removeVisibleUser(id);
                }
                for (final id in picked) {
                  controller.addVisibleUser(id);
                }
              }
              controller.setVisibility(value);
            },
          ),
        ),
        IconButton(
          tooltip: l10n.localOnly,
          onPressed: () => controller.setLocalOnly(!state.localOnly),
          icon: Icon(
            Icons.rocket_launch_outlined,
            color: state.localOnly
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        _MoreMenu(
          replyId: replyId,
          state: state,
          controller: controller,
          showHandle: showHandle,
          used: used,
          limit: limit,
          onClearText: onClearText,
        ),
        const SizedBox(width: 4),
        FilledButton.icon(
          onPressed: canPost
              ? () async {
                  final ok = await controller.post();
                  if (ok) onPosted?.call();
                }
              : null,
          icon: state.posting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send, size: 16),
          label: Text(l10n.post),
        ),
      ],
    );
  }
}

/// Overflow menu: character budget, reaction acceptance, save draft, schedule,
/// preview and reset.
class _MoreMenu extends ConsumerWidget {
  const _MoreMenu({
    required this.replyId,
    required this.state,
    required this.controller,
    required this.showHandle,
    required this.used,
    required this.limit,
    required this.onClearText,
  });

  final String? replyId;
  final ComposerState state;
  final ComposerController controller;
  final bool showHandle;
  final int used;
  final int limit;
  final VoidCallback onClearText;

  static const _acceptanceOptions = <String, String?>{
    'acceptanceAny': null,
    'acceptanceLikeOnly': 'likeOnly',
    'acceptanceNonSensitive': 'nonSensitiveOnly',
    'acceptanceNonSensitiveLocalLike':
        'nonSensitiveOnlyForLocalLikeOnlyForRemote',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
      onSelected: (value) async {
        final acceptance = _acceptanceOptions[value];
        if (acceptance != null || value == 'acceptanceAny') {
          controller.setReactionAcceptance(acceptance);
          return;
        }
        switch (value) {
          case 'expand':
            final navigator = Navigator.of(context);
            navigator.pop();
            await navigator.push<void>(
              MaterialPageRoute<void>(
                builder: (_) => ComposePage(replyId: replyId),
              ),
            );
          case 'saveDraft':
            await controller.saveDraftNow();
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l10n.draftSaved)));
            }
          case 'preview':
            controller.togglePreview();
          case 'schedule':
            await _pickSchedule(context);
          case 'reset':
            final ok = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                content: Text(l10n.resetDraft),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(l10n.resetDraft),
                  ),
                ],
              ),
            );
            if (ok == true) {
              await controller.reset();
              onClearText();
            }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  value: limit <= 0 ? 0 : (used / limit).clamp(0.0, 1.0),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(width: 10),
              Text(l10n.charLimit(used, limit)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        if (showHandle)
          PopupMenuItem<String>(
            value: 'expand',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.open_in_full),
              title: Text(l10n.openFullComposer),
            ),
          ),
        PopupMenuItem<String>(
          value: 'saveDraft',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.save_outlined),
            title: Text(l10n.saveDraftNow),
          ),
        ),
        PopupMenuItem<String>(
          value: 'preview',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.visibility_outlined),
            title: Text(l10n.preview),
            trailing: Switch(
              value: state.showPreview,
              onChanged: (_) => controller.togglePreview(),
            ),
          ),
        ),
        if (ref.watch(instanceInfoProvider).value?.scheduledNotesSupported ??
            false)
          PopupMenuItem<String>(
            value: 'schedule',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(l10n.schedule),
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            l10n.reactionAcceptance,
            style: theme.textTheme.bodySmall,
          ),
        ),
        for (final entry in _acceptanceOptions.entries)
          PopupMenuItem<String>(
            value: entry.key,
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.acceptanceLabel(entry.key)),
              trailing: state.reactionAcceptance == entry.value
                  ? const Icon(Icons.check)
                  : null,
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'reset',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.restart_alt, color: theme.colorScheme.error),
            title: Text(
              l10n.resetDraft,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickSchedule(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: state.scheduledAt ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        state.scheduledAt ?? now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null) return;
    controller.setScheduledAt(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }
}

extension _AcceptanceLabels on AppLocalizations {
  String acceptanceLabel(String key) => switch (key) {
    'acceptanceLikeOnly' => acceptanceLikeOnly,
    'acceptanceNonSensitive' => acceptanceNonSensitive,
    'acceptanceNonSensitiveLocalLike' => acceptanceNonSensitiveLocalLike,
    _ => acceptanceAny,
  };
}

/// Bottom toolbar: images, files, poll, CW, #, @, emoji.
class _ComposerToolbar extends StatelessWidget {
  const _ComposerToolbar({
    required this.state,
    required this.controller,
    required this.uploading,
    required this.onPickImages,
    required this.onPickFiles,
    required this.onToggleCw,
    required this.onInsert,
  });

  final ComposerState state;
  final ComposerController controller;
  final int uploading;
  final VoidCallback onPickImages;
  final VoidCallback onPickFiles;
  final VoidCallback onToggleCw;
  final ValueChanged<String> onInsert;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget tool(Widget child, {bool enabled = true}) => enabled
        ? child
        : Opacity(opacity: 0.4, child: IgnorePointer(child: child));

    return Row(
      children: [
        tool(
          IconButton(
            tooltip: l10n.attachMedia,
            onPressed: uploading > 0 ? null : onPickImages,
            icon: const Icon(Icons.image_outlined),
          ),
          enabled: !state.showPoll,
        ),
        tool(
          IconButton(
            tooltip: l10n.attachFiles,
            onPressed: uploading > 0 ? null : onPickFiles,
            icon: uploading > 0
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
          ),
          enabled: !state.showPoll,
        ),
        IconButton(
          tooltip: l10n.poll,
          onPressed: () => controller.setShowPoll(!state.showPoll),
          icon: Icon(
            Icons.how_to_vote_outlined,
            color: state.showPoll
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        ),
        IconButton(
          tooltip: l10n.contentWarning,
          onPressed: onToggleCw,
          icon: Icon(
            state.cw != null
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
        IconButton(
          tooltip: l10n.insertHashtag,
          onPressed: () => onInsert('#'),
          icon: const Icon(Icons.tag),
        ),
        IconButton(
          tooltip: l10n.insertMention,
          onPressed: () => onInsert('@'),
          icon: const Icon(Icons.alternate_email),
        ),
        const Spacer(),
        IconButton(
          tooltip: l10n.insertEmoji,
          onPressed: () async {
            final shortcode = await showEmojiInsertSheet(context);
            if (shortcode != null) onInsert(shortcode);
          },
          icon: const Icon(Icons.mood_outlined),
        ),
      ],
    );
  }
}

/// Poll editor: choices, multiple answers and expiry.
class _PollEditor extends StatelessWidget {
  const _PollEditor({required this.state, required this.controller});

  final ComposerState state;
  final ComposerController controller;

  static const _durations = <int?>[null, 30, 60, 360, 1440, 4320, 10080];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final valid = controller.validPollChoices().length;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < state.pollChoices.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: state.pollChoices[i],
                      decoration: InputDecoration(
                        hintText: l10n.pollChoiceHint(i + 1),
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) => controller.setPollChoice(i, value),
                    ),
                  ),
                  if (state.pollChoices.length > 2)
                    IconButton(
                      tooltip: l10n.delete,
                      onPressed: () => controller.removePollChoice(i),
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
            ),
          if (valid < 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                l10n.pollNeedsTwoChoices,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
          TextButton.icon(
            onPressed: state.pollChoices.length >= 10
                ? null
                : controller.addPollChoice,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.addChoice),
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.pollMultipleVotes),
            value: state.pollMultiple,
            onChanged: controller.setPollMultiple,
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.timer_outlined),
            title: Text(l10n.pollDuration),
            trailing: DropdownButton<int?>(
              value: _selectedMinutes(),
              underline: const SizedBox.shrink(),
              items: [
                for (final minutes in _durations)
                  DropdownMenuItem<int?>(
                    value: minutes,
                    child: Text(_durationLabel(context, minutes)),
                  ),
              ],
              onChanged: (minutes) => controller.setPollExpiresAt(
                minutes == null
                    ? null
                    : DateTime.now().add(Duration(minutes: minutes)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Round-trips the absolute expiry back to the dropdown's minute buckets.
  int? _selectedMinutes() {
    final expiresAt = state.pollExpiresAt;
    if (expiresAt == null) return null;
    final minutes = expiresAt.difference(DateTime.now()).inMinutes;
    for (final option in _durations) {
      if (option != null && (option - minutes).abs() <= 1) return option;
    }
    return null;
  }

  static String _durationLabel(BuildContext context, int? minutes) {
    final l10n = context.l10n;
    if (minutes == null) return l10n.pollNoExpiry;
    if (minutes < 60) return l10n.pollMinutes(minutes);
    if (minutes < 1440) return l10n.pollHours(minutes ~/ 60);
    return l10n.pollDays(minutes ~/ 1440);
  }
}

/// Live preview of the note body.
class _PreviewCard extends ConsumerWidget {
  const _PreviewCard({required this.state});

  final ComposerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(emojiCatalogProvider).value ?? const [];
    final emojis = <String, String>{
      for (final emoji in catalog) emoji.name: emoji.url,
    };
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.cw != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                state.cw!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          NoteContent(text: state.text, emojis: emojis),
        ],
      ),
    );
  }
}

class _AttachmentChips extends StatelessWidget {
  const _AttachmentChips({required this.state, required this.controller});

  final ComposerState state;
  final ComposerController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final fileId in state.fileIds)
            InputChip(
              label: Text(fileId),
              avatar: const Icon(Icons.insert_drive_file_outlined, size: 16),
              onDeleted: () => controller.removeFileId(fileId),
            ),
        ],
      ),
    );
  }
}

class _RecipientChips extends StatelessWidget {
  const _RecipientChips({required this.state, required this.controller});

  final ComposerState state;
  final ComposerController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(l10n.selectRecipients),
          for (final id in state.visibleUserIds)
            InputChip(
              label: Text(id),
              onDeleted: () => controller.removeVisibleUser(id),
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
        PopupMenuItem(
          value: NotesCreateRequestVisibility.specified,
          child: Text(l10n.visibilitySpecified),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(visibility), size: 20),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _label(context, visibility),
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

  IconData _icon(NotesCreateRequestVisibility visibility) =>
      switch (visibility) {
        NotesCreateRequestVisibility.public => Icons.public_outlined,
        NotesCreateRequestVisibility.home => Icons.home_outlined,
        NotesCreateRequestVisibility.followers => Icons.lock_outline,
        NotesCreateRequestVisibility.specified => Icons.mail_outline,
      };

  String _label(BuildContext context, NotesCreateRequestVisibility visibility) {
    final l10n = context.l10n;
    return switch (visibility) {
      NotesCreateRequestVisibility.public => l10n.visibilityPublic,
      NotesCreateRequestVisibility.home => l10n.visibilityHome,
      NotesCreateRequestVisibility.followers => l10n.visibilityFollowers,
      NotesCreateRequestVisibility.specified => l10n.visibilitySpecified,
    };
  }
}

/// Compact preview of the note being replied to.
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
                backgroundImage: nyachiImageProvider(user.avatarUrl),
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
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (note.cw != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          context.l10n.contentWarning,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
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
