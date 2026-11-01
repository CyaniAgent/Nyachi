// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

/// Watches the enclosing scrollable and calls [onEdge] once the viewport
/// comes within [extent] pixels of its far edge, replacing explicit
/// load-more buttons with scroll-triggered pagination.
///
/// [canLoad] gates the trigger (feed state, hasMore flags); one load runs at
/// a time. Feed lists scroll forward, so the loader only reacts to downward
/// scrollables.
class ScrollEdgeLoader extends StatefulWidget {
  const ScrollEdgeLoader({
    super.key,
    required this.child,
    required this.onEdge,
    this.canLoad,
    this.extent = 600,
  });

  final Widget child;
  final Future<void> Function() onEdge;
  final bool Function()? canLoad;
  final double extent;

  @override
  State<ScrollEdgeLoader> createState() => _ScrollEdgeLoaderState();
}

class _ScrollEdgeLoaderState extends State<ScrollEdgeLoader> {
  var _loading = false;

  bool _handle(ScrollNotification notification) {
    if (_loading) return false;
    final metrics = notification.metrics;
    if (metrics.axisDirection != AxisDirection.down) return false;
    if (metrics.maxScrollExtent - metrics.pixels >= widget.extent) {
      return false;
    }
    if (widget.canLoad?.call() != true) return false;
    _loading = true;
    widget.onEdge().whenComplete(() {
      if (mounted) setState(() => _loading = false);
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handle,
      child: widget.child,
    );
  }
}
