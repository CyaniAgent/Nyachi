// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Identifies this installation to a server the user connects to.
///
/// Misskey lists every authorized client by the name the app supplies, so a
/// constant "Nyachi" turns the account's app list into a row of identical
/// entries: a user with a phone and two desktops cannot tell them apart, and
/// therefore cannot revoke just one. A per-install random id makes each entry
/// distinct.
///
/// The id is drawn locally and never derived from the machine: a hardware
/// identifier (Windows `MachineGuid`, Android `ANDROID_ID`) would leak a
/// stable device fingerprint to whichever instance the user signs into.
abstract final class DeviceIdentity {
  static const installIdKey = 'app.installId';

  /// Short enough to read in a permission dialog, long enough that two
  /// installs of the same app are not likely to collide (32 bits).
  static const shortIdLength = 8;

  /// A platform name a person recognises. Web has no `Platform`, and the
  /// browser cannot tell which OS it runs on precisely enough to be useful,
  /// so it reports itself.
  static String platformLabel() {
    if (kIsWeb) return 'Web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
  }

  /// The installation's id, creating and persisting it on first use.
  static Future<String> installId(SharedPreferences prefs) async {
    final existing = prefs.getString(installIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    // A plain v4 UUID: random, so it says nothing about the machine.
    final created = const Uuid().v4();
    await prefs.setString(installIdKey, created);
    return created;
  }

  /// The MFM-independent client name shown in Misskey's app list, e.g.
  /// `Nyachi (Windows · 3f2a1b8c)`.
  static String clientName(String installId) {
    final short = installId.replaceAll('-', '');
    final suffix = short.length <= shortIdLength
        ? short
        : short.substring(0, shortIdLength);
    return 'Nyachi (${platformLabel()} · $suffix)';
  }

  /// Reads or creates the id and builds the name in one step.
  static Future<String> clientNameFor(SharedPreferences prefs) async =>
      clientName(await installId(prefs));
}
