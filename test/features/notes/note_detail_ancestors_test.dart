// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/notes/application/note_providers.dart';
import 'package:nyachi/features/notes/domain/note_repository.dart';
import 'package:nyachi/features/notes/presentation/note_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fixtures.dart';

/// Serves a fixed ancestor chain for one note.
///
/// Only the two methods the detail page reaches are overridden; the rest throw,
/// so a page that grew an unexpected dependency fails loudly instead of
/// silently rendering stale data.
class _FakeRepository implements NoteRepository {
  _FakeRepository({required this.note, this.ancestors = const []});

  final Note note;
  final List<Note> ancestors;

  @override
  Future<Note> fetch(String noteId) async => note;

  @override
  Future<List<Note>> conversation(String noteId, {int limit = 10}) async =>
      ancestors;

  @override
  Future<CursorPage<Note>> childrenPage(
    String noteId, {
    int limit = 10,
    String? untilId,
  }) => CursorPage.fetch<Note>(
    limit: limit,
    untilId: untilId,
    idOf: (note) => note.id,
    fetchPage: (_, _) async => const [],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, NoteRepository repository) async {
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      activeAccountProvider.overrideWithValue(null),
      noteRepositoryProvider.overrideWithValue(repository),
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
        home: const NoteDetailPage(noteId: 'n3'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a reply renders its ancestor chain above the focused note', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakeRepository(
        note: makeNote('n3', text: 'third'),
        ancestors: [
          makeNote('n1', text: 'first'),
          makeNote('n2', text: 'second'),
        ],
      ),
    );

    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsOneWidget);
    expect(find.text('third'), findsOneWidget);

    // Order matters: the chain reads oldest → newest into the focused note.
    final first = tester.getTopLeft(find.text('first')).dy;
    final second = tester.getTopLeft(find.text('second')).dy;
    final third = tester.getTopLeft(find.text('third')).dy;
    expect(first, lessThan(second));
    expect(second, lessThan(third));
  });

  testWidgets('a note without a parent shows no ancestor rows', (tester) async {
    await _pump(tester, _FakeRepository(note: makeNote('n1', text: 'alone')));

    expect(find.text('alone'), findsOneWidget);
    // Only the focused note remains, so nothing renders above it.
    expect(find.text('No replies yet'), findsOneWidget);
  });

  testWidgets('ancestor text stays selectable, the chevron navigates', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakeRepository(
        note: makeNote('n3', text: 'third'),
        ancestors: [makeNote('n1', text: 'first')],
      ),
    );

    // The chain is reading material: its text must not be sacrificed to a row
    // tap, so selection stays and the jump is an explicit control.
    expect(find.byType(SelectionArea), findsNWidgets(2));
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });
}
