// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/app/router/router_guards.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/features/settings/application/app_settings.dart';

void main() {
  final account = LocalAccount(
    id: 'a',
    host: 'example.test',
    userId: 'u',
    username: 'u',
    addedAt: DateTime(2026),
    lastUsedAt: DateTime(2026),
  );

  test('unauthenticated routes redirect to login', () {
    const session = SessionState(accounts: [], active: null, initialized: true);
    expect(authRedirect(session, '/home'), '/login');
    expect(authRedirect(session, '/login'), isNull);
  });

  test('authenticated login redirects home', () {
    final session = SessionState(
      accounts: [account],
      active: account,
      initialized: true,
    );
    expect(authRedirect(session, '/login'), '/home');
    expect(authRedirect(session, '/notes/n1'), isNull);
  });

  test('hidden current tab falls back home', () {
    final config = defaultNavConfig().copyWith(
      visible: {AppTab.home, AppTab.explore},
    );
    expect(shouldFallbackToHome(config, AppTab.chat), isTrue);
    expect(shouldFallbackToHome(config, AppTab.home), isFalse);
  });
}
