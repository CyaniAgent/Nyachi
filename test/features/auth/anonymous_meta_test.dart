// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/auth/session_controller.dart';

// No network in this suite: the provider is exercised only up to the point
// where host normalization decides whether a client is constructed. Fetch
// behaviour is covered by widget tests overriding [anonymousMetaProvider].

void main() {
  test('host variants normalize to the same provider parameter', () {
    // Uppercase, path suffix, and missing scheme all collapse to one value —
    // this is the value callers pass into anonymousMetaProvider so family
    // cache keys stay stable.
    expect(normalizeHost('HTTPS://MissKey.IO/'), 'misskey.io');
    expect(normalizeHost('misskey.io'), 'misskey.io');
    expect(normalizeHost('https://misskey.io/about'), 'misskey.io');
  });

  test('invalid host fails before any client is built', () {
    expect(() => normalizeHost(''), throwsFormatException);
  });
}
