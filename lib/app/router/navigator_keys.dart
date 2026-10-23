// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';

/// Navigator that hosts authenticated routes inside the persistent shell.
///
/// Detail, settings, and chat routes set this as their `$parentNavigatorKey`
/// so they are pushed above the tab body without covering the navigation rail.
final GlobalKey<NavigatorState> appShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'app-shell');
