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

/// Tab order and visibility for one chrome surface. Both the narrow bottom
/// bar and the desktop sidebar store their own [NavConfig]; the difference
/// lives in the sanitizing rules and the extra sidebar preferences on
/// [AppSettings], not in the shape.
@freezed
abstract class NavConfig with _$NavConfig {
  const factory NavConfig({
    required List<AppTab> order,
    required Set<AppTab> visible,
  }) = _NavConfig;
}

/// Bottom bar default: explore stays out so the bar holds four destinations.
NavConfig defaultBottomNavConfig() => const NavConfig(
  order: AppTab.values,
  visible: {AppTab.home, AppTab.notifications, AppTab.chat, AppTab.profile},
);

/// Sidebar default: every tab visible, the account row at the top.
NavConfig defaultSidebarNavConfig() =>
    NavConfig(order: AppTab.values, visible: AppTab.values.toSet());

/// Legacy default kept for callers that only need "everything visible".
NavConfig defaultNavConfig() =>
    NavConfig(order: AppTab.values, visible: AppTab.values.toSet());

NavConfig sanitizeNavConfig(NavConfig config) {
  final order = _dedupeTabs(config.order);
  final visible = config.visible.intersection(AppTab.values.toSet())
    ..add(AppTab.home);
  return NavConfig(order: order, visible: visible);
}

/// Bottom bar rules: home always visible and at most four destinations, so
/// the bar never overflows. Extra visible tabs beyond the cap are dropped in
/// configured order.
NavConfig sanitizeBottomNavConfig(NavConfig config) {
  final sanitized = sanitizeNavConfig(config);
  final others = sanitized.order
      .where((tab) => tab != AppTab.home && sanitized.visible.contains(tab))
      .take(3)
      .toSet();
  return NavConfig(order: sanitized.order, visible: {AppTab.home, ...others});
}

List<AppTab> _dedupeTabs(List<AppTab> order) {
  final deduped = <AppTab>[];
  for (final tab in [...order, ...AppTab.values]) {
    if (!deduped.contains(tab)) deduped.add(tab);
  }
  return deduped;
}

@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.localeCode,
    required this.accentColor,
    required this.navConfig,
    required this.sidebarNavConfig,
    required this.detailBreakpoint,
    required this.oobeCompleted,
    this.showMeAtTop = false,
    this.sidebarWidth = appSidebarDefaultWidth,
    this.sidebarAutoCollapse = true,
    this.sidebarCollapseForPanel = false,
    this.sidebarToggle = true,
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

  /// Bottom-bar tabs on narrow screens.
  final NavConfig navConfig;

  /// Sidebar tabs on wide screens, plus the account-row placement.
  final NavConfig sidebarNavConfig;
  final int detailBreakpoint;

  /// Whether the first-run OOBE wizard has been completed. Until it is, the
  /// router guard pins every route to `/oobe`.
  final bool oobeCompleted;

  /// Desktop sidebar: the account header replaces the "me" tab row when set.
  final bool showMeAtTop;

  /// Desktop sidebar width in logical pixels (drag-adjusted, 160-400).
  final double sidebarWidth;

  /// Desktop sidebar collapses/expands automatically with window width until
  /// the user toggles it manually or turns the automation off.
  final bool sidebarAutoCollapse;

  /// Whether opening the wide-screen detail panel collapses the sidebar.
  /// Off by default: the panel just squeezes the feed. When the window is
  /// too narrow for both, the panel still wins (feed minimum width).
  final bool sidebarCollapseForPanel;

  /// Whether the sidebar offers its expand/collapse button. Hidden, the pane
  /// stays expanded — nothing could bring it back from the collapsed rail.
  final bool sidebarToggle;
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
    NavConfig? sidebarNavConfig,
    int? detailBreakpoint,
    bool? oobeCompleted,
    bool? showMeAtTop,
    double? sidebarWidth,
    bool? sidebarAutoCollapse,
    bool? sidebarCollapseForPanel,
    bool? sidebarToggle,
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
      sidebarNavConfig: sidebarNavConfig ?? this.sidebarNavConfig,
      detailBreakpoint: detailBreakpoint ?? this.detailBreakpoint,
      oobeCompleted: oobeCompleted ?? this.oobeCompleted,
      showMeAtTop: showMeAtTop ?? this.showMeAtTop,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      sidebarAutoCollapse: sidebarAutoCollapse ?? this.sidebarAutoCollapse,
      sidebarCollapseForPanel:
          sidebarCollapseForPanel ?? this.sidebarCollapseForPanel,
      sidebarToggle: sidebarToggle ?? this.sidebarToggle,
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
  static const bottomOrderKey = 'settings.bottomTabOrder';
  static const bottomHiddenKey = 'settings.bottomHiddenTabs';
  static const sidebarOrderKey = 'settings.sidebarTabOrder';
  static const sidebarHiddenKey = 'settings.sidebarHiddenTabs';
  static const showMeAtTopKey = 'layout.showMeAtTop';
  static const sidebarWidthKey = 'layout.sidebarWidth';
  static const sidebarAutoCollapseKey = 'layout.sidebarAutoCollapse';
  static const sidebarCollapseForPanelKey = 'layout.sidebarCollapseForPanel';
  static const sidebarToggleKey = 'layout.sidebarToggle';
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
    final bottom = _readNavConfig(
      prefs,
      orderKey: bottomOrderKey,
      hiddenKey: bottomHiddenKey,
      legacyOrderKey: orderKey,
      legacyHiddenKey: hiddenKey,
      fallback: defaultBottomNavConfig(),
      sanitize: sanitizeBottomNavConfig,
    );
    final sidebar = _readNavConfig(
      prefs,
      orderKey: sidebarOrderKey,
      hiddenKey: sidebarHiddenKey,
      legacyOrderKey: orderKey,
      legacyHiddenKey: hiddenKey,
      fallback: defaultSidebarNavConfig(),
      sanitize: sanitizeNavConfig,
    );
    return AppSettings(
      themeMode: prefs.getString(themeKey) ?? 'system',
      localeCode: prefs.getString(localeKey) ?? 'system',
      accentColor: prefs.getString(accentKey) ?? 'instance',
      navConfig: bottom,
      sidebarNavConfig: sidebar,
      oobeCompleted: prefs.getBool(oobeCompletedKey) ?? false,
      showMeAtTop: prefs.getBool(showMeAtTopKey) ?? false,
      sidebarWidth: (prefs.getDouble(sidebarWidthKey) ?? appSidebarDefaultWidth)
          .clamp(appSidebarMinWidth, appSidebarMaxWidth),
      sidebarAutoCollapse: prefs.getBool(sidebarAutoCollapseKey) ?? true,
      sidebarCollapseForPanel:
          prefs.getBool(sidebarCollapseForPanelKey) ?? false,
      sidebarToggle: prefs.getBool(sidebarToggleKey) ?? true,
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

  /// Reads one surface's config. Both surfaces seed from the legacy single
  /// `settings.tabOrder`/`settings.hiddenTabs` pair on first read, so an
  /// existing install keeps its tab order instead of snapping to defaults;
  /// the bottom config additionally drops tabs beyond the four-slot cap.
  NavConfig _readNavConfig(
    SharedPreferences prefs, {
    required String orderKey,
    required String hiddenKey,
    required String legacyOrderKey,
    required String legacyHiddenKey,
    required NavConfig fallback,
    required NavConfig Function(NavConfig) sanitize,
  }) {
    final order =
        prefs.getStringList(orderKey) ?? prefs.getStringList(legacyOrderKey);
    final hidden =
        prefs.getStringList(hiddenKey) ?? prefs.getStringList(legacyHiddenKey);
    if (order == null && hidden == null) return sanitize(fallback);
    final parsedOrder = order
        ?.map(_parseTab)
        .whereType<AppTab>()
        .toList(growable: false);
    return sanitize(
      NavConfig(
        order: parsedOrder == null || parsedOrder.isEmpty
            ? fallback.order
            : parsedOrder,
        visible: AppTab.values
            .where((tab) => !(hidden ?? const []).contains(tab.name))
            .toSet(),
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
    final sanitized = sanitizeBottomNavConfig(config);
    state = state.copyWith(navConfig: sanitized);
    await _writeNavConfig(
      sanitized,
      orderKey: bottomOrderKey,
      hiddenKey: bottomHiddenKey,
    );
  }

  Future<void> setSidebarNavConfig(NavConfig config) async {
    final sanitized = sanitizeNavConfig(config);
    state = state.copyWith(sidebarNavConfig: sanitized);
    await _writeNavConfig(
      sanitized,
      orderKey: sidebarOrderKey,
      hiddenKey: sidebarHiddenKey,
    );
  }

  Future<void> _writeNavConfig(
    NavConfig sanitized, {
    required String orderKey,
    required String hiddenKey,
  }) async {
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

  Future<void> setShowMeAtTop(bool value) async {
    state = state.copyWith(showMeAtTop: value);
    await _prefs.setBool(showMeAtTopKey, value);
  }

  Future<void> setSidebarWidth(double value) async {
    final clamped = value.clamp(appSidebarMinWidth, appSidebarMaxWidth);
    state = state.copyWith(sidebarWidth: clamped);
    await _prefs.setDouble(sidebarWidthKey, clamped);
  }

  /// Drag-time width update: in-memory only, persisted by [setSidebarWidth]
  /// when the drag gesture ends.
  void setSidebarWidthLive(double value) {
    state = state.copyWith(
      sidebarWidth: value.clamp(appSidebarMinWidth, appSidebarMaxWidth),
    );
  }

  Future<void> setSidebarAutoCollapse(bool value) async {
    state = state.copyWith(sidebarAutoCollapse: value);
    await _prefs.setBool(sidebarAutoCollapseKey, value);
  }

  Future<void> setSidebarCollapseForPanel(bool value) async {
    state = state.copyWith(sidebarCollapseForPanel: value);
    await _prefs.setBool(sidebarCollapseForPanelKey, value);
  }

  Future<void> setSidebarToggle(bool value) async {
    state = state.copyWith(sidebarToggle: value);
    await _prefs.setBool(sidebarToggleKey, value);
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
