// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/composer/application/composer_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late SharedPreferences preferences;
  late LocalAccount account;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    account = LocalAccount(
      id: 'account',
      host: 'example.test',
      userId: 'u1',
      username: 'alice',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );
  });

  tearDown(() async {
    await database.close();
  });

  ProviderContainer container({ComposerSender? sender}) {
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appDatabaseProvider.overrideWithValue(database),
        activeAccountProvider.overrideWithValue(account),
        composerSenderProvider.overrideWithValue(
          sender ??
              ({
                required text,
                cw,
                required visibility,
                required localOnly,
                replyId,
              }) async {},
        ),
      ],
    );
  }

  test('autosaves and restores one draft per account', () async {
    final first = container();
    final firstSub = first.listen(composerControllerProvider(null), (_, _) {});
    first.read(composerControllerProvider(null).notifier).setText('draft body');
    await Future<void>.delayed(const Duration(milliseconds: 650));
    firstSub.close();
    first.dispose();

    final saved = await database.draftDao.read(account.id);
    expect(saved?.text, 'draft body');

    final second = container();
    final provider = composerControllerProvider(null);
    final secondSub = second.listen(provider, (_, _) {});
    await pumpEventQueue();
    final state = second.read(provider);
    expect(state.text, 'draft body');
    expect(state.restored, isTrue);
    secondSub.close();
    second.dispose();
  });

  test('successful post clears the draft', () async {
    var sent = false;
    final scope = container(
      sender:
          ({
            required text,
            cw,
            required visibility,
            required localOnly,
            replyId,
          }) async {
            sent = true;
            expect(text, 'posted');
          },
    );
    final provider = composerControllerProvider(null);
    final sub = scope.listen(provider, (_, _) {});
    final controller = scope.read(provider.notifier);
    controller.setText('posted');
    final ok = await controller.post();
    expect(ok, isTrue);
    expect(sent, isTrue);
    expect(await database.draftDao.read(account.id), isNull);
    sub.close();
    scope.dispose();
  });

  test('over-limit text cannot be posted', () async {
    final scope = container();
    final provider = composerControllerProvider(null);
    final sub = scope.listen(provider, (_, _) {});
    final controller = scope.read(provider.notifier);
    controller.setText('x' * 3001);
    expect(controller.canPost, isFalse);
    expect(await controller.post(), isFalse);
    sub.close();
    scope.dispose();
  });

  test('draft is scoped to its reply id', () async {
    final first = container();
    final firstSub = first.listen(
      composerControllerProvider('reply-a'),
      (_, _) {},
    );
    first.read(composerControllerProvider('reply-a').notifier).setText('reply');
    await Future<void>.delayed(const Duration(milliseconds: 650));
    firstSub.close();
    first.dispose();

    final second = container();
    final provider = composerControllerProvider('reply-b');
    final secondSub = second.listen(provider, (_, _) {});
    await pumpEventQueue();
    expect(second.read(provider).text, isEmpty);
    secondSub.close();
    second.dispose();
  });
}
