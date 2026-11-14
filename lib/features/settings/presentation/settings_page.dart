// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../admin/data/admin_repository.dart';
import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/mfm/mfm_motion.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../core/network/instance_repository.dart';
import '../../../core/update/app_version.dart';
import '../../../core/ui/l10n_ext.dart';
import 'accent_color_picker.dart';
import 'contributors_page.dart';
import 'licenses_page.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/ui/content_width.dart';
import '../application/app_settings.dart';

/// Settings entry point.
///
/// Three sections: the account domain (profile, privacy, email, security —
/// pages that change this user on the server), the client domain, and the
/// instance domain with the moderation hub behind a single gated entry.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider);
    // Moderator rights are read from the server, so the group appears and
    // disappears with the account's actual role rather than a stored flag.
    final canModerate = ref.watch(canModerateProvider).value ?? false;
    final entries = <_SettingsEntry>[
      _SettingsEntry(
        group: _SettingsGroup.account,
        icon: Icons.person_outline,
        title: l10n.editProfile,
        subtitle: l10n.profile,
        open: const SettingsProfileLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.account,
        icon: Icons.lock_outline,
        title: l10n.privacy,
        subtitle: l10n.mutedUsers,
        open: const SettingsPrivacyLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.account,
        icon: Icons.mail_outline,
        title: l10n.emailSettings,
        subtitle: l10n.emailAddress,
        open: const SettingsEmailLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.account,
        icon: Icons.shield_outlined,
        title: l10n.security,
        subtitle: l10n.twoFactor,
        open: const SettingsSecurityLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.account,
        icon: Icons.person_add_alt,
        title: l10n.addAccount,
        subtitle: l10n.accounts,
        open: const AddAccountLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.client,
        icon: Icons.tune,
        title: l10n.navigation,
        subtitle: l10n.visibleTabs,
        open: const SettingsNavigationLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.client,
        icon: Icons.palette_outlined,
        title: l10n.appearance,
        subtitle: l10n.theme,
        open: const SettingsAppearanceLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.client,
        icon: Icons.notifications_outlined,
        title: l10n.notificationSettings,
        subtitle: l10n.notifyAll,
        open: const SettingsNotificationLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.client,
        icon: Icons.notifications_active_outlined,
        title: l10n.pushNotifications,
        subtitle: l10n.pushSystemTitle,
        open: const SettingsPushLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.client,
        icon: Icons.cloud_outlined,
        title: l10n.driveSpace,
        subtitle: l10n.openDrive,
        open: const SettingsDriveLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.client,
        icon: Icons.cleaning_services_outlined,
        title: l10n.cacheManagement,
        subtitle: l10n.cacheManagementSubtitle,
        open: const SettingsCacheLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.client,
        icon: Icons.info_outline,
        title: l10n.about,
        subtitle: l10n.appVersion(ref.watch(appVersionProvider).value ?? ''),
        open: const SettingsAboutLocation(),
      ),
      if (canModerate)
        _SettingsEntry(
          group: _SettingsGroup.manage,
          icon: Icons.shield_outlined,
          title: l10n.adminHome,
          subtitle: l10n.adminHomeSubtitle,
          open: const AdminHomeLocation(),
        ),
    ];
    final active = session.active;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: _SettingsBody(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: NyachiAvatar(
              url: active?.avatarUrl,
              size: 48,
              fallback: Text(
                active?.username.characters.firstOrNull?.toUpperCase() ?? '?',
              ),
            ),
            title: Text(
              active?.displayName ?? active?.username ?? l10n.noAccounts,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              active == null
                  ? l10n.settingsAccountAndServer
                  : '@${active.username}@${active.host}',
            ),
            // Display only: "edit profile" below is the single entry point,
            // and a second tap target on the same row only adds ambiguity.
          ),
          for (final group in _SettingsGroup.values)
            if (entries.any((entry) => entry.group == group)) ...[
              _SettingsSectionHeader(
                label: switch (group) {
                  _SettingsGroup.account => l10n.settingsGroupAccount,
                  _SettingsGroup.client => l10n.settingsGroupClient,
                  _SettingsGroup.manage => l10n.settingsGroupManage,
                },
              ),
              for (final entry in entries.where(
                (entry) => entry.group == group,
              ))
                _SettingsTile(
                  icon: entry.icon,
                  title: entry.title,
                  subtitle: entry.subtitle,
                  onTap: entry.onTap ?? () => openDetail(context, entry.open!),
                ),
            ],
        ],
      ),
    );
  }
}

enum _SettingsGroup { account, client, manage }

/// One searchable settings row: a page location or a direct callback.
class _SettingsEntry {
  const _SettingsEntry({
    required this.group,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.open,
    this.onTap,
  }) : assert(open != null || onTap != null);

  final _SettingsGroup group;
  final IconData icon;
  final String title;
  final String subtitle;
  final DetailLocation? open;
  final VoidCallback? onTap;
}

class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class NavigationSettingsPage extends ConsumerWidget {
  const NavigationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    // The page edits the chrome of the form factor it is shown in: the
    // bottom bar on narrow windows, the sidebar on wide ones. Showing both
    // at once reads as two competing states for one navigation.
    final wide = MediaQuery.sizeOf(context).width >= kCompactBreakpoint;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navigation)),
      body: _SettingsBody(
        children: [
          if (wide) ...[
            _SettingsSectionHeader(label: l10n.sidebarSection),
            _NavList(
              config: settings.sidebarNavConfig,
              capped: false,
              onReorder: (order) => controller.setSidebarNavConfig(
                settings.sidebarNavConfig.copyWith(order: order),
              ),
              onToggle: (tab, value) {
                final visible = {...settings.sidebarNavConfig.visible};
                if (value) {
                  visible.add(tab);
                } else {
                  visible.remove(tab);
                }
                controller.setSidebarNavConfig(
                  settings.sidebarNavConfig.copyWith(visible: visible),
                );
              },
            ),
            SwitchListTile(
              title: Text(l10n.showMeAtTop),
              subtitle: Text(l10n.showMeAtTopHint),
              value: settings.showMeAtTop,
              onChanged: controller.setShowMeAtTop,
            ),
            ListTile(
              title: Text(l10n.sidebarWidth),
              subtitle: Text('${settings.sidebarWidth.round()} px'),
            ),
            Slider(
              value: settings.sidebarWidth,
              min: appSidebarMinWidth,
              max: appSidebarMaxWidth,
              label: '${settings.sidebarWidth.round()} px',
              // Dragging updates memory only; the write lands once on release.
              onChanged: controller.setSidebarWidthLive,
              onChangeEnd: controller.setSidebarWidth,
            ),
            SwitchListTile(
              title: Text(l10n.sidebarAutoCollapse),
              subtitle: Text(l10n.sidebarAutoCollapseHint),
              value: settings.sidebarAutoCollapse,
              onChanged: controller.setSidebarAutoCollapse,
            ),
            SwitchListTile(
              title: Text(l10n.sidebarCollapseForPanel),
              subtitle: Text(l10n.sidebarCollapseForPanelHint),
              value: settings.sidebarCollapseForPanel,
              onChanged: controller.setSidebarCollapseForPanel,
            ),
          ] else ...[
            _SettingsSectionHeader(label: l10n.bottomBar),
            _NavList(
              config: settings.navConfig,
              capped: true,
              onReorder: (order) => controller.setNavConfig(
                settings.navConfig.copyWith(order: order),
              ),
              onToggle: (tab, value) {
                final visible = {...settings.navConfig.visible};
                if (value) {
                  visible.add(tab);
                } else {
                  visible.remove(tab);
                }
                controller.setNavConfig(
                  settings.navConfig.copyWith(visible: visible),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// One reorderable tab list for a chrome surface. When [capped] is set the
/// bottom-bar rules apply: home stays visible and the switch disables once
/// four tabs are on.
class _NavList extends StatelessWidget {
  const _NavList({
    required this.config,
    required this.capped,
    required this.onReorder,
    required this.onToggle,
  });

  final NavConfig config;
  final bool capped;
  final ValueChanged<List<AppTab>> onReorder;
  final void Function(AppTab tab, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visibleCount = config.visible.length;
    return ReorderableListView.builder(
      // The default desktop drag handle is drawn over the trailing
      // switch; draw our own handle next to it instead.
      buildDefaultDragHandles: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: config.order.length,
      onReorderItem: (oldIndex, newIndex) {
        final order = [...config.order];
        final item = order.removeAt(oldIndex);
        order.insert(newIndex, item);
        onReorder(order);
      },
      itemBuilder: (context, index) {
        final tab = config.order[index];
        final atCap =
            capped && !config.visible.contains(tab) && visibleCount >= 4;
        return Column(
          key: ValueKey(tab),
          children: [
            ListTile(
              leading: Icon(_tabIcon(tab)),
              title: Text(_tabLabel(context, tab)),
              subtitle: atCap ? Text(l10n.maxTabsReached) : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: config.visible.contains(tab),
                    onChanged: tab == AppTab.home || atCap
                        ? null
                        : (value) => onToggle(tab, value),
                  ),
                  const SizedBox(width: 8),
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(
                      Icons.drag_indicator,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        );
      },
    );
  }
}

class AppearanceSettingsPage extends ConsumerWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final instance = ref.watch(instanceInfoProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearance)),
      body: _SettingsBody(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: Text(l10n.accentColor),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: AccentColorPicker(
              selected: settings.accentColor,
              instanceColor: instance?.themeColor,
              onSelected: controller.setAccentColor,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l10n.theme),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'system',
                  label: Text(l10n.themeSystem),
                  icon: const Icon(Icons.brightness_auto_outlined),
                ),
                ButtonSegment(
                  value: 'light',
                  label: Text(l10n.themeLight),
                  icon: const Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: 'dark',
                  label: Text(l10n.themeDark),
                  icon: const Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selection) =>
                  controller.setThemeMode(selection.first),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.view_sidebar_outlined),
            title: Text(l10n.detailBreakpoint),
            subtitle: Text('${settings.detailBreakpoint} px'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              value: settings.detailBreakpoint.toDouble(),
              min: appDetailBreakpointMin.toDouble(),
              max: appDetailBreakpointMax.toDouble(),
              divisions:
                  (appDetailBreakpointMax - appDetailBreakpointMin) ~/
                  appDetailBreakpointStep,
              label: '${settings.detailBreakpoint} px',
              onChanged: (value) {
                controller.setDetailBreakpoint(value.round());
              },
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.center_focus_strong_outlined),
            title: Text(l10n.centerContent),
            subtitle: Text(l10n.centerContentHint),
            value: settings.centerContent,
            onChanged: controller.setCenterContent,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l10n.language),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DropdownMenu<String>(
              initialSelection: settings.localeCode,
              expandedInsets: EdgeInsets.zero,
              label: Text(l10n.language),
              onSelected: (value) {
                if (value != null) controller.setLocale(value);
              },
              dropdownMenuEntries: [
                DropdownMenuEntry(value: 'system', label: l10n.languageSystem),
                DropdownMenuEntry(value: 'zh', label: l10n.languageChinese),
                DropdownMenuEntry(value: 'en', label: l10n.languageEnglish),
                DropdownMenuEntry(value: 'ja', label: l10n.languageJapanese),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.animation),
            title: Text(l10n.mfmMotionTitle),
            subtitle: Text(l10n.mfmMotionSubtitle),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'all',
                  label: Text(l10n.mfmMotionAll),
                  icon: const Icon(Icons.public),
                ),
                ButtonSegment(
                  value: 'detailOnly',
                  label: Text(l10n.mfmMotionDetailOn),
                  icon: const Icon(Icons.notes),
                ),
                ButtonSegment(
                  value: 'off',
                  label: Text(l10n.mfmMotionOff),
                  icon: const Icon(Icons.block),
                ),
              ],
              selected: {settings.mfmMotionMode},
              onSelectionChanged: (selection) =>
                  controller.setMfmMotionMode(selection.first),
            ),
          ),
          for (final motionClass in mfmMotionClasses)
            SwitchListTile(
              title: Text(switch (motionClass) {
                MfmMotionClass.scale => l10n.mfmClassScale,
                MfmMotionClass.translate => l10n.mfmClassTranslate,
                MfmMotionClass.rotate => l10n.mfmClassRotate,
                MfmMotionClass.color => l10n.mfmClassColor,
                MfmMotionClass.flicker => l10n.mfmClassFlicker,
              }),
              value: settings.mfmMotionClasses.isEmpty
                  ? true
                  : settings.mfmMotionClasses.contains(motionClass.name),
              onChanged: (value) =>
                  controller.setMfmMotionClass(motionClass.name, value),
            ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.mfmHelpTitle),
            subtitle: Text(l10n.mfmHelpSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openDetail(context, const MfmHelpLocation()),
          ),
        ],
      ),
    );
  }
}

class AboutSettingsPage extends ConsumerWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: _SettingsBody(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pets,
                    size: 36,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(l10n.appTitle, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  l10n.appVersion(ref.watch(appVersionProvider).value ?? ''),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _UpdateBanner(ref: ref),
          const Divider(height: 1),
          const _LicensesTile(),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: Text(l10n.contributors),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l10n.contributorsBody),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => const ContributorsPage()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Text(
              l10n.flutterTrademark,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Offers the newest published release, when one is newer than this build.
///
/// Failures stay silent here: the About page must not turn a network problem
/// into an error surface, and the version line above already tells the user
/// what they are running.
class _UpdateBanner extends StatelessWidget {
  const _UpdateBanner({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final release = ref.watch(availableReleaseProvider).value;
    if (release == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.system_update_alt, color: scheme.primary),
          title: Text(l10n.updateAvailable(release.tag)),
          subtitle: release.name == release.tag ? null : Text(release.name),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _open(context, release.url),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.updateFailed)));
      }
    }
  }
}

/// Third-party notices entry; the package count loads from the asset itself so
/// it never drifts from the generated manifest.
class _LicensesTile extends StatefulWidget {
  const _LicensesTile();

  @override
  State<_LicensesTile> createState() => _LicensesTileState();
}

class _LicensesTileState extends State<_LicensesTile> {
  late final Future<int> _count = loadBundledLicenses().then(
    (entries) => entries.length,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<int>(
      future: _count,
      builder: (context, snapshot) {
        final count = snapshot.data;
        return ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(l10n.thirdPartyNotices),
          subtitle: Text(count == null ? '…' : l10n.licensesBody(count)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => openDetail(context, const SettingsLicensesLocation()),
        );
      },
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: children,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

String _tabLabel(BuildContext context, AppTab tab) => switch (tab) {
  AppTab.home => context.l10n.home,
  AppTab.notifications => context.l10n.notifications,
  AppTab.explore => context.l10n.discover,
  AppTab.chat => context.l10n.chat,
  AppTab.profile => context.l10n.profile,
};

IconData _tabIcon(AppTab tab) => switch (tab) {
  AppTab.home => Icons.home_outlined,
  AppTab.notifications => Icons.notifications_outlined,
  AppTab.explore => Icons.explore_outlined,
  AppTab.chat => Icons.chat_bubble_outline,
  AppTab.profile => Icons.person_outline,
};
