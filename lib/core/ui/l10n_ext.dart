// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import '../network/error_mapper.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Localized user-facing message for a failure kind.
extension AppFailureL10n on AppFailure {
  String message(AppLocalizations l10n) => switch (kind) {
    AppFailureKind.auth => l10n.errorAuth,
    AppFailureKind.rateLimit => l10n.errorRateLimit,
    AppFailureKind.server => l10n.errorServer,
    AppFailureKind.network => l10n.errorNetwork,
    AppFailureKind.storage => l10n.errorStorage,
    AppFailureKind.unknown => l10n.errorGeneric,
  };
}
