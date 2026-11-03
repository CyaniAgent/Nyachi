// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart' hide Clip;

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
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
    return NoteList(
      source: NoteFeedSource.user(user.id),
      emptyText: l10n.noNotes,
      header: _ProfileHeader(user: user, isMe: isMe),
      // The banner is the page's background: it must span the viewport
      // instead of shrinking to the content column.
      headerFullBleed: true,
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
        Stack(
          clipBehavior: Clip.none,
          children: [
            // The banner spans the full viewport width at a height that stays
            // usable on narrow windows instead of collapsing with an aspect
            // ratio; the image covers whatever space it gets.
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = (width * 0.28).clamp(
                  kProfileBannerMinHeight,
                  kProfileBannerMaxHeight,
                );
                return SizedBox(
                  height: height,
                  width: double.infinity,
                  child: banner != null && banner.isNotEmpty
                      ? NyachiImage(url: banner, fit: BoxFit.cover)
                      : const _BannerFallback(),
                );
              },
            ),
            Positioned.fill(
              child: DecoratedBox(
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
            ),
            Positioned(
              left: 16,
              right: 16,
              // Half of the avatar hangs below the banner edge.
              bottom: -kProfileAvatarSize / 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  NyachiAvatar(
                    url: user.avatarUrl,
                    size: kProfileAvatarSize,
                    borderColor: scheme.surface,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
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
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          // Top padding clears the avatar half overhanging the banner.
          padding: EdgeInsets.fromLTRB(16, kProfileAvatarSize / 2 + 12, 16, 14),
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

/// Fixed avatar size on the profile page so the header overlap stays
/// consistent across layouts.
const double kProfileAvatarSize = 72;

/// Banner height bounds. The height tracks the viewport width between these
/// limits: a phone gets a readable strip instead of a sliver, and a wide
/// window does not grow the banner into a wall.
const double kProfileBannerMinHeight = 140;
const double kProfileBannerMaxHeight = 240;

/// Neutral placeholder shown when the user has no banner.
class _BannerFallback extends StatelessWidget {
  const _BannerFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
