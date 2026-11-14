// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/settings/application/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  ProviderContainer newContainer(SharedPreferences preferences) =>
      ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      );

  test('bottom config caps visible tabs at four and keeps home', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = newContainer(preferences);
    addTearDown(container.dispose);

    final controller = container.read(settingsControllerProvider.notifier);
    await controller.setNavConfig(
      NavConfig(order: AppTab.values, visible: AppTab.values.toSet()),
    );

    final config = container.read(settingsControllerProvider).navConfig;
    expect(config.visible, hasLength(4));
    expect(config.visible, contains(AppTab.home));
    // Enabling everything still keeps only the first four in configured
    // order: home, notifications, explore, chat — profile drops last.
    expect(config.visible, {
      AppTab.home,
      AppTab.notifications,
      AppTab.explore,
      AppTab.chat,
    });
  });

  test(
    'bottom reorder and visibility persist through the controller',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final container = newContainer(preferences);
      addTearDown(container.dispose);

      final controller = container.read(settingsControllerProvider.notifier);
      await controller.setNavConfig(
        const NavConfig(
          order: [
            AppTab.chat,
            AppTab.home,
            AppTab.notifications,
            AppTab.profile,
          ],
          visible: {AppTab.home, AppTab.chat},
        ),
      );

      // Round-trip through the persisted keys, not the in-memory state. The
      // order is always the full tab list (missing tabs append at the end);
      // visibility is the subset.
      final reopened = await SharedPreferences.getInstance();
      expect(reopened.getStringList('settings.bottomTabOrder'), [
        'chat',
        'home',
        'notifications',
        'profile',
        'explore',
      ]);
      expect(reopened.getStringList('settings.bottomHiddenTabs'), [
        'notifications',
        'explore',
        'profile',
      ]);
    },
  );

  test(
    'sidebar config seeds from the legacy keys once, then persists',
    () async {
      SharedPreferences.setMockInitialValues({
        'settings.tabOrder': ['profile', 'home'],
        'settings.hiddenTabs': ['explore', 'chat', 'notifications'],
      });
      final preferences = await SharedPreferences.getInstance();
      final container = newContainer(preferences);
      addTearDown(container.dispose);

      final sidebar = container
          .read(settingsControllerProvider)
          .sidebarNavConfig;
      expect(sidebar.order.first, AppTab.profile);
      expect(sidebar.visible, {AppTab.home, AppTab.profile});

      // First read also seeds the bottom config, with the four-slot cap.
      final bottom = container.read(settingsControllerProvider).navConfig;
      expect(bottom.order.first, AppTab.profile);
      expect(bottom.visible, {AppTab.home, AppTab.profile});
    },
  );

  test('showMeAtTop round-trip', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = newContainer(preferences);
    addTearDown(container.dispose);

    final controller = container.read(settingsControllerProvider.notifier);
    await controller.setShowMeAtTop(true);

    final reopened = await SharedPreferences.getInstance();
    expect(reopened.getBool('layout.showMeAtTop'), isTrue);

    final state = container.read(settingsControllerProvider);
    expect(state.showMeAtTop, isTrue);
  });

  test('sanitizeBottomNavConfig forces home even with everything hidden', () {
    final config = sanitizeBottomNavConfig(
      NavConfig(order: AppTab.values, visible: {}),
    );
    expect(config.visible, {AppTab.home});
  });
}
