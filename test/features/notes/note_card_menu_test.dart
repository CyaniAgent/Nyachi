// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/features/notes/application/note_providers.dart';
import 'package:nyachi/features/notes/domain/note_repository.dart';
import 'package:nyachi/features/notes/presentation/note_card.dart';

import '../../support/fixtures.dart';

class _MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  late _MockNoteRepository repository;

  setUp(() {
    repository = _MockNoteRepository();
    registerFallbackValue(<String, String>{});
  });

  Future<void> pumpCard(
    WidgetTester tester, {
    required Note note,
    required LocalAccount account,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeAccountProvider.overrideWithValue(account),
          noteRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: SafeArea(child: NoteCard(note: note)),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  LocalAccount account({String userId = 'me'}) => LocalAccount(
    id: 'account',
    host: 'example.test',
    userId: userId,
    username: 'alice',
    addedAt: DateTime(2026),
    lastUsedAt: DateTime(2026),
  );

  Note noteBy({required String userId, String username = 'bob'}) {
    final note = makeNote('n1', user: makeUser(username, name: 'Bob'));
    return note.copyWith(userId: userId);
  }

  testWidgets('the action row shows reply, renote, react and detail', (
    tester,
  ) async {
    await pumpCard(tester, note: makeNote('n1'), account: account());

    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
    expect(find.byIcon(Icons.add_reaction_outlined), findsOneWidget);
    expect(find.byIcon(Icons.article_outlined), findsOneWidget);
  });

  testWidgets('the overflow menu lists the real entries without delete', (
    tester,
  ) async {
    when(
      () => repository.state('n1'),
    ).thenAnswer((_) async => (isFavorited: false, isMutedThread: false));

    await pumpCard(tester, note: makeNote('n1'), account: account());
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    expect(find.text('Copy link'), findsOneWidget);
    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('User memo'), findsOneWidget);
    expect(find.text('Mute thread'), findsOneWidget);
    expect(find.text('Report user'), findsOneWidget);
    expect(find.text('Delete note'), findsNothing);
  });

  testWidgets('own notes offer delete in the menu', (tester) async {
    when(
      () => repository.state('n1'),
    ).thenAnswer((_) async => (isFavorited: false, isMutedThread: false));

    await pumpCard(
      tester,
      note: noteBy(userId: 'me'),
      account: account(userId: 'me'),
    );
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    expect(find.text('Delete note'), findsOneWidget);
  });

  testWidgets('copy link puts the origin note URL on the clipboard', (
    tester,
  ) async {
    // Clipboard platform calls never complete without a mock handler.
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = call.arguments['text'] as String?;
        }
        return null;
      },
    );
    when(
      () => repository.state('n1'),
    ).thenAnswer((_) async => (isFavorited: false, isMutedThread: false));

    await pumpCard(tester, note: makeNote('n1'), account: account());
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy link'));
    await tester.pump();

    expect(clipboard, 'https://example.test/notes/n1');
    expect(find.text('Link copied'), findsOneWidget);
  });

  testWidgets('favorite in the menu calls the repository', (tester) async {
    when(
      () => repository.state('n1'),
    ).thenAnswer((_) async => (isFavorited: false, isMutedThread: false));
    when(() => repository.favorite('n1')).thenAnswer((_) async {});

    await pumpCard(tester, note: makeNote('n1'), account: account());
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorite'));
    await tester.pump();
    await tester.pump();

    verify(() => repository.favorite('n1')).called(1);
  });
}
