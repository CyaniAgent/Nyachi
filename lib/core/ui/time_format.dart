// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'l10n_ext.dart';

String relativeTime(BuildContext context, DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return context.l10n.justNow;
  if (diff.inHours < 1) return context.l10n.minutesAgo(diff.inMinutes);
  if (diff.inDays < 1) return context.l10n.hoursAgo(diff.inHours);
  if (diff.inDays < 30) return context.l10n.daysAgo(diff.inDays);
  return DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
      .format(time);
}

String compactCount(BuildContext context, num value) {
  return NumberFormat.compact(
    locale: Localizations.localeOf(context).toLanguageTag(),
  ).format(value);
}
