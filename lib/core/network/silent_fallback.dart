// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';

/// Logs a data-layer fallback that would otherwise fail silently.
/// Debug-only: release builds keep the original silent behavior.
void logSilentFallback(String site, Object error) {
  if (kDebugMode) debugPrint('[silent-fallback] $site: $error');
}
