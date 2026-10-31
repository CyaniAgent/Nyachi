// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/github_contributors.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';

/// The repository's contributor roster, fetched live from GitHub.
///
/// Tapping a row opens the contributor's GitHub profile in the browser.
class ContributorsPage extends ConsumerWidget {
  const ContributorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final contributors = ref.watch(githubContributorsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contributors)),
      body: contributors.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorGeneric),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(githubContributorsProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text(
                l10n.contributorsEmpty,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            );
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final contributor = list[index];
              return ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipOval(
                    child: NyachiImage(
                      url: contributor.avatarUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(contributor.login),
                trailing: Text(
                  l10n.contributionsCount(contributor.contributions),
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                onTap: () => _openProfile(context, contributor.htmlUrl),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openProfile(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
      }
    }
  }
}
