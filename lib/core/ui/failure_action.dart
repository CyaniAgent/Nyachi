// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_controller.dart';
import '../network/error_mapper.dart';
import 'l10n_ext.dart';

class FailureAction extends ConsumerStatefulWidget {
  const FailureAction({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final AppFailure failure;
  final VoidCallback onRetry;

  @override
  ConsumerState<FailureAction> createState() => _FailureActionState();
}

class _FailureActionState extends ConsumerState<FailureAction> {
  @override
  void initState() {
    super.initState();
    if (widget.failure.kind == AppFailureKind.auth) {
      // The token is dead: expire eagerly instead of waiting for the tap.
      // expireActiveAccount is idempotent, so duplicate triggers are safe.
      Future.microtask(
        () =>
            ref.read(sessionControllerProvider.notifier).expireActiveAccount(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.failure.kind == AppFailureKind.auth) {
      return TextButton(
        onPressed: () =>
            ref.read(sessionControllerProvider.notifier).expireActiveAccount(),
        child: Text(context.l10n.sessionExpired),
      );
    }
    return TextButton(
      onPressed: widget.onRetry,
      child: Text(context.l10n.retry),
    );
  }
}
