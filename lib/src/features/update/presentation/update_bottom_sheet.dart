import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:nyachi/src/core/utils/logger.dart';
import 'package:nyachi/src/features/update/application/update_notifier.dart';
import 'package:nyachi/src/features/update/domain/app_update.dart';
import 'package:nyachi/src/shared/widgets/adaptive_sheet.dart';
import 'package:nyachi/src/shared/widgets/toast_helper.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showUpdateBottomSheet(BuildContext context, AppUpdate update) {
  return showAdaptiveSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _UpdateBottomSheetContent(update: update),
  );
}

class _UpdateBottomSheetContent extends ConsumerWidget {
  final AppUpdate update;

  const _UpdateBottomSheetContent({required this.update});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(updateProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Icon(
                Icons.system_update_rounded,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '发现新版本',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'v${update.latestVersion}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              _buildCurrentVersionBadge(context),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: state.state == UpdateState.checking
                      ? null
                      : () => _openGitHubReleases(context),
                  icon: state.state == UpdateState.checking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.open_in_new_rounded),
                  label: const Text('去 GitHub 发行下载'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentVersionBadge(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final info = snapshot.data!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '当前版本: v${info.version}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }

  Future<void> _openGitHubReleases(BuildContext context) async {
    const url = 'https://github.com/CyaniAgent/Nyachi/releases';
    try {
      logger.info('UpdateBottomSheet: Opening GitHub releases: $url');
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        logger.error('UpdateBottomSheet: Failed to open: $url');
        if (context.mounted) {
          showToast(title: '无法打开链接', type: ToastificationType.error);
        }
      }
    } catch (e) {
      logger.error('UpdateBottomSheet: Open error: $e');
      if (context.mounted) {
        showToast(title: '打开失败: $e', type: ToastificationType.error);
      }
    }
  }
}
