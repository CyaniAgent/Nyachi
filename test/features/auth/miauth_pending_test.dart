// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/features/auth/application/login_controller.dart';

void main() {
  test('unapproved MiAuth checks are treated as pending', () {
    expect(
      isMiAuthPending(MisskeyApiException('not found', statusCode: 404)),
      isTrue,
    );
    expect(
      isMiAuthPending(
        MisskeyApiException(
          'failed to parse',
          statusCode: 200,
          raw: const {'ok': false},
        ),
      ),
      isTrue,
    );
    expect(
      isMiAuthPending(MisskeyApiException('server error', statusCode: 500)),
      isFalse,
    );
  });

  test('the MiAuth grant covers every scope the app writes with', () {
    // A missing scope is invisible at sign-in and surfaces much later as a
    // bare 403 on the feature that needed it — `write:votes` broke voting
    // exactly that way, and `write:notes` does not imply it.
    expect(miAuthPermissions, contains('write:votes'));
    expect(miAuthPermissions, contains('write:favorites'));
    expect(miAuthPermissions, contains('write:account'));
    expect(miAuthPermissions, contains('write:report-abuse'));
    expect(miAuthPermissions, contains('read:drive'));
    expect(miAuthPermissions, contains('write:drive'));

    // Scopes are grouped read/write, never a bare group name.
    for (final permission in miAuthPermissions) {
      expect(permission, matches(RegExp(r'^(read|write):')));
    }
  });

  test('the basic grant is a strict subset and still posts', () {
    expect(miAuthBasicPermissions, contains('write:notes'));
    expect(miAuthBasicPermissions, contains('read:notes'));
    expect(miAuthBasicPermissions, isNot(contains('write:votes')));
    expect(
      miAuthPermissions.toSet().containsAll(miAuthBasicPermissions),
      isTrue,
    );
  });
}
