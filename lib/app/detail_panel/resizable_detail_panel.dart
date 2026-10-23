// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const detailPanelHandleKey = Key('detail-panel-handle');

class ResizableDetailPanel extends StatefulWidget {
  const ResizableDetailPanel({
    required this.child,
    required this.panel,
    required this.open,
    this.snapOpen = false,
    required this.width,
    required this.minWidth,
    required this.maxWidth,
    required this.onWidthChanged,
    required this.onWidthChangeEnd,
    required this.onResetWidth,
    required this.onClosed,
    super.key,
  });

  final Widget child;
  final Widget? panel;
  final bool open;
  final bool snapOpen;
  final double width;
  final double minWidth;
  final double maxWidth;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<double> onWidthChangeEnd;
  final VoidCallback onResetWidth;
  final VoidCallback onClosed;

  @override
  State<ResizableDetailPanel> createState() => _ResizableDetailPanelState();
}

class _ResizableDetailPanelState extends State<ResizableDetailPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _open;
  Widget? _lastPanel;
  double? _dragWidth;
  var _closedNotified = false;

  @override
  void initState() {
    super.initState();
    _lastPanel = widget.panel;
    _open = AnimationController(
      vsync: this,
      duration: appDetailPanelAnimationDuration,
      value: widget.open && widget.panel != null ? 1 : 0,
    )..addStatusListener(_onStatus);
  }

  @override
  void didUpdateWidget(covariant ResizableDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.panel != null) _lastPanel = widget.panel;
    if (widget.open == oldWidget.open) return;
    if (widget.open) {
      _closedNotified = false;
      if (widget.snapOpen) {
        _open.value = 1;
      } else {
        _open.forward();
      }
    } else {
      _open.reverse();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed &&
        !widget.open &&
        !_closedNotified) {
      _closedNotified = true;
      _lastPanel = null;
      widget.onClosed();
    }
  }

  @override
  void dispose() {
    _open.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panel = widget.panel ?? _lastPanel;
    if (panel == null || widget.maxWidth < widget.minWidth) {
      return widget.child;
    }
    final targetWidth = widget.width
        .clamp(widget.minWidth, widget.maxWidth)
        .toDouble();
    return Row(
      children: [
        Expanded(child: widget.child),
        AnimatedBuilder(
          animation: _open,
          builder: (context, _) {
            final visible = _open.value > 0;
            if (!visible) return const SizedBox.shrink();
            return SizedBox(
              width: targetWidth * _open.value,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: targetWidth,
                  maxWidth: targetWidth,
                  child: SizedBox(
                    width: targetWidth,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        panel,
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: appDetailPanelHandleWidth,
                          child: _ResizeHandle(
                            onStart: () {
                              _dragWidth = targetWidth;
                              if (_open.value < 1) _open.value = 1;
                            },
                            onUpdate: (delta) {
                              final current = _dragWidth ?? targetWidth;
                              final next = (current - delta)
                                  .clamp(widget.minWidth, widget.maxWidth)
                                  .toDouble();
                              _dragWidth = next;
                              widget.onWidthChanged(next);
                            },
                            onEnd: () {
                              final value = _dragWidth ?? targetWidth;
                              _dragWidth = null;
                              widget.onWidthChangeEnd(value);
                            },
                            onReset: widget.onResetWidth,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.onReset,
  });

  final VoidCallback onStart;
  final ValueChanged<double> onUpdate;
  final VoidCallback onEnd;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        key: detailPanelHandleKey,
        behavior: HitTestBehavior.opaque,
        onDoubleTap: onReset,
        onHorizontalDragStart: (_) => onStart(),
        onHorizontalDragUpdate: (details) => onUpdate(details.delta.dx),
        onHorizontalDragEnd: (_) => onEnd(),
        onHorizontalDragCancel: onEnd,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 1,
            height: double.infinity,
            child: ColoredBox(color: Theme.of(context).dividerColor),
          ),
        ),
      ),
    );
  }
}
