// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Renders an image through a real DOM `<img>` element.
///
/// This is the fallback, not the normal path. Flutter's canvas renderer
/// fetches image bytes to decode pixels, and the browser only hands those over
/// when the host sends CORS headers; plenty of Misskey media hosts do not, so
/// an image the canvas pipeline refused still displays through the browser's
/// own loader. Every image attempts the Flutter pipeline first.
///
/// The element takes no pointer input at all: a DOM node painted over the
/// canvas would otherwise swallow taps meant for the Flutter widget behind it,
/// and an image inside a note is a tap target that opens the viewer.

/// The DOM fallback exists on this target.
const bool webImageSupported = true;

/// View types already registered, keyed by URL and fit; the registry throws on
/// a duplicate type, and each widget rebuild must not register a new one.
final _registered = <String>{};

/// Hosts whose images the canvas pipeline already refused.
///
/// The refusal is a property of the host's CORS policy, not of one URL, and
/// retrying it cannot succeed: without this, every rebuild of every image from
/// that host re-attempted the fetch, painted the placeholder again and logged
/// another policy error. Only cross-origin hosts are recorded — a same-origin
/// failure is about that one image, not about the instance's media at all.
final _refusedHosts = <String>{};

/// Whether images from [url]'s host already failed the canvas pipeline.
bool webImageOriginRefused(String url) =>
    _refusedHosts.contains(Uri.tryParse(url)?.host);

/// Records that [url] failed the canvas pipeline, so later images from the
/// same cross-origin host skip straight to the DOM fallback.
void webMarkImageOriginRefused(String url) {
  final uri = Uri.tryParse(url);
  final host = uri?.host;
  if (host == null || host.isEmpty || host == Uri.base.host) return;
  _refusedHosts.add(host);
}

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
        ..style.objectPosition = 'center'
        // The image is presentation only. Without this the node sits above the
        // canvas and eats the click, so a tap on a note image would never
        // reach the widget that opens the viewer.
        ..style.pointerEvents = 'none';
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
    child: HtmlElementView(
      viewType: viewType,
      // Pointer events fall through to the Flutter widgets behind, which is
      // where the tap targets live.
      hitTestBehavior: PlatformViewHitTestBehavior.transparent,
    ),
  );
}
