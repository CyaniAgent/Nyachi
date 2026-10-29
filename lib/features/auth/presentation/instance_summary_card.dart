// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
import '../../../core/ui/remote_document.dart';

/// Compliance-facing instance summary: icon, display name, the server rules
/// in full, and the instance's ToS / privacy / impressum links.
///
/// Rendered on the login page and inside the OOBE compliance step once the
/// anonymous meta for the entered host has loaded.
class InstanceSummaryCard extends ConsumerWidget {
  const InstanceSummaryCard({required this.meta, super.key});

  final MetaLite meta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.instanceRules,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            if (meta.serverRules.isEmpty)
              Text(
                l10n.noServerRules,
                style: TextStyle(color: scheme.onSurfaceVariant),
              )
            else
              for (var i = 0; i < meta.serverRules.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('${i + 1}. ${meta.serverRules[i]}'),
                ),
            const SizedBox(height: 12),
            Text(
              l10n.instanceLinks,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (meta.tosUrl != null)
              _linkTile(context, l10n.complianceTermsTitle, meta.tosUrl!),
            if (meta.privacyPolicyUrl != null)
              _linkTile(
                context,
                l10n.compliancePrivacyTitle,
                meta.privacyPolicyUrl!,
              ),
            if (meta.impressumUrl != null)
              _linkTile(context, l10n.impressum, meta.impressumUrl!),
          ],
        ),
      ),
    );
  }

  Widget _linkTile(BuildContext context, String label, String url) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text(label, style: TextStyle(color: scheme.primary)),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: scheme.onSurfaceVariant,
      ),
      onTap: () => openRemoteDocument(context, title: label, url: url),
    );
  }
}
