// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../drive/data/drive_repository.dart';
import '../../drive/presentation/drive_page.dart';

/// Drive entry point plus the storage quota the drive page does not state.
///
/// The quota comes from the same listing provider the drive page uses, so the
/// numbers here and there can never disagree.
class DriveSettingsPage extends ConsumerWidget {
  const DriveSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final listing = ref.watch(driveListingProvider(null));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.drive)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              listing.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: LinearProgressIndicator(),
                ),
                error: (error, _) => Text(l10n.driveSpaceUnavailable),
                data: (data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.driveSpace,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: data.usedRatio),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatSize(data.usage)} / ${_formatSize(data.capacity)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.folder_outlined),
                title: Text(l10n.openDrive),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const DrivePage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
  final mb = kb / 1024;
  if (mb < 1024) return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
  return '${(mb / 1024).toStringAsFixed(1)} GB';
}
