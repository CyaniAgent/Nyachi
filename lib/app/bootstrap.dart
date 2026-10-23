// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/auth/session_controller.dart';

part 'bootstrap.g.dart';

@Riverpod(keepAlive: true)
Future<void> bootstrap(Ref ref) async {
  try {
    await ref.read(sessionControllerProvider.notifier).initialize();
  } catch (error, stack) {
    debugPrint('Nyachi bootstrap failed: $error\n$stack');
    rethrow;
  }
}
