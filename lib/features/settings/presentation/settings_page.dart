// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/storage/storage_models.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/network/instance_repository.dart';
import '../../../core/update/app_version.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../announcements/presentation/announcements_page.dart';
import 'accent_color_picker.dart';
import 'contributors_page.dart';
import 'licenses_page.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/ui/content_width.dart';
import '../application/app_settings.dart';

/// Settings entry point.
///
/// A profile header opens the account hub - the account itself plus the
/// profile, privacy, email and security pages, which all change this user on
/// the server. Below it the remaining pages are grouped by who owns the
/// setting (this server vs. this app), with the rarely touched ones under
/// "Advanced", and the search field jumps straight to any of them.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider);
    final entries = <_SettingsEntry>[
      _SettingsEntry(
        group: _SettingsGroup.app,
        icon: Icons.tune,
        title: l10n.navigation,
        subtitle: l10n.visibleTabs,
        open: const SettingsNavigationLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.app,
        icon: Icons.palette_outlined,
        title: l10n.appearance,
        subtitle: l10n.theme,
        open: const SettingsAppearanceLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.app,
        icon: Icons.info_outline,
        title: l10n.about,
        subtitle: l10n.appVersion(ref.watch(appVersionProvider).value ?? ''),
        open: const SettingsAboutLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.server,
        icon: Icons.notifications_outlined,
        title: l10n.notificationSettings,
        subtitle: l10n.notifyAll,
        open: const SettingsNotificationLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.server,
        icon: Icons.notifications_active_outlined,
        title: l10n.pushNotifications,
        subtitle: l10n.pushEnable,
        open: const SettingsPushLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.server,
        icon: Icons.cloud_outlined,
        title: l10n.driveSpace,
        subtitle: l10n.openDrive,
        open: const SettingsDriveLocation(),
      ),
      _SettingsEntry(
        group: _SettingsGroup.server,
        icon: Icons.campaign_outlined,
        title: l10n.instanceAnnouncements,
        subtitle: l10n.settingsServerSubtitle,
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => const AnnouncementsPage()),
        ),
      ),
      _SettingsEntry(
        group: _SettingsGroup.advanced,
        icon: Icons.cleaning_services_outlined,
        title: l10n.cacheManagement,
        subtitle: l10n.cacheManagementSubtitle,
        open: const SettingsCacheLocation(),
      ),
    ];
    final query = _query.trim().toLowerCase();
    final visible = query.isEmpty
        ? entries
        : entries
              .where(
                (entry) =>
                    entry.title.toLowerCase().contains(query) ||
                    entry.subtitle.toLowerCase().contains(query),
              )
              .toList(growable: false);
    final active = session.active;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: _SettingsBody(
        children: [
          if (query.isEmpty) ...[
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
              subtitle: Text(l10n.settingsAccountAndServer),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  openDetail(context, const SettingsAccountsLocation()),
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.settingsSearchHint,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.noSearchResults),
            ),
          for (final group in _SettingsGroup.values)
            if (visible.any((entry) => entry.group == group)) ...[
              _SettingsSectionHeader(
                label: switch (group) {
                  _SettingsGroup.app => l10n.settingsGroupApp,
                  _SettingsGroup.server => l10n.settingsGroupServer,
                  _SettingsGroup.advanced => l10n.settingsGroupAdvanced,
                },
              ),
              for (final entry in visible.where(
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

enum _SettingsGroup { app, server, advanced }

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

class AccountsSettingsPage extends ConsumerWidget {
  const AccountsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accounts)),
      body: _SettingsBody(
        children: [
          for (final account in session.accounts) ...[
            ListTile(
              leading: NyachiAvatar(
                url: account.avatarUrl,
                fallback: Text(account.username.characters.first),
              ),
              title: Text(account.displayName ?? account.username),
              subtitle: Text('@${account.username}@${account.host}'),
              trailing: account.id == session.active?.id
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : TextButton(
                      onPressed: () => _switch(context, ref, account),
                      child: Text(l10n.switchLabel),
                    ),
              onTap: account.id == session.active?.id
                  ? null
                  : () => _switch(context, ref, account),
              onLongPress: () => _remove(context, ref, account),
            ),
            const Divider(height: 1),
          ],
          ListTile(
            leading: const Icon(Icons.person_add_alt),
            title: Text(l10n.addAccount),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openDetail(context, const AddAccountLocation()),
          ),
          // These pages change this user on the server, so they belong to the
          // account rather than to the app-wide settings list.
          _SettingsSectionHeader(label: l10n.settingsGroupAccount),
          _SettingsTile(
            icon: Icons.person_outline,
            title: l10n.editProfile,
            subtitle: l10n.profile,
            onTap: () => openDetail(context, const SettingsProfileLocation()),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: l10n.privacy,
            subtitle: l10n.mutedUsers,
            onTap: () => openDetail(context, const SettingsPrivacyLocation()),
          ),
          _SettingsTile(
            icon: Icons.mail_outline,
            title: l10n.emailSettings,
            subtitle: l10n.emailAddress,
            onTap: () => openDetail(context, const SettingsEmailLocation()),
          ),
          _SettingsTile(
            icon: Icons.shield_outlined,
            title: l10n.security,
            subtitle: l10n.twoFactor,
            onTap: () => openDetail(context, const SettingsSecurityLocation()),
          ),
        ],
      ),
    );
  }

  Future<void> _switch(
    BuildContext context,
    WidgetRef ref,
    LocalAccount account,
  ) async {
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .switchAccount(account.id);
      if (context.mounted) context.go('/home');
    } on SessionExpiredException {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.sessionExpired)));
      }
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    LocalAccount account,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeAccount),
        content: Text(l10n.removeAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(sessionControllerProvider.notifier)
        .removeAccount(account.id);
    if (!context.mounted) return;
    final active = ref.read(sessionControllerProvider).active;
    context.go(active == null ? '/login' : '/home');
  }
}

class NavigationSettingsPage extends ConsumerWidget {
  const NavigationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final config = settings.navConfig;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navigation)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
          child: ReorderableListView.builder(
            // The default desktop drag handle is drawn over the trailing
            // switch; draw our own handle next to it instead.
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            header: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.visibleTabs,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            itemCount: config.order.length,
            onReorderItem: (oldIndex, newIndex) {
              final order = [...config.order];
              final item = order.removeAt(oldIndex);
              order.insert(newIndex, item);
              controller.setNavConfig(config.copyWith(order: order));
            },
            itemBuilder: (context, index) {
              final tab = config.order[index];
              return Column(
                key: ValueKey(tab),
                children: [
                  ListTile(
                    leading: Icon(_tabIcon(tab)),
                    title: Text(_tabLabel(context, tab)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: config.visible.contains(tab),
                          onChanged: tab == AppTab.home
                              ? null
                              : (value) {
                                  final visible = {...config.visible};
                                  if (value) {
                                    visible.add(tab);
                                  } else {
                                    visible.remove(tab);
                                  }
                                  controller.setNavConfig(
                                    config.copyWith(visible: visible),
                                  );
                                },
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
          ),
        ),
      ),
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
  AppTab.explore => context.l10n.explore,
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
