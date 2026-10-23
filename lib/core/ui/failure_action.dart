// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_controller.dart';
import '../network/error_mapper.dart';
import 'l10n_ext.dart';

class FailureAction extends ConsumerWidget {
  const FailureAction({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final AppFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (failure.kind == AppFailureKind.auth) {
      return TextButton(
        onPressed: () =>
            ref.read(sessionControllerProvider.notifier).expireActiveAccount(),
        child: Text(context.l10n.relogin),
      );
    }
    return TextButton(onPressed: onRetry, child: Text(context.l10n.retry));
  }
}
