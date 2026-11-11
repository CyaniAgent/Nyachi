// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nyachi/features/admin/presentation/admin_announcements_page.dart';
import 'package:nyachi/features/admin/presentation/admin_content_page.dart';
import 'package:nyachi/features/admin/presentation/admin_instance_page.dart';
import 'package:nyachi/features/admin/presentation/admin_invites_page.dart';
import 'package:nyachi/features/admin/presentation/admin_reports_page.dart';
import 'package:nyachi/features/admin/presentation/admin_system_page.dart';
import 'package:nyachi/features/admin/presentation/admin_users_page.dart';
import 'package:nyachi/app/router/navigator_keys.dart';
import 'package:nyachi/app/router/routes.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/drive/presentation/drive_page.dart';
import 'package:nyachi/features/settings/presentation/cache_page.dart';
import 'package:nyachi/features/settings/presentation/drive_settings_page.dart';
import 'package:nyachi/features/settings/presentation/email_settings_page.dart';
import 'package:nyachi/features/settings/presentation/licenses_page.dart';
import 'package:nyachi/features/settings/presentation/notification_settings_page.dart';
import 'package:nyachi/features/settings/presentation/profile_edit_page.dart';
import 'package:nyachi/features/settings/presentation/push_settings_page.dart';
import 'package:nyachi/features/settings/presentation/privacy_settings_page.dart';
import 'package:nyachi/features/settings/presentation/security_settings_page.dart';
import 'package:nyachi/features/settings/presentation/settings_page.dart';
import 'package:nyachi/features/shell/presentation/root_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every settings destination reachable from [SettingsPage] tiles must resolve
/// to a real GoRouter route, both for the wide-screen detail panel (which
/// pushes the location through the router when the panel cannot host it) and
/// for narrow-window navigation. A missing registration renders the
/// router's not-found page instead.
void main() {
  final cases = <String, Type>{
    '/settings': SettingsPage,
    '/settings/accounts': AccountsSettingsPage,
    '/settings/navigation': NavigationSettingsPage,
    '/settings/appearance': AppearanceSettingsPage,
    '/settings/about': AboutSettingsPage,
    '/settings/cache': CacheSettingsPage,
    '/settings/licenses': LicensesPage,
    '/settings/drive': DrivePage,
    '/settings/profile': ProfileEditPage,
    '/settings/privacy': PrivacySettingsPage,
    '/settings/notifications': NotificationSettingsPage,
    '/settings/email': EmailSettingsPage,
    '/settings/security': SecuritySettingsPage,
    '/settings/drive-settings': DriveSettingsPage,
    '/settings/push': PushSettingsPage,
    '/settings/admin-reports': AdminReportsPage,
    '/settings/admin-users': AdminUsersPage,
    '/settings/admin-content': AdminContentPage,
    '/settings/admin-announcements': AdminAnnouncementsPage,
    '/settings/admin-instance': AdminInstancePage,
    '/settings/admin-system': AdminSystemPage,
    '/settings/admin-invites': AdminInvitesPage,
  };

  for (final entry in cases.entries) {
    testWidgets('router resolves ${entry.key} to ${entry.value}', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          ShellRoute(
            navigatorKey: appShellNavigatorKey,
            builder: (context, state, child) =>
                RootShell(uri: state.uri, child: child),
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const Scaffold(body: Text('home')),
              ),
              ...$appRoutes,
            ],
          ),
        ],
        errorBuilder: (context, state) => const Scaffold(
          key: Key('router-not-found'),
          body: SizedBox.shrink(),
        ),
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
          child: MaterialApp.router(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();

      router.go(entry.key);
      // Pump a bounded number of frames instead of pumpAndSettle: some pages
      // start async fetches whose retry timers would never settle.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byType(entry.value),
        findsOneWidget,
        reason: '${entry.key} must resolve to ${entry.value}',
      );
      expect(
        find.byKey(const Key('router-not-found')),
        findsNothing,
        reason: '${entry.key} must not render the not-found page',
      );
    });
  }
}
