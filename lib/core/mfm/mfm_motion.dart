// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:mfm_parser/mfm_parser.dart';

/// How much of the note's motion to play.
///
/// Motion repaints every frame, and a timeline holds many notes at once, so
/// the default plays it only where one note owns the screen.
enum MfmMotionMode { all, detailOnly, off }

MfmMotionMode mfmMotionModeFrom(String? raw) => switch (raw) {
  'all' => MfmMotionMode.all,
  'off' => MfmMotionMode.off,
  _ => MfmMotionMode.detailOnly,
};

/// The five independently switchable groups of motion.
///
/// Grouping by what moves keeps the setting list short while still letting a
/// user silence the effects that bother them — colour cycling and flicker are
/// usually the objectionable ones, transforms rarely are.
enum MfmMotionClass { scale, translate, rotate, color, flicker }

const mfmMotionClasses = MfmMotionClass.values;

/// Whether motion plays at all in this context.
bool mfmMotionEnabled(MfmMotionMode mode, {required bool detail}) =>
    switch (mode) {
      MfmMotionMode.all => true,
      MfmMotionMode.off => false,
      MfmMotionMode.detailOnly => detail,
    };

/// Whether [enabled] contains [motionClass]. An empty set means "no explicit
/// choice", which plays everything rather than silently muting every effect.
bool mfmClassEnabled(Set<MfmMotionClass> enabled, MfmMotionClass motionClass) =>
    enabled.isEmpty || enabled.contains(motionClass);

/// One `$[fn ...]` resolved to an effect.
class MfmEffectSpec {
  const MfmEffectSpec(
    this.effect,
    this.motionClass, {
    this.duration = const Duration(milliseconds: 1000),
    this.delay = Duration.zero,
    this.easing = Curves.linear,
    this.reverse = false,
    this.alternate = false,
    this.axisX = false,
    this.axisY = false,
  });

  final MfmEffect effect;
  final MfmMotionClass motionClass;
  final Duration duration;
  final Duration delay;
  final Curve easing;

  /// Plays the cycle backwards (`spin.left`).
  final bool reverse;

  /// Reverses every other cycle (`spin.alternate`).
  final bool alternate;

  /// Rotates around the horizontal / vertical axis instead of the Z axis
  /// (`spin.x`, `spin.y`).
  final bool axisX;
  final bool axisY;
}

enum MfmEffect {
  jump,
  bounce,
  shake,
  twitch,
  rubberBand,
  tada,
  spin,
  rainbow,
  blur,
  sparkle,
}

/// Misskey's own argument rules: `speed`/`delay` are seconds (`1s`, `0.5s`) and
/// anything else is ignored, so a hostile value cannot change the timing.
Duration? _parseSeconds(Object? raw) {
  if (raw is! String) return null;
  final match = RegExp(r'^-?[0-9.]+s$').firstMatch(raw);
  if (match == null) return null;
  final seconds = double.tryParse(raw.substring(0, raw.length - 1));
  if (seconds == null) return null;
  return Duration(milliseconds: (seconds * 1000).round());
}

Duration _duration(Object? raw, int fallbackMs) =>
    _parseSeconds(raw) ?? Duration(milliseconds: fallbackMs);

/// Resolves an MFM function to an effect, or null when the function is not a
/// motion at all (unknown names, `fg.color`, `font.serif`, …).
///
/// Durations and easings reproduce the frontend's stylesheet so a note animates
/// at the pace its author saw while writing it.
MfmEffectSpec? mfmEffectOf(MfmFn node) {
  final args = node.args;
  final delay = _parseSeconds(args['delay']) ?? Duration.zero;
  final reverse = args['left'] == true;
  final alternate = args['alternate'] == true;
  final axisX = args['x'] == true;
  final axisY = args['y'] == true;
  switch (node.name) {
    case 'jump':
      return MfmEffectSpec(
        MfmEffect.jump,
        MfmMotionClass.translate,
        duration: _duration(args['speed'], 750),
        delay: delay,
      );
    case 'bounce':
      return MfmEffectSpec(
        MfmEffect.bounce,
        MfmMotionClass.translate,
        duration: _duration(args['speed'], 750),
        delay: delay,
      );
    case 'shake':
      return MfmEffectSpec(
        MfmEffect.shake,
        MfmMotionClass.translate,
        duration: _duration(args['speed'], 500),
        delay: delay,
        easing: Curves.ease,
      );
    case 'twitch':
      return MfmEffectSpec(
        MfmEffect.twitch,
        MfmMotionClass.translate,
        duration: _duration(args['speed'], 500),
        delay: delay,
        easing: Curves.ease,
      );
    case 'jelly':
      return MfmEffectSpec(
        MfmEffect.rubberBand,
        MfmMotionClass.translate,
        duration: _duration(args['speed'], 1000),
        delay: delay,
      );
    case 'tada':
      return MfmEffectSpec(
        MfmEffect.tada,
        MfmMotionClass.color,
        duration: _duration(args['speed'], 1000),
        delay: delay,
      );
    case 'spin':
      return MfmEffectSpec(
        MfmEffect.spin,
        MfmMotionClass.rotate,
        duration: _duration(args['speed'], 1500),
        delay: delay,
        reverse: reverse,
        alternate: alternate,
        axisX: axisX,
        axisY: axisY,
      );
    case 'rainbow':
      return MfmEffectSpec(
        MfmEffect.rainbow,
        MfmMotionClass.color,
        duration: _duration(args['speed'], 1000),
        delay: delay,
      );
    case 'blur':
      return const MfmEffectSpec(MfmEffect.blur, MfmMotionClass.flicker);
    case 'sparkle':
      return MfmEffectSpec(
        MfmEffect.sparkle,
        MfmMotionClass.flicker,
        duration: _duration(args['speed'], 1000),
        delay: delay,
      );
    default:
      return null;
  }
}

/// Size multiplier for `x2`/`x3`/`x4`, matching the frontend: they step
/// 200% → 400% → 600% rather than doubling each time.
double? mfmScaleFactor(MfmFn node, {int depth = 0}) {
  final base = switch (node.name) {
    'x2' => 2.0,
    'x3' => 4.0,
    'x4' => 6.0,
    _ => null,
  };
  if (base == null) return null;
  // Nested scaling is only half effective once, then ignored, so a note cannot
  // explode its layout with a deep stack of x4.
  return switch (depth) {
    0 => base,
    1 => base / 2 + 0.5,
    _ => 1.0,
  };
}

/// Colours an `fg.color`/`bg.color` argument names.
///
/// The frontend accepts bare hex (3–6 digits) and falls back to red otherwise,
/// which is what this mirrors — a CSS colour name is not a valid argument
/// there, so it is not one here either.
Color mfmParseColor(Object? raw) {
  const fallback = Color(0xFFFF0000);
  if (raw is! String) return fallback;
  var value = raw.trim();
  if (value.startsWith('#')) value = value.substring(1);
  if (!RegExp(r'^[0-9a-fA-F]{3,6}$').hasMatch(value)) return fallback;
  if (value.length == 6) {
    final parsed = int.tryParse(value, radix: 16);
    return parsed == null ? fallback : Color(0xFF000000 | parsed);
  }
  if (value.length == 3) {
    final expanded = value.split('').map((c) => '$c$c').join();
    final parsed = int.tryParse(expanded, radix: 16);
    return parsed == null ? fallback : Color(0xFF000000 | parsed);
  }
  // A 4- or 5-digit value has no CSS meaning for these functions.
  return fallback;
}

/// The blurred presentation behind `$[blur ...]`.
///
/// The frontend applies `filter: blur(6px)` with a 0.3s transition and clears
/// it on hover. A pointer resolves it here the same way; touch devices reveal
/// it on press, since they have no hover state.
class MfmBlurred extends StatefulWidget {
  const MfmBlurred({required this.child, this.style, super.key});

  final List<InlineSpan> child;
  final TextStyle? style;

  @override
  State<MfmBlurred> createState() => _MfmBlurredState();
}

class _MfmBlurredState extends State<MfmBlurred> {
  var _revealed = false;

  @override
  Widget build(BuildContext context) {
    final content = RichText(
      text: TextSpan(style: widget.style, children: widget.child),
    );
    return MouseRegion(
      onEnter: (_) => setState(() => _revealed = true),
      onExit: (_) => setState(() => _revealed = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _revealed = true),
        onTapUp: (_) => setState(() => _revealed = false),
        onTapCancel: () => setState(() => _revealed = false),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: ImageFiltered(
            key: ValueKey(_revealed),
            imageFilter: ImageFilter.blur(
              sigmaX: _revealed ? 0 : 6,
              sigmaY: _revealed ? 0 : 6,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Renders [children] with [spec] applied, repainting only this subtree.
///
/// The wrapper is a widget rather than a span transform because Flutter can
/// only animate a `TextSpan` by rebuilding the whole paragraph; keeping each
/// effect in its own widget means one spinning word repaints one box.
class MfmMotion extends StatefulWidget {
  const MfmMotion({
    required this.spec,
    required this.children,
    this.style,
    this.textAlign,
    super.key,
  });

  final MfmEffectSpec spec;
  final List<InlineSpan> children;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  State<MfmMotion> createState() => _MfmMotionState();
}

class _MfmMotionState extends State<MfmMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.spec.duration,
  );

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _controller.repeat(reverse: widget.spec.alternate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = widget.spec.easing.transform(_controller.value);
        return _render(context, t);
      },
    );
  }

  Widget _text(TextStyle? style) => RichText(
    textAlign: widget.textAlign ?? TextAlign.start,
    text: TextSpan(style: style ?? widget.style, children: widget.children),
  );

  Widget _render(BuildContext context, double t) {
    switch (widget.spec.effect) {
      case MfmEffect.jump:
        return Transform.translate(
          offset: Offset(0, _sample(_jumpFrames, t).dy),
          child: _text(null),
        );
      case MfmEffect.bounce:
        final frame = _sample(_bounceFrames, t);
        return Transform.translate(
          offset: Offset(0, frame.dy),
          child: Transform.scale(
            scaleX: frame.sx,
            scaleY: frame.sy,
            alignment: Alignment.bottomCenter,
            child: _text(null),
          ),
        );
      case MfmEffect.shake:
        final frame = _sample(_shakeFrames, t);
        return Transform.translate(
          offset: Offset(frame.dx, frame.dy),
          child: Transform.rotate(
            angle: frame.deg * math.pi / 180,
            child: _text(null),
          ),
        );
      case MfmEffect.twitch:
        final frame = _sample(_twitchFrames, t);
        return Transform.translate(
          offset: Offset(frame.dx, frame.dy),
          child: _text(null),
        );
      case MfmEffect.rubberBand:
        final frame = _sample(_rubberFrames, t);
        return Transform.scale(
          scaleX: frame.sx,
          scaleY: frame.sy,
          child: _text(null),
        );
      case MfmEffect.tada:
        final frame = _sample(_tadaFrames, t);
        final base = widget.style ?? const TextStyle();
        return Transform.rotate(
          angle: frame.deg * math.pi / 180,
          child: Transform.scale(
            scaleX: frame.sx,
            scaleY: frame.sy,
            child: _text(base.copyWith(fontSize: (base.fontSize ?? 14) * 1.5)),
          ),
        );
      case MfmEffect.spin:
        final angle = (widget.spec.reverse ? -1 : 1) * t * math.pi * 2;
        if (widget.spec.axisX || widget.spec.axisY) {
          // The frontend rotates inside `perspective(128px)`, so the glyphs
          // visibly tumble rather than merely narrowing.
          final m = Matrix4.identity()..setEntry(3, 2, 1 / 128);
          if (widget.spec.axisX) {
            m.rotateX(angle);
          } else {
            m.rotateY(angle);
          }
          return Transform(
            alignment: Alignment.center,
            transform: m,
            child: _text(null),
          );
        }
        return Transform.rotate(angle: angle, child: _text(null));
      case MfmEffect.rainbow:
        final base =
            widget.style?.color ??
            DefaultTextStyle.of(context).style.color ??
            Colors.black;
        final hsl = HSLColor.fromColor(base);
        final cycled = hsl
            .withHue((hsl.hue + t * 360) % 360)
            // `contrast(150%) saturate(150%)` from the stylesheet.
            .withSaturation(math.min(1, hsl.saturation * 1.5))
            .withLightness(((hsl.lightness - 0.5) * 1.5 + 0.5).clamp(0.0, 1.0));
        return _text(
          (widget.style ?? const TextStyle()).copyWith(color: cycled.toColor()),
        );
      case MfmEffect.sparkle:
        return _SparkleOverlay(t: t, child: _text(null));
      case MfmEffect.blur:
        // Handled by [MfmBlurred]; reaching this means the caller wired the
        // effect up without a static shape.
        return _text(null);
    }
  }
}

/// Misskey renders `$[sparkle ...]` as the text plus drifting sparkles, so the
/// words stay readable and only the decoration animates.
class _SparkleOverlay extends StatelessWidget {
  const _SparkleOverlay({required this.t, required this.child});

  final double t;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    const positions = <Offset>[
      Offset(-4, -10),
      Offset(38, -6),
      Offset(-8, 8),
      Offset(40, 10),
      Offset(16, -14),
    ];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        for (var i = 0; i < positions.length; i++)
          Positioned(
            left: positions[i].dx,
            top: positions[i].dy,
            child: Opacity(
              opacity:
                  (math.sin((t + i / positions.length) * math.pi * 2) * 0.5 +
                          0.5)
                      .clamp(0.0, 1.0),
              child: Icon(Icons.auto_awesome, size: 8, color: accent),
            ),
          ),
      ],
    );
  }
}

typedef _Frame = ({
  double at,
  double dx,
  double dy,
  double sx,
  double sy,
  double deg,
});

const _rest = (at: 0.0, dx: 0.0, dy: 0.0, sx: 1.0, sy: 1.0, deg: 0.0);

/// Linear interpolation between the stylesheet's keyframes.
_Frame _sample(List<_Frame> frames, double t) {
  if (frames.isEmpty) return _rest;
  if (t <= frames.first.at) return frames.first;
  if (t >= frames.last.at) return frames.last;
  for (var i = 1; i < frames.length; i++) {
    final next = frames[i];
    if (t > next.at) continue;
    final prev = frames[i - 1];
    final span = next.at - prev.at;
    final k = span == 0 ? 0.0 : (t - prev.at) / span;
    double mix(double a, double b) => a + (b - a) * k;
    return (
      at: t,
      dx: mix(prev.dx, next.dx),
      dy: mix(prev.dy, next.dy),
      sx: mix(prev.sx, next.sx),
      sy: mix(prev.sy, next.sy),
      deg: mix(prev.deg, next.deg),
    );
  }
  return frames.last;
}

/// `@keyframes mfm-jump`
const _jumpFrames = <_Frame>[
  (at: 0, dx: 0, dy: 0, sx: 1, sy: 1, deg: 0),
  (at: 0.25, dx: 0, dy: -16, sx: 1, sy: 1, deg: 0),
  (at: 0.5, dx: 0, dy: 0, sx: 1, sy: 1, deg: 0),
  (at: 0.75, dx: 0, dy: -8, sx: 1, sy: 1, deg: 0),
  (at: 1, dx: 0, dy: 0, sx: 1, sy: 1, deg: 0),
];

/// `@keyframes mfm-bounce`
const _bounceFrames = <_Frame>[
  (at: 0, dx: 0, dy: 0, sx: 1, sy: 1, deg: 0),
  (at: 0.25, dx: 0, dy: -16, sx: 1, sy: 1, deg: 0),
  (at: 0.5, dx: 0, dy: 0, sx: 1, sy: 1, deg: 0),
  (at: 0.75, dx: 0, dy: 0, sx: 1.5, sy: 0.75, deg: 0),
  (at: 1, dx: 0, dy: 0, sx: 1, sy: 1, deg: 0),
];

/// `@keyframes mfm-twitch`
const _twitchFrames = <_Frame>[
  (at: 0, dx: 7, dy: -2, sx: 1, sy: 1, deg: 0),
  (at: 0.05, dx: -3, dy: 1, sx: 1, sy: 1, deg: 0),
  (at: 0.10, dx: -7, dy: -1, sx: 1, sy: 1, deg: 0),
  (at: 0.15, dx: 0, dy: -1, sx: 1, sy: 1, deg: 0),
  (at: 0.20, dx: -8, dy: 6, sx: 1, sy: 1, deg: 0),
  (at: 0.25, dx: -4, dy: -3, sx: 1, sy: 1, deg: 0),
  (at: 0.30, dx: -4, dy: -6, sx: 1, sy: 1, deg: 0),
  (at: 0.35, dx: -8, dy: -8, sx: 1, sy: 1, deg: 0),
  (at: 0.40, dx: 4, dy: 6, sx: 1, sy: 1, deg: 0),
  (at: 0.45, dx: -3, dy: 1, sx: 1, sy: 1, deg: 0),
  (at: 0.50, dx: 2, dy: -10, sx: 1, sy: 1, deg: 0),
  (at: 0.55, dx: -7, dy: 0, sx: 1, sy: 1, deg: 0),
  (at: 0.60, dx: -2, dy: 4, sx: 1, sy: 1, deg: 0),
  (at: 0.65, dx: 3, dy: -8, sx: 1, sy: 1, deg: 0),
  (at: 0.70, dx: 6, dy: 7, sx: 1, sy: 1, deg: 0),
  (at: 0.75, dx: -7, dy: -2, sx: 1, sy: 1, deg: 0),
  (at: 0.80, dx: -7, dy: -8, sx: 1, sy: 1, deg: 0),
  (at: 0.85, dx: 9, dy: 3, sx: 1, sy: 1, deg: 0),
  (at: 0.90, dx: -3, dy: -2, sx: 1, sy: 1, deg: 0),
  (at: 0.95, dx: -10, dy: 2, sx: 1, sy: 1, deg: 0),
  (at: 1, dx: -2, dy: -6, sx: 1, sy: 1, deg: 0),
];

/// `@keyframes mfm-shake`
const _shakeFrames = <_Frame>[
  (at: 0, dx: -3, dy: -1, sx: 1, sy: 1, deg: -8),
  (at: 0.05, dx: 0, dy: -1, sx: 1, sy: 1, deg: -10),
  (at: 0.10, dx: 1, dy: -3, sx: 1, sy: 1, deg: 0),
  (at: 0.15, dx: 1, dy: 1, sx: 1, sy: 1, deg: 11),
  (at: 0.20, dx: -2, dy: 1, sx: 1, sy: 1, deg: 1),
  (at: 0.25, dx: -1, dy: -2, sx: 1, sy: 1, deg: -2),
  (at: 0.30, dx: -1, dy: 2, sx: 1, sy: 1, deg: -3),
  (at: 0.35, dx: 2, dy: 1, sx: 1, sy: 1, deg: 6),
  (at: 0.40, dx: -2, dy: -3, sx: 1, sy: 1, deg: -9),
  (at: 0.45, dx: 0, dy: -1, sx: 1, sy: 1, deg: -12),
  (at: 0.50, dx: 1, dy: 2, sx: 1, sy: 1, deg: 10),
  (at: 0.55, dx: 0, dy: -3, sx: 1, sy: 1, deg: 8),
  (at: 0.60, dx: 1, dy: -1, sx: 1, sy: 1, deg: 8),
  (at: 0.65, dx: 0, dy: -1, sx: 1, sy: 1, deg: -7),
  (at: 0.70, dx: -1, dy: -3, sx: 1, sy: 1, deg: 6),
  (at: 0.75, dx: 0, dy: -2, sx: 1, sy: 1, deg: 4),
  (at: 0.80, dx: -2, dy: -1, sx: 1, sy: 1, deg: 3),
  (at: 0.85, dx: 1, dy: -3, sx: 1, sy: 1, deg: -10),
  (at: 0.90, dx: 1, dy: 0, sx: 1, sy: 1, deg: 3),
  (at: 0.95, dx: -2, dy: 0, sx: 1, sy: 1, deg: -3),
  (at: 1, dx: 2, dy: 1, sx: 1, sy: 1, deg: 2),
];

/// `@keyframes mfm-rubberBand` — the shape `$[jelly ...]` uses.
const _rubberFrames = <_Frame>[
  (at: 0, dx: 0, dy: 0, sx: 1, sy: 1, deg: 0),
  (at: 0.30, dx: 0, dy: 0, sx: 1.25, sy: 0.75, deg: 0),
  (at: 0.40, dx: 0, dy: 0, sx: 0.75, sy: 1.25, deg: 0),
  (at: 0.50, dx: 0, dy: 0, sx: 1.15, sy: 0.85, deg: 0),
  (at: 0.65, dx: 0, dy: 0, sx: 0.95, sy: 1.05, deg: 0),
  (at: 0.75, dx: 0, dy: 0, sx: 1.05, sy: 0.95, deg: 0),
  (at: 1, dx: 0, dy: 0, sx: 1, sy: 1, deg: 0),
];

/// `@keyframes global-tada`
const _tadaFrames = <_Frame>[
  (at: 0, dx: 0, dy: 0, sx: 1, sy: 1, deg: 0),
  (at: 0.10, dx: 0, dy: 0, sx: 0.91, sy: 0.91, deg: -2),
  (at: 0.20, dx: 0, dy: 0, sx: 0.91, sy: 0.91, deg: -2),
  (at: 0.30, dx: 0, dy: 0, sx: 1.09, sy: 1.09, deg: 2),
  (at: 0.50, dx: 0, dy: 0, sx: 1.09, sy: 1.09, deg: -2),
  (at: 0.70, dx: 0, dy: 0, sx: 1.09, sy: 1.09, deg: 2),
  (at: 0.90, dx: 0, dy: 0, sx: 1.09, sy: 1.09, deg: -2),
  (at: 1, dx: 0, dy: 0, sx: 1, sy: 1, deg: 0),
];
