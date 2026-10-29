// SPDX-License-Identifier: AGPL-3.0-or-later

import '../../core/auth/session_controller.dart';
import '../../features/settings/application/app_settings.dart';

/// Route guard rules:
/// - session not initialized yet → no redirect;
/// - on `/oobe` while completed → release to `/home` (authenticated) or
///   `/login` (unauthenticated), otherwise stay;
/// - OOBE not completed → pin every route to `/oobe`, authenticated or not
///   (a login finished mid-OOBE must still walk the remaining steps);
/// - otherwise the classic login rules apply.
String? authRedirect(
  SessionState session,
  String location, {
  required bool oobeCompleted,
}) {
  if (!session.initialized) return null;
  if (location == '/oobe') {
    if (!oobeCompleted) return null;
    return session.isAuthenticated ? '/home' : '/login';
  }
  if (!oobeCompleted) return '/oobe';
  final onLogin = location == '/login';
  if (!session.isAuthenticated) {
    return onLogin ? null : '/login';
  }
  return onLogin ? '/home' : null;
}

bool shouldFallbackToHome(NavConfig config, AppTab current) {
  return !config.visible.contains(current) && current != AppTab.home;
}
