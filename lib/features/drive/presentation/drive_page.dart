// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart' hide Clip;

import '../../../core/network/error_mapper.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
import '../../../core/ui/time_format.dart';
import '../../notes/presentation/image_viewer.dart';
import '../data/drive_repository.dart';

/// One level of the drive folder stack, for breadcrumb navigation.
class _Crumb {
  const _Crumb({required this.id, required this.name});

  final String? id;
  final String name;
}

/// Remote drive browser laid out like the classic drive screen: breadcrumbs on
/// top, the file list in the middle, quota in a bottom bar, and a FAB that
/// offers create-folder / upload.
class DrivePage extends ConsumerStatefulWidget {
  const DrivePage({this.folderId, this.folderName, super.key});

  final String? folderId;
  final String? folderName;

  @override
  ConsumerState<DrivePage> createState() => _DrivePageState();
}

class _DrivePageState extends ConsumerState<DrivePage> {
  late List<_Crumb> _stack = [
    _Crumb(id: widget.folderId, name: widget.folderName ?? ''),
  ];
  var _busy = false;

  String? get _currentFolderId => _stack.last.id;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listing = ref.watch(driveListingProvider(_currentFolderId));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName ?? l10n.drive),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: _busy
                ? null
                : () => ref.invalidate(driveListingProvider(_currentFolderId)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: listing.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mapFailure(error).message(l10n)),
              TextButton(
                onPressed: () =>
                    ref.invalidate(driveListingProvider(_currentFolderId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) => Column(
          children: [
            _breadcrumbs(context, l10n),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(driveListingProvider(_currentFolderId)),
                child: _list(context, l10n, data),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: listing.maybeWhen(
        data: (data) =>
            data.capacity > 0 ? _quotaBar(context, l10n, data) : null,
        orElse: () => null,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _busy ? null : _addOptions,
        tooltip: l10n.upload,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _breadcrumbs(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _stack.length + 1,
        separatorBuilder: (_, _) => const Icon(Icons.chevron_right, size: 16),
        itemBuilder: (context, index) {
          final isRoot = index == 0;
          final isLast = index == _stack.length;
          final title = isRoot ? l10n.drive : _stack[index - 1].name;
          return TextButton(
            onPressed: isLast
                ? null
                : () => setState(() {
                    if (isRoot) {
                      _stack = [_Crumb(id: widget.folderId, name: '')];
                    } else {
                      _stack = _stack.sublist(0, index);
                    }
                  }),
            child: Text(
              title,
              style: TextStyle(
                color: isLast ? null : theme.colorScheme.primary,
                fontWeight: isLast ? FontWeight.bold : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _list(BuildContext context, AppLocalizations l10n, DriveListing data) {
    if (data.files.isEmpty && data.folders.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.noFiles),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return ListView(
      children: [
        for (final folder in data.folders)
          ListTile(
            leading: Icon(
              Icons.folder,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            title: Text(
              folder.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(relativeTime(context, folder.createdAt)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openFolder(folder),
            onLongPress: () => _deleteFolder(folder.id, folder.name),
          ),
        for (final file in data.files) _fileTile(context, l10n, file),
      ],
    );
  }

  Widget _fileTile(
    BuildContext context,
    AppLocalizations l10n,
    DriveFile file,
  ) {
    final isImage = file.type.startsWith('image/');
    return ListTile(
      leading: isImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: NyachiImage(
                url: file.thumbnailUrl ?? file.url,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            )
          : const Icon(Icons.insert_drive_file_outlined),
      title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${_size(file.size.toInt())} · ${relativeTime(context, file.createdAt)}',
      ),
      onTap: isImage ? () => showImageViewer(context, [file]) : null,
      onLongPress: () => _deleteFile(file.name, file.id),
    );
  }

  Widget _quotaBar(
    BuildContext context,
    AppLocalizations l10n,
    DriveListing data,
  ) {
    final theme = Theme.of(context);
    return BottomAppBar(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.driveSpace,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_size(data.usage)} / ${_size(data.capacity)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.usedRatio,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: data.usedRatio > 0.9 ? theme.colorScheme.error : null,
            ),
          ),
        ],
      ),
    );
  }

  void _openFolder(DriveFolder folder) {
    setState(
      () => _stack = [..._stack, _Crumb(id: folder.id, name: folder.name)],
    );
  }

  Future<void> _addOptions() async {
    final l10n = context.l10n;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: Text(l10n.newFolder),
              onTap: () => Navigator.of(sheetContext).pop('folder'),
            ),
            ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: Text(l10n.upload),
              onTap: () => Navigator.of(sheetContext).pop('upload'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'folder') {
      await _createFolder();
    } else {
      await _upload();
    }
  }

  Future<void> _createFolder() async {
    final l10n = context.l10n;
    final name = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.newFolder),
        content: TextField(
          controller: name,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.folderName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.create),
          ),
        ],
      ),
    );
    final folderName = name.text.trim();
    name.dispose();
    if (result != true || folderName.isEmpty || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(driveRepositoryProvider)
          .createFolder(name: folderName, parentId: _currentFolderId);
      ref.invalidate(driveListingProvider(_currentFolderId));
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _upload() async {
    final picked = await FilePicker.pickFiles(type: FileType.media);
    if (picked.isEmpty || !mounted) return;
    setState(() => _busy = true);
    try {
      final file = picked.first;
      final bytes = await file.readAsBytes();
      await ref
          .read(driveRepositoryProvider)
          .upload(
            bytes: bytes,
            fileName: file.name,
            folderId: _currentFolderId,
          );
      ref.invalidate(driveListingProvider(_currentFolderId));
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteFile(String name, String fileId) async {
    final l10n = context.l10n;
    final ok = await _confirm(l10n.deleteFileConfirm(name));
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(driveRepositoryProvider).delete(fileId);
      ref.invalidate(driveListingProvider(_currentFolderId));
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteFolder(String folderId, String name) async {
    final l10n = context.l10n;
    final ok = await _confirm(l10n.deleteFileConfirm(name));
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(driveRepositoryProvider).deleteFolder(folderId);
      ref.invalidate(driveListingProvider(_currentFolderId));
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirm(String message) {
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(message),
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
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mapFailure(error).message(context.l10n))),
    );
  }
}

String _size(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}
