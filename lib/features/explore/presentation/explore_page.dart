// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
import '../../../core/ui/time_format.dart';
import '../../shell/presentation/app_sidebar.dart';
import '../application/explore_controllers.dart';

/// Discovery: what is happening on this instance — trending hashtags and
/// recommended users. Note/user search lives on the separate search page.
class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.discover),
        leading: const AppDrawerButton(),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _SettingsHeader(label: l10n.trendingTags),
              const _Trends(),
              _SettingsHeader(label: l10n.recommendedUsers),
              const _RecommendedUsers(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _Trends extends ConsumerWidget {
  const _Trends();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trends = ref.watch(trendsProvider);
    return trends.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(trendsProvider),
          child: Text(l10n.retry),
        ),
      ),
      data: (items) {
        if (items.isEmpty) return Center(child: Text(l10n.noTrends));
        return Column(
          children: [
            for (final trend in items)
              ListTile(
                leading: const Icon(Icons.tag),
                title: Text('#${trend.tag}'),
                trailing: Text(compactCount(context, trend.usersCount)),
                onTap: () => openDetail(context, TagDetailLocation(trend.tag)),
              ),
          ],
        );
      },
    );
  }
}

/// `users/recommendation` — who this instance suggests following.
class _RecommendedUsers extends ConsumerWidget {
  const _RecommendedUsers();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final users = ref.watch(recommendedUsersProvider);
    return users.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mapFailure(error).message(l10n)),
            TextButton(
              onPressed: () => ref.invalidate(recommendedUsersProvider),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
      data: (items) {
        if (items.isEmpty) return Center(child: Text(l10n.noUsers));
        return Column(
          children: [
            for (final user in items)
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: nyachiImageProvider(user.avatarUrl),
                ),
                title: Text(user.name ?? user.username),
                subtitle: Text(
                  '@${user.username}${user.host == null ? '' : '@${user.host}'}',
                ),
                onTap: () => openDetail(context, UserDetailLocation(user.id)),
              ),
          ],
        );
      },
    );
  }
}
