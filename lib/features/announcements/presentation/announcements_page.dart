// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
import '../data/announcement_repository.dart';

/// Lists the instance announcements. The three server-side `display` kinds are
/// honoured: banners stay as compact tiles at the top, dialogs are shown with
/// their call-to-action framing, and normal announcements fill the list.
class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(announcementsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.announcements)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.noAnnouncements));
          }
          final banners = items
              .where((item) => item.display == AnnouncementDisplay.banner)
              .toList();
          final rest = items
              .where((item) => item.display != AnnouncementDisplay.banner)
              .toList();
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              for (final banner in banners) _BannerTile(announcement: banner),
              for (final item in rest) _AnnouncementTile(announcement: item),
            ],
          );
        },
      ),
    );
  }
}

class _BannerTile extends StatelessWidget {
  const _BannerTile({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (announcement.imageUrl case final url?)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: NyachiImage(
                url: url,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (announcement.title.isNotEmpty)
                  Text(announcement.title, style: theme.textTheme.titleSmall),
                Text(
                  announcement.text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementTile extends StatefulWidget {
  const _AnnouncementTile({required this.announcement});

  final Announcement announcement;

  @override
  State<_AnnouncementTile> createState() => _AnnouncementTileState();
}

class _AnnouncementTileState extends State<_AnnouncementTile> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final announcement = widget.announcement;
    final isDialog = announcement.display == AnnouncementDisplay.dialog;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isDialog)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.campaign_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      announcement.title.isEmpty
                          ? MaterialLocalizations.of(context)
                                .formatMediumDate(announcement.createdAt)
                          : announcement.title,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  if (announcement.isRead != true)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                announcement.text,
                maxLines: _expanded ? null : 4,
                overflow: _expanded ? null : TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              if (_expanded)
                if (announcement.imageUrl case final url?)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: NyachiImage(url: url, fit: BoxFit.contain),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
