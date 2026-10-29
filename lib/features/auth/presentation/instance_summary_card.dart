// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
import 'instance_detail_page.dart';

/// Compact instance summary on the login/OOBE surface: icon, display name,
/// and a chevron. Tapping opens [InstanceDetailPage] with the full server
/// rules and the instance's ToS / privacy / impressum links.
class InstanceSummaryCard extends ConsumerWidget {
  const InstanceSummaryCard({required this.meta, super.key});

  final MetaLite meta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => InstanceDetailPage(meta: meta),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: meta.iconUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: NyachiImage(
                          url: meta.iconUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ColoredBox(
                        color: scheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.dns_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  meta.name ?? l10n.serverNameFallback,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
