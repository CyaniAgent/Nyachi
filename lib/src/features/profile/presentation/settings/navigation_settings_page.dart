import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nyachi/src/core/navigation/navigation.dart';
import 'package:nyachi/src/core/navigation/navigation_element.dart';
import 'package:nyachi/src/core/theme/desktop_semantic_colors.dart';
import 'package:nyachi/src/shared/widgets/cyani_loading_indicator.dart';
import 'package:nyachi/src/shared/widgets/toast_helper.dart';

class NavigationSettingsPage extends ConsumerStatefulWidget {
  const NavigationSettingsPage({super.key});

  @override
  ConsumerState<NavigationSettingsPage> createState() =>
      _NavigationSettingsPageState();
}

class _NavigationSettingsPageState extends ConsumerState<NavigationSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final navigationSettingsAsync = ref.watch(navigationSettingsProvider);
    final navigationNotifier = ref.read(navigationSettingsProvider.notifier);
    final desktopColors = context.desktopSemanticColors;

    return Scaffold(
      appBar: AppBar(title: Text('settings_navigation_title'.tr())),
      body: navigationSettingsAsync.when(
        loading: () => const Center(child: CyaniLoadingIndicator()),
        error: (error, stack) =>
            Center(child: Text('settings_navigation_error_loading'.tr())),
        data: (navigationSettings) {
          final itemElements = navigationSettings.elements
              .where(
                (element) =>
                    element.type == NavigationElementType.item &&
                    element is NavigationItemElement &&
                    element.item.id != 'me',
              )
              .cast<NavigationItemElement>()
              .toList();

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            children: [
              _header(context, 'settings_navigation_section_items'.tr()),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 16, 10),
                child: Text(
                  '样式已对齐正式侧栏。拖拽调整顺序，非"用户"项用 +/- 控制显示。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: desktopColors.paneBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  children: [
                    _buildUserHeaderPreview(context),
                    const Divider(indent: 12, endIndent: 12),
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: itemElements.length,
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                      itemBuilder: (context, index) {
                        final itemElement = itemElements[index];
                        final item = itemElement.item;
                        return _buildNavigationRow(
                          context: context,
                          key: ValueKey(item.id),
                          item: item,
                          index: index,
                          onToggle: item.isRemovable
                              ? () => navigationNotifier.updateItemEnabled(
                                    item.id,
                                    !item.isEnabled,
                                    context,
                                  )
                              : null,
                        );
                      },
                      onReorderItem: (oldIndex, newIndex) {
                        final newOrder = itemElements.map((e) => e.item).toList();
                        final moved = newOrder.removeAt(oldIndex);
                        newOrder.insert(newIndex, moved);
                        navigationNotifier.updateItemOrder(newOrder);
                      },
                    ),
                    const Divider(indent: 12, endIndent: 12),
                    _buildSettingsPreviewRow(context),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.tonalIcon(
                  onPressed: () =>
                      _showResetConfirmation(context, navigationNotifier),
                  icon: const Icon(Icons.restart_alt),
                  label: Text('settings_navigation_reset_config'.tr()),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserHeaderPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '用户（固定）',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRow({
    required BuildContext context,
    required Key key,
    required NavigationItem item,
    required int index,
    required VoidCallback? onToggle,
  }) {
    final isLocked = !item.isRemovable;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 4),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: item.isEnabled
              ? Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.75)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              item.isEnabled ? item.selectedIcon : item.icon,
              color: item.isEnabled
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: item.isEnabled
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: item.isEnabled ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isLocked)
              Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.outline,
              )
            else
              IconButton.filledTonal(
                tooltip: item.isEnabled ? '删除该导航项' : '添加该导航项',
                onPressed: onToggle,
                icon: Icon(item.isEnabled ? Icons.remove_rounded : Icons.add_rounded),
                visualDensity: VisualDensity.compact,
              ),
            const SizedBox(width: 2),
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle_rounded,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPreviewRow(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.settings_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        'nav_settings'.tr(),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.outline,
      ),
      enabled: false,
    );
  }

  void _showResetConfirmation(
    BuildContext context,
    NavigationSettingsNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('settings_navigation_reset_config'.tr()),
        content: Text('settings_navigation_reset_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('accounts_remove_cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              notifier.resetSettings();
              Navigator.of(context).pop();
              showToast(title: 'settings_navigation_reset_done'.tr(), type: ToastificationType.success);
            },
            child: Text('post_reset'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 16, 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
