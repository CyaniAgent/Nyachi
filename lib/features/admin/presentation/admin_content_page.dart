// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/error_mapper.dart';
import '../../../core/ui/l10n_ext.dart';
import '../data/admin_repository.dart';
import 'admin_list_scaffold.dart';

/// Every file the instance stores, newest first.
///
/// Deletion is permanent and takes the file out of its owner's drive, so it
/// confirms first. The row shows the owner because that is what a takedown
/// decision actually needs: the same image is a different case depending on who
/// uploaded it.
class AdminContentPage extends ConsumerWidget {
  const AdminContentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AdminListScaffold<DriveFile>(
      title: l10n.adminContent,
      load: (ref) => ref.read(adminRepositoryProvider).files(limit: 40),
      builder: (context, files, reload) => ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: files.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) =>
            _FileTile(file: files[index], onDeleted: reload),
      ),
    );
  }
}

class _FileTile extends ConsumerStatefulWidget {
  const _FileTile({required this.file, required this.onDeleted});

  final DriveFile file;
  final VoidCallback onDeleted;

  @override
  ConsumerState<_FileTile> createState() => _FileTileState();
}

class _FileTileState extends ConsumerState<_FileTile> {
  var _busy = false;

  Future<void> _delete() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.adminConfirmDeleteFile),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(adminRepositoryProvider).deleteFile(widget.file.id);
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminDeleted)));
      widget.onDeleted();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(mapFailure(error).message(l10n))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final file = widget.file;
    final owner = file.user;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: SizedBox(
        width: 40,
        height: 40,
        child: file.thumbnailUrl == null
            ? const Icon(Icons.insert_drive_file_outlined)
            : ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  file.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.insert_drive_file_outlined),
                ),
              ),
      ),
      title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${owner == null ? '' : '@${owner.username}'}'
        '${file.size >= 0 ? ' · ${_size(file.size)}' : ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              tooltip: l10n.delete,
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
    );
  }

  static String _size(num bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
