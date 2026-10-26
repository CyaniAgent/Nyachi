// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Circular avatar with unified placeholder and error chrome.
///
/// Covers the app-wide avatar semantics: nullable URL with a fallback child,
/// optional online status dot, and an optional circular border ring.
class NyachiAvatar extends StatelessWidget {
  const NyachiAvatar({
    required this.url,
    this.size = 48,
    this.fallback,
    this.showStatus = false,
    this.statusRingColor,
    this.borderColor,
    this.borderWidth = 3,
    super.key,
  });

  final String? url;
  final double size;

  /// Shown inside the circle when [url] is null (an icon or a text glyph).
  /// Defaults to a person outline icon.
  final Widget? fallback;

  /// Draws the green online-status dot at the bottom-right corner.
  final bool showStatus;

  /// Border color around the status dot; defaults to the scaffold background.
  final Color? statusRingColor;

  /// Optional circular border ring (e.g. the profile page's surface ring).
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surfaceContainerHighest,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: url == null || url!.isEmpty
          ? (fallback ??
                Icon(
                  Icons.person_outline,
                  size: size * 0.5,
                  color: scheme.onSurfaceVariant,
                ))
          : CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  ColoredBox(color: scheme.surfaceContainerHighest),
              errorWidget: (_, _, _) => ColoredBox(
                color: scheme.surfaceContainerHighest,
                child: Icon(
                  Icons.person_outline,
                  size: size * 0.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
    );
    if (!showStatus) return avatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: size * 0.36,
            height: size * 0.36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF23A559),
              border: Border.all(
                color:
                    statusRingColor ??
                    Theme.of(context).scaffoldBackgroundColor,
                width: size * 0.09,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
