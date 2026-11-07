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

/// The animation a `MfmFn` asks for, resolved from its name and arguments.
class MfmEffectSpec {
  const MfmEffectSpec(
    this.effect,
    this.motionClass, {
    this.period = const Duration(seconds: 1),
    this.reverseX = false,
    this.reverseY = false,
    this.alternate = false,
    this.scale = 1,
  });

  final MfmEffect effect;
  final MfmMotionClass motionClass;
  final Duration period;
  final bool reverseX;
  final bool reverseY;
  final bool alternate;
  final double scale;
}

enum MfmEffect {
  none,
  jump,
  bounce,
  shake,
  twitch,
  jelly,
  spin,
  rainbow,
  tada,
  jackOLantern,
  blur,
  sparkle,
}

/// Resolves an MFM function to an effect, or null when the function is not a
/// motion at all (unknown names, `fg.color`, `font.serif`, …).
MfmEffectSpec? mfmEffectOf(MfmFn node) {
  final args = node.args;
  final fast = args['fast'] == true;
  final slow = args['slow'] == true;
  final period = Duration(milliseconds: fast ? 400 : (slow ? 2400 : 1200));
  switch (node.name) {
    case 'jump':
      return MfmEffectSpec(
        MfmEffect.jump,
        MfmMotionClass.translate,
        period: period,
      );
    case 'bounce':
      return MfmEffectSpec(
        MfmEffect.bounce,
        MfmMotionClass.translate,
        period: period,
      );
    case 'shake':
    case 'twitch':
      return MfmEffectSpec(
        args['twitch'] == true ? MfmEffect.twitch : MfmEffect.shake,
        MfmMotionClass.translate,
        period: Duration(milliseconds: fast ? 200 : 600),
      );
    case 'jelly':
      return MfmEffectSpec(
        MfmEffect.jelly,
        MfmMotionClass.translate,
        period: period,
      );
    case 'spin':
      return MfmEffectSpec(
        MfmEffect.spin,
        MfmMotionClass.rotate,
        period: period,
        reverseX: args['left'] == true,
        alternate: args['alternate'] == true,
      );
    case 'rainbow':
      return MfmEffectSpec(
        MfmEffect.rainbow,
        MfmMotionClass.color,
        period: period,
        alternate: args['alt'] == true,
      );
    case 'tada':
      return MfmEffectSpec(
        MfmEffect.tada,
        MfmMotionClass.color,
        period: period,
      );
    case 'jack-o-lantern':
      return MfmEffectSpec(
        MfmEffect.jackOLantern,
        MfmMotionClass.color,
        period: period,
      );
    case 'blur':
      return MfmEffectSpec(MfmEffect.blur, MfmMotionClass.flicker);
    case 'sparkle':
      return MfmEffectSpec(
        MfmEffect.sparkle,
        MfmMotionClass.flicker,
        period: period,
      );
    default:
      return null;
  }
}

/// Size multiplier for the static `x2`/`x3`/`x4`/`x6` functions.
double? mfmScaleFactor(MfmFn node) => switch (node.name) {
  'x2' => 2,
  'x3' => 3,
  'x4' => 4,
  'x6' => 6,
  _ => null,
};

/// Colours an `fg.color`/`bg.color`/`fg.hex` argument names, or null when the
/// argument is not a colour this build understands.
Color? mfmParseColor(Object? raw) {
  if (raw is! String) return null;
  final value = raw.trim().toLowerCase();
  const named = {
    'red': 0xFFF44336,
    'pink': 0xFFE91E63,
    'purple': 0xFF9C27B0,
    'deep-purple': 0xFF673AB7,
    'indigo': 0xFF3F51B5,
    'blue': 0xFF2196F3,
    'light-blue': 0xFF03A9F4,
    'cyan': 0xFF00BCD4,
    'teal': 0xFF009688,
    'green': 0xFF4CAF50,
    'light-green': 0xFF8BC34A,
    'lime': 0xFFCDDC39,
    'yellow': 0xFFFFEB3B,
    'amber': 0xFFFFC107,
    'orange': 0xFFFF9800,
    'deep-orange': 0xFFFF5722,
    'brown': 0xFF795548,
    'grey': 0xFF9E9E9E,
    'blue-grey': 0xFF607D8B,
    'white': 0xFFFFFFFF,
    'black': 0xFF000000,
  };
  final direct = named[value];
  if (direct != null) return Color(direct);
  if (value.startsWith('#') && (value.length == 7 || value.length == 4)) {
    final hex = value.substring(1);
    if (hex.length == 6) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) return Color(0xFF000000 | parsed);
    } else {
      final expanded = hex.split('').map((c) => '$c$c').join();
      final parsed = int.tryParse(expanded, radix: 16);
      if (parsed != null) return Color(0xFF000000 | parsed);
    }
  }
  return null;
}

/// Renders [children] with [effect] applied, repainting only this subtree.
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
    duration: widget.spec.period,
  )..repeat(reverse: widget.spec.alternate);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final wave = math.sin(t * math.pi * 2);
        Widget text(TextStyle? style) => RichText(
          textAlign: widget.textAlign ?? TextAlign.start,
          text: TextSpan(
            style: style ?? widget.style,
            children: widget.children,
          ),
        );
        switch (spec.effect) {
          case MfmEffect.none:
            return text(null);
          case MfmEffect.jump:
            return Transform.translate(
              offset: Offset(0, -3 * wave),
              child: text(null),
            );
          case MfmEffect.bounce:
            return Transform.translate(
              offset: Offset(0, -3 * wave.abs()),
              child: text(null),
            );
          case MfmEffect.shake:
            return Transform.translate(
              offset: Offset(1.5 * wave, 0),
              child: text(null),
            );
          case MfmEffect.twitch:
            // A square wave reads as a twitch; a sine reads as a sway.
            return Transform.translate(
              offset: Offset(t < 0.5 ? 2 : -2, 0),
              child: text(null),
            );
          case MfmEffect.jelly:
            return Transform.scale(
              scaleX: 1 + 0.05 * wave,
              scaleY: 1 - 0.05 * wave,
              child: text(null),
            );
          case MfmEffect.spin:
            return Transform.rotate(
              angle: (spec.reverseX ? -1 : 1) * t * math.pi * 2,
              child: text(null),
            );
          case MfmEffect.rainbow:
          case MfmEffect.tada:
          case MfmEffect.jackOLantern:
            final base =
                widget.style?.color ?? DefaultTextStyle.of(context).style.color;
            final hsl = HSLColor.fromColor(
              spec.effect == MfmEffect.jackOLantern
                  ? const Color(0xFFFF9800)
                  : (base ?? Colors.black),
            );
            final hue = spec.effect == MfmEffect.jackOLantern
                ? (30 + 8 * wave) % 360
                : (hsl.hue + t * 360) % 360;
            final animated = hsl.withHue(hue).toColor();
            final child = text(
              (widget.style ?? const TextStyle()).copyWith(color: animated),
            );
            return spec.effect == MfmEffect.tada
                ? Transform.rotate(angle: 0.02 * wave, child: child)
                : child;
          case MfmEffect.blur:
            return _blurred(text(null));
          case MfmEffect.sparkle:
            return Opacity(
              opacity: 0.55 + 0.45 * wave.abs(),
              child: text(null),
            );
        }
      },
    );
  }

  /// Blur is an interaction rather than a cycle — it stays blurred until the
  /// reader touches it — so this shape is also the static equivalent.
  Widget _blurred(Widget child) => GestureDetector(
    onTapDown: (_) => _controller.stop(),
    onTapUp: (_) => _controller.repeat(),
    onTapCancel: () => _controller.repeat(),
    child: ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: child,
    ),
  );
}
