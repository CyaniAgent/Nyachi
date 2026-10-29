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
    expect(authRedirect(session, '/home', oobeCompleted: true), '/login');
    expect(authRedirect(session, '/login', oobeCompleted: true), isNull);
  });

  test('authenticated login redirects home', () {
    final session = SessionState(
      accounts: [account],
      active: account,
      initialized: true,
    );
    expect(authRedirect(session, '/login', oobeCompleted: true), '/home');
    expect(authRedirect(session, '/notes/n1', oobeCompleted: true), isNull);
  });

  test('uninitialized session never redirects', () {
    const session = SessionState(
      accounts: [],
      active: null,
      initialized: false,
    );
    expect(authRedirect(session, '/home', oobeCompleted: false), isNull);
    expect(authRedirect(session, '/oobe', oobeCompleted: true), isNull);
  });

  test('on /oobe when completed releases by authentication', () {
    final authed = SessionState(
      accounts: [account],
      active: account,
      initialized: true,
    );
    expect(authRedirect(authed, '/oobe', oobeCompleted: true), '/home');
    expect(
      authRedirect(
        const SessionState(accounts: [], active: null, initialized: true),
        '/oobe',
        oobeCompleted: true,
      ),
      '/login',
    );
  });

  test('on /oobe while incomplete stays', () {
    const unauthed = SessionState(
      accounts: [],
      active: null,
      initialized: true,
    );
    expect(authRedirect(unauthed, '/oobe', oobeCompleted: false), isNull);
    expect(
      authRedirect(
        SessionState(accounts: [account], active: account, initialized: true),
        '/oobe',
        oobeCompleted: false,
      ),
      isNull,
    );
  });

  test('incomplete OOBE pins every other route', () {
    const unauthed = SessionState(
      accounts: [],
      active: null,
      initialized: true,
    );
    expect(authRedirect(unauthed, '/home', oobeCompleted: false), '/oobe');
    expect(authRedirect(unauthed, '/login', oobeCompleted: false), '/oobe');
    expect(
      authRedirect(
        SessionState(accounts: [account], active: account, initialized: true),
        '/home',
        oobeCompleted: false,
      ),
      '/oobe',
    );
  });

  test('hidden current tab falls back home', () {
    final config = defaultNavConfig().copyWith(
      visible: {AppTab.home, AppTab.explore},
    );
    expect(shouldFallbackToHome(config, AppTab.chat), isTrue);
    expect(shouldFallbackToHome(config, AppTab.home), isFalse);
  });
}
