// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart' hide Clip;

import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
import '../../../core/ui/time_format.dart';
import '../../notes/presentation/image_viewer.dart';
import '../data/drive_repository.dart';

/// Remote drive browser laid out like the classic drive screen: breadcrumbs on
/// top, the file list in the middle, quota in a bottom bar, and a FAB that
/// offers create-folder / upload.
///
/// Long-pressing an entry (or the app-bar select button) enters selection mode;
/// tapping entries then toggles their selection and the app bar offers delete.
class DrivePage extends ConsumerStatefulWidget {
  const DrivePage({this.folderId, this.folderName, super.key});

  final String? folderId;
  final String? folderName;

  @override
  ConsumerState<DrivePage> createState() => _DrivePageState();
}

class _DrivePageState extends ConsumerState<DrivePage> {
  /// Folder breadcrumb below the drive root; empty when at the root.
  List<_Crumb> _stack = const [];

  /// Seeds the breadcrumb stack when the page was opened inside a folder.
  List<_Crumb> _initialStack() {
    final id = widget.folderId;
    if (id == null) return const [];
    return [_Crumb(id: id, name: widget.folderName ?? '')];
  }

  final Set<String> _selected = <String>{};
  var _busy = false;

  bool get _selectMode => _selected.isNotEmpty;

  String? get _currentFolderId => _stack.isEmpty ? null : _stack.last.id;

  @override
  void initState() {
    super.initState();
    _stack = _initialStack();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listing = ref.watch(driveListingProvider(_currentFolderId));
    return Scaffold(
      appBar: AppBar(
        leading: _selectMode
            ? IconButton(
                tooltip: l10n.cancel,
                onPressed: _exitSelection,
                icon: const Icon(Icons.close),
              )
            : null,
        title: Text(
          _selectMode
              ? l10n.driveSelectedCount(_selected.length)
              : (widget.folderName ?? l10n.drive),
        ),
        actions: [
          if (_selectMode) ...[
            IconButton(
              tooltip: l10n.delete,
              onPressed: _busy ? null : _deleteSelected,
              icon: const Icon(Icons.delete_outlined),
            ),
          ] else ...[
            IconButton(
              tooltip: l10n.selectAll,
              onPressed: _busy ? null : _selectAllVisible,
              icon: const Icon(Icons.select_all_outlined),
            ),
            IconButton(
              tooltip: l10n.refresh,
              onPressed: _busy
                  ? null
                  : () =>
                        ref.invalidate(driveListingProvider(_currentFolderId)),
              icon: const Icon(Icons.refresh),
            ),
          ],
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
      floatingActionButton: _selectMode
          ? null
          : FloatingActionButton(
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
                    _stack = isRoot ? const [] : _stack.sublist(0, index);
                    _selected.clear();
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
          _FolderTile(
            folder: folder,
            selected: _selected.contains(folder.id),
            selectMode: _selectMode,
            onOpen: () => _openFolder(folder),
            onToggle: () => _toggle(folder.id),
            onDelete: () => _deleteFolders({folder}),
          ),
        for (final file in data.files)
          _FileTile(
            file: file,
            selected: _selected.contains(file.id),
            selectMode: _selectMode,
            onOpen: () => showImageViewer(context, [file]),
            onToggle: () => _toggle(file.id),
            onDelete: () => _deleteFiles({file}),
          ),
      ],
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

  void _toggle(String id) {
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
    });
  }

  void _selectAllVisible() {
    final data = ref.read(driveListingProvider(_currentFolderId)).value;
    if (data == null) return;
    setState(() {
      _selected.addAll(data.folders.map((f) => f.id));
      _selected.addAll(data.files.map((f) => f.id));
    });
  }

  void _exitSelection() {
    setState(() => _selected.clear());
  }

  void _openFolder(DriveFolder folder) {
    setState(() {
      _stack = [..._stack, _Crumb(id: folder.id, name: folder.name)];
      _selected.clear();
    });
  }

  Future<void> _deleteSelected() async {
    final data = ref.read(driveListingProvider(_currentFolderId)).value;
    if (data == null) return;
    final folders = data.folders.where((f) => _selected.contains(f.id)).toSet();
    final files = data.files.where((f) => _selected.contains(f.id)).toSet();
    await _delete(context, folders: folders, files: files);
    _exitSelection();
  }

  Future<void> _deleteFiles(Set<DriveFile> files) =>
      _delete(context, files: files);

  Future<void> _deleteFolders(Set<DriveFolder> folders) =>
      _delete(context, folders: folders);

  Future<void> _delete(
    BuildContext context, {
    Set<DriveFolder> folders = const {},
    Set<DriveFile> files = const {},
  }) async {
    final l10n = context.l10n;
    final count = folders.length + files.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.deleteItemsConfirm(count)),
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
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final repo = ref.read(driveRepositoryProvider);
    try {
      for (final folder in folders) {
        await repo.deleteFolder(folder.id);
      }
      for (final file in files) {
        await repo.delete(file.id);
      }
      ref.invalidate(driveListingProvider(_currentFolderId));
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mapFailure(error).message(context.l10n))),
    );
  }
}

/// One level of the drive folder stack, for breadcrumb navigation.
class _Crumb {
  const _Crumb({required this.id, required this.name});

  final String? id;
  final String name;

  @override
  bool operator ==(Object other) => other is _Crumb && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Leading slot shared by both tile kinds: a fixed 48x48 area so folder and
/// file rows line up, with a selection check badge.
class _TileLeading extends StatelessWidget {
  const _TileLeading({required this.child, required this.selected});

  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          Center(child: child),
          if (selected)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check,
                  size: 12,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({
    required this.folder,
    required this.selected,
    required this.selectMode,
    required this.onOpen,
    required this.onToggle,
    required this.onDelete,
  });

  final DriveFolder folder;
  final bool selected;
  final bool selectMode;
  final VoidCallback onOpen;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      tileColor: selected ? scheme.secondaryContainer.withAlpha(128) : null,
      leading: _TileLeading(
        selected: selected,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.folder, size: 20, color: scheme.onPrimaryContainer),
        ),
      ),
      title: Text(folder.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(relativeTime(context, folder.createdAt)),
      onTap: selectMode ? onToggle : onOpen,
      onLongPress: onToggle,
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.file,
    required this.selected,
    required this.selectMode,
    required this.onOpen,
    required this.onToggle,
    required this.onDelete,
  });

  final DriveFile file;
  final bool selected;
  final bool selectMode;
  final VoidCallback onOpen;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isImage = file.type.startsWith('image/');
    return ListTile(
      tileColor: selected ? scheme.secondaryContainer.withAlpha(128) : null,
      leading: _TileLeading(
        selected: selected,
        child: isImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: NyachiImage(
                  url: file.thumbnailUrl ?? file.url,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
              ),
      ),
      title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${_size(file.size.toInt())} · ${relativeTime(context, file.createdAt)}',
      ),
      onTap: selectMode ? onToggle : (isImage ? onOpen : null),
      onLongPress: onToggle,
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
