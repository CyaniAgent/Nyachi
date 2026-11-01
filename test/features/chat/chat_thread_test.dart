// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/network/client_provider.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/chat/domain/chat_models.dart';
import 'package:nyachi/features/chat/presentation/chat_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSessionController extends SessionController {
  _FakeSessionController(this.account);

  final LocalAccount account;

  @override
  SessionState build() =>
      SessionState(accounts: [account], active: account, initialized: true);
}

class _MockClient extends Mock implements MisskeyClient {}

class _MockChatApi extends Mock implements ChatApi {}

ChatMessageLiteFor1on1 _msg(String id, String text, DateTime at) =>
    ChatMessageLiteFor1on1(
      id: id,
      createdAt: at,
      fromUserId: 'peer',
      toUserId: 'u1',
      text: text,
      reactions: const [],
    );

/// Builds a [CursorPage] whose `hasMore` is decided by the caller, since the
/// type only derives it from `items.length == limit`.
Future<CursorPage<ChatMessageLiteFor1on1>> _page(
  List<ChatMessageLiteFor1on1> items, {
  required bool hasMore,
}) {
  return CursorPage.fetch<ChatMessageLiteFor1on1>(
    limit: hasMore ? items.length : items.length + 1,
    idOf: (item) => item.id,
    fetchPage: (_, _) async => items,
  );
}

void main() {
  late AppDatabase database;
  late _MockClient client;
  late _MockChatApi chat;
  late LocalAccount account;
  final base = DateTime(2026, 1, 1, 12);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    SharedPreferences.setMockInitialValues({});
    client = _MockClient();
    chat = _MockChatApi();
    when(() => client.chat).thenReturn(chat);
    account = LocalAccount(
      id: 'account',
      host: 'example.test',
      userId: 'u1',
      username: 'alice',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );
  });

  Future<void> pumpThread(WidgetTester tester) async {
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appDatabaseProvider.overrideWithValue(database),
        sessionControllerProvider.overrideWith(
          () => _FakeSessionController(account),
        ),
        misskeyClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SafeArea(
              child: ChatThreadPage(target: ChatTarget.user('peer')),
            ),
          ),
        ),
      ),
    );
  }

  void stubTimeline(
    Future<CursorPage<ChatMessageLiteFor1on1>> Function(String? untilId) page,
  ) {
    when(
      () => chat.messagesUserTimelinePage(
        limit: any(named: 'limit'),
        untilId: any(named: 'untilId'),
        userId: 'peer',
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((invocation) async {
      final untilId = invocation.namedArguments[#untilId] as String?;
      return page(untilId);
    });
  }

  testWidgets('the transcript opens at the newest message', (tester) async {
    final only = [
      _msg('m1', 'first', base.add(const Duration(minutes: 1))),
      _msg('m2', 'second', base.add(const Duration(minutes: 2))),
      _msg('m3', 'third', base.add(const Duration(minutes: 3))),
    ];
    stubTimeline((untilId) => _page(only, hasMore: false));

    await pumpThread(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 300));

    // The reversed list starts at offset 0, so the newest message is the one
    // rendered nearest the bottom of the viewport.
    expect(find.text('third'), findsOneWidget);
    final newestTop = tester.getTopLeft(find.text('third')).dy;
    final olderTop = tester.getTopLeft(find.text('second')).dy;
    expect(newestTop, greaterThan(olderTop));
  });

  testWidgets('reaching the oldest edge loads one older page in place', (
    tester,
  ) async {
    final first = [
      for (var i = 1; i <= 20; i++)
        _msg('m$i', 'first $i', base.add(Duration(minutes: i))),
    ];
    final older = [
      for (var i = 1; i <= 20; i++)
        _msg('m${20 + i}', 'older $i', base.subtract(Duration(minutes: i))),
    ];
    stubTimeline(
      (untilId) =>
          _page(untilId == null ? first : older, hasMore: untilId == null),
    );

    await pumpThread(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 300));

    // Drag towards the oldest edge (visually up, finger down).
    await tester.drag(find.byType(ListView), const Offset(0, 2000));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    verify(
      () => chat.messagesUserTimelinePage(
        limit: 20,
        untilId: 'm1',
        userId: 'peer',
        cancelToken: null,
      ),
    ).called(1);
    expect(find.text('older 1'), findsOneWidget);
    expect(find.text('first 1'), findsOneWidget);
  });
}
