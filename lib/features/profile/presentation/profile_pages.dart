// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/time_format.dart';
import '../../notes/domain/note_feed_source.dart';
import '../../notes/presentation/note_list.dart';
import '../application/profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            tooltip: l10n.accountSwitch,
            onPressed: () => context.push('/settings/accounts'),
            icon: const Icon(Icons.switch_account_outlined),
          ),
          IconButton(
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/compose'),
        child: const Icon(Icons.edit_outlined),
      ),
      body: current.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(currentUserProvider),
            child: Text(l10n.retry),
          ),
        ),
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.userNotFound));
          }
          return _ProfileBody(user: user, isMe: true);
        },
      ),
    );
  }
}

class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final active = ref.watch(sessionControllerProvider).active;
    final profile = ref.watch(userProfileProvider(userId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(userProfileProvider(userId)),
            child: Text(l10n.retry),
          ),
        ),
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.userNotFound));
          }
          return _ProfileBody(user: user, isMe: active?.userId == user.id);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user, required this.isMe});

  final UserDetailed user;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Expanded(
          child: NoteList(
            source: NoteFeedSource.user(user.id),
            emptyText: l10n.noNotes,
            header: _ProfileHeader(user: user, isMe: isMe),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.isMe});

  final UserDetailed user;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final banner = user.bannerUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (banner != null)
          CachedNetworkImage(
            imageUrl: banner,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => const SizedBox(height: 40),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? user.username,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '@${user.username}${user.host == null ? '' : '@${user.host}'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (isMe)
                    IconButton(
                      tooltip: l10n.settings,
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                ],
              ),
              if (user.description?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(user.description!),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                children: [
                  _Stat(label: l10n.noteCount, value: user.notesCount),
                  _Stat(label: l10n.followers, value: user.followersCount),
                  _Stat(label: l10n.following, value: user.followingCount),
                ],
              ),
              if (!isMe && user.canChat) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/chat/user/${user.id}'),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(l10n.message),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final num value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          compactCount(context, value),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
