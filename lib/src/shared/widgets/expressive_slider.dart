import 'package:flutter/material.dart';
import 'package:nyachi/src/core/theme/design_tokens.dart';

class ExpressiveSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final bool centered;
  final ValueChanged<double>? onChanged;
  final String? label;
  final bool showIndicator;

  const ExpressiveSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.onChanged,
    this.divisions,
    this.centered = false,
    this.label,
    this.showIndicator = false,
  });

  @override
  State<ExpressiveSlider> createState() => _ExpressiveSliderState();
}

class _ExpressiveSliderState extends State<ExpressiveSlider> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final geometry = _ExpressiveSliderGeometry(tokens: context.m3eSlider);
    final enabled = widget.onChanged != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Semantics(
          slider: true,
          value: widget.value.round().toString(),
          increasedValue: _formatSemanticValue(_nextValue(1)),
          decreasedValue: _formatSemanticValue(_nextValue(-1)),
          onIncrease:
              enabled ? () => widget.onChanged!(_nextValue(1)) : null,
          onDecrease:
              enabled ? () => widget.onChanged!(_nextValue(-1)) : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled
                ? (details) =>
                    _updateFromDx(details.localPosition.dx, width)
                : null,
            onHorizontalDragStart: enabled
                ? (details) {
                    setState(() => _dragging = true);
                    _updateFromDx(details.localPosition.dx, width);
                  }
                : null,
            onHorizontalDragUpdate: enabled
                ? (details) =>
                    _updateFromDx(details.localPosition.dx, width)
                : null,
            onHorizontalDragEnd: enabled
                ? (_) => setState(() => _dragging = false)
                : null,
            onHorizontalDragCancel:
                enabled ? () => setState(() => _dragging = false) : null,
            child: CustomPaint(
              size: Size(width, geometry.height),
              painter: _ExpressiveSliderPainter(
                colorScheme: colorScheme,
                geometry: geometry,
                value: widget.value,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                centered: widget.centered,
                dragging: _dragging,
                showIndicator: widget.showIndicator,
                label: widget.label,
                disabled: !enabled,
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateFromDx(double dx, double width) {
    widget.onChanged?.call(_valueFromDx(dx, width));
  }

  double _valueFromDx(double dx, double width) {
    final geometry = _ExpressiveSliderGeometry(tokens: context.m3eSlider);
    final fraction = geometry.fractionFromDx(dx, width);
    final rawValue = widget.min + (widget.max - widget.min) * fraction;
    return _snapSliderValue(rawValue, widget.min, widget.max, widget.divisions);
  }

  double _nextValue(int direction) {
    final step = widget.divisions == null
        ? (widget.max - widget.min) / 100
        : (widget.max - widget.min) / widget.divisions!;
    return _snapSliderValue(
      widget.value + step * direction,
      widget.min,
      widget.max,
      widget.divisions,
    );
  }

  String _formatSemanticValue(double value) => value.round().toString();
}

class ExpressiveRangeSlider extends StatefulWidget {
  final RangeValues values;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<RangeValues>? onChanged;

  const ExpressiveRangeSlider({
    super.key,
    required this.values,
    this.min = 0,
    this.max = 100,
    this.onChanged,
    this.divisions,
  });

  @override
  State<ExpressiveRangeSlider> createState() => _ExpressiveRangeSliderState();
}

class _ExpressiveRangeSliderState extends State<ExpressiveRangeSlider> {
  _RangeThumb? _activeThumb;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final geometry = _ExpressiveSliderGeometry(tokens: context.m3eSlider);
    final enabled = widget.onChanged != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Semantics(
          slider: true,
          value:
              '${widget.values.start.round()} - ${widget.values.end.round()}',
          increasedValue: _formatSemanticValue(_nextValue(1, _RangeThumb.end)),
          decreasedValue: _formatSemanticValue(_nextValue(-1, _RangeThumb.start)),
          onIncrease: enabled
              ? () => widget.onChanged!(_nextValue(1, _RangeThumb.end))
              : null,
          onDecrease: enabled
              ? () => widget.onChanged!(_nextValue(-1, _RangeThumb.start))
              : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled
                ? (details) {
                    _activeThumb =
                        _nearestThumb(details.localPosition.dx, width);
                    _updateFromDx(details.localPosition.dx, width);
                  }
                : null,
            onHorizontalDragStart: enabled
                ? (details) {
                    setState(
                      () => _activeThumb = _nearestThumb(
                        details.localPosition.dx,
                        width,
                      ),
                    );
                    _updateFromDx(details.localPosition.dx, width);
                  }
                : null,
            onHorizontalDragUpdate: enabled
                ? (details) =>
                    _updateFromDx(details.localPosition.dx, width)
                : null,
            onHorizontalDragEnd: enabled
                ? (_) => setState(() => _activeThumb = null)
                : null,
            onHorizontalDragCancel:
                enabled ? () => setState(() => _activeThumb = null) : null,
            child: CustomPaint(
              size: Size(width, geometry.height),
              painter: _ExpressiveRangeSliderPainter(
                colorScheme: colorScheme,
                geometry: geometry,
                values: widget.values,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                activeThumb: _activeThumb,
                disabled: !enabled,
              ),
            ),
          ),
        );
      },
    );
  }

  _RangeThumb _nearestThumb(double dx, double width) {
    final geometry = _ExpressiveSliderGeometry(tokens: context.m3eSlider);
    final startX = geometry.dxForValue(
      widget.values.start,
      widget.min,
      widget.max,
      width,
    );
    final endX = geometry.dxForValue(
      widget.values.end,
      widget.min,
      widget.max,
      width,
    );
    return (dx - startX).abs() <= (dx - endX).abs()
        ? _RangeThumb.start
        : _RangeThumb.end;
  }

  void _updateFromDx(double dx, double width) {
    final activeThumb = _activeThumb;
    if (activeThumb == null) return;

    final geometry = _ExpressiveSliderGeometry(tokens: context.m3eSlider);
    final fraction = geometry.fractionFromDx(dx, width);
    final rawValue = widget.min + (widget.max - widget.min) * fraction;

    if (activeThumb == _RangeThumb.start) {
      widget.onChanged?.call(
        RangeValues(rawValue.clamp(widget.min, widget.values.end), widget.values.end),
      );
    } else {
      widget.onChanged?.call(
        RangeValues(widget.values.start, rawValue.clamp(widget.values.start, widget.max)),
      );
    }
  }

  RangeValues _nextValue(int direction, _RangeThumb thumb) {
    final step = (widget.max - widget.min) / 100;
    if (thumb == _RangeThumb.start) {
      final next = _snapSliderValue(
        widget.values.start + step * direction, widget.min, widget.values.end, null,
      );
      return RangeValues(next, widget.values.end);
    } else {
      final next = _snapSliderValue(
        widget.values.end + step * direction, widget.values.start, widget.max, null,
      );
      return RangeValues(widget.values.start, next);
    }
  }

  String _formatSemanticValue(RangeValues values) =>
      '${values.start.round()} - ${values.end.round()}';
}

enum _RangeThumb { start, end }

class _ExpressiveSliderGeometry {
  final double height;
  final double horizontalPadding;
  final double trackCenterY;
  final double trackHeight;
  final double handleWidth;
  final double handleHeight;
  final double handleRadius;
  final double stopIndicatorRadius;
  final double haloRadius;
  final double trackGap;
  final double tickRadius;
  final double indicatorRadius;
  final double indicatorBottomGap;

  _ExpressiveSliderGeometry({required M3ESliderTokens tokens})
      : height = 96.0,
        horizontalPadding = 24.0,
        trackCenterY = 58.0,
        trackHeight = tokens.trackHeight * 3,
        handleWidth = tokens.thumbRadius * 0.5,
        handleHeight = tokens.thumbRadius * 5,
        handleRadius = tokens.thumbRadius * 0.25,
        stopIndicatorRadius = 2.0,
        haloRadius = tokens.overlayRadius * 1.25,
        trackGap = tokens.thumbRadius,
        tickRadius = 1.4,
        indicatorRadius = 15.0,
        indicatorBottomGap = 10.0;

  double get _trackOffset => trackHeight / 2;

  double effectiveLeft(double width) => horizontalPadding + _trackOffset;

  double effectiveRight(double width) => width - horizontalPadding - _trackOffset;

  double fractionFromDx(double dx, double width) {
    final left = effectiveLeft(width);
    final right = effectiveRight(width);
    return ((dx - left) / (right - left)).clamp(0.0, 1.0);
  }

  double dxForValue(double value, double min, double max, double width) {
    final fraction = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final left = effectiveLeft(width);
    final right = effectiveRight(width);
    return left + (right - left) * fraction;
  }
}

mixin _SliderPainterUtils on CustomPainter {
  _ExpressiveSliderGeometry get geometry;
  ColorScheme get colorScheme;
  bool get disabled;

  Color get _activeColor =>
      disabled ? colorScheme.outline.withValues(alpha: 0.38) : colorScheme.primary;

  Color get _inactiveColor =>
      disabled
          ? colorScheme.outline.withValues(alpha: 0.12)
          : colorScheme.primary.withValues(alpha: 0.18);

  void drawSegment(Canvas canvas, Paint paint, double start, double end, double y) {
    if (end - start <= 1) return;
    final rect = Rect.fromLTRB(
      start,
      y - geometry.trackHeight / 2,
      end,
      y + geometry.trackHeight / 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        Radius.circular(geometry.trackHeight / 2),
      ),
      paint,
    );
  }

  void drawTicks(
    Canvas canvas,
    Size size,
    double activeStart,
    double activeEnd,
    List<double> hiddenCenters,
    int? divisions,
  ) {
    if (divisions == null || divisions <= 0) return;

    final left = geometry.horizontalPadding;
    final right = size.width - geometry.horizontalPadding;
    final y = geometry.trackCenterY;

    for (var i = 0; i <= divisions; i++) {
      final x = left + (right - left) * i / divisions;
      final hidden = hiddenCenters.any(
        (center) => (x - center).abs() < geometry.trackGap + 3,
      );
      if (hidden) continue;

      final isActive = x >= activeStart && x <= activeEnd;
      canvas.drawCircle(
        Offset(x, y),
        geometry.tickRadius,
        Paint()
          ..color = isActive
              ? colorScheme.onPrimary.withValues(alpha: disabled ? 0.6 : 1.0)
              : _activeColor.withValues(alpha: disabled ? 0.3 : 0.45),
      );
    }
  }

  void drawThumb(Canvas canvas, double thumbX, bool isActive) {
    final center = Offset(thumbX, geometry.trackCenterY);
    if (!disabled) {
      canvas.drawCircle(
        center,
        geometry.haloRadius,
        Paint()
          ..color = colorScheme.primary
              .withValues(alpha: isActive ? 0.16 : 0.0),
      );
    }
    final rect = Rect.fromCenter(
      center: center,
      width: geometry.handleWidth,
      height: geometry.handleHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(geometry.handleRadius)),
      Paint()..color = _activeColor,
    );
  }

  void drawIndicator(Canvas canvas, double thumbX, String text) {
    if (disabled) return;
    final center = Offset(
      thumbX,
      geometry.trackCenterY -
          geometry.handleHeight / 2 -
          geometry.indicatorBottomGap -
          geometry.indicatorRadius,
    );
    final paint = Paint()..color = colorScheme.primary;
    canvas.drawCircle(center, geometry.indicatorRadius, paint);

    const notchWidth = 6.0;
    const notchHeight = 11.0;
    final notchConnectY = geometry.indicatorRadius - 4.0;
    final notchPath = Path()
      ..moveTo(center.dx - notchWidth, center.dy + notchConnectY)
      ..lineTo(center.dx + notchWidth, center.dy + notchConnectY)
      ..lineTo(center.dx, center.dy + notchConnectY + notchHeight)
      ..close();
    canvas.drawPath(notchPath, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void drawStopIndicator(Canvas canvas, double x) {
    canvas.drawCircle(
      Offset(x, geometry.trackCenterY),
      geometry.stopIndicatorRadius,
      Paint()..color = _activeColor,
    );
  }
}

class _ExpressiveSliderPainter extends CustomPainter with _SliderPainterUtils {
  @override
  final ColorScheme colorScheme;
  @override
  final _ExpressiveSliderGeometry geometry;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final bool centered;
  final bool dragging;
  final bool showIndicator;
  final String? label;
  @override
  final bool disabled;

  const _ExpressiveSliderPainter({
    required this.colorScheme,
    required this.geometry,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.centered,
    required this.dragging,
    this.showIndicator = false,
    this.label,
    this.disabled = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final thumbX = geometry.dxForValue(value, min, max, size.width);
    final midX = geometry.dxForValue((min + max) / 2, min, max, size.width);

    late final double activeLeft, activeRight;
    if (centered) {
      activeLeft = thumbX < midX ? thumbX : midX;
      activeRight = thumbX < midX ? midX : thumbX;
    } else {
      activeLeft = geometry.horizontalPadding;
      activeRight = thumbX;
    }

    final left = geometry.horizontalPadding;
    final right = size.width - geometry.horizontalPadding;
    final gapStart = thumbX - geometry.trackGap;
    final gapEnd = thumbX + geometry.trackGap;
    final y = geometry.trackCenterY;

    final inactivePaint = Paint()
      ..color = _inactiveColor
      ..style = PaintingStyle.fill;
    final activePaint = Paint()
      ..color = _activeColor
      ..style = PaintingStyle.fill;

    drawSegment(canvas, inactivePaint, left, gapStart, y);
    drawSegment(canvas, inactivePaint, gapEnd, right, y);
    drawSegment(
      canvas, activePaint, activeLeft, gapStart.clamp(activeLeft, activeRight), y,
    );
    drawSegment(
      canvas, activePaint, gapEnd.clamp(activeLeft, activeRight), activeRight, y,
    );
    drawStopIndicator(canvas, geometry.effectiveLeft(size.width));
    drawStopIndicator(canvas, geometry.effectiveRight(size.width));
    drawTicks(canvas, size, activeLeft, activeRight, [thumbX], divisions);
    drawThumb(canvas, thumbX, dragging);

    if (showIndicator || dragging) {
      drawIndicator(canvas, thumbX, label ?? value.round().toString());
    }
  }

  @override
  bool shouldRepaint(covariant _ExpressiveSliderPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.dragging != dragging ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.centered != centered ||
        oldDelegate.disabled != disabled ||
        oldDelegate.showIndicator != showIndicator ||
        oldDelegate.label != label ||
        oldDelegate.geometry != geometry;
  }
}

class _ExpressiveRangeSliderPainter extends CustomPainter with _SliderPainterUtils {
  @override
  final ColorScheme colorScheme;
  @override
  final _ExpressiveSliderGeometry geometry;
  final RangeValues values;
  final double min;
  final double max;
  final int? divisions;
  final _RangeThumb? activeThumb;
  @override
  final bool disabled;

  const _ExpressiveRangeSliderPainter({
    required this.colorScheme,
    required this.geometry,
    required this.values,
    required this.min,
    required this.max,
    required this.divisions,
    this.activeThumb,
    this.disabled = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startX = geometry.dxForValue(values.start, min, max, size.width);
    final endX = geometry.dxForValue(values.end, min, max, size.width);
    final y = geometry.trackCenterY;
    final left = geometry.horizontalPadding;
    final right = size.width - geometry.horizontalPadding;
    final startGapStart = startX - geometry.trackGap;
    final startGapEnd = startX + geometry.trackGap;
    final endGapStart = endX - geometry.trackGap;
    final endGapEnd = endX + geometry.trackGap;

    final inactivePaint = Paint()
      ..color = _inactiveColor
      ..style = PaintingStyle.fill;
    final activePaint = Paint()
      ..color = _activeColor
      ..style = PaintingStyle.fill;

    drawSegment(canvas, inactivePaint, left, startGapStart, y);
    drawSegment(canvas, inactivePaint, endGapEnd, right, y);
    drawSegment(canvas, activePaint, startGapEnd, endGapStart, y);
    drawStopIndicator(canvas, geometry.effectiveLeft(size.width));
    drawStopIndicator(canvas, geometry.effectiveRight(size.width));
    drawTicks(canvas, size, startGapEnd, endGapStart, [startX, endX], divisions);
    drawThumb(canvas, startX, activeThumb == _RangeThumb.start);
    drawThumb(canvas, endX, activeThumb == _RangeThumb.end);

    if (activeThumb == _RangeThumb.start) {
      drawIndicator(canvas, startX, values.start.round().toString());
    } else if (activeThumb == _RangeThumb.end) {
      drawIndicator(canvas, endX, values.end.round().toString());
    }
  }

  @override
  bool shouldRepaint(covariant _ExpressiveRangeSliderPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.activeThumb != activeThumb ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.disabled != disabled ||
        oldDelegate.geometry != geometry;
  }
}

double _snapSliderValue(double rawValue, double min, double max, int? divisions) {
  final clamped = rawValue.clamp(min, max);
  if (divisions == null || divisions <= 0) return clamped;

  final step = (max - min) / divisions;
  return min + ((clamped - min) / step).round() * step;
}
