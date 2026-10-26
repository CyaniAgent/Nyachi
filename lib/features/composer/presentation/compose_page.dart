// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import 'package:file_picker/file_picker.dart';

import '../../../core/network/error_mapper.dart';
import '../../../core/network/instance_repository.dart';
import '../../drive/data/drive_repository.dart';
import '../../settings/application/app_settings.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/failure_action.dart';
import '../../../core/ui/l10n_ext.dart';
import '../application/composer_controller.dart';
import 'compose_sheet.dart';

class ComposePage extends ConsumerStatefulWidget {
  const ComposePage({this.replyId, super.key});

  final String? replyId;

  @override
  ConsumerState<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends ConsumerState<ComposePage> {
  final _text = TextEditingController();
  final _cw = TextEditingController();
  var _hasCw = false;
  var _uploading = false;

  /// Picks files and uploads them to the drive, then attaches their ids.
  Future<void> _attach() async {
    final picked = await FilePicker.pickFiles(type: FileType.media);
    if (picked.isEmpty || !mounted) return;
    setState(() => _uploading = true);
    final controller = ref.read(
      composerControllerProvider(widget.replyId).notifier,
    );
    final drive = ref.read(driveRepositoryProvider);
    try {
      for (final file in picked) {
        final bytes = await file.readAsBytes();
        final uploaded = await drive.upload(bytes: bytes, fileName: file.name);
        controller.addFileId(uploaded.id);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapFailure(error).message(context.l10n))),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.replyId == null ? l10n.newNote : l10n.replyTo),
        actions: [
          if (state.restored)
            IconButton(
              tooltip: l10n.deleteDraft,
              onPressed: () {
                controller.deleteDraft();
                _text.clear();
                _cw.clear();
              },
              icon: const Icon(Icons.delete_outline),
            ),
          TextButton(
            onPressed: canPost
                ? () async {
                    final ok = await controller.post();
                    if (ok && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                : null,
            child: Text(state.posting ? l10n.posting : l10n.post),
          ),
        ],
      ),
      body: ReadableWidth(
        centered: ref.watch(settingsControllerProvider).centerContent,
        maxWidth: appMaxContentWidth,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.replyId != null)
              ReplyPreviewCard(noteId: widget.replyId!),
            if (state.restored)
              Material(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: const Icon(Icons.restore),
                  title: Text(l10n.draftRestored),
                ),
              ),
            if (state.error != null)
              Material(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(state.error!.message(l10n)),
                  trailing: FailureAction(
                    failure: state.error!,
                    onRetry: () => controller.post(),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(child: Text(l10n.contentWarning)),
                Switch(
                  value: _hasCw,
                  onChanged: (value) {
                    setState(() {
                      _hasCw = value;
                      if (!value) {
                        _cw.clear();
                        controller.setCw(null);
                      }
                    });
                  },
                ),
              ],
            ),
            if (_hasCw)
              TextField(
                controller: _cw,
                decoration: InputDecoration(
                  hintText: l10n.contentWarningHint,
                  border: const OutlineInputBorder(),
                ),
                onChanged: controller.setCw,
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              minLines: 6,
              maxLines: null,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: controller.setText,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: state.posting || _uploading ? null : _attach,
                  icon: _uploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.attach_file, size: 18),
                  label: Text(_uploading ? l10n.uploading : l10n.attachFiles),
                ),
                const Spacer(),
                Text(
                  l10n.characterCount(state.text.runes.length),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (state.fileIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final fileId in state.fileIds)
                    InputChip(
                      label: Text(fileId.substring(0, 8)),
                      avatar: const Icon(Icons.image_outlined, size: 16),
                      onDeleted: () => controller.removeFileId(fileId),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<NotesCreateRequestVisibility>(
                    key: ValueKey(state.visibility),
                    initialValue: state.visibility,
                    decoration: InputDecoration(labelText: l10n.visibility),
                    items: [
                      DropdownMenuItem(
                        value: NotesCreateRequestVisibility.public,
                        child: Text(l10n.visibilityPublic),
                      ),
                      DropdownMenuItem(
                        value: NotesCreateRequestVisibility.home,
                        child: Text(l10n.visibilityHome),
                      ),
                      DropdownMenuItem(
                        value: NotesCreateRequestVisibility.followers,
                        child: Text(l10n.visibilityFollowers),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.setVisibility(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Text(l10n.localOnly),
                    Switch(
                      value: state.localOnly,
                      onChanged: controller.setLocalOnly,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
