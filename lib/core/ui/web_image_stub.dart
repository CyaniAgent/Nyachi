// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';

/// Non-web stub: the canvas renderer never has a CORS problem, so nothing
/// renders a DOM image there.
const bool webImageSupported = false;

Widget webImageFallback({
  required String url,
  double? width,
  double? height,
  BoxFit? fit,
}) => const SizedBox.shrink();

/// Non-web: nothing is ever refused.
bool webImageOriginRefused(String url) => false;

/// Non-web: nothing is ever refused, so there is nothing to record.
void webMarkImageOriginRefused(String url) {}
