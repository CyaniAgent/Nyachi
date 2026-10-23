// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/app/detail_panel/detail_location.dart';
import 'package:nyachi/app/detail_panel/detail_panel_controller.dart';
import 'package:nyachi/app/theme/app_theme.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('manages the stack and persists width', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final controller = container.read(detailPanelControllerProvider.notifier);
    DetailPanelState state() => container.read(detailPanelControllerProvider);

    expect(state().width, 480);

    controller.replaceStack(const NoteDetailLocation('n1'));
    expect(state().stack, [const NoteDetailLocation('n1')]);

    controller.push(const UserDetailLocation('u1'));
    expect(state().stack, [
      const NoteDetailLocation('n1'),
      const UserDetailLocation('u1'),
    ]);

    controller.push(const UserDetailLocation('u1'));
    expect(state().stack.length, 2);

    controller.pop();
    expect(state().top, const NoteDetailLocation('n1'));

    controller.close();
    expect(state().isOpen, isFalse);

    controller.setWidth(100);
    expect(state().width, appDetailPanelMinWidth);
    controller.setWidth(2000);
    expect(state().width, appDetailPanelMaxWidth);

    controller.setWidth(500);
    await controller.persistWidth();
    expect(prefs.getDouble(DetailPanelController.widthKey), 500);

    controller.resetWidth();
    expect(state().width, appDetailPanelDefaultWidth);
    await controller.persistWidth();
    expect(
      prefs.getDouble(DetailPanelController.widthKey),
      appDetailPanelDefaultWidth,
    );
  });
}
