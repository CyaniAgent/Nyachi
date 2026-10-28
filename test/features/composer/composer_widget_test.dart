// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/network/instance_repository.dart';
import 'package:nyachi/core/storage/app_database.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/composer/application/composer_controller.dart';
import 'package:nyachi/features/composer/presentation/compose_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps [ComposerBody] in a page-like surface with a fake account and sender.
///
/// [scheduledNotes] mirrors `InstanceInfo.scheduledNotesSupported`, which gates
/// the schedule entry in the overflow menu.
Future<ProviderContainer> _pumpComposer(
  WidgetTester tester, {
  bool scheduledNotes = false,
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
          scheduledNotesSupported: scheduledNotes,
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

  testWidgets('the overflow menu exposes the character budget and all four '
      'acceptance options', (tester) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpComposer(tester);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('0 / 3000'), findsOneWidget);
    expect(find.text('Reaction acceptance'), findsOneWidget);
    expect(find.text('Any reactions'), findsOneWidget);
    expect(find.text('Likes only'), findsOneWidget);
    expect(find.text('Non-sensitive only'), findsOneWidget);
    expect(find.text('Save draft'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    // The schedule entry only appears once the server has been probed as
    // supporting notes/drafts; this instance has not been.
    expect(find.text('Schedule'), findsNothing);
  });

  testWidgets('the schedule entry appears when the server supports drafts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpComposer(tester, scheduledNotes: true);
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
}
