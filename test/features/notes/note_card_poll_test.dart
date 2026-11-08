// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart' hide Clip;
import 'package:mocktail/mocktail.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/notes/application/note_providers.dart';
import 'package:nyachi/features/notes/domain/note_repository.dart';
import 'package:nyachi/features/notes/presentation/note_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fixtures.dart';

class _MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  late _MockNoteRepository repository;
  late LocalAccount account;

  setUp(() {
    repository = _MockNoteRepository();
    account = LocalAccount(
      id: 'account',
      host: 'example.test',
      userId: 'alice',
      username: 'alice',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );
  });

  Future<void> pumpCard(WidgetTester tester, Note note) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
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

  testWidgets('a note with a poll renders it under the body', (tester) async {
    final note = makeNote(
      'n1',
      text: 'pick one',
      poll: makePoll([
        (text: 'Red', votes: 1, voted: false),
        (text: 'Blue', votes: 0, voted: false),
      ]),
    );

    await pumpCard(tester, note);

    expect(find.text('pick one'), findsOneWidget);
    expect(find.text('Red'), findsOneWidget);
    expect(find.text('Blue'), findsOneWidget);
    expect(find.text('View results'), findsOneWidget);
  });

  testWidgets('a note without a poll renders none of it', (tester) async {
    await pumpCard(tester, makeNote('n1'));

    expect(find.text('View results'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('voting sends the choice and shows the tally', (tester) async {
    final note = makeNote(
      'n1',
      text: null,
      poll: makePoll([
        (text: 'Red', votes: 1, voted: false),
        (text: 'Blue', votes: 3, voted: false),
      ]),
    );
    final voted = makeNote(
      'n1',
      text: null,
      poll: makePoll([
        (text: 'Red', votes: 1, voted: false),
        (text: 'Blue', votes: 4, voted: true),
      ]),
    );
    when(() => repository.vote('n1', [1])).thenAnswer((_) async => voted);

    await pumpCard(tester, note);
    await tester.tap(find.text('Blue'));
    await tester.pumpAndSettle();

    verify(() => repository.vote('n1', [1])).called(1);
    // Once the viewer has answered, the result replaces the voting UI.
    expect(find.text('5 votes'), findsOneWidget);
    expect(find.textContaining('80%'), findsOneWidget);
    expect(find.text('View results'), findsNothing);
  });

  testWidgets('a failed vote keeps the poll votable', (tester) async {
    final note = makeNote(
      'n1',
      text: null,
      poll: makePoll([
        (text: 'Red', votes: 1, voted: false),
        (text: 'Blue', votes: 3, voted: false),
      ]),
    );
    when(() => repository.vote('n1', [1])).thenThrow(Exception('network down'));

    await pumpCard(tester, note);
    await tester.tap(find.text('Blue'));
    await tester.pumpAndSettle();

    // The failure is surfaced and the choices stay tappable.
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Blue'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
  });
}
