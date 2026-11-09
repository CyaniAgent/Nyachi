// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/ui/l10n_ext.dart';
import '../../../core/mfm/mfm_body.dart';
import '../../../core/ui/network_image.dart';
import '../../../core/ui/content_width.dart';
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
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final banner in banners)
                    _BannerTile(announcement: banner),
                  for (final (index, item) in rest.indexed) ...[
                    if (index > 0) const Divider(height: 1),
                    _AnnouncementTile(announcement: item),
                  ],
                ],
              ),
            ),
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
    // Banners keep their emphasis through the tinted band alone; a card around
    // it would double the framing against the row style used below.
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
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
                MfmBody(
                  text: announcement.text,
                  maxLines: 3,
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
    final title = announcement.title.isEmpty
        ? MaterialLocalizations.of(context)
              .formatMediumDate(announcement.createdAt)
        : announcement.title;
    // A row rather than a card: the list is dense content, and the app does not
    // box each entry. The divider between rows is what separates them.
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
                Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
                if (announcement.isRead != true) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            MfmBody(
              text: announcement.text,
              maxLines: _expanded ? null : 4,
              // The row toggles on tap; selecting would take that tap.
              selectable: false,
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
    );
  }
}
