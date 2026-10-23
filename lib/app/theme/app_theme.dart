// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

Color parseThemeColor(String? value) {
  if (value == null) return Colors.indigo;
  final cleaned = value.trim().replaceFirst('#', '');
  if (cleaned.length != 6 && cleaned.length != 8) return Colors.indigo;
  final parsed = int.tryParse(cleaned, radix: 16);
  if (parsed == null) return Colors.indigo;
  return Color(cleaned.length == 6 ? 0xff000000 | parsed : parsed);
}

ThemeData buildAppTheme({required Brightness brightness, required Color seed}) {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    visualDensity: VisualDensity.standard,
  );
}

ThemeMode parseThemeMode(String value) {
  return switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
