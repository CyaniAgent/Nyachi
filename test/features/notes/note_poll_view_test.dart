// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/features/notes/presentation/note_poll_view.dart';

import '../../support/fixtures.dart';

Future<void> _pump(WidgetTester tester, {required Widget child}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a single-answer poll is cast on the first tap', (tester) async {
    final votes = <List<int>>[];
    await _pump(
      tester,
      child: NotePollView(
        note: makeNote(
          'n1',
          text: null,
          poll: makePoll([
            (text: 'Red', votes: 1, voted: false),
            (text: 'Blue', votes: 4, voted: false),
          ]),
        ),
        onVote: (choices) async => votes.add(choices),
      ),
    );

    // Results stay hidden until the viewer votes: seeing the tally first would
    // push them towards the majority.
    expect(find.textContaining('%'), findsNothing);

    await tester.tap(find.text('Blue'));
    await tester.pumpAndSettle();

    expect(votes, [
      [1],
    ]);
  });

  testWidgets('a multiple-answer poll votes only after submitting', (
    tester,
  ) async {
    final votes = <List<int>>[];
    await _pump(
      tester,
      child: NotePollView(
        note: makeNote(
          'n1',
          text: null,
          poll: makePoll([
            (text: 'Red', votes: 0, voted: false),
            (text: 'Green', votes: 0, voted: false),
            (text: 'Blue', votes: 0, voted: false),
          ], multiple: true),
        ),
        onVote: (choices) async => votes.add(choices),
      ),
    );

    await tester.tap(find.text('Green'));
    await tester.pumpAndSettle();
    expect(votes, isEmpty, reason: 'selecting is not voting');
    expect(find.widgetWithText(FilledButton, 'Vote'), findsOneWidget);

    await tester.tap(find.text('Blue'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Vote'));
    await tester.pumpAndSettle();

    expect(votes, [
      [1, 2],
    ]);
  });

  testWidgets('results can be revealed before voting', (tester) async {
    final votes = <List<int>>[];
    await _pump(
      tester,
      child: NotePollView(
        note: makeNote(
          'n1',
          text: null,
          poll: makePoll([
            (text: 'Yes', votes: 3, voted: false),
            (text: 'No', votes: 1, voted: false),
          ]),
        ),
        onVote: (choices) async => votes.add(choices),
      ),
    );

    expect(find.textContaining('75%'), findsNothing);

    await tester.tap(find.text('View results'));
    await tester.pumpAndSettle();

    expect(find.textContaining('75%'), findsOneWidget);
    expect(find.textContaining('25%'), findsOneWidget);
    expect(votes, isEmpty, reason: 'viewing results is not voting');

    // Taps no longer count as votes while results are on screen.
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(votes, isEmpty);
  });

  testWidgets('a poll the viewer already answered is read-only', (
    tester,
  ) async {
    final votes = <List<int>>[];
    await _pump(
      tester,
      child: NotePollView(
        note: makeNote(
          'n1',
          text: null,
          poll: makePoll([
            (text: 'Tea', votes: 2, voted: true),
            (text: 'Coffee', votes: 2, voted: false),
          ]),
        ),
        onVote: (choices) async => votes.add(choices),
      ),
    );

    expect(find.textContaining('50%'), findsNWidgets(2));
    expect(find.text('4 votes'), findsOneWidget);
    expect(find.text('View results'), findsNothing);

    await tester.tap(find.text('Coffee'));
    await tester.pumpAndSettle();
    expect(votes, isEmpty);
  });

  testWidgets('a closed poll reports that it has closed', (tester) async {
    await _pump(
      tester,
      child: NotePollView(
        note: makeNote(
          'n1',
          text: null,
          poll: makePoll([
            (text: 'A', votes: 1, voted: false),
            (text: 'B', votes: 0, voted: false),
          ], expiresAt: DateTime.now().subtract(const Duration(hours: 1))),
        ),
        onVote: (_) async {},
      ),
    );

    expect(find.text('The poll has closed'), findsOneWidget);
    expect(find.text('View results'), findsNothing);
  });
}
