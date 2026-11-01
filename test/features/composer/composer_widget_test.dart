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
import 'package:nyachi/core/ui/avatar.dart';
import 'package:nyachi/features/composer/application/composer_controller.dart';
import 'package:nyachi/features/composer/application/draft_store.dart';
import 'package:nyachi/features/composer/presentation/compose_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps [ComposerBody] in a page-like surface with a fake account and sender.
///
/// [draftsSupported] mirrors `InstanceInfo.draftsSupported`, which gates
/// the schedule entry in the overflow menu.
Future<ProviderContainer> _pumpComposer(
  WidgetTester tester, {
  bool draftsSupported = false,
}) async {
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final account = LocalAccount(
    id: 'account',
    host: 'example.test',
    userId: 'u1',
    username: 'alice',
    addedAt: DateTime(2026),
    lastUsedAt: DateTime(2026),
  );
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      appDatabaseProvider.overrideWithValue(database),
      activeAccountProvider.overrideWithValue(account),
      // Local-only draft store: the widget tests exercise the composer UI,
      // never the server drafts round-trip, so the network client is unused.
      draftStoreProvider.overrideWith(
        (ref) => DraftStore(
          client: MisskeyClient.fromHost('https://example.invalid'),
          dao: database.localDraftsDao,
          draftsSupported: false,
          accountId: account.id,
        ),
      ),
      composerSenderProvider.overrideWithValue(
        ({
          required text,
          cw,
          required visibility,
          required localOnly,
          replyId,
          fileIds = const [],
          pollChoices,
          pollMultiple = false,
          pollExpiresAt,
          reactionAcceptance,
          visibleUserIds = const [],
          scheduledAt,
        }) async {},
      ),
      instanceInfoProvider.overrideWith(
        (ref) async => InstanceInfo(
          name: 'Example',
          themeColor: '#123456',
          maxNoteTextLength: 3000,
          draftsSupported: draftsSupported,
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
        home: const Scaffold(
          body: SafeArea(child: ComposerBody(replyId: null, showHandle: false)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('renders the header and toolbar of the official layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpComposer(tester);

    // Header: visibility chip, local-only rocket, post button.
    expect(find.text('Public'), findsOneWidget);
    expect(find.byIcon(Icons.rocket_launch_outlined), findsOneWidget);
    expect(find.text('Post'), findsOneWidget);
    // Hint text of the text area.
    expect(find.text("What's on your mind?"), findsOneWidget);
    // Toolbar tools.
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    expect(find.byIcon(Icons.how_to_vote_outlined), findsOneWidget);
    expect(find.byIcon(Icons.tag), findsOneWidget);
    expect(find.byIcon(Icons.alternate_email), findsOneWidget);
    expect(find.byIcon(Icons.mood_outlined), findsOneWidget);
  });

  testWidgets('poll tool reveals the editor and blocks posting below two '
      'choices', (tester) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = await _pumpComposer(tester);
    await tester.enterText(find.byType(TextField).first, 'hello');
    await tester.pump();

    final provider = composerControllerProvider(null);
    container.read(provider.notifier).setShowPoll(true);
    await tester.pumpAndSettle();

    expect(find.text('Choice 1'), findsOneWidget);
    expect(find.text('Choice 2'), findsOneWidget);
    expect(find.text('A poll needs at least two choices'), findsOneWidget);

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Post'),
    );
    expect(button.onPressed, isNull);

    // Two filled choices make it postable.
    container.read(provider.notifier).setPollChoice(0, 'yes');
    container.read(provider.notifier).setPollChoice(1, 'no');
    await tester.pumpAndSettle();

    expect(find.text('A poll needs at least two choices'), findsNothing);
    final enabled = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Post'),
    );
    expect(enabled.onPressed, isNotNull);

    // Let the 500ms draft autosave debounce fire before teardown, otherwise
    // the pending timer trips the test binding's invariants.
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets(
    'the overflow menu keeps the budget and nests all five acceptance values',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpComposer(tester);
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('0 / 3000'), findsOneWidget);
      expect(find.text('Save draft'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      // The acceptance options are collapsed into a submenu, not flat.
      expect(find.text('Reaction acceptance'), findsOneWidget);
      expect(find.text('Likes only'), findsNothing);
      // The schedule entry only appears once the server has been probed as
      // supporting notes/drafts; this instance has not been.
      expect(find.text('Schedule'), findsNothing);

      await tester.tap(find.text('Reaction acceptance'));
      await tester.pumpAndSettle();

      // Every API value plus "any" is reachable from the submenu.
      expect(find.text('Any reactions'), findsOneWidget);
      expect(find.text('Likes only'), findsOneWidget);
      expect(find.text('Likes only for remote'), findsOneWidget);
      expect(find.text('Non-sensitive only'), findsOneWidget);
      expect(find.text('Non-sensitive; remote likes only'), findsOneWidget);
    },
  );

  testWidgets('the schedule entry appears when the server supports drafts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpComposer(tester, draftsSupported: true);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Schedule'), findsOneWidget);
  });

  testWidgets('visibility menu lists the direct option', (tester) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpComposer(tester);
    await tester.tap(find.text('Public'));
    await tester.pumpAndSettle();

    expect(find.text('Direct'), findsOneWidget);
  });

  testWidgets('the header action group sits flush to the trailing edge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpComposer(tester);

    // ComposerBody pads 16 on each side; the publish button ends at the
    // padding edge, so the action group is flush right rather than flowing
    // from the left cluster.
    final post = tester.getRect(find.widgetWithText(FilledButton, 'Post'));
    expect(1000 - post.right, 16);

    // The spacer keeps the avatar cluster away from the action group.
    final avatar = tester.getRect(find.byType(NyachiAvatar));
    final visibility = tester.getRect(find.text('Public'));
    expect(visibility.left, greaterThan(avatar.right + 100));
  });
  testWidgets('picking the new remote-likes value reaches the post payload', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = await _pumpComposer(tester);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reaction acceptance'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Likes only for remote'));
    await tester.pumpAndSettle();

    // The value survives into the state the sender maps to the API enum.
    expect(
      container.read(composerControllerProvider(null)).reactionAcceptance,
      'likeOnlyForRemote',
    );

    // Reopening the menu marks only the selected row.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reaction acceptance'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('the toolbar preview toggle swaps the editor for the preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpComposer(tester);
    await tester.enterText(find.byType(TextField), 'hello preview');
    await tester.pumpAndSettle();

    // The preview switch left the overflow menu for the toolbar.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.byType(SwitchListTile), findsNothing);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.preview_outlined));
    await tester.pumpAndSettle();

    // Preview is a mode: the editor is replaced, not supplemented, and the
    // footnote names what it does not render.
    expect(find.byType(TextField), findsNothing);
    expect(find.text('hello preview'), findsOneWidget);
    expect(
      find.text(
        'The preview does not render attachments, polls or recipients.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });
}
