// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Exposes the branch shell to the persistent chrome above the shell navigator.
final shellNavigationProvider =
    Provider<ValueNotifier<StatefulNavigationShell?>>((ref) {
      final notifier = ValueNotifier<StatefulNavigationShell?>(null);
      ref.onDispose(notifier.dispose);
      return notifier;
    });
