// SPDX-License-Identifier: AGPL-3.0-or-later

/// Fallback used when no platform-specific implementation is selected.
Future<String> saveImageBytes(List<int> bytes, String fileName) async {
  throw UnsupportedError('Image saving is not supported on this platform.');
}
