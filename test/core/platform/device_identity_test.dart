// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/platform/device_identity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('the install id is created once and then reused', () async {
    final prefs = await SharedPreferences.getInstance();

    final first = await DeviceIdentity.installId(prefs);
    final second = await DeviceIdentity.installId(prefs);

    // A changing id would make every login look like a new device and defeat
    // the point of naming them apart.
    expect(first, isNotEmpty);
    expect(second, first);
    expect(prefs.getString(DeviceIdentity.installIdKey), first);
  });

  test('the client name carries the platform and a short id', () async {
    final prefs = await SharedPreferences.getInstance();
    final id = await DeviceIdentity.installId(prefs);

    final name = DeviceIdentity.clientName(id);

    // 8 hex characters: enough to tell two installs apart in a permission
    // dialog, short enough to read there.
    final short = id.replaceAll('-', '').substring(0, 8);
    expect(name, 'Nyachi (${DeviceIdentity.platformLabel()} · $short)');
    expect(name, contains(short));
  });

  test('the name is stable across calls', () async {
    final prefs = await SharedPreferences.getInstance();

    expect(
      await DeviceIdentity.clientNameFor(prefs),
      await DeviceIdentity.clientNameFor(prefs),
    );
  });

  test('the platform label names the running platform', () {
    expect(DeviceIdentity.platformLabel(), switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    });
  });
}
