import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyachi/src/core/theme/color_constants.dart';
import 'package:nyachi/src/core/widgets/settings_widgets.dart';
import 'package:nyachi/src/features/update/application/update_notifier.dart';
import 'package:nyachi/src/features/update/presentation/update_bottom_sheet.dart';
import 'package:nyachi/src/shared/widgets/toast_helper.dart';
import 'package:nyachi/src/core/utils/logger.dart';
import 'about_page.dart';
import 'accounts_page.dart';
import 'appearance_page.dart';
import 'cache_settings_page.dart';
import 'developer_settings_page.dart';
import 'licenses_page.dart';
import 'navigation_settings_page.dart';
import 'network_settings_page.dart';
import 'notification_settings_page.dart';
import 'sound_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool showMiaoLanguage = false;

  @override
  void initState() {
    super.initState();
    _loadShowMiaoLanguage();
  }

  Future<void> _loadShowMiaoLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getBool('show_miao_language') ?? false;
      setState(() => showMiaoLanguage = value);
    } catch (_) {
      setState(() => showMiaoLanguage = false);
    }
  }

  Future<void> _saveShowMiaoLanguage(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_miao_language', value);
    } catch (e) {
      logger.warning('SettingsPage: Failed to save show_miao_language preference', e);
    }
  }

  // ── Icon color palette ──────────────────────────────────────────
  // Colors moved to SettingsIconColors in core/theme/color_constants.dart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings_title'.tr())),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          SettingsCardGroup(
            children: [
              SettingsTile(
                icon: Icons.person_outline,
                iconColor: SettingsIconColors.blue,
                title: 'settings_account_title'.tr(),
                subtitle: 'settings_account_description'.tr(),
                onTap: () => _pushSettingsPage(const AccountsPage()),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SettingsCardGroup(
            children: [
              SettingsTile(
                icon: Icons.wifi,
                iconColor: SettingsIconColors.cyan,
                title: 'settings_network_title'.tr(),
                subtitle: 'settings_network_description'.tr(),
                onTap: () => _pushSettingsPage(const NetworkSettingsPage()),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SettingsCardGroup(
            children: [
              SettingsTile(
                icon: Icons.palette_outlined,
                iconColor: SettingsIconColors.purple,
                title: 'settings_appearance_title'.tr(),
                subtitle: 'settings_appearance_description'.tr(),
                onTap: () => _pushSettingsPage(const AppearancePage()),
              ),
              GestureDetector(
                onDoubleTap: () {
                  final newValue = !showMiaoLanguage;
                  setState(() => showMiaoLanguage = newValue);
                  _saveShowMiaoLanguage(newValue);
                  showToast(title: newValue ? '已解锁喵星语选项！' : '已隐藏喵星语选项');
                },
                child: SettingsTile(
                  icon: Icons.language_outlined,
                  iconColor: SettingsIconColors.lightBlue,
                  title: 'settings_language_title'.tr(),
                  subtitle: 'settings_language_description'.tr(),
                  onTap: () => _showLanguageDialog(context),
                ),
              ),
              SettingsTile(
                icon: Icons.notifications_outlined,
                iconColor: SettingsIconColors.orange,
                title: 'settings_notifications_title'.tr(),
                subtitle: 'settings_notifications_description'.tr(),
                onTap: () => _pushSettingsPage(const NotificationSettingsPage()),
              ),
              SettingsTile(
                icon: Icons.volume_up_outlined,
                iconColor: SettingsIconColors.pink,
                title: 'settings_sound_title'.tr(),
                subtitle: 'settings_sound_description'.tr(),
                onTap: () => _pushSettingsPage(const SoundSettingsPage()),
              ),
              SettingsTile(
                icon: Icons.navigation_outlined,
                iconColor: SettingsIconColors.indigo,
                title: 'settings_navigation_title'.tr(),
                subtitle: 'settings_navigation_description'.tr(),
                onTap: () => _pushSettingsPage(const NavigationSettingsPage()),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SettingsCardGroup(
            children: [
              SettingsTile(
                icon: Icons.system_update_rounded,
                iconColor: SettingsIconColors.green,
                title: '检查更新',
                subtitle: '检查是否有新版本可用',
                onTap: _checkForUpdate,
              ),
              SettingsTile(
                icon: Icons.bug_report_outlined,
                iconColor: SettingsIconColors.amber,
                title: 'settings_developer_title'.tr(),
                subtitle: 'settings_developer_description'.tr(),
                onTap: () => _pushSettingsPage(const DeveloperSettingsPage()),
              ),
              SettingsTile(
                icon: Icons.storage_outlined,
                iconColor: SettingsIconColors.brown,
                title: 'settings_storage_title'.tr(),
                subtitle: 'settings_storage_description'.tr(),
                onTap: () => _pushSettingsPage(const CacheSettingsPage()),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SettingsCardGroup(
            children: [
              SettingsTile(
                icon: Icons.info_outline,
                iconColor: SettingsIconColors.blueGrey,
                title: 'settings_about_title'.tr(),
                subtitle: 'settings_about_description'.tr(),
                onTap: () => _pushSettingsPage(const AboutPage()),
              ),
              SettingsTile(
                icon: Icons.description_outlined,
                iconColor: SettingsIconColors.blueGrey,
                title: 'settings_licenses_title'.tr(),
                subtitle: 'settings_licenses_description'.tr(),
                onTap: () => _pushSettingsPage(const LicensesPage()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdate() async {
    final container = ProviderScope.containerOf(context, listen: false);
    final notifier = container.read(updateProvider.notifier);
    await notifier.checkForUpdate();
    if (!mounted) return;
    final state = container.read(updateProvider);

    if (state.state == UpdateState.updateAvailable && state.update != null) {
      showUpdateBottomSheet(context, state.update!);
    } else if (state.state == UpdateState.upToDate) {
      showToast(title: '当前已是最新版本');
    } else if (state.state == UpdateState.error) {
      showToast(title: state.errorMessage ?? '检查更新失败', type: ToastificationType.error);
    }
  }

  /// Push a settings sub-page, wrapping it with [DesktopPageShell] on desktop.
  void _pushSettingsPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final currentLocale = context.locale;

        final languageOptions = <Widget>[
          _langTile(context, currentLocale, 'settings_language_chinese'.tr(), const Locale('zh', 'CN')),
          _langTile(context, currentLocale, 'settings_language_english'.tr(), const Locale('en', 'US')),
          _langTile(context, currentLocale, 'settings_language_japanese'.tr(), const Locale('ja', 'JP')),
        ];

        if (showMiaoLanguage) {
          languageOptions.addAll([
            _langTile(context, currentLocale, '喵星语', const Locale('zh', 'Miao')),
            _langTile(context, currentLocale, 'にゃ語', const Locale('ja', 'Miao')),
            _langTile(context, currentLocale, 'Meow Language（英文）', const Locale('en', 'Miao')),
            _langTile(context, currentLocale, 'Meow Meow Meow', const Locale('miao', 'Miao')),
          ]);
        }

        return AlertDialog(
          title: Text('settings_language_select_title'.tr()),
          content: Column(mainAxisSize: MainAxisSize.min, children: languageOptions),
        );
      },
    );
  }

  Widget _langTile(BuildContext context, Locale current, String label, Locale target) {
    final isActive = current == target;
    return ListTile(
      title: Text(label),
      onTap: () {
        context.setLocale(target);
        Navigator.pop(context);
      },
      trailing: Icon(
        isActive ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
