// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/network/error_mapper.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/ui/l10n_ext.dart';
import '../data/admin_repository.dart';
import 'admin_list_scaffold.dart';

/// The report queue: what users flagged, who it targets, and the decision.
///
/// Unresolved reports come first because that is the work. Accepting or
/// rejecting closes the report only; punishing the account is a separate step
/// on the user screen, deliberately not folded in here.
class AdminReportsPage extends ConsumerWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AdminListScaffold<AdminAbuseUserReportsResponseItem>(
      title: l10n.adminReports,
      load: (ref) => ref
          .read(adminRepositoryProvider)
          .reports(state: 'unresolved', limit: 40),
      emptyMessage: l10n.adminReportUnresolved,
      builder: (context, items, reload) {
        final sorted = [...items]
          ..sort((a, b) {
            if (a.resolved != b.resolved) return a.resolved ? 1 : -1;
            return b.createdAt.compareTo(a.createdAt);
          });
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sorted.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) =>
              _ReportTile(report: sorted[index], onChanged: reload),
        );
      },
    );
  }
}

class _ReportTile extends ConsumerStatefulWidget {
  const _ReportTile({required this.report, required this.onChanged});

  final AdminAbuseUserReportsResponseItem report;
  final VoidCallback onChanged;

  @override
  ConsumerState<_ReportTile> createState() => _ReportTileState();
}

class _ReportTileState extends ConsumerState<_ReportTile> {
  var _busy = false;

  Future<void> _run(Future<void> Function() action, String done) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(done)));
      widget.onChanged();
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
    final report = widget.report;
    final theme = Theme.of(context);
    final status = report.resolved
        ? (report.resolvedAs ==
                  AdminAbuseUserReportsResponseItemResolvedAs.accept
              ? l10n.adminReportAccepted
              : l10n.adminReportRejected)
        : l10n.adminReportUnresolved;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NyachiAvatar(url: report.targetUser.avatarUrl, size: 32),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.targetUser.name ?? report.targetUser.username,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '@${report.targetUser.username}'
                      '${report.targetUser.host == null ? '' : '@${report.targetUser.host}'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(status),
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(report.comment),
          const SizedBox(height: 4),
          Text(
            l10n.adminReportedBy(report.reporter.username),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (report.moderationNote.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              report.moderationNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (!report.resolved) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          () => ref
                              .read(adminRepositoryProvider)
                              .resolveReport(
                                reportId: report.id,
                                resolvedAs:
                                    AdminResolveAbuseUserReportRequestResolvedAs
                                        .accept,
                              ),
                          l10n.adminReportAccepted,
                        ),
                  child: Text(l10n.adminAccept),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          () => ref
                              .read(adminRepositoryProvider)
                              .resolveReport(
                                reportId: report.id,
                                resolvedAs:
                                    AdminResolveAbuseUserReportRequestResolvedAs
                                        .reject,
                              ),
                          l10n.adminReportRejected,
                        ),
                  child: Text(l10n.adminReject),
                ),
                if (report.targetUser.host != null)
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => ref
                                .read(adminRepositoryProvider)
                                .forwardReport(report.id),
                            l10n.adminForward,
                          ),
                    child: Text(l10n.adminForward),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: _busy ? null : () => _editNote(context, report),
                  child: Text(l10n.adminNote),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _editNote(
    BuildContext context,
    AdminAbuseUserReportsResponseItem report,
  ) async {
    final controller = TextEditingController(text: report.moderationNote);
    final l10n = context.l10n;
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminNote),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          decoration: InputDecoration(hintText: l10n.adminNote),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.adminSaveNote),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note == null) return;
    await _run(
      () => ref
          .read(adminRepositoryProvider)
          .setReportNote(report.id, note.isEmpty ? null : note),
      l10n.adminNoteSaved,
    );
  }
}
