// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/network/instance_repository.dart';
import '../../../core/storage/storage_models.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/time_format.dart';
import '../application/composer_controller.dart';
import '../application/draft_store.dart';
import 'visibility_ui.dart';

/// The composer header avatar's panel: stored drafts, server-side scheduled
/// posts, and switching between accounts on the same instance.
Future<void> showComposerPanel(
  BuildContext context, {
  required String? replyId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ComposerPanel(replyId: replyId),
  );
}

class _ComposerPanel extends ConsumerWidget {
  const _ComposerPanel({required this.replyId});

  final String? replyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(composerControllerProvider(replyId).notifier);
    final drafts = ref.watch(composerDraftsProvider);
    final scheduled = ref.watch(composerScheduledDraftsProvider);
    final session = ref.watch(sessionControllerProvider);
    final host = session.active?.host;
    final siblings = session.accounts
        .where((account) => account.host == host)
        .toList(growable: false);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          _SectionHeader(l10n.drafts),
          drafts.when(
            loading: () => const _BusyRow(),
            error: (error, _) => _EmptyRow(l10n.draftsLoadFailed),
            data: (items) => items.isEmpty
                ? _EmptyRow(l10n.noDrafts)
                : Column(
                    children: [
                      for (final draft in items)
                        _DraftRow(
                          draft: draft,
                          onLoad: () {
                            controller.loadDraft(draft);
                            Navigator.of(context).pop();
                          },
                          onDelete: () => _delete(context, ref, draft),
                        ),
                    ],
                  ),
          ),
          if (ref.watch(instanceInfoProvider).value?.draftsSupported ?? false)
            ..._scheduledSection(context, ref, l10n, scheduled),
          const Divider(height: 1),
          _SectionHeader(l10n.switchLabel),
          for (final account in siblings)
            ListTile(
              leading: Icon(
                account.id == session.active?.id
                    ? Icons.check_circle
                    : Icons.person_outline,
                color: account.id == session.active?.id
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(account.displayName ?? account.username),
              subtitle: Text('@${account.username}@${account.host}'),
              onTap: account.id == session.active?.id
                  ? null
                  : () => _switch(context, ref, account),
            ),
        ],
      ),
    );
  }

  List<Widget> _scheduledSection(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AsyncValue<List<ComposerDraft>> scheduled,
  ) {
    return [
      const Divider(height: 1),
      _SectionHeader(l10n.scheduledPosts),
      scheduled.when(
        loading: () => const _BusyRow(),
        error: (error, _) => _EmptyRow(l10n.draftsLoadFailed),
        data: (items) => items.isEmpty
            ? _EmptyRow(l10n.noScheduledPosts)
            : Column(
                children: [
                  for (final draft in items)
                    ListTile(
                      leading: Icon(
                        visibilityIcon(parseVisibility(draft.visibility)),
                      ),
                      title: Text(
                        draft.text.isEmpty
                            ? l10n.attachment
                            : draft.text.replaceAll('\n', ' '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        draft.scheduledAt == null
                            ? relativeTime(context, draft.updatedAt)
                            : l10n.scheduledFor(
                                relativeTime(context, draft.scheduledAt!),
                              ),
                      ),
                      trailing: IconButton(
                        tooltip: l10n.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteScheduled(context, ref, draft),
                      ),
                    ),
                ],
              ),
      ),
    ];
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ComposerDraft draft,
  ) async {
    await ref
        .read(composerControllerProvider(replyId).notifier)
        .deleteStoredDraft(draft.id);
    ref.invalidate(composerDraftsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.draftDeleted)));
    }
  }

  Future<void> _deleteScheduled(
    BuildContext context,
    WidgetRef ref,
    ComposerDraft draft,
  ) async {
    await ref
        .read(composerControllerProvider(replyId).notifier)
        .deleteStoredDraft(draft.id);
    ref.invalidate(composerScheduledDraftsProvider);
  }

  /// Switches the active account without leaving the composer: the panel
  /// closes and the sheet stays open on the new account's drafts.
  Future<void> _switch(
    BuildContext context,
    WidgetRef ref,
    LocalAccount account,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .switchAccount(account.id);
      navigator.pop();
    } on SessionExpiredException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.sessionExpired)));
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(mapFailure(error).message(l10n))),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _DraftRow extends StatelessWidget {
  const _DraftRow({
    required this.draft,
    required this.onLoad,
    required this.onDelete,
  });

  final ComposerDraft draft;
  final VoidCallback onLoad;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = draft.text.replaceAll('\n', ' ').trim();
    return ListTile(
      leading: Icon(visibilityIcon(parseVisibility(draft.visibility))),
      title: Text(
        text.isEmpty ? l10n.attachment : text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(relativeTime(context, draft.updatedAt)),
      onTap: onLoad,
      trailing: IconButton(
        tooltip: l10n.delete,
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _BusyRow extends StatelessWidget {
  const _BusyRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
