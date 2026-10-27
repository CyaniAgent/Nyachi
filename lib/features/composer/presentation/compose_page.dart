// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

import 'compose_sheet.dart';

/// Full-page composer. Shares [ComposerBody] with the bottom sheet, so both
/// surfaces stay identical.
class ComposePage extends StatelessWidget {
  const ComposePage({this.replyId, super.key});

  final String? replyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ComposerBody(
          replyId: replyId,
          showHandle: false,
          expandContent: true,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
