// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/features/settings/application/app_settings.dart';

void main() {
  test('sanitize keeps every tab once and forces home visible', () {
    final config = sanitizeNavConfig(
      const NavConfig(
        order: [AppTab.profile, AppTab.profile, AppTab.chat],
        visible: {AppTab.notifications},
      ),
    );

    expect(config.order.toSet(), AppTab.values.toSet());
    expect(config.order, hasLength(AppTab.values.length));
    expect(config.visible, contains(AppTab.home));
  });

  test('hiding and reordering retains all destinations', () {
    final config = sanitizeNavConfig(
      NavConfig(
        order: [AppTab.profile, AppTab.explore, AppTab.home],
        visible: {AppTab.profile, AppTab.home},
      ),
    );

    expect(config.order.first, AppTab.profile);
    expect(config.visible, {AppTab.home, AppTab.profile});
    expect(config.order.toSet(), AppTab.values.toSet());
  });
}
