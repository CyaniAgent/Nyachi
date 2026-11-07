// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Renders an image through a real DOM `<img>` element.
///
/// Flutter's canvas renderer fetches image bytes to decode pixels, which the
/// browser only allows when the host sends CORS headers. Plenty of Misskey
/// media hosts do not, so those images fail even though a plain `<img>` would
/// display them fine. This fallback hands the URL to the browser instead.

/// The DOM fallback exists on this target.
const bool webImageSupported = true;

/// Whether [url] comes from a different origin than the page.
///
/// Relative URLs are the page's own origin by definition; a host that differs
/// from the document's cannot be read back through the canvas without CORS.
bool webIsCrossOrigin(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return false;
  return uri.host != Uri.base.host;
}

/// View types already registered, keyed by URL and fit; the registry throws on
/// a duplicate type, and each widget rebuild must not register a new one.
final _registered = <String>{};

String _cssFit(BoxFit? fit) => switch (fit) {
  BoxFit.contain => 'contain',
  BoxFit.cover => 'cover',
  BoxFit.fill => 'fill',
  BoxFit.fitWidth => 'scale-down',
  BoxFit.fitHeight => 'scale-down',
  BoxFit.none => 'none',
  BoxFit.scaleDown || null => 'scale-down',
};

/// A DOM-backed image that bypasses CORS, or an empty box on non-web targets.
Widget webImageFallback({
  required String url,
  double? width,
  double? height,
  BoxFit? fit,
}) {
  final viewType = 'nyachi-img-${url.hashCode}-${_cssFit(fit)}';
  if (_registered.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
      final img = web.HTMLImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = _cssFit(fit)
        ..style.objectPosition = 'center';
      // A broken URL must leave the surrounding chrome visible instead of
      // painting the browser's broken-image glyph.
      img.addEventListener(
        'error',
        (web.Event _) {
          img.style.visibility = 'hidden';
        }.toJS,
      );
      return img;
    });
  }
  return SizedBox(
    width: width,
    height: height,
    child: HtmlElementView(viewType: viewType),
  );
}
