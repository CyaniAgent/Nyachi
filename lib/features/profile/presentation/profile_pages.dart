// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/time_format.dart';
import '../../notes/domain/note_feed_source.dart';
import '../../notes/presentation/note_content.dart';
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
          if (MediaQuery.sizeOf(context).width < kCompactBreakpoint)
            IconButton(
              tooltip: l10n.settings,
              onPressed: () => GoRouter.of(context).push('/settings'),
              icon: const Icon(Icons.settings_outlined),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openDetail(context, const ComposeDetailLocation(null)),
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
    final scheme = Theme.of(context).colorScheme;
    final banner = user.bannerUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 190,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (banner != null && banner.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: banner,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) =>
                      _BannerFallback(avatarUrl: user.avatarUrl),
                  placeholder: (_, _) =>
                      _BannerFallback(avatarUrl: user.avatarUrl),
                )
              else
                _BannerFallback(avatarUrl: user.avatarUrl),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      scheme.surface.withValues(alpha: 0.15),
                      scheme.surface.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: Row(
                  children: [
                    NyachiAvatar(
                      url: user.avatarUrl,
                      size: 76,
                      borderColor: scheme.surface,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.name ?? user.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '@${user.username}${user.host == null ? '' : '@${user.host}'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user.description?.isNotEmpty == true) ...[
                NoteContent(
                  text: _normalizeDescription(user.description!),
                  emojis: user.emojis,
                ),
                const SizedBox(height: 12),
              ],
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
                  onPressed: () =>
                      openDetail(context, ChatUserDetailLocation(user.id)),
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

String _normalizeDescription(String text) {
  final links = text.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\(([^)]+)\)'),
    (match) => '${match[1]}: ${match[2]}',
  );
  return links
      .replaceAll('**', '')
      .replaceAll('__', '')
      .split('\n')
      .map((line) {
        final trimmed = line.trimLeft();
        return trimmed.startsWith('>') ? trimmed.substring(1).trimLeft() : line;
      })
      .join('\n');
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback({this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primaryContainer, scheme.tertiaryContainer],
            ),
          ),
        ),
        if (avatarUrl != null && avatarUrl!.isNotEmpty)
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: CachedNetworkImage(
              imageUrl: avatarUrl!,
              fit: BoxFit.cover,
              color: scheme.surface.withValues(alpha: 0.35),
              colorBlendMode: BlendMode.srcOver,
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
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
