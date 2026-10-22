import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:nyachi/src/core/core.dart';
import 'package:nyachi/src/core/theme/color_constants.dart';
import 'package:nyachi/src/core/theme/font_selector.dart';
import 'package:nyachi/src/core/widgets/settings_widgets.dart';
import 'package:nyachi/src/shared/widgets/cyani_loading_indicator.dart';
import 'package:nyachi/src/shared/widgets/toast_helper.dart';

part 'appearance_page.g.dart';

class AppearanceSettings {
  final ThemeMode displayMode;
  final bool useDynamicColor;
  final bool useCustomColor;
  final Color? primaryColor;
  final String? fontFamily;
  final bool useCustomTitleBar;

  const AppearanceSettings({
    required this.displayMode,
    required this.useDynamicColor,
    this.useCustomColor = false,
    this.primaryColor,
    this.fontFamily,
    this.useCustomTitleBar = true,
  });

  bool get isDarkMode => displayMode == ThemeMode.dark;

  AppearanceSettings copyWith({
    ThemeMode? displayMode,
    bool? useDynamicColor,
    bool? useCustomColor,
    Color? primaryColor,
    String? fontFamily,
    bool? useCustomTitleBar,
  }) {
    return AppearanceSettings(
      displayMode: displayMode ?? this.displayMode,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      useCustomColor: useCustomColor ?? this.useCustomColor,
      primaryColor: primaryColor ?? this.primaryColor,
      fontFamily: fontFamily ?? this.fontFamily,
      useCustomTitleBar: useCustomTitleBar ?? this.useCustomTitleBar,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppearanceSettings &&
          runtimeType == other.runtimeType &&
          displayMode == other.displayMode &&
          useDynamicColor == other.useDynamicColor &&
          useCustomColor == other.useCustomColor &&
          primaryColor?.toARGB32() == other.primaryColor?.toARGB32() &&
          fontFamily == other.fontFamily &&
          useCustomTitleBar == other.useCustomTitleBar;

  @override
  int get hashCode =>
      displayMode.hashCode ^
      useDynamicColor.hashCode ^
      useCustomColor.hashCode ^
      (primaryColor?.toARGB32().hashCode ?? 0) ^
      (fontFamily?.hashCode ?? 0) ^
      useCustomTitleBar.hashCode;
}

@Riverpod(keepAlive: true)
class AppearanceSettingsNotifier extends _$AppearanceSettingsNotifier {
  @override
  Future<AppearanceSettings> build() async {
    final settings = await _loadFromStorage();
    return settings;
  }

  Future<AppearanceSettings> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeModeIndex =
          prefs.getInt('appearance_display_mode') ?? 0;
      final displayMode = ThemeMode.values[themeModeIndex];

      // 动态色彩：所有支持的平台默认开启（Android/macOS/Windows）
      final useDynamicColor =
          prefs.getBool('appearance_dynamic_color') ?? true;
      final useCustomColor =
          prefs.getBool('appearance_custom_color') ?? false;

      final primaryColorValue = prefs.getInt('appearance_primary_color');
      final primaryColor = primaryColorValue != null
          ? Color(primaryColorValue)
          : SaucePalette.mikuGreen;

      final fontFamily = prefs.getString('appearance_font_family') ?? 'MiSans';

      final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux;
      final useCustomTitleBar = isDesktop
          ? (prefs.getBool('appearance_custom_title_bar') ?? true)
          : false;

      return AppearanceSettings(
        displayMode: displayMode,
        useDynamicColor: useDynamicColor,
        useCustomColor: useCustomColor,
        primaryColor: primaryColor,
        fontFamily: fontFamily,
        useCustomTitleBar: useCustomTitleBar,
      );
    } catch (_) {
      final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux;
      return AppearanceSettings(
        displayMode: ThemeMode.system,
        useDynamicColor: true,
        useCustomColor: false,
        primaryColor: SaucePalette.mikuGreen,
        fontFamily: 'MiSans',
        useCustomTitleBar: isDesktop,
      );
    }
  }

  Future<void> _saveToStorage(AppearanceSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('appearance_display_mode', settings.displayMode.index);
      await prefs.setBool('appearance_dynamic_color', settings.useDynamicColor);
      await prefs.setBool('appearance_custom_color', settings.useCustomColor);
      if (settings.primaryColor != null) {
        await prefs.setInt('appearance_primary_color', settings.primaryColor!.toARGB32());
      }
      if (settings.fontFamily != null) {
        await prefs.setString('appearance_font_family', settings.fontFamily!);
      }
      await prefs.setBool(
        'appearance_custom_title_bar',
        settings.useCustomTitleBar,
      );
    } catch (e) {
      logger.warning('AppearanceSettings: Failed to save settings to storage', e);
    }
  }

  Future<void> updateDisplayMode(ThemeMode mode) async {
    final newState = state.value!.copyWith(displayMode: mode);
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  Future<void> toggleDynamicColor(bool value) async {
    final newState = state.value!.copyWith(
      useDynamicColor: value,
      useCustomColor: value ? false : state.value!.useCustomColor,
    );
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  Future<void> toggleCustomColor(bool value) async {
    final newState = state.value!.copyWith(
      useCustomColor: value,
      useDynamicColor: value ? false : state.value!.useDynamicColor,
    );
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  Future<void> updatePrimaryColor(Color color) async {
    final newState = state.value!.copyWith(
      primaryColor: color,
      useCustomColor: true,
      useDynamicColor: false,
    );
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  Future<void> updateFontFamily(String fontFamily) async {
    final newState = state.value!.copyWith(fontFamily: fontFamily);
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  Future<void> toggleCustomTitleBar(bool value) async {
    final newState = state.value!.copyWith(useCustomTitleBar: value);
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }

  Future<void> resetSettings() async {
    final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
    final newState = AppearanceSettings(
      displayMode: ThemeMode.system,
      useDynamicColor: true,
      useCustomColor: false,
      primaryColor: SaucePalette.mikuGreen,
      fontFamily: 'MiSans',
      useCustomTitleBar: isDesktop,
    );
    state = AsyncData(newState);
    await _saveToStorage(newState);
  }
}

class AppearancePage extends ConsumerStatefulWidget {
  const AppearancePage({super.key});

  @override
  ConsumerState<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends ConsumerState<AppearancePage> {
  static const _purple = Color(0xFFAB47BC);
  static const _teal = Color(0xFF26A69A);

  @override
  Widget build(BuildContext context) {
    final appearanceSettingsAsync = ref.watch(appearanceSettingsProvider);
    final appearanceNotifier = ref.read(appearanceSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('settings_appearance_title'.tr())),
      body: appearanceSettingsAsync.when(
        loading: () => const Center(child: CyaniLoadingIndicator()),
        error: (_, _) =>
            Center(child: Text('settings_appearance_error_loading'.tr())),
        data: (appearanceSettings) {
          final isDesktop =
              defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.linux;

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            children: [
              SettingsCardGroup(
                children: [
                  _displayModeSelector(appearanceSettings.displayMode, appearanceNotifier),
                  _switchTile(
                    icon: Icons.color_lens_outlined,
                    iconColor: SettingsIconColors.purple,
                    title: 'settings_appearance_dynamic_color'.tr(),
                    subtitle: 'settings_appearance_dynamic_color_description'.tr(),
                    value: appearanceSettings.useDynamicColor,
                    onChanged: appearanceNotifier.toggleDynamicColor,
                  ),
                  _switchTile(
                    icon: Icons.palette_outlined,
                    iconColor: _purple,
                    title: 'settings_appearance_custom_color'.tr(),
                    subtitle: 'settings_appearance_custom_color_description'.tr(),
                    value: appearanceSettings.useCustomColor,
                    onChanged: appearanceNotifier.toggleCustomColor,
                  ),
                  if (appearanceSettings.useCustomColor)
                    _colorPickerRow(appearanceSettings, appearanceNotifier),
                  if (isDesktop)
                    _switchTile(
                      icon: Icons.crop_square_rounded,
                      iconColor: const Color(0xFF42A5F5),
                      title: '自定义标题栏',
                      subtitle: '使用自定义窗口标题栏',
                      value: appearanceSettings.useCustomTitleBar,
                      onChanged: (value) {
                        if (value && !appearanceSettings.useCustomTitleBar) {
                          _showTitleBarRestartDialog(appearanceNotifier);
                        } else {
                          appearanceNotifier.toggleCustomTitleBar(value);
                        }
                      },
                    ),
                ],
              ),

              const SizedBox(height: 16),
              SettingsCardGroup(
                children: [
                  SettingsTile(
                    icon: Icons.font_download_outlined,
                    iconColor: _teal,
                    title: 'settings_font_title'.tr(),
                    subtitle: appearanceSettings.fontFamily ?? 'MiSans',
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const FontSelectorDialog(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _buildPreviewCard(context, appearanceSettings),

              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.tonalIcon(
                  onPressed: () => _showResetConfirmation(appearanceNotifier),
                  icon: const Icon(Icons.restart_alt),
                  label: Text('settings_appearance_reset_config'.tr()),
                ),
              ),
              const SizedBox(height: 48),
            ],
          );
        },
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────────
  // ── Display Mode Selector ────────────────────────────────────
  Widget _displayModeSelector(ThemeMode current, AppearanceSettingsNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings_appearance_display_mode'.tr(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('跟随系统'),
                  icon: Icon(Icons.settings_suggest_outlined, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('浅色'),
                  icon: Icon(Icons.light_mode_outlined, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('深色'),
                  icon: Icon(Icons.dark_mode_outlined, size: 18),
                ),
              ],
              selected: {current},
              onSelectionChanged: (v) => notifier.updateDisplayMode(v.first),
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Switch Tile ──────────────────────────────────────────────
  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabled = onChanged == null;
    final effectiveIconColor = disabled ? colorScheme.outline : iconColor;
    final effectiveTextColor = disabled ? colorScheme.outline : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: disabled ? Colors.transparent : iconColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: effectiveIconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: effectiveTextColor,
                )),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: disabled ? colorScheme.outline : colorScheme.onSurfaceVariant,
                )),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  // ── Color Picker Row ─────────────────────────────────────────
  Widget _colorPickerRow(AppearanceSettings settings, AppearanceSettingsNotifier notifier) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentColor = settings.primaryColor ?? colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showColorPicker(notifier),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Center(
                  child: Icon(Icons.color_lens, color: currentColor.computeLuminance() > 0.5 ? Colors.black54 : Colors.white70),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => notifier.resetSettings(),
            child: Text('settings_appearance_reset_color'.tr()),
          ),
        ],
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────
  void _showResetConfirmation(AppearanceSettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('settings_appearance_reset_config'.tr()),
        content: Text('settings_appearance_reset_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              notifier.resetSettings();
              Navigator.of(ctx).pop();
              showToast(title: 'settings_appearance_reset_done'.tr(), type: ToastificationType.success);
            },
            child: Text('confirm'.tr()),
          ),
        ],
      ),
    );
  }

  void _showTitleBarRestartDialog(AppearanceSettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('需要重启 App'),
        content: const Text('开启此功能后需要重启一次 App，以保障良好的使用体验。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('保持关闭'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              notifier.toggleCustomTitleBar(true);
              Navigator.of(ctx).pop();
              // 重启应用
              if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
                windowManager.close();
              }
            },
            child: const Text('重启 App'),
          ),
        ],
      ),
    );
  }

  Future<void> _showColorPicker(AppearanceSettingsNotifier notifier) async {
    final currentColor = ref.read(appearanceSettingsProvider).value?.primaryColor ??
        Theme.of(context).colorScheme.primary;

    final List<Color> presetColors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
      Colors.brown, Colors.grey, Colors.blueGrey,
      SaucePalette.mikuGreen,
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('settings_appearance_select_color'.tr()),
        content: Wrap(
          spacing: 10, runSpacing: 10,
          children: presetColors.map((color) {
            final isSelected = currentColor == color;
            return GestureDetector(
              onTap: () {
                notifier.updatePrimaryColor(color);
                Navigator.of(ctx).pop();
              },
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('cancel'.tr()),
          ),
        ],
      ),
    );
  }

  // ── Preview Card (kept from original) ────────────────────────
  Widget _buildPreviewCard(BuildContext context, AppearanceSettings settings) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'settings_appearance_design_example'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'settings_appearance_design_example_subtitle'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: colorScheme.primary,
                          child: const Text("01", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 100, height: 8,
                          decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(4)),
                        ),
                        const Spacer(),
                        Icon(Icons.notifications_none, size: 18, color: colorScheme.primary),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16), topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16), bottomLeft: Radius.circular(4),
                          ),
                        ),
                        child: Text(
                          "Producer-san, let's make the best stage! (≧▽≦)",
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onPrimaryContainer),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(color: colorScheme.secondaryContainer, shape: BoxShape.circle),
                                  child: Icon(Icons.person, size: 16, color: colorScheme.onSecondaryContainer),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 60, height: 6,
                                      decoration: BoxDecoration(color: colorScheme.onSurface, borderRadius: BorderRadius.circular(3)),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 40, height: 4,
                                      decoration: BoxDecoration(color: colorScheme.outline, borderRadius: BorderRadius.circular(2)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity, height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primaryContainer.withAlpha(80),
                                    colorScheme.secondaryContainer.withAlpha(60),
                                    colorScheme.tertiaryContainer.withAlpha(40),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(Icons.play_circle_outline, color: colorScheme.primary, size: 32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMockButton(colorScheme.primary, Icons.favorite),
                        _buildMockButton(colorScheme.secondary, Icons.share),
                        _buildMockButton(colorScheme.tertiary, Icons.bookmark),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                _buildStatusChip(settings.isDarkMode ? 'Dark Mode' : 'Light Mode', settings.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                if (settings.useDynamicColor) _buildStatusChip('Dynamic', Icons.auto_fix_high),
                if (settings.useCustomColor) _buildStatusChip('Custom', Icons.palette),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockButton(Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildStatusChip(String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold,
          )),
        ],
      ),
    );
  }
}
