// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/features/auth/application/compliance_controller.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app-level acceptance persists and restores', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(complianceControllerProvider.notifier);
    expect(container.read(complianceControllerProvider).appAccepted, isFalse);

    await controller.acceptAppTerms();
    expect(container.read(complianceControllerProvider).appAccepted, isTrue);

    // Rebuild the container against the same mock store: state restores.
    final rebuilt = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(rebuilt.dispose);
    expect(rebuilt.read(complianceControllerProvider).appAccepted, isTrue);
  });

  testWidgets('per-host acceptance is isolated between hosts', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(complianceControllerProvider.notifier);
    await controller.acceptInstanceForHost('misskey.io');

    expect(controller.isInstanceAccepted('misskey.io'), isTrue);
    expect(controller.isInstanceAccepted('other.tld'), isFalse);
    expect(container.read(complianceControllerProvider).instanceAcceptedHosts, {
      'misskey.io',
    });
  });

  testWidgets('per-host acceptance restores across containers', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(complianceControllerProvider.notifier)
        .acceptInstanceForHost('misskey.io');

    final rebuilt = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(rebuilt.dispose);
    expect(rebuilt.read(complianceControllerProvider).instanceAcceptedHosts, {
      'misskey.io',
    });
    expect(
      rebuilt
          .read(complianceControllerProvider.notifier)
          .isInstanceAccepted('misskey.io'),
      isTrue,
    );
  });
}
