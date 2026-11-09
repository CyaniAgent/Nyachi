// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/mfm/mfm_body.dart';
import 'package:nyachi/features/announcements/data/announcement_repository.dart';
import 'package:nyachi/features/announcements/presentation/announcements_page.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Announcement _announcement({
  String id = 'a1',
  String title = 'Maintenance',
  String text = 'Servers restart at midnight.',
  AnnouncementDisplay display = AnnouncementDisplay.normal,
  bool isRead = false,
}) {
  return Announcement(
    id: id,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: null,
    title: title,
    text: text,
    imageUrl: null,
    display: display,
    isRead: isRead,
    forYou: false,
    icon: AnnouncementIcon.info,
    needConfirmationToRead: false,
    silence: false,
  );
}

Future<void> _pump(WidgetTester tester, List<Announcement> items) async {
  SharedPreferences.setMockInitialValues({});
  final shared = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(shared),
        announcementsProvider.overrideWith((ref) async => items),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AnnouncementsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('announcements render as rows, not cards', (tester) async {
    await _pump(tester, [
      _announcement(id: 'a1'),
      _announcement(id: 'a2', title: 'Second'),
    ]);

    // Dense content: the app does not box each entry, so a card here would
    // read as a different surface from every other list.
    expect(find.byType(Card), findsNothing);
    expect(find.text('Maintenance'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('the body keeps its selection, the header toggles', (
    tester,
  ) async {
    await _pump(tester, [
      _announcement(
        text: 'Line one.\nLine two.\nLine three.\nLine four.\nLine five.',
      ),
    ]);

    Text body() => tester.widget<Text>(
      find.descendant(of: find.byType(MfmBody), matching: find.byType(Text)),
    );

    // Selecting inside the body must not be blocked by the row gesture, so the
    // body is selectable and the toggle lives in the header only.
    expect(find.byType(SelectionArea), findsOneWidget);
    expect(body().maxLines, 4);

    await tester.tap(find.text('Maintenance'));
    await tester.pumpAndSettle();
    expect(body().maxLines, isNull);

    await tester.tap(find.text('Maintenance'));
    await tester.pumpAndSettle();
    expect(body().maxLines, 4);
  });

  testWidgets('a drag over the body does not collapse the row', (tester) async {
    await _pump(tester, [
      _announcement(
        text: 'Line one.\nLine two.\nLine three.\nLine four.\nLine five.',
      ),
    ]);
    await tester.tap(find.text('Maintenance'));
    await tester.pumpAndSettle();

    final start = tester.getTopLeft(find.byType(MfmBody)) + const Offset(4, 8);
    final gesture = await tester.startGesture(
      start,
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveBy(const Offset(120, 0));
    await gesture.moveBy(const Offset(120, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    final body = tester.widget<Text>(
      find.descendant(of: find.byType(MfmBody), matching: find.byType(Text)),
    );
    expect(body.maxLines, isNull, reason: 'the row must stay expanded');
  });
}
