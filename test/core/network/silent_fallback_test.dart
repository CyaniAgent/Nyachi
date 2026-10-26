// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/features/chat/data/chat_repository.dart';
import 'package:nyachi/features/notes/data/note_feed_repository.dart';
import 'package:nyachi/features/notes/domain/note_feed_source.dart';

import '../../support/fixtures.dart';

class _MockClient extends Mock implements MisskeyClient {}

class _MockChatApi extends Mock implements ChatApi {}

void main() {
  late AppDatabase db;
  late _MockClient client;
  late _MockChatApi chat;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    client = _MockClient();
    chat = _MockChatApi();
    when(() => client.chat).thenReturn(chat);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'history rethrows authentication failures instead of hiding them',
    () async {
      final repository = MisskeyChatRepository(
        client: client,
        cache: db.cacheDao,
        accountId: 'a',
      );
      when(() => chat.history(limit: any(named: 'limit'))).thenAnswer(
        (_) async =>
            throw MisskeyAuthenticationException('expired', statusCode: 401),
      );

      await expectLater(
        repository.history(),
        throwsA(isA<MisskeyAuthenticationException>()),
      );
    },
  );

  test('history falls back to an empty list on transport failures', () async {
    final repository = MisskeyChatRepository(
      client: client,
      cache: db.cacheDao,
      accountId: 'a',
    );
    when(() => chat.history(limit: any(named: 'limit'))).thenAnswer(
      (_) async => throw MisskeyApiException('boom', statusCode: 503),
    );

    expect(await repository.history(), isEmpty);
  });

  test('note feed cache decode failures degrade to an empty list', () async {
    final repository = MisskeyNoteFeedRepository(
      client: client,
      cache: db.cacheDao,
      accountId: 'a',
    );
    final source = NoteFeedSource.home(HomeFeedKind.home);
    await db.cacheDao.write('a', source.cacheKey, '{not json');

    expect(await repository.readCache(source), isEmpty);
  });

  test('note feed cache decodes valid payloads', () async {
    final repository = MisskeyNoteFeedRepository(
      client: client,
      cache: db.cacheDao,
      accountId: 'a',
    );
    final source = NoteFeedSource.home(HomeFeedKind.home);
    final note = makeNote('n1');
    await db.cacheDao.write('a', source.cacheKey, jsonEncode([note.toJson()]));

    final notes = await repository.readCache(source);
    expect(notes, hasLength(1));
    expect(notes.single.id, 'n1');
  });
}
