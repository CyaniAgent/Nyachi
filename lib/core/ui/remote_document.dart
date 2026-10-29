// SPDX-License-Identifier: AGPL-3.0-or-later

library;

/// Opens a remote document (instance ToS / privacy / impressum, links inside
/// compliance docs) inside the app. Native platforms render an embedded
/// WebView; the web build falls back to opening a new browser tab, keeping
/// `flutter build web` green.
export 'remote_document_io.dart'
    if (dart.library.js_interop) 'remote_document_web.dart';
