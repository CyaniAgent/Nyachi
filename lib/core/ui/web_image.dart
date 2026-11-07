// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';

import 'web_image_stub.dart' if (dart.library.js_interop) 'web_image_web.dart';

/// Whether a CORS failure on this target can be worked around with a DOM
/// image. Only the web renderer fetches pixels; everywhere else a failed image
/// is a genuine network failure, not a policy refusal.
bool get hasDomImageFallback => webImageSupported;

/// Renders [url] through the browser's own image loader (web only); an empty
/// box on other targets.
Widget domImage({
  required String url,
  double? width,
  double? height,
  BoxFit? fit,
}) => webImageFallback(url: url, width: width, height: height, fit: fit);

/// Whether [url] must skip the canvas path entirely.
///
/// A cross-origin image cannot be fetched for decoding unless the host sends
/// CORS headers, and most Misskey media hosts do not. Loading it through the
/// canvas first would therefore fail every time and log a policy error before
/// the DOM fallback ran, so cross-origin images go straight to the browser.
bool needsDomImage(String url) => webImageSupported && webIsCrossOrigin(url);
