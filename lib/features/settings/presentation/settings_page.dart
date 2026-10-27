// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/storage/storage_models.dart';
import '../../../core/ui/avatar.dart';
import '../../../core/network/instance_repository.dart';
import '../../../core/ui/l10n_ext.dart';
import 'licenses_page.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/ui/content_width.dart';
import '../application/app_settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: _SettingsBody(
        children: [
          _SettingsTile(
            icon: Icons.people_outline,
            title: l10n.accounts,
            subtitle:
                session.active?.displayName ??
                session.active?.username ??
                l10n.noAccounts,
            onTap: () => openDetail(context, const SettingsAccountsLocation()),
          ),

          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.tune,
            title: l10n.navigation,
            subtitle: l10n.visibleTabs,
            onTap: () =>
                openDetail(context, const SettingsNavigationLocation()),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: l10n.appearance,
            subtitle: l10n.theme,
            onTap: () =>
                openDetail(context, const SettingsAppearanceLocation()),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.info_outline,
            title: l10n.about,
            subtitle: l10n.appVersion,
            onTap: () => openDetail(context, const SettingsAboutLocation()),
          ),
        ],
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
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _AccentDot(
                  label: l10n.instanceColor,
                  color: parseThemeColor(instance?.themeColor),
                  selected: settings.accentColor == 'instance',
                  onTap: () => controller.setAccentColor('instance'),
                ),
                for (final accent in _accentColors)
                  _AccentDot(
                    label: _accentLabel(l10n, accent.$2),
                    color: parseThemeColor(accent.$1),
                    selected: settings.accentColor == accent.$1,
                    onTap: () => controller.setAccentColor(accent.$1),
                  ),
              ],
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

class AboutSettingsPage extends StatelessWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  l10n.appVersion,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const _LicensesTile(),
          const Divider(height: 1),
          _AboutSection(
            icon: Icons.people_outline,
            title: l10n.contributors,
            body: l10n.contributorsBody,
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
          subtitle: Text(
            count == null ? l10n.appVersion : l10n.licensesBody(count),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => openDetail(context, const SettingsLicensesLocation()),
        );
      },
    );
  }
}

/// Non-interactive titled block used by the about page.
class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(body),
      ),
    );
  }
}

const _accentColors = [
  ('#3F51B5', 'indigo'),
  ('#E91E63', 'pink'),
  ('#4CAF50', 'green'),
  ('#2196F3', 'blue'),
  ('#FF9800', 'orange'),
];

String _accentLabel(AppLocalizations l10n, String key) {
  return switch (key) {
    'indigo' => l10n.colorIndigo,
    'pink' => l10n.colorPink,
    'green' => l10n.colorGreen,
    'blue' => l10n.colorBlue,
    'orange' => l10n.colorOrange,
    _ => key,
  };
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

/// Selectable accent colour swatch.
class _AccentDot extends StatelessWidget {
  const _AccentDot({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? scheme.onSurface : scheme.outlineVariant,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: selected
                ? Icon(
                    Icons.check,
                    size: 18,
                    color:
                        ThemeData.estimateBrightnessForColor(color) ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
