import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nyachi/src/core/services/notification_service.dart';
import 'package:nyachi/src/core/theme/color_constants.dart';
import 'package:nyachi/src/core/widgets/settings_widgets.dart';
import 'package:nyachi/src/features/profile/application/notification_settings_provider.dart';
import 'package:nyachi/src/shared/widgets/cyani_loading_indicator.dart';
import 'package:nyachi/src/shared/widgets/toast_helper.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  // Colors moved to SettingsIconColors in core/theme/color_constants.dart

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return Scaffold(
      appBar: AppBar(title: Text('settings_notifications_title'.tr())),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          children: [
            if (isDesktop)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'settings_notif_mobile_only'.tr(),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SettingsCardGroup(
              children: [
                _buildPermissionTile(context, isDesktop),
                _buildTestTile(context, isDesktop),
              ],
            ),

            const SizedBox(height: 16),
            SettingsCardGroup(
              children: [
                SettingsSwitchTile(
                  icon: Icons.rss_feed,
                  iconColor: SettingsIconColors.cyan,
                  title: 'settings_notif_misskey_posts'.tr(),
                  subtitle: 'settings_notif_misskey_posts_desc'.tr(),
                  value: settings.misskeyRealtimePost,
                  onChanged: isDesktop
                      ? null
                      : (value) => ref
                            .read(notificationSettingsProvider.notifier)
                            .toggleMisskeyRealtimePost(value),
                ),
                SettingsSwitchTile(
                  icon: Icons.message_outlined,
                  iconColor: SettingsIconColors.blue,
                  title: 'settings_notif_misskey_messages'.tr(),
                  subtitle: 'settings_notif_misskey_messages_desc'.tr(),
                  value: settings.misskeyMessages,
                  onChanged: isDesktop
                      ? null
                      : (value) => ref
                            .read(notificationSettingsProvider.notifier)
                            .toggleMisskeyMessages(value),
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CyaniLoadingIndicator()),
        error: (_, _) => const Center(child: Text('Error')),
      ),
    );
  }

  Widget _buildPermissionTile(BuildContext context, bool isDesktop) {
    return SettingsTile(
      icon: Icons.security_outlined,
      iconColor: SettingsIconColors.cyan,
      title: 'settings_notif_permission'.tr(),
      subtitle: 'settings_notif_permission_desc'.tr(),
      onTap: isDesktop
          ? null
          : () async {
              final granted = await NotificationService().requestPermissions();
              if (context.mounted) {
                showToast(
                  title: granted
                      ? 'settings_notif_permission_granted'.tr()
                      : 'settings_notif_permission_denied'.tr(),
                  type: granted ? ToastificationType.success : ToastificationType.error,
                );
              }
            },
    );
  }

  Widget _buildTestTile(BuildContext context, bool isDesktop) {
    return SettingsTile(
      icon: Icons.notification_add_outlined,
      iconColor: SettingsIconColors.cyan,
      title: 'settings_notif_test'.tr(),
      subtitle: 'settings_notif_test_desc'.tr(),
      onTap: isDesktop
          ? null
          : () async {
              await NotificationService().showNotification(
                id: 0,
                title: 'Notification Test',
                body: 'settings_notif_test_body'.tr(),
              );
            },
    );
  }
}
