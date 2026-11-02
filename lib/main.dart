// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/storage/storage_providers.dart';
import 'core/platform/residency.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    // Residency is best-effort: a platform without tray support or an Android
    // build without the notification grant still starts normally.
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const _ResidencyBootstrap(),
    ),
  );
}

/// Starts the platform residency surfaces before the app renders.
class _ResidencyBootstrap extends ConsumerStatefulWidget {
  const _ResidencyBootstrap();

  @override
  ConsumerState<_ResidencyBootstrap> createState() =>
      _ResidencyBootstrapState();
}

class _ResidencyBootstrapState extends ConsumerState<_ResidencyBootstrap> {
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(residencyProvider).initialize());
  }

  @override
  Widget build(BuildContext context) => const NyachiApp();
}
