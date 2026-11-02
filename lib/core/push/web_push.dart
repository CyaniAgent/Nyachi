// SPDX-License-Identifier: AGPL-3.0-or-later

library;

/// Web Push helpers, resolved per platform at compile time.
///
/// The web implementation drives the browser's Push API; every other target
/// gets one that reports [pushSupported] false and refuses to register, so
/// callers never need a platform check of their own.
export 'web_push_io.dart' if (dart.library.js_interop) 'web_push_web.dart';
