// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/error_mapper.dart';
import '../../../core/ui/l10n_ext.dart';
import '../data/admin_repository.dart';
import 'admin_list_scaffold.dart';

/// Instance announcements: publish, edit the active state, delete.
///
/// Announcements are shown to every user, so creating one is a deliberate act
/// with a form rather than a single tap. Deleting asks first, because it
/// removes the notice from every user's screen.
class AdminAnnouncementsPage extends ConsumerWidget {
  const AdminAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AdminListScaffold<AdminAnnouncementsListResponseItem>(
      title: l10n.adminAnnouncements,
      load: (ref) => ref.read(adminRepositoryProvider).announcements(limit: 40),
      actions: [
        IconButton(
          tooltip: l10n.adminAnnouncements,
          onPressed: () => _create(context, ref),
          icon: const Icon(Icons.add),
        ),
      ],
      builder: (context, items, reload) => ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) =>
            _AnnouncementTile(announcement: items[index], onChanged: reload),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final title = TextEditingController();
    final text = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminAnnouncements),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.adminTitle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: text,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.adminBody),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    final titleText = title.text;
    final bodyText = text.text;
    title.dispose();
    text.dispose();
    if (!(result ?? false) || titleText.trim().isEmpty) return;
    try {
      await ref
          .read(adminRepositoryProvider)
          .createAnnouncement(title: titleText, text: bodyText);
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminSaved)));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(mapFailure(error).message(l10n))),
      );
    }
  }
}

class _AnnouncementTile extends ConsumerWidget {
  const _AnnouncementTile({
    required this.announcement,
    required this.onChanged,
  });

  final AdminAnnouncementsListResponseItem announcement;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      title: Text(
        announcement.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        announcement.text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: announcement.isActive,
            onChanged: (active) async {
              await ref
                  .read(adminRepositoryProvider)
                  .updateAnnouncement(id: announcement.id, isActive: active);
              onChanged();
            },
          ),
          IconButton(
            tooltip: l10n.delete,
            onPressed: () async {
              await ref
                  .read(adminRepositoryProvider)
                  .deleteAnnouncement(announcement.id);
              onChanged();
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
