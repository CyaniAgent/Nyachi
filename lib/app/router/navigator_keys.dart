// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';

/// Navigator that hosts authenticated routes inside the persistent shell.
///
/// Detail, settings, and chat routes set this as their `$parentNavigatorKey`
/// so they are pushed above the tab body without covering the navigation rail.
/// Settings is treated as a tab root by the detail-panel machinery, so its
/// sub-pages open beside the settings list instead of replacing it.
final GlobalKey<NavigatorState> appShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'app-shell');
