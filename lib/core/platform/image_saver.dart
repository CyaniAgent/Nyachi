// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';

import 'image_saver_stub.dart'
    if (dart.library.io) 'image_saver_io.dart'
    if (dart.library.js_interop) 'image_saver_web.dart';

/// Outcome of a save attempt, used by callers to build their snackbar text.
class SaveImageResult {
  const SaveImageResult.saved(this.location) : failed = false;
  const SaveImageResult.failed(this.location) : failed = true;

  /// File path, browser download name, or an error description.
  final String location;
  final bool failed;
}

/// Downloads [url] and hands the bytes to the platform-specific saver.
///
/// Web triggers a browser download; desktop and mobile write to the user's
/// Downloads directory (falling back to app documents when unavailable).
Future<SaveImageResult> saveImageFromUrl(
  String url, {
  required String fileName,
}) async {
  try {
    final response = await Dio().get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      return const SaveImageResult.failed('empty response');
    }
    final saved = await saveImageBytes(bytes, fileName);
    return SaveImageResult.saved(saved);
  } catch (error) {
    return SaveImageResult.failed(error.toString());
  }
}

/// Builds a safe file name for a remote image URL.
String imageFileName(String url, String id) {
  final path = Uri.tryParse(url)?.pathSegments ?? const <String>[];
  final raw = path.isEmpty ? '' : path.last;
  final ext = RegExp(r'\.([a-zA-Z0-9]{2,5})$').firstMatch(raw)?.group(1);
  return 'nyachi-$id.${ext ?? 'jpg'}';
}
