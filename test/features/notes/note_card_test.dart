// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/app/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/notes/presentation/note_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fixtures.dart';

DriveFile _file() {
  return DriveFile(
    id: 'f1',
    createdAt: DateTime(2026),
    name: 'document.pdf',
    type: 'application/pdf',
    md5: 'x',
    size: 1,
    isSensitive: false,
    blurhash: null,
    properties: const DriveFileProperties(),
    url: 'https://example.test/document.pdf',
    thumbnailUrl: null,
    comment: null,
    folderId: null,
    userId: null,
  );
}

Widget _app(Note note, {required GoRouter router}) {
  return MaterialApp.router(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

GoRouter _router(Note note) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(body: NoteCard(note: note)),
      ),
      GoRoute(
        path: '/notes/:id',
        builder: (_, _) => const Scaffold(body: Text('detail')),
      ),
    ],
  );
}

void main() {
  testWidgets('renders CW, reveals content, and shows attachments', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final note = makeNote(
      'n1',
      text: 'hello world',
    ).copyWith(cw: 'spoiler', files: [_file()]);
    final router = _router(note);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: _app(note, router: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('spoiler'), findsOneWidget);
    expect(find.text('hello world'), findsNothing);
    expect(find.text('document.pdf'), findsNothing);

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(find.text('hello world'), findsOneWidget);
    expect(find.text('document.pdf'), findsOneWidget);
  });

  testWidgets('opens note detail', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final note = makeNote('n1', text: 'hello');
    final router = _router(note);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: _app(note, router: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('hello'));
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsOneWidget);
  });
}
