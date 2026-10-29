// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../settings/application/app_settings.dart';

part 'oobe_controller.g.dart';

/// OOBE step index. Steps: 0 language + welcome, 1 compliance + sign-in,
/// 2 appearance, 3 done. The wizard cannot be skipped: completion persists
/// `oobe.completed` and the router guard releases the app only afterwards.
@riverpod
class OobeController extends _$OobeController {
  static const lastStep = 3;

  @override
  int build() => 0;

  void next() {
    if (state < lastStep) state = state + 1;
  }

  void back() {
    if (state > 0) state = state - 1;
  }

  Future<void> complete() async {
    await ref.read(settingsControllerProvider.notifier).completeOobe();
  }
}
