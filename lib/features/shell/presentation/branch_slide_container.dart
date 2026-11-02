// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/breakpoints.dart';

/// Animated container for the shell's branch navigators.
///
/// Replaces the default `IndexedStack` container of `StatefulShellRoute` so
/// that switching between bottom-navigation tabs slides horizontally, and
/// switching between sidebar destinations on wide screens slides vertically.
/// Only tab-to-tab switches animate; regular route pushes keep the platform
/// default transition. All branch navigators stay in the tree (offstage when
/// inactive) so each branch keeps its navigation state.
class BranchSlideContainer extends StatefulWidget {
  const BranchSlideContainer({
    required this.navigationShell,
    required this.children,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  State<BranchSlideContainer> createState() => _BranchSlideContainerState();
}

class _BranchSlideContainerState extends State<BranchSlideContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  )..addStatusListener(_onStatus);

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _outgoingIndex != null) {
      setState(() => _outgoingIndex = null);
    }
  }

  /// Branch index animating out, `null` when no transition is running.
  int? _outgoingIndex;

  /// Index the outgoing branch slid from; the sign of `current - previous`
  /// decides the slide direction.
  int? _previousIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BranchSlideContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = widget.navigationShell.currentIndex;
    if (newIndex == oldWidget.navigationShell.currentIndex) return;
    // Interrupting a running transition: the branch that was still animating
    // out is replaced outright by the new target.
    _previousIndex = oldWidget.navigationShell.currentIndex;
    _outgoingIndex = _previousIndex;
    _controller.forward(from: 0);
  }

  Axis _axisOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= kCompactBreakpoint
          ? Axis.vertical
          : Axis.horizontal;

  @override
  Widget build(BuildContext context) {
    final current = widget.navigationShell.currentIndex;
    final axis = _axisOf(context);
    final animating =
        _outgoingIndex != null && _controller.status == AnimationStatus.forward;
    final delta =
        _previousIndex == null ? 0 : (current - _previousIndex!).sign;

    Widget branch(int index) {
      final child = widget.children[index];
      final isActive = index == current;
      final isOutgoing = animating && index == _outgoingIndex;
      if (!isActive && !isOutgoing) {
        return Offstage(offstage: true, child: child);
      }
      if (!animating || delta == 0) {
        return child;
      }
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOutCubic.transform(_controller.value);
          // The incoming branch enters from the trailing edge (right on
          // horizontal, bottom on vertical) when the index increases and from
          // the leading edge otherwise; the outgoing branch slides out
          // towards the opposite edge.
          final distance = (isActive ? 1 - t : -t) * delta.toDouble();
          return FractionalTranslation(
            translation: Offset(
              axis == Axis.horizontal ? distance : 0,
              axis == Axis.vertical ? distance : 0,
            ),
            child: child,
          );
        },
      );
    }

    return Stack(
      fit: StackFit.expand,
      textDirection: TextDirection.ltr,
      children: <Widget>[
        for (var i = 0; i < widget.children.length; i++) branch(i),
      ],
    );
  }
}
