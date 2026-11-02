// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/features/composer/presentation/compose_sheet.dart';
import 'package:nyachi/features/notes/application/note_providers.dart';
import 'package:nyachi/features/notes/domain/note_repository.dart';

import '../../support/fixtures.dart';

/// The note the user is replying to, with distinctive body text.
Note _replyTarget() =>
    makeNote('n1', text: 'quick reply target content zzz9').copyWith(
      user: makeUser('alice', name: 'Alice'),
    );

/// Repository whose [fetch] succeeds; the preview must show what it returns.
class _FakeNoteRepository implements NoteRepository {
  _FakeNoteRepository(this.note);

  final Note note;

  @override
  Future<Note> fetch(String noteId) async {
    if (noteId != note.id) {
      throw Exception('unexpected fetch for $noteId');
    }
    return note;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Future<void> _pumpPreview(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [noteRepositoryProvider.overrideWithValue(_FakeNoteRepository(_replyTarget()))],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'the reply preview shows the replied-to note text, never a reaction',
    (tester) async {
      await _pumpPreview(tester, ReplyPreviewCard(noteId: 'n1'));

      // The resolved note's real text is visible.
      expect(find.textContaining('quick reply target content zzz9'), findsOneWidget);
      // A heart reaction must never stand in for the content.
      expect(find.text('❤️'), findsNothing);
    },
  );

  testWidgets(
    'a wrong reply id surfaces nothing rather than a foreign note',
    (tester) async {
      await _pumpPreview(tester, ReplyPreviewCard(noteId: 'other'));

      // The fake repository only knows n1; a mismatched id shows an empty
      // preview instead of some other note's content.
      expect(find.textContaining('quick reply target content zzz9'), findsNothing);
    },
  );
}
