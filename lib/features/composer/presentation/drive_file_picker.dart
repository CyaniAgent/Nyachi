// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/error_mapper.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
import '../../drive/data/drive_repository.dart';

/// Opens the drive picker and returns the chosen file ids, or null.
///
/// Selected files are attached as they are: the drive already holds the
/// bytes, so no upload happens and the caller receives ids directly.
Future<List<String>?> showDriveFilePicker(BuildContext context) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _DriveFilePicker(),
  );
}

class _DriveFilePicker extends ConsumerStatefulWidget {
  const _DriveFilePicker();

  @override
  ConsumerState<_DriveFilePicker> createState() => _DriveFilePickerState();
}

class _DriveFilePickerState extends ConsumerState<_DriveFilePicker> {
  String? _folderId;
  final _selected = <String>{};
  var _busy = false;

  /// Folder trail from the root to [_folderId], so the header can go back.
  final _trail = <DriveFolder>[];

  void _enter(DriveFolder folder) {
    setState(() {
      _trail.add(folder);
      _folderId = folder.id;
    });
  }

  void _up() {
    setState(() {
      _trail.removeLast();
      _folderId = _trail.isEmpty ? null : _trail.last.id;
    });
  }

  Future<void> _createFolder() async {
    // The text controller belongs to the dialog's own State: disposing one
    // owned here would clash with the closing animation still rebuilding
    // the field after this future resolves.
    final folderName = await showDialog<String>(
      context: context,
      builder: (_) => const _NewFolderDialog(),
    );
    if (folderName == null || folderName.isEmpty || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(driveRepositoryProvider)
          .createFolder(name: folderName, parentId: _folderId);
      ref.invalidate(driveListingProvider(_folderId));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapFailure(error).message(context.l10n))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listing = ref.watch(driveListingProvider(_folderId));
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  if (_trail.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _up,
                      tooltip: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                    )
                  else
                    const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _trail.isEmpty ? l10n.drive : _trail.last.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.create_new_folder_outlined),
                    onPressed: _busy ? null : _createFolder,
                    tooltip: l10n.newFolder,
                  ),
                ],
              ),
            ),
            Flexible(
              child: listing.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mapFailure(error).message(l10n)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(driveListingProvider(_folderId)),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
                data: (data) {
                  final files = data.files;
                  if (data.folders.isEmpty && files.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l10n.driveEmpty),
                    );
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      for (final folder in data.folders)
                        ListTile(
                          leading: const Icon(Icons.folder_outlined),
                          title: Text(
                            folder.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _enter(folder),
                        ),
                      for (final file in files)
                        _FileRow(
                          file: file,
                          selected: _selected.contains(file.id),
                          onToggle: () => setState(() {
                            if (!_selected.remove(file.id)) {
                              _selected.add(file.id);
                            }
                          }),
                        ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.driveSelectedCount(_selected.length),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  FilledButton(
                    onPressed: _selected.isEmpty
                        ? null
                        : () =>
                              Navigator.of(context)
                                  .pop(_selected.toList(growable: false)),
                    child: Text(l10n.attach),
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

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.file,
    required this.selected,
    required this.onToggle,
  });

  final DriveFile file;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final thumbnail = file.thumbnailUrl;
    return ListTile(
      selected: selected,
      leading: SizedBox(
        width: 32,
        height: 32,
        child: thumbnail == null
            ? const Icon(Icons.insert_drive_file_outlined)
            : NyachiImage(url: thumbnail, fit: BoxFit.cover),
      ),
      title: Text(file.name, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        _formatSize(file.size.toInt()),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Checkbox(value: selected, onChanged: (_) => onToggle()),
      onTap: onToggle,
    );
  }
}

/// Asks for a folder name and pops the trimmed value, or null on cancel.
///
/// A StatefulWidget so the text controller shares the dialog's lifecycle; a
/// controller owned by the caller would be disposed while the closing
/// animation still rebuilds the field.
class _NewFolderDialog extends StatefulWidget {
  const _NewFolderDialog();

  @override
  State<_NewFolderDialog> createState() => _NewFolderDialogState();
}

class _NewFolderDialogState extends State<_NewFolderDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_name.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.newFolder),
      content: TextField(
        controller: _name,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.folderName),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(l10n.create)),
      ],
    );
  }
}

String _formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
}
