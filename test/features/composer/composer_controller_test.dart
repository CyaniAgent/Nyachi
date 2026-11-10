// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/composer/application/composer_controller.dart';
import 'package:nyachi/features/composer/application/draft_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Makes the restore listing resolve on demand, so the window where the user
/// types while a draft is still loading can be exercised deterministically.
class _SlowDraftStore extends DraftStore {
  _SlowDraftStore({
    required super.dao,
    required super.accountId,
    required this.gate,
  }) : super(
         client: MisskeyClient.fromHost('https://example.invalid'),
         draftsSupported: false,
       );

  final Future<void> gate;

  @override
  Future<List<ComposerDraft>> list() async {
    await gate;
    return super.list();
  }
}

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

  ProviderContainer container({ComposerSender? sender, DraftStore? store}) {
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appDatabaseProvider.overrideWithValue(database),
        activeAccountProvider.overrideWithValue(account),
        // The local fallback store: no server drafts round-trip in these
        // tests, so the network client is never reached.
        draftStoreProvider.overrideWith(
          (ref) =>
              store ??
              DraftStore(
                client: MisskeyClient.fromHost('https://example.invalid'),
                dao: database.localDraftsDao,
                draftsSupported: false,
                accountId: account.id,
              ),
        ),
        composerSenderProvider.overrideWithValue(
          sender ??
              ({
                required text,
                cw,
                required visibility,
                required localOnly,
                replyId,
                fileIds = const [],
                pollChoices,
                pollMultiple = false,
                pollExpiresAt,
                reactionAcceptance,
                visibleUserIds = const [],
                scheduledAt,
              }) async {},
        ),
      ],
    );
  }

  test('autosaves and restores the newest draft for the context', () async {
    final first = container();
    final firstSub = first.listen(composerControllerProvider(null), (_, _) {});
    first.read(composerControllerProvider(null).notifier).setText('draft body');
    await Future<void>.delayed(const Duration(milliseconds: 650));
    firstSub.close();
    first.dispose();

    final saved = await database.localDraftsDao.list(account.id);
    expect(saved.single.text, 'draft body');

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
            fileIds = const [],
            pollChoices,
            pollMultiple = false,
            pollExpiresAt,
            reactionAcceptance,
            visibleUserIds = const [],
            scheduledAt,
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
    expect(await database.localDraftsDao.list(account.id), isEmpty);
    sub.close();
    scope.dispose();
  });

  test('over-limit text cannot be posted', () async {
    final scope = container();
    final provider = composerControllerProvider(null);
    final sub = scope.listen(provider, (_, _) {});
    final controller = scope.read(provider.notifier);
    controller.setText('x' * 3001);
    expect(controller.canPost(), isFalse);
    expect(await controller.post(), isFalse);
    // Let the draft debounce settle so dispose has nothing left to flush
    // against a database the teardown is about to close.
    await Future<void>.delayed(const Duration(milliseconds: 650));
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

  test(
    'a poll and attachments coexist in state and in the post payload',
    () async {
      List<String>? sentFileIds;
      List<String>? sentChoices;
      final scope = container(
        sender:
            ({
              required text,
              cw,
              required visibility,
              required localOnly,
              replyId,
              fileIds = const [],
              pollChoices,
              pollMultiple = false,
              pollExpiresAt,
              reactionAcceptance,
              visibleUserIds = const [],
              scheduledAt,
            }) async {
              sentFileIds = fileIds;
              sentChoices = pollChoices;
            },
      );
      final provider = composerControllerProvider(null);
      final sub = scope.listen(provider, (_, _) {});
      final controller = scope.read(provider.notifier);

      controller.setText('poll with an image');
      controller.addFileId('file-1');
      // Turning the poll on no longer drops the attachment.
      controller.setShowPoll(true);
      expect(scope.read(provider).fileIds, ['file-1']);

      controller.setPollChoice(0, 'yes');
      controller.setPollChoice(1, 'no');
      // Attaching while the poll is open still records the file.
      controller.addFileId('file-2');
      expect(scope.read(provider).fileIds, ['file-1', 'file-2']);

      expect(await controller.post(), isTrue);
      expect(sentFileIds, ['file-1', 'file-2']);
      expect(sentChoices, ['yes', 'no']);

      sub.close();
      scope.dispose();
    },
  );

  test('identical poll choices block the post instead of being sent', () async {
    // The server declares `uniqueItems` on the choices list and rejects the
    // whole request with INVALID_PARAM, so the composer must catch it first.
    List<String>? sentChoices;
    final scope = container(
      sender:
          ({
            required text,
            cw,
            required visibility,
            required localOnly,
            replyId,
            fileIds = const [],
            pollChoices,
            pollMultiple = false,
            pollExpiresAt,
            reactionAcceptance,
            visibleUserIds = const [],
            scheduledAt,
          }) async {
            sentChoices = pollChoices;
          },
    );
    final provider = composerControllerProvider(null);
    final sub = scope.listen(provider, (_, _) {});
    final controller = scope.read(provider.notifier);

    controller.setText('pick one');
    controller.setShowPoll(true);
    controller.setPollChoice(0, 'yes');
    // Trailing space: the same choice to a reader, a duplicate to the schema.
    controller.setPollChoice(1, ' yes ');

    expect(controller.hasDuplicatePollChoices(), isTrue);
    expect(controller.canPost(), isFalse);
    expect(await controller.post(), isFalse);
    expect(sentChoices, isNull);

    // Making them distinct unblocks it, and the payload carries them trimmed.
    controller.setPollChoice(1, 'no');
    expect(controller.hasDuplicatePollChoices(), isFalse);
    expect(controller.canPost(), isTrue);
    expect(await controller.post(), isTrue);
    expect(sentChoices, ['yes', 'no']);

    sub.close();
    scope.dispose();
  });

  test(
    'a slow restore never overwrites what the user typed while waiting',
    () async {
      final releaseGate = Completer<void>();
      await database.localDraftsDao.save(
        ComposerDraft(
          id: 'local:stored',
          accountId: account.id,
          text: 'stored earlier',
          visibility: 'public',
          updatedAt: DateTime(2026),
        ),
      );

      final scope = container(
        store: _SlowDraftStore(
          dao: database.localDraftsDao,
          accountId: account.id,
          gate: releaseGate.future,
        ),
      );
      final provider = composerControllerProvider(null);
      final sub = scope.listen(provider, (_, _) {});
      final controller = scope.read(provider.notifier);

      // The user types before the listing resolves.
      controller.setText('typed while loading');
      releaseGate.complete();
      await pumpEventQueue();

      expect(scope.read(provider).text, 'typed while loading');
      sub.close();
      scope.dispose();
    },
  );
}
