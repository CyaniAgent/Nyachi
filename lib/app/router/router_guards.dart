// SPDX-License-Identifier: AGPL-3.0-or-later

import '../../core/auth/session_controller.dart';
import '../../features/settings/application/app_settings.dart';

String? authRedirect(SessionState session, String location) {
  if (!session.initialized) return null;
  final onLogin = location == '/login';
  if (!session.isAuthenticated) {
    return onLogin ? null : '/login';
  }
  return onLogin ? '/home' : null;
}

bool shouldFallbackToHome(NavConfig config, AppTab current) {
  return !config.visible.contains(current) && current != AppTab.home;
}
