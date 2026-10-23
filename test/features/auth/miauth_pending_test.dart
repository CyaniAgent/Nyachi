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
}
