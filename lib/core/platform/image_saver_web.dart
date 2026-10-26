// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Triggers a browser download for [bytes] and returns the file name.
Future<String> saveImageBytes(List<int> bytes, String fileName) async {
  final data = Uint8List.fromList(bytes).toJS;
  final blob = web.Blob([data].toJS, web.BlobPropertyBag(type: 'image/*'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName;
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return fileName;
}
