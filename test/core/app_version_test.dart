// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/update/app_version.dart';

void main() {
  group('version ordering', () {
    test('a beta is older than the release it leads to', () {
      expect(compareVersions('2.0.0-beta.9', '2.0.0'), lessThan(0));
      expect(compareVersions('2.0.0', '2.0.0-beta.9'), greaterThan(0));
    });

    test('beta numbers compare numerically, not as text', () {
      // The trap: as strings, beta.10 sorts before beta.9.
      expect(compareVersions('2.0.0-beta.9', '2.0.0-beta.10'), lessThan(0));
      expect(compareVersions('2.0.0-beta.10', '2.0.0-beta.9'), greaterThan(0));
    });

    test('the build suffix does not affect ordering', () {
      expect(compareVersions('2.0.0-beta.9+7', '2.0.0-beta.9'), 0);
      expect(compareVersions('2.0.0-beta.9+8', '2.0.0-beta.9+7'), 0);
    });

    test('core versions compare component by component', () {
      expect(compareVersions('2.0.0', '2.1.0'), lessThan(0));
      expect(compareVersions('2.10.0', '2.9.0'), greaterThan(0));
      expect(compareVersions('1.9.0', '2.0.0'), lessThan(0));
    });

    test('equal versions compare equal', () {
      expect(compareVersions('2.0.0-beta.9', '2.0.0-beta.9'), 0);
    });
  });
}
