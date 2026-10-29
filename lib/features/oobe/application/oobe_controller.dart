// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../settings/application/app_settings.dart';

part 'oobe_controller.g.dart';

/// OOBE step index. Steps: 0 language, 1 welcome, 2 compliance + sign-in,
/// 3 appearance, 4 done. The wizard cannot be skipped: completion persists
/// `oobe.completed` and the router guard releases the app only afterwards.
@riverpod
class OobeController extends _$OobeController {
  @override
  int build() => 0;

  void next() {
    if (state < 4) state = state + 1;
  }

  void back() {
    if (state > 0) state = state - 1;
  }

  Future<void> complete() async {
    await ref.read(settingsControllerProvider.notifier).completeOobe();
  }
}
