import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:nyachi/src/core/navigation/navigation.dart';
import 'package:nyachi/src/core/navigation/navigation_element.dart';
import 'package:nyachi/src/core/navigation/sub_navigation_notifier.dart';
import 'package:nyachi/src/shared/widgets/user_navigation_header.dart';

class RootNavigationDrawer extends ConsumerWidget {
  final int selectedRootIndex;
  final Function(int) onRootSelected;

  const RootNavigationDrawer({
    super.key,
    required this.selectedRootIndex,
    required this.onRootSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationSettings = ref.watch(navigationSettingsProvider).value;

    // We only care about the first 3 roots: Misskey, Drive, Messages
    // 'me' is now handled by the header.
    final rootItems =
        navigationSettings?.elements
            .where(
              (element) =>
                  element.type == NavigationElementType.item &&
                  element is NavigationItemElement,
            )
            .cast<NavigationItemElement>()
            .where(
              (itemElement) =>
                  itemElement.item.isEnabled && itemElement.item.id != 'me',
            )
            .map((e) => e.item)
            .toList() ??
        [];

    final effectiveSelectedRootIndex = selectedRootIndex >= rootItems.length
        ? -1
        : selectedRootIndex;

    return NavigationDrawer(
      selectedIndex: -1,
      onDestinationSelected: (index) {},
      children: [
        UserNavigationHeader(
          isDrawer: true,
          isSelected: effectiveSelectedRootIndex == -1,
          onTap: () {
            onRootSelected(
              NavigationService.mapBranchIndexToDisplayIndex(
                NavigationService.getBranchIndexForItem('me'),
                navigationSettings!,
              ),
            );
          },
        ),
        const Divider(indent: 12, endIndent: 12),

        // Root Sections
        for (int i = 0; i < rootItems.length; i++) ...[
          _buildRootSection(
            context,
            ref,
            rootItems[i],
            i,
            effectiveSelectedRootIndex,
          ),
        ],

        const SizedBox(height: 12),
        const Divider(indent: 12, endIndent: 12),
        _buildSettingsButton(context),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildRootSection(
    BuildContext context,
    WidgetRef ref,
    NavigationItem rootItem,
    int index,
    int effectiveSelectedRootIndex,
  ) {
    final isSelected = index == effectiveSelectedRootIndex;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: () => onRootSelected(index),
              borderRadius: BorderRadius.circular(32),
              splashColor: theme.colorScheme.primary.withAlpha(20),
              highlightColor: theme.colorScheme.primary.withAlpha(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.secondaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withAlpha(10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer.withAlpha(40)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSelected ? rootItem.selectedIcon : rootItem.icon,
                        color: isSelected
                            ? theme.colorScheme.onSecondaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rootItem.title,
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Sub-navigation for the selected root
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: isSelected
                ? _buildSubNavigation(context, ref, rootItem.id)
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ),

        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildSubNavigation(
    BuildContext context,
    WidgetRef ref,
    String rootId,
  ) {
    if (rootId == 'misskey') {
      return _buildMisskeySubs(context, ref);
    }
    return const SizedBox.shrink();
  }

  Widget _buildMisskeySubs(BuildContext context, WidgetRef ref) {
    final selectedSub = ref.watch(misskeySubIndexProvider);

    final subs = [
      {'icon': Icons.timeline, 'label': 'misskey_drawer_timeline'.tr()},
      {
        'icon': Icons.collections_bookmark,
        'label': 'misskey_drawer_clips'.tr(),
      },
      {'icon': Icons.satellite_alt, 'label': 'misskey_drawer_antennas'.tr()},
      {'icon': Icons.hub, 'label': 'misskey_drawer_channels'.tr()},
      {'icon': Icons.explore, 'label': 'misskey_drawer_explore'.tr()},
      {
        'icon': Icons.person_add,
        'label': 'misskey_drawer_follow_requests'.tr(),
      },
      {'icon': Icons.campaign, 'label': 'misskey_drawer_announcements'.tr()},
      {'icon': Icons.terminal, 'label': 'misskey_drawer_aiscript_console'.tr()},
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 12),
      child: Column(
        children: [
          for (int i = 0; i < subs.length; i++)
            _buildSubItem(
              context,
              icon: subs[i]['icon'] as IconData,
              label: subs[i]['label'] as String,
              isSelected: selectedSub == i,
              onTap: () {
                ref.read(misskeySubIndexProvider.notifier).set(i);
                Navigator.of(context).maybePop();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSubItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          splashColor: theme.colorScheme.primary.withAlpha(20),
          highlightColor: theme.colorScheme.primary.withAlpha(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withAlpha(15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary.withAlpha(30)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer.withAlpha(30)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () {
            context.push('/settings');
          },
          borderRadius: BorderRadius.circular(32),
          splashColor: theme.colorScheme.primary.withAlpha(20),
          highlightColor: theme.colorScheme.primary.withAlpha(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'navigation_settings'.tr(),
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
