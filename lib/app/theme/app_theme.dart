// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

const double appBorderRadius = 18;
const double appColumnWidth = 380;
const double appNavRailWidth = 80;
const double appSidebarWidth = 240;
const double appDetailPanelDefaultWidth = 480;
const double appDetailPanelMinWidth = 360;
const double appDetailPanelMaxWidth = 900;
const double appFeedMinWidth = 480;
const double appDetailPanelHandleWidth = 8;
const Duration appDetailPanelAnimationDuration = Duration(milliseconds: 300);
const Curve appDetailPanelAnimationCurve = Curves.easeInOutCubicEmphasized;
const int appDetailBreakpointMin = 960;
const int appDetailBreakpointMax = 1600;
const int appDetailBreakpointStep = 40;
const int appDetailBreakpointDefault = 1200;

/// Neutral seed used when neither the user nor the instance provides a colour.
const Color appFallbackSeed = Color(0xFF6750A4);

/// Parses a `#rrggbb`/`#aarrggbb` colour string.
///
/// Returns [fallback] when [value] is null or malformed; callers that follow the
/// instance pass the instance theme colour so the seed tracks the server.
Color parseThemeColor(String? value, {Color fallback = appFallbackSeed}) {
  if (value == null) return fallback;
  final cleaned = value.trim().replaceFirst('#', '');
  if (cleaned.length != 6 && cleaned.length != 8) return fallback;
  final parsed = int.tryParse(cleaned, radix: 16);
  if (parsed == null) return fallback;
  return Color(cleaned.length == 6 ? 0xff000000 | parsed : parsed);
}

ThemeData buildAppTheme({
  required Brightness brightness,
  required Color seed,
  required bool isWide,
  ColorScheme? colorScheme,
}) {
  final scheme =
      colorScheme ??
      ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.rainbow,
      );
  final dividerColor = brightness == Brightness.dark
      ? scheme.surfaceContainerHighest
      : scheme.surfaceContainer;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    visualDensity: VisualDensity.standard,
    scaffoldBackgroundColor: scheme.surface,
    dividerColor: dividerColor,
    dividerTheme: DividerThemeData(color: dividerColor, space: 1, thickness: 1),
    appBarTheme: AppBarTheme(
      toolbarHeight: isWide ? 72 : 56,
      backgroundColor: scheme.surface,
      surfaceTintColor: isWide ? scheme.surface : Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: isWide ? 24 : null,
      actionsPadding: isWide
          ? const EdgeInsets.symmetric(horizontal: 16)
          : null,
    ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: scheme.onSurface.withValues(alpha: 0.5),
      selectionHandleColor: scheme.secondary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(appBorderRadius / 2),
      ),
      contentPadding: const EdgeInsets.all(12),
    ),
    chipTheme: ChipThemeData(
      showCheckmark: false,
      backgroundColor: scheme.surfaceContainer,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appBorderRadius),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: scheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(appBorderRadius / 2),
        ),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      strokeCap: StrokeCap.round,
      color: scheme.primary,
      refreshBackgroundColor: scheme.primaryContainer,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      width: isWide ? appColumnWidth * 1.5 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appBorderRadius / 2),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appBorderRadius),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minVerticalPadding: 10,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(appBorderRadius / 2),
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.secondaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appBorderRadius),
      ),
      selectedIconTheme: IconThemeData(color: scheme.onSecondaryContainer),
      unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      elevation: 0,
      backgroundColor: scheme.surfaceContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appBorderRadius),
      ),
    ),
  );
}

ThemeMode parseThemeMode(String value) {
  return switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
