// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Writes [bytes] into the user's Downloads directory.
///
/// Falls back to the app documents directory when the platform has no
/// Downloads folder (mobile), returning the absolute path that was written.
Future<String> saveImageBytes(List<int> bytes, String fileName) async {
  final dir = await _targetDirectory();
  final file = File('${dir.path}${Platform.pathSeparator}$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

Future<Directory> _targetDirectory() async {
  try {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) return downloads;
  } catch (_) {
    // Platform has no Downloads directory; use the documents directory.
  }
  return getApplicationDocumentsDirectory();
}
