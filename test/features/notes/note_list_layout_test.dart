// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/notes/data/note_feed_repository.dart'
    show noteFeedRepositoryProvider;
import 'package:nyachi/features/notes/domain/note_feed_repository.dart';
import 'package:nyachi/features/notes/domain/note_feed_source.dart';
import 'package:nyachi/features/notes/presentation/note_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSessionController extends SessionController {
  _FakeSessionController(this.account);

  final LocalAccount account;

  @override
  SessionState build() =>
      SessionState(accounts: [account], active: account, initialized: true);
}

class _EmptyRepository implements NoteFeedRepository {
  @override
  Future<NotePage> fetchPage(NoteFeedSource source, {String? untilId}) async =>
      const NotePage(items: [], hasMore: false);

  @override
  Future<List<Note>> readCache(NoteFeedSource source) async => const [];

  @override
  Future<void> writeCache(NoteFeedSource source, List<Note> notes) async {}
}

LocalAccount _account() => LocalAccount(
  id: 'a1',
  host: 'misskey.io',
  userId: 'u1',
  username: 'alice',
  addedAt: DateTime(2026),
  lastUsedAt: DateTime(2026),
);

void main() {
  testWidgets('a full-bleed header scrolls away with the list', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          sessionControllerProvider.overrideWith(
            () => _FakeSessionController(_account()),
          ),
          noteFeedRepositoryProvider.overrideWith(
            (ref, source) => _EmptyRepository(),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: NoteList(
              source: NoteFeedSource.home(HomeFeedKind.home),
              headerFullBleed: true,
              // Tall enough that pinning it would leave the notes almost no
              // room, which is the shape a profile header has on a phone.
              header: const SizedBox(
                height: 600,
                child: Text('HEADER', textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final before = tester.getTopLeft(find.text('HEADER')).dy;
    expect(before, greaterThanOrEqualTo(0));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    // Scrolling moves the header; a pinned header would stay put and the
    // below it would never get the space back.
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    final after = tester.getTopLeft(find.text('HEADER')).dy;
    expect(position.pixels, greaterThan(0));
    expect(after, lessThan(before));
  });
}
