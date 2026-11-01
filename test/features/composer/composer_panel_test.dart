// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/network/instance_repository.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/composer/application/composer_controller.dart';
import 'package:nyachi/features/composer/application/draft_store.dart';
import 'package:nyachi/features/composer/presentation/composer_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSessionController extends SessionController {
  _FakeSessionController(this.accounts, this.active);

  final List<LocalAccount> accounts;
  final LocalAccount active;

  @override
  SessionState build() =>
      SessionState(accounts: accounts, active: active, initialized: true);
}

void main() {
  late AppDatabase database;
  late LocalAccount account;
  late LocalAccount sibling;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    SharedPreferences.setMockInitialValues({});
    account = LocalAccount(
      id: 'account',
      host: 'example.test',
      userId: 'u1',
      username: 'alice',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );
    sibling = LocalAccount(
      id: 'second',
      host: 'example.test',
      userId: 'u2',
      username: 'bob',
      addedAt: DateTime(2026),
      lastUsedAt: DateTime(2026),
    );
  });

  Future<void> pumpPanel(
    WidgetTester tester, {
    bool draftsSupported = false,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appDatabaseProvider.overrideWithValue(database),
        sessionControllerProvider.overrideWith(
          () => _FakeSessionController([account, sibling], account),
        ),
        instanceInfoProvider.overrideWith(
          (ref) async => InstanceInfo(
            name: 'Example',
            themeColor: '#123456',
            maxNoteTextLength: 3000,
            draftsSupported: draftsSupported,
          ),
        ),
        draftStoreProvider.overrideWith(
          (ref) => DraftStore(
            client: MisskeyClient.fromHost('https://example.invalid'),
            dao: database.localDraftsDao,
            draftsSupported: draftsSupported,
            accountId: account.id,
          ),
        ),
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
          home: const Scaffold(body: _PanelHost()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open panel'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists saved drafts and deletes one', (tester) async {
    await database.localDraftsDao.save(
      ComposerDraft(
        id: 'local:d1',
        accountId: account.id,
        text: 'draft body',
        visibility: 'public',
        replyId: 'note-9',
        updatedAt: DateTime(2026),
      ),
    );

    await pumpPanel(tester);

    expect(find.text('Drafts'), findsOneWidget);
    expect(find.text('draft body'), findsOneWidget);
    // The scheduled section is absent without the instance probe.
    expect(find.text('Scheduled posts'), findsNothing);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(await database.localDraftsDao.list(account.id), isEmpty);
  });

  testWidgets('shows the empty draft state and same-instance accounts', (
    tester,
  ) async {
    await pumpPanel(tester);

    expect(find.text('No saved drafts'), findsOneWidget);
    expect(find.text('alice'), findsOneWidget);
    expect(find.text('bob'), findsOneWidget);
  });

  testWidgets('loading a draft applies it to the composer', (tester) async {
    await database.localDraftsDao.save(
      ComposerDraft(
        id: 'local:d1',
        accountId: account.id,
        text: 'reusable text',
        visibility: 'followers',
        replyId: 'note-9',
        updatedAt: DateTime(2026),
      ),
    );
    await pumpPanel(tester);

    await tester.tap(find.text('reusable text'));
    await tester.pumpAndSettle();

    // The panel closed and the host shows the loaded draft in the composer.
    expect(find.text('body:reusable text'), findsOneWidget);
    expect(find.text('ctx:note-9'), findsOneWidget);
  });
}

/// Hosts the panel with a live composer controller and renders its state, so a
/// draft loaded from the panel is observable after the panel closes.
class _PanelHost extends ConsumerWidget {
  const _PanelHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(composerControllerProvider(null));
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ctx:${state.replyId ?? 'none'}'),
          Text('body:${state.text}'),
          TextButton(
            onPressed: () => showComposerPanel(context, replyId: null),
            child: const Text('open panel'),
          ),
        ],
      ),
    );
  }
}
