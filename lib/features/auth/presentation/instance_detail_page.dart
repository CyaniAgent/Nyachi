// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/remote_document.dart';

/// Resolves an instance-provided document link against the instance origin.
/// Misskey meta usually returns absolute URLs, but some instances return
/// paths (`/terms`); those must resolve against `meta.uri` to be openable.
Uri? resolveInstanceLink(MetaLite meta, String url) {
  if (url.trim().isEmpty) return null;
  final parsed = Uri.tryParse(url);
  if (parsed == null) return null;
  if (parsed.scheme == 'http' || parsed.scheme == 'https') return parsed;
  final base = Uri.tryParse(meta.uri);
  if (base == null || !(base.scheme == 'http' || base.scheme == 'https')) {
    return null;
  }
  return base.resolve(url);
}

/// Full instance compliance details: server rules in order and the
/// instance's ToS / privacy / impressum links, each opened in the embedded
/// remote-document page.
class InstanceDetailPage extends StatelessWidget {
  const InstanceDetailPage({required this.meta, super.key});

  final MetaLite meta;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(meta.name ?? l10n.serverNameFallback)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
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
          const SizedBox(height: 16),
          Text(
            l10n.instanceLinks,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          for (final entry in _linkEntries(l10n))
            if (entry != null) _linkTile(context, entry.$1, entry.$2),
        ],
      ),
    );
  }

  /// Link rows, three-valued per field: a `null` entry skips the row (field
  /// absent); an entry whose URI is `null` renders a disabled row (the
  /// instance declares the link but ships an empty/unresolvable URL, a real
  /// case: `tosUrl: ''`); a resolved URI is tappable.
  List<(String, Uri?)?> _linkEntries(AppLocalizations l10n) {
    (String, Uri?)? entry(String label, String? url) {
      if (url == null) return null;
      return (label, resolveInstanceLink(meta, url));
    }

    return [
      entry(l10n.complianceTermsTitle, meta.tosUrl),
      entry(l10n.compliancePrivacyTitle, meta.privacyPolicyUrl),
      entry(l10n.impressum, meta.impressumUrl),
    ];
  }

  Widget _linkTile(BuildContext context, String label, Uri? url) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = url != null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text(
        label,
        style: TextStyle(
          color: enabled ? scheme.primary : scheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: scheme.onSurfaceVariant,
      ),
      enabled: enabled,
      onTap: enabled
          ? () => openRemoteDocument(context, title: label, url: url.toString())
          : null,
    );
  }
}
