// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_providers.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

enum AppTab { home, notifications, explore, chat, profile }

@freezed
abstract class NavConfig with _$NavConfig {
  const factory NavConfig({
    required List<AppTab> order,
    required Set<AppTab> visible,
  }) = _NavConfig;
}

NavConfig defaultNavConfig() =>
    NavConfig(order: AppTab.values, visible: AppTab.values.toSet());

NavConfig sanitizeNavConfig(NavConfig config) {
  final order = <AppTab>[];
  for (final tab in [...config.order, ...AppTab.values]) {
    if (!order.contains(tab)) order.add(tab);
  }
  final visible = config.visible.intersection(AppTab.values.toSet())
    ..add(AppTab.home);
  return NavConfig(order: order, visible: visible);
}

@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.localeCode,
    required this.navConfig,
  });

  final String themeMode;
  final String localeCode;
  final NavConfig navConfig;

  AppSettings copyWith({
    String? themeMode,
    String? localeCode,
    NavConfig? navConfig,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      navConfig: navConfig ?? this.navConfig,
    );
  }
}

@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  static const themeKey = 'settings.themeMode';
  static const localeKey = 'settings.locale';
  static const orderKey = 'settings.tabOrder';
  static const hiddenKey = 'settings.hiddenTabs';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final order = prefs.getStringList(orderKey);
    final hidden = prefs.getStringList(hiddenKey) ?? const [];
    final parsedOrder = order
        ?.map(_parseTab)
        .whereType<AppTab>()
        .toList(growable: false);
    final nav = sanitizeNavConfig(
      NavConfig(
        order: parsedOrder == null || parsedOrder.isEmpty
            ? AppTab.values
            : parsedOrder,
        visible: AppTab.values
            .where((tab) => !hidden.contains(tab.name))
            .toSet(),
      ),
    );
    return AppSettings(
      themeMode: prefs.getString(themeKey) ?? 'system',
      localeCode: prefs.getString(localeKey) ?? 'system',
      navConfig: nav,
    );
  }

  Future<void> setThemeMode(String mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(themeKey, mode);
  }

  Future<void> setLocale(String code) async {
    state = state.copyWith(localeCode: code);
    await _prefs.setString(localeKey, code);
  }

  Future<void> setNavConfig(NavConfig config) async {
    final sanitized = sanitizeNavConfig(config);
    state = state.copyWith(navConfig: sanitized);
    await _prefs.setStringList(
      orderKey,
      sanitized.order.map((tab) => tab.name).toList(growable: false),
    );
    await _prefs.setStringList(
      hiddenKey,
      AppTab.values
          .where((tab) => !sanitized.visible.contains(tab))
          .map((tab) => tab.name)
          .toList(growable: false),
    );
  }

  AppTab? _parseTab(String value) {
    for (final tab in AppTab.values) {
      if (tab.name == value) return tab;
    }
    return null;
  }
}
