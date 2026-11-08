// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';

import 'web_image_stub.dart' if (dart.library.js_interop) 'web_image_web.dart';

/// Whether this target can render an image through a DOM `<img>` at all.
///
/// Only the web renderer has the CORS problem the fallback exists for; on
/// every other target a failed image is a genuine network failure.
bool get hasDomImageFallback => webImageSupported;

/// Renders [url] through the browser's own image loader (web only); an empty
/// box on other targets.
///
/// Reserve this for images the Flutter pipeline could not decode — it is the
/// fallback, and it costs a platform view per URL.
Widget domImage({
  required String url,
  double? width,
  double? height,
  BoxFit? fit,
}) => webImageFallback(url: url, width: width, height: height, fit: fit);

/// Whether the canvas pipeline already refused images from [url]'s origin, in
/// which case there is nothing to retry.
bool imageOriginRefused(String url) =>
    webImageSupported && webImageOriginRefused(url);

/// Records that [url] could not be decoded by the canvas pipeline.
void markImageOriginRefused(String url) {
  if (!webImageSupported) return;
  webMarkImageOriginRefused(url);
}
