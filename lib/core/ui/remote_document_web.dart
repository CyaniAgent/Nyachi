// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Web fallback: no embedded WebView page (third-party sites commonly block
/// iframe embedding), so open a new browser tab instead.
Future<void> openRemoteDocument(
  BuildContext context, {
  required String title,
  required String url,
}) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
