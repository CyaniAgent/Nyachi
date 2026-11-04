// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/features/composer/application/draft_store.dart';

import '../../support/fixtures.dart';

class _MockClient extends Mock implements MisskeyClient {}

class _MockNotesApi extends Mock implements NotesApi {}

ComposerDraft _draft(String text, {List<String> fileIds = const []}) =>
    ComposerDraft(
      accountId: 'account',
      text: text,
      visibility: 'public',
      updatedAt: DateTime(2026),
      fileIds: fileIds,
    );

NoteDraft _serverDraft(String id, String text) => NoteDraft(
  id: id,
  createdAt: DateTime(2026),
  text: text,
  cw: null,
  userId: 'u1',
  user: makeUser('u1'),
  replyId: null,
  renoteId: null,
  visibility: NoteDraftVisibility.public,
  visibleUserIds: const [],
  fileIds: const [],
  hashtag: null,
  poll: null,
  channelId: null,
  localOnly: false,
  reactionAcceptance: null,
  scheduledAt: null,
  isActuallyScheduled: false,
);

void main() {
  late AppDatabase database;
  late _MockClient client;
  late _MockNotesApi notes;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    client = _MockClient();
    notes = _MockNotesApi();
    when(() => client.notes).thenReturn(notes);
    // Non-null enum params need a registered fallback before `any()` works.
    registerFallbackValue(NotesDraftsCreateRequestVisibility.public);
  });

  DraftStore store({bool draftsSupported = true}) => DraftStore(
    client: client,
    dao: database.localDraftsDao,
    draftsSupported: draftsSupported,
    accountId: 'account',
  );

  test('a blank draft deletes the stored row instead of persisting', () async {
    final s = store(draftsSupported: false);
    final id = await s.save(_draft('hello'));
    expect(id, isNotNull);

    // The content became blank: the stored row goes away.
    final after = await s.save(
      _draft('').copyWith(id: id, accountId: 'account'),
    );
    expect(after, isNull);
    expect(await database.localDraftsDao.list('account'), isEmpty);
  });

  test('a poll with two non-empty choices counts as substantive', () async {
    final s = store(draftsSupported: false);
    final id = await s.save(
      _draft('')
          .copyWith(accountId: 'account', pollChoices: '["", "yes", "no"]'),
    );
    expect(id, isNotNull);
    final stored = await database.localDraftsDao.list('account');
    expect(stored.single.pollChoices, '["", "yes", "no"]');
  });

  test(
    'local fallback drafts drop attachments and carry the local prefix',
    () async {
      final s = store(draftsSupported: false);

      final id = await s.save(_draft('hello', fileIds: ['file1']));

      expect(id, startsWith('local:'));
      final stored = await database.localDraftsDao.list('account');
      expect(stored.single.fileIds, isEmpty);
    },
  );

  test('a supported instance stores drafts on the server', () async {
    when(
      () => notes.draftsCreate(
        visibility: any(named: 'visibility'),
        visibleUserIds: any(named: 'visibleUserIds'),
        cw: any(named: 'cw'),
        localOnly: any(named: 'localOnly'),
        reactionAcceptance: any(named: 'reactionAcceptance'),
        replyId: any(named: 'replyId'),
        text: any(named: 'text'),
        fileIds: any(named: 'fileIds'),
        poll: any(named: 'poll'),
        scheduledAt: any(named: 'scheduledAt'),
        isActuallyScheduled: any(named: 'isActuallyScheduled'),
      ),
    ).thenAnswer(
      (_) async => NotesDraftsCreateResponse(
        createdDraft: _serverDraft('server-1', 'hello'),
      ),
    );
    when(
      () => notes.draftsList(
        limit: any(named: 'limit'),
        sinceId: any(named: 'sinceId'),
        untilId: any(named: 'untilId'),
        sinceDate: any(named: 'sinceDate'),
        untilDate: any(named: 'untilDate'),
        scheduled: any(named: 'scheduled'),
      ),
    ).thenAnswer((_) async => [_serverDraft('server-1', 'hello')]);

    final id = await store().save(_draft('hello'));
    expect(id, 'server-1');

    final drafts = await store().list();
    expect(drafts.single.id, 'server-1');
    expect(await database.localDraftsDao.list('account'), isEmpty);
  });

  test('a server failure falls back to the local table', () async {
    when(
      () => notes.draftsCreate(
        visibility: any(named: 'visibility'),
        visibleUserIds: any(named: 'visibleUserIds'),
        cw: any(named: 'cw'),
        localOnly: any(named: 'localOnly'),
        reactionAcceptance: any(named: 'reactionAcceptance'),
        replyId: any(named: 'replyId'),
        text: any(named: 'text'),
        fileIds: any(named: 'fileIds'),
        poll: any(named: 'poll'),
        scheduledAt: any(named: 'scheduledAt'),
        isActuallyScheduled: any(named: 'isActuallyScheduled'),
      ),
    ).thenThrow(Exception('network down'));

    final id = await store().save(_draft('hello'));

    expect(id, startsWith('local:'));
    expect(await database.localDraftsDao.list('account'), hasLength(1));
  });

  test('the local table keeps at most fifty drafts per account', () async {
    final s = store(draftsSupported: false);
    for (var i = 0; i < 55; i++) {
      await s.save(
        _draft('draft $i').copyWith(
          accountId: 'account',
          updatedAt: DateTime(2026, 1, 1).add(Duration(minutes: i)),
        ),
      );
    }

    final drafts = await database.localDraftsDao.list('account');
    expect(drafts, hasLength(50));
    // The oldest drafts are pruned, the newest kept.
    expect(drafts.first.text, 'draft 54');
    expect(drafts.any((draft) => draft.text == 'draft 4'), isFalse);
  });

  test(
    'a failed server update falls back locally and recovers in place',
    () async {
      final s = store();
      // First save lands on the server.
      when(
        () => notes.draftsCreate(
          visibility: any(named: 'visibility'),
          visibleUserIds: any(named: 'visibleUserIds'),
          cw: any(named: 'cw'),
          localOnly: any(named: 'localOnly'),
          reactionAcceptance: any(named: 'reactionAcceptance'),
          replyId: any(named: 'replyId'),
          text: any(named: 'text'),
          fileIds: any(named: 'fileIds'),
          poll: any(named: 'poll'),
          scheduledAt: any(named: 'scheduledAt'),
          isActuallyScheduled: any(named: 'isActuallyScheduled'),
        ),
      ).thenAnswer(
        (_) async => NotesDraftsCreateResponse(
          createdDraft: _serverDraft('server-1', 'hello'),
        ),
      );
      final id = await s.save(_draft('hello'));
      expect(id, 'server-1');

      // A transient network failure during the next autosave.
      var updateCalls = 0;
      when(
        () => notes.draftsUpdate(
          draftId: any(named: 'draftId'),
          visibility: any(named: 'visibility'),
          visibleUserIds: any(named: 'visibleUserIds'),
          cw: any(named: 'cw'),
          localOnly: any(named: 'localOnly'),
          reactionAcceptance: any(named: 'reactionAcceptance'),
          replyId: any(named: 'replyId'),
          text: any(named: 'text'),
          fileIds: any(named: 'fileIds'),
          poll: any(named: 'poll'),
          scheduledAt: any(named: 'scheduledAt'),
          isActuallyScheduled: any(named: 'isActuallyScheduled'),
        ),
      ).thenAnswer((_) async {
        updateCalls++;
        if (updateCalls == 1) throw Exception('timeout');
        return NotesDraftsUpdateResponse(
          updatedDraft: _serverDraft('server-1', 'hello v2'),
        );
      });

      final fallbackId = await s.save(
        _draft('hello v2').copyWith(id: id, accountId: 'account'),
      );
      // The fallback keeps the server identity under the local prefix
      // instead of minting a fresh UUID that would fork the draft.
      expect(fallbackId, 'local:server-1');

      // Recovery updates the same server draft and drops the shadow row.
      final recovered = await s.save(
        _draft('hello v2').copyWith(id: fallbackId, accountId: 'account'),
      );
      expect(recovered, 'server-1');
      expect(updateCalls, 2);
      expect(await database.localDraftsDao.list('account'), isEmpty);

      // The panel shows exactly one row for the draft.
      when(
        () => notes.draftsList(
          limit: any(named: 'limit'),
          sinceId: any(named: 'sinceId'),
          untilId: any(named: 'untilId'),
          sinceDate: any(named: 'sinceDate'),
          untilDate: any(named: 'untilDate'),
          scheduled: any(named: 'scheduled'),
        ),
      ).thenAnswer((_) async => [_serverDraft('server-1', 'hello v2')]);
      final drafts = await s.list();
      expect(drafts.single.id, 'server-1');
    },
  );

  test('a shadow row is deduplicated against its server draft', () async {
    // A leftover shadow row from an older fallback, plus the live server row.
    await database.localDraftsDao.save(
      _draft(
        'hello v2',
      ).copyWith(id: 'local:server-1', accountId: 'account', fileIds: const []),
    );
    when(
      () => notes.draftsList(
        limit: any(named: 'limit'),
        sinceId: any(named: 'sinceId'),
        untilId: any(named: 'untilId'),
        sinceDate: any(named: 'sinceDate'),
        untilDate: any(named: 'untilDate'),
        scheduled: any(named: 'scheduled'),
      ),
    ).thenAnswer((_) async => [_serverDraft('server-1', 'hello v2')]);

    final drafts = await store().list();

    expect(drafts, hasLength(1));
    expect(drafts.single.id, 'server-1');
  });

  test('an expired session falls back to the local table', () async {
    when(
      () => notes.draftsCreate(
        visibility: any(named: 'visibility'),
        visibleUserIds: any(named: 'visibleUserIds'),
        cw: any(named: 'cw'),
        localOnly: any(named: 'localOnly'),
        reactionAcceptance: any(named: 'reactionAcceptance'),
        replyId: any(named: 'replyId'),
        text: any(named: 'text'),
        fileIds: any(named: 'fileIds'),
        poll: any(named: 'poll'),
        scheduledAt: any(named: 'scheduledAt'),
        isActuallyScheduled: any(named: 'isActuallyScheduled'),
      ),
    ).thenThrow(MisskeyAuthenticationException('expired', statusCode: 401));

    final s = store();
    final id = await s.save(_draft('typed before expiry'));

    // Content survives in the local table instead of escaping as an
    // unhandled error.
    expect(id, startsWith('local:'));
    final stored = await database.localDraftsDao.list('account');
    expect(stored.single.text, 'typed before expiry');
  });
}
