// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Network image with unified placeholder and error chrome.
///
/// All in-app remote images go through this widget (or [nyachiImageProvider])
/// so caching, placeholder, and failure states stay consistent.
class NyachiImage extends StatelessWidget {
  const NyachiImage({
    required this.url,
    this.width,
    this.height,
    this.fit,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) => ColoredBox(color: scheme.surfaceContainerHighest),
      errorWidget: (_, _, _) => ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.wifi_off, color: scheme.onSurfaceVariant),
      ),
    );
  }
}

/// [ImageProvider] variant for places that need a provider instead of a
/// widget (e.g. `CircleAvatar.backgroundImage`, `DecorationImage`).
ImageProvider<Object> nyachiImageProvider(String url) =>
    CachedNetworkImageProvider(url);
