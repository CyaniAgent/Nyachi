// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';

/// Maximum width of the readable content column.
const double appMaxContentWidth = 760;

/// Constrains content to a readable column.
///
/// [centered] defaults to `true` so wide screens keep the column in the middle;
/// pass `false` for the left-aligned feed layout.
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({
    required this.child,
    this.maxWidth = appMaxContentWidth,
    this.centered = true,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: centered ? Alignment.topCenter : Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
