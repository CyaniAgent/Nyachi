// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/storage/storage_models.dart';
import '../application/app_settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(l10n.accounts),
          Card(
            child: Column(
              children: [
                for (final account in session.accounts)
                  ListTile(
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
                if (session.accounts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.noAccounts),
                  ),
                ListTile(
                  leading: const Icon(Icons.person_add_alt),
                  title: Text(l10n.addAccount),
                  onTap: () => context.push('/add-account'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(l10n.appearance),
          Card(
            child: Column(
              children: [
                ListTile(
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
                ListTile(
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
          const SizedBox(height: 16),
          _SectionTitle(l10n.navigation),
          Card(
            child: Column(
              children: [
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: true,
                  itemCount: settings.navConfig.order.length,
                  onReorderItem: (oldIndex, newIndex) {
                    final order = [...settings.navConfig.order];
                    final item = order.removeAt(oldIndex);
                    order.insert(newIndex, item);
                    controller.setNavConfig(
                      settings.navConfig.copyWith(order: order),
                    );
                  },
                  itemBuilder: (context, index) {
                    final tab = settings.navConfig.order[index];
                    return ListTile(
                      key: ValueKey(tab),
                      title: Text(_tabLabel(context, tab)),
                      trailing: Switch(
                        value: settings.navConfig.visible.contains(tab),
                        onChanged: tab == AppTab.home
                            ? null
                            : (value) {
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
                    );
                  },
                ),
                if (!settings.navConfig.visible.contains(AppTab.home))
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(l10n.homeLocked),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(l10n.about),
          Card(
            child: ListTile(
              title: Text(l10n.appTitle),
              subtitle: Text(l10n.appVersion),
              trailing: const Icon(Icons.info_outline),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.removeAccount),
        content: Text(context.l10n.removeAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.remove),
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

  String _tabLabel(BuildContext context, AppTab tab) => switch (tab) {
    AppTab.home => context.l10n.home,
    AppTab.notifications => context.l10n.notifications,
    AppTab.explore => context.l10n.explore,
    AppTab.chat => context.l10n.chat,
    AppTab.profile => context.l10n.profile,
  };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
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
