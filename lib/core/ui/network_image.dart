// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'web_image.dart';

/// Network image with unified placeholder and error chrome.
///
/// All in-app remote images go through this widget (or [nyachiImageProvider])
/// so caching, placeholder, and failure states stay consistent.
///
/// On the web the canvas renderer fetches pixels, and a host without CORS
/// headers refuses that fetch; the error branch therefore re-renders through a
/// DOM `<img>` ([domImage]) so the picture still shows. Other targets keep the
/// plain failure chrome, where a failed load is a genuine network failure.
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
    // Cross-origin images cannot be decoded through the canvas at all, so ask
    // the browser instead of trying and failing first.
    if (needsDomImage(url)) {
      return Stack(
        children: [
          ColoredBox(color: scheme.surfaceContainerHighest),
          domImage(url: url, width: width, height: height, fit: fit),
        ],
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) => ColoredBox(color: scheme.surfaceContainerHighest),
      errorWidget: (_, _, _) {
        if (hasDomImageFallback) {
          return domImage(url: url, width: width, height: height, fit: fit);
        }
        return ColoredBox(
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.wifi_off, color: scheme.onSurfaceVariant),
        );
      },
    );
  }
}

/// [ImageProvider] variant for places that need a provider instead of a
/// widget (e.g. `CircleAvatar.backgroundImage`, `DecorationImage`).
ImageProvider<Object> nyachiImageProvider(String url) =>
    CachedNetworkImageProvider(url);
