// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/storage/storage_models.dart';
import '../../../core/ui/l10n_ext.dart';
import '../application/app_settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsTile(
            icon: Icons.people_outline,
            title: l10n.accounts,
            subtitle:
                session.active?.displayName ??
                session.active?.username ??
                l10n.noAccounts,
            onTap: () => context.push('/settings/accounts'),
          ),
          _SettingsTile(
            icon: Icons.tune,
            title: l10n.navigation,
            subtitle: l10n.visibleTabs,
            onTap: () => context.push('/settings/navigation'),
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: l10n.appearance,
            subtitle: l10n.theme,
            onTap: () => context.push('/settings/appearance'),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: l10n.about,
            subtitle: l10n.appVersion,
            onTap: () => context.push('/settings/about'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final account in session.accounts)
            Card(
              child: ListTile(
                leading: _Avatar(account: account),
                title: Text(account.displayName ?? account.username),
                subtitle: Text('@${account.username}@${account.host}'),
                trailing: account.id == session.active?.id
                    ? Chip(label: Text(l10n.activeAccount))
                    : TextButton(
                        onPressed: () => _switch(context, ref, account),
                        child: Text(l10n.switchLabel),
                      ),
                onTap: account.id == session.active?.id
                    ? null
                    : () => _switch(context, ref, account),
                onLongPress: () => _remove(context, ref, account),
              ),
            ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_add_alt),
              title: Text(l10n.addAccount),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/add-account'),
            ),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.visibleTabs, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: true,
              itemCount: config.order.length,
              onReorderItem: (oldIndex, newIndex) {
                final order = [...config.order];
                final item = order.removeAt(oldIndex);
                order.insert(newIndex, item);
                controller.setNavConfig(config.copyWith(order: order));
              },
              itemBuilder: (context, index) {
                final tab = config.order[index];
                return ListTile(
                  key: ValueKey(tab),
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
                );
              },
            ),
          ),
          if (!config.visible.contains(AppTab.home))
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(l10n.homeLocked),
            ),
        ],
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
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
                      DropdownMenuItem(
                        value: 'light',
                        child: Text(l10n.themeLight),
                      ),
                      DropdownMenuItem(
                        value: 'dark',
                        child: Text(l10n.themeDark),
                      ),
                    ],
                  ),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.pets),
              title: Text(l10n.appTitle),
              subtitle: Text(l10n.appVersion),
              trailing: const Icon(Icons.info_outline),
            ),
          ),
        ],
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
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.account});

  final LocalAccount account;

  @override
  Widget build(BuildContext context) {
    final url = account.avatarUrl;
    return CircleAvatar(
      backgroundImage: url == null ? null : NetworkImage(url),
      child: url == null ? Text(account.username.characters.first) : null,
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
