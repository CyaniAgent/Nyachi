// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/error_mapper.dart';
import '../../../core/ui/l10n_ext.dart';
import '../data/admin_repository.dart';
import 'admin_list_scaffold.dart';

/// Invite codes for a closed instance.
///
/// Creating one is cheap and instantly usable for sign-up, so the new code is
/// surfaced directly rather than only appearing in the refreshed list.
class AdminInvitesPage extends ConsumerWidget {
  const AdminInvitesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AdminListScaffold<InviteCode>(
      title: l10n.adminInvites,
      load: (ref) => ref.read(adminRepositoryProvider).invites(limit: 40),
      actions: [
        IconButton(
          tooltip: l10n.adminCreateInvite,
          onPressed: () => _create(context, ref),
          icon: const Icon(Icons.add),
        ),
      ],
      builder: (context, invites, reload) => ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: invites.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) =>
            _InviteTile(invite: invites[index], onChanged: reload),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final codes = await ref.read(adminRepositoryProvider).createInvite();
      // The full code is shown here because this is the only moment it is
      // useful: it is what gets handed to the invited person.
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminInviteCreated(codes.first.code))),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(mapFailure(error).message(l10n))),
      );
    }
  }
}

class _InviteTile extends StatelessWidget {
  const _InviteTile({required this.invite, required this.onChanged});

  final InviteCode invite;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final expires = invite.expiresAt;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(
        invite.used ? Icons.check_circle : Icons.key,
        color: invite.used
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.primary,
      ),
      title: Text(invite.code),
      subtitle: Text(
        invite.used
            ? l10n.adminInviteUsed
            : (expires == null
                  ? ''
                  : '${l10n.adminExpiry} ${expires.toLocal().toString().substring(0, 16)}'),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
