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
import '../../../core/ui/l10n_ext.dart';
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
          FilledButton(
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
                    trailing: Switch(
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearance)),
      body: _SettingsBody(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: Text(l10n.accentColor),
            trailing: DropdownButton<String>(
              value: settings.accentColor,
              isDense: true,
              onChanged: (value) {
                if (value != null) controller.setAccentColor(value);
              },
              items: [
                DropdownMenuItem(
                  value: 'instance',
                  child: Text(l10n.instanceColor),
                ),
                for (final accent in _accentColors)
                  DropdownMenuItem(
                    value: accent.$1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: parseThemeColor(accent.$1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_accentLabel(l10n, accent.$2)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l10n.theme),
            trailing: DropdownButton<String>(
              value: settings.themeMode,
              onChanged: (value) {
                if (value != null) controller.setThemeMode(value);
              },
              items: [
                DropdownMenuItem(
                  value: 'system',
                  child: Text(l10n.themeSystem),
                ),
                DropdownMenuItem(value: 'light', child: Text(l10n.themeLight)),
                DropdownMenuItem(value: 'dark', child: Text(l10n.themeDark)),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.view_sidebar_outlined),
            title: Text(l10n.detailBreakpoint),
            subtitle: Text('${settings.detailBreakpoint} px'),
          ),
          Slider(
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
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: settings.localeCode,
              onChanged: (value) {
                if (value != null) controller.setLocale(value);
              },
              items: [
                DropdownMenuItem(
                  value: 'system',
                  child: Text(l10n.languageSystem),
                ),
                DropdownMenuItem(
                  value: 'zh',
                  child: Text(l10n.languageChinese),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text(l10n.languageEnglish),
                ),
                DropdownMenuItem(
                  value: 'ja',
                  child: Text(l10n.languageJapanese),
                ),
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: _SettingsBody(
        children: [
          ListTile(
            leading: const Icon(Icons.pets),
            title: Text(l10n.appTitle),
            subtitle: Text(l10n.appVersion),
            trailing: const Icon(Icons.info_outline),
          ),
        ],
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
