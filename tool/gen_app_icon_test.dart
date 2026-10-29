// SPDX-License-Identifier: AGPL-3.0-or-later

// Renders the in-app brand icon (Material `Icons.pets` paw on the themed
// container) into the PNG assets consumed by flutter_launcher_icons.
//
// Usage:
//   flutter test --update-goldens tool/gen_app_icon_test.dart
//   dart run tool/apply_app_icon.dart   (moves goldens into assets/brand)
//
// Outputs (1024×1024):
//   - app_icon_full: primaryContainer background + paw (iOS, macOS, Windows,
//     Android legacy fallback)
//   - app_icon_fg:   transparent background + paw in the adaptive-icon safe
//     zone (Android adaptive foreground, web favicon/icons — no background
//     on the web, per product decision)
//
// The widget-test environment does not bundle the MaterialIcons font (an
// unregistered Icon renders as a tofu box), so the font is loaded explicitly
// from the engine's flutter_assets directory before rendering.

@Timeout(Duration(minutes: 2))
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _seed = Color(0xFF6750A4); // fallback brand seed used by the app
const _size = 1024.0;
Future<void> _loadMaterialIcons() async {
  const candidates = [
    // Flutter SDK cache (canonical copy, lowercase name). Relative to the
    // project root where `flutter test` resolves File() paths.
    '../../../../../Flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    // Built app bundle layout, if present.
    'build/windows/x64/runner/Debug/data/flutter_assets/fonts/MaterialIcons-Regular.otf',
  ];
  for (final path in candidates) {
    final file = File(path);
    if (file.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(
          Future<ByteData>.value(
            ByteData.view(file.readAsBytesSync().buffer, 0, file.lengthSync()),
          ),
        );
      await loader.load();
      return;
    }
  }
  throw StateError('MaterialIcons-Regular.otf not found');
}

Future<void> _render(
  WidgetTester tester,
  Key key,
  Widget Function(ColorScheme scheme) builder,
  String golden,
) async {
  tester.view.physicalSize = const Size(_size, _size);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(key: key, child: builder(_scheme)),
    ),
  );
  await expectLater(find.byKey(key), matchesGoldenFile(golden));
}

late ColorScheme _scheme;

void main() {
  setUpAll(_loadMaterialIcons);

  testWidgets('render full app icon', (tester) async {
    _scheme = ColorScheme.fromSeed(seedColor: _seed);
    await _render(
      tester,
      const Key('full'),
      (scheme) => ColoredBox(
        color: scheme.primaryContainer,
        child: Center(
          child: Icon(Icons.pets, size: 560, color: scheme.onPrimaryContainer),
        ),
      ),
      'goldens/app_icon_full.png',
    );
  });

  testWidgets('render adaptive foreground / web icon', (tester) async {
    _scheme = ColorScheme.fromSeed(seedColor: _seed);
    // Adaptive foreground safe zone: content stays inside the center ~66%.
    await _render(
      tester,
      const Key('fg'),
      (scheme) => Center(
        child: Icon(Icons.pets, size: 560, color: scheme.onPrimaryContainer),
      ),
      'goldens/app_icon_fg.png',
    );
  });
}
