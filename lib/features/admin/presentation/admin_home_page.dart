// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/l10n_ext.dart';

/// Moderation hub: the seven admin destinations behind the single "manage
/// this instance" entry on the settings root. Each row opens the section's own
/// location, so wide windows host it in the detail panel and narrow ones push
/// it full-screen.
class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final entries = <(IconData, String, String, DetailLocation)>[
      (
        Icons.flag_outlined,
        l10n.adminReports,
        l10n.adminReportsSubtitle,
        const AdminReportsLocation(),
      ),
      (
        Icons.people_outline,
        l10n.adminUsers,
        l10n.adminUsersSubtitle,
        const AdminUsersLocation(),
      ),
      (
        Icons.folder_outlined,
        l10n.adminContent,
        l10n.adminContentSubtitle,
        const AdminContentLocation(),
      ),
      (
        Icons.campaign_outlined,
        l10n.adminAnnouncements,
        l10n.adminAnnouncementsSubtitle,
        const AdminAnnouncementsLocation(),
      ),
      (
        Icons.dns_outlined,
        l10n.adminInstance,
        l10n.adminInstanceSubtitle,
        const AdminInstanceLocation(),
      ),
      (
        Icons.monitor_heart_outlined,
        l10n.adminSystem,
        l10n.adminSystemSubtitle,
        const AdminSystemLocation(),
      ),
      (
        Icons.confirmation_number_outlined,
        l10n.adminInvites,
        l10n.adminInvitesSubtitle,
        const AdminInvitesLocation(),
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminHome)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(l10n.adminHomeSubtitle),
              ),
              for (final (icon, title, subtitle, location) in entries)
                ListTile(
                  leading: Icon(icon),
                  title: Text(title),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openDetail(context, location),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
