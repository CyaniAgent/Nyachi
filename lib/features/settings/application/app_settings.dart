// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/app_theme.dart';
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
    required this.accentColor,
    required this.navConfig,
    required this.detailBreakpoint,
    required this.oobeCompleted,
    this.centerContent = true,
    this.defaultVisibility = 'public',
    this.defaultLocalOnly = false,
    this.mfmMotionMode = 'detailOnly',
    this.mfmMotionClasses = const {
      'scale',
      'translate',
      'rotate',
      'color',
      'flicker',
    },
  });

  final String themeMode;
  final String localeCode;
  final String accentColor;
  final NavConfig navConfig;
  final int detailBreakpoint;

  /// Whether the first-run OOBE wizard has been completed. Until it is, the
  /// router guard pins every route to `/oobe`.
  final bool oobeCompleted;

  /// Centers the readable column on wide screens instead of left-aligning it.
  final bool centerContent;

  /// Starting visibility and local-only flag for a new note. The composer
  /// reads them when it opens; the user can still change both per post.
  final String defaultVisibility;
  final bool defaultLocalOnly;

  /// `all` / `detailOnly` / `off`: how much MFM motion plays. The default
  /// keeps timelines static, because a feed of many notes would otherwise
  /// repaint every frame.
  final String mfmMotionMode;

  /// Enabled [MfmMotionClass] names; an empty set means "everything".
  final Set<String> mfmMotionClasses;

  AppSettings copyWith({
    String? themeMode,
    String? localeCode,
    String? accentColor,
    NavConfig? navConfig,
    int? detailBreakpoint,
    bool? oobeCompleted,
    bool? centerContent,
    String? defaultVisibility,
    bool? defaultLocalOnly,
    String? mfmMotionMode,
    Set<String>? mfmMotionClasses,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      accentColor: accentColor ?? this.accentColor,
      navConfig: navConfig ?? this.navConfig,
      detailBreakpoint: detailBreakpoint ?? this.detailBreakpoint,
      oobeCompleted: oobeCompleted ?? this.oobeCompleted,
      centerContent: centerContent ?? this.centerContent,
      defaultVisibility: defaultVisibility ?? this.defaultVisibility,
      defaultLocalOnly: defaultLocalOnly ?? this.defaultLocalOnly,
      mfmMotionMode: mfmMotionMode ?? this.mfmMotionMode,
      mfmMotionClasses: mfmMotionClasses ?? this.mfmMotionClasses,
    );
  }
}

@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  static const themeKey = 'settings.themeMode';
  static const localeKey = 'settings.locale';
  static const accentKey = 'settings.accentColor';
  static const orderKey = 'settings.tabOrder';
  static const hiddenKey = 'settings.hiddenTabs';
  static const detailBreakpointKey = 'layout.detailBreakpoint';
  static const centerContentKey = 'layout.centerContent';
  static const oobeCompletedKey = 'oobe.completed';
  static const defaultVisibilityKey = 'composer.defaultVisibility';
  static const defaultLocalOnlyKey = 'composer.defaultLocalOnly';
  static const mfmMotionModeKey = 'mfm.motionMode';
  static const mfmMotionClassesKey = 'mfm.motionClasses';

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
      accentColor: prefs.getString(accentKey) ?? 'instance',
      navConfig: nav,
      oobeCompleted: prefs.getBool(oobeCompletedKey) ?? false,
      detailBreakpoint:
          (prefs.getInt(detailBreakpointKey) ?? appDetailBreakpointDefault)
              .clamp(appDetailBreakpointMin, appDetailBreakpointMax)
              .toInt(),
      centerContent: prefs.getBool(centerContentKey) ?? true,
      defaultVisibility: prefs.getString(defaultVisibilityKey) ?? 'public',
      defaultLocalOnly: prefs.getBool(defaultLocalOnlyKey) ?? false,
      mfmMotionMode: _parseMotionMode(prefs.getString(mfmMotionModeKey)),
      mfmMotionClasses: _parseMotionClasses(
        prefs.getStringList(mfmMotionClassesKey),
      ),
    );
  }

  Future<void> setDefaultVisibility(String visibility) async {
    state = state.copyWith(defaultVisibility: visibility);
    await _prefs.setString(defaultVisibilityKey, visibility);
  }

  Future<void> setDefaultLocalOnly(bool value) async {
    state = state.copyWith(defaultLocalOnly: value);
    await _prefs.setBool(defaultLocalOnlyKey, value);
  }

  Future<void> setThemeMode(String mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(themeKey, mode);
  }

  Future<void> setLocale(String code) async {
    state = state.copyWith(localeCode: code);
    await _prefs.setString(localeKey, code);
  }

  Future<void> setAccentColor(String color) async {
    state = state.copyWith(accentColor: color);
    await _prefs.setString(accentKey, color);
  }

  /// Persists OOBE completion; the router guard reads this via the settings
  /// state to release the app from `/oobe`.
  Future<void> completeOobe() async {
    state = state.copyWith(oobeCompleted: true);
    await _prefs.setBool(oobeCompletedKey, true);
  }

  Future<void> setDetailBreakpoint(int value) async {
    final clamped = value
        .clamp(appDetailBreakpointMin, appDetailBreakpointMax)
        .toInt();
    final aligned =
        appDetailBreakpointMin +
        ((clamped - appDetailBreakpointMin) ~/ appDetailBreakpointStep) *
            appDetailBreakpointStep;
    state = state.copyWith(detailBreakpoint: aligned);
    await _prefs.setInt(detailBreakpointKey, aligned);
  }

  Future<void> setCenterContent(bool value) async {
    state = state.copyWith(centerContent: value);
    await _prefs.setBool(centerContentKey, value);
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

  static const _motionModes = {'all', 'detailOnly', 'off'};

  String _parseMotionMode(String? raw) =>
      raw != null && _motionModes.contains(raw) ? raw : 'detailOnly';

  Set<String> _parseMotionClasses(List<String>? raw) {
    const known = {'scale', 'translate', 'rotate', 'color', 'flicker'};
    if (raw == null) return known;
    return raw.where(known.contains).toSet();
  }

  Future<void> setMfmMotionMode(String mode) async {
    final value = _parseMotionMode(mode);
    state = state.copyWith(mfmMotionMode: value);
    await _prefs.setString(mfmMotionModeKey, value);
  }

  Future<void> setMfmMotionClass(String motionClass, bool enabled) async {
    final classes = {...state.mfmMotionClasses};
    if (enabled) {
      classes.add(motionClass);
    } else {
      classes.remove(motionClass);
    }
    state = state.copyWith(mfmMotionClasses: classes);
    await _prefs.setStringList(
      mfmMotionClassesKey,
      classes.toList(growable: false),
    );
  }
}
