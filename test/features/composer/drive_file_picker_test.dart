// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/features/composer/presentation/drive_file_picker.dart';
import 'package:nyachi/features/drive/data/drive_repository.dart';

DriveFile _file(String id, String name) => DriveFile(
  id: id,
  createdAt: DateTime(2026),
  name: name,
  type: 'application/octet-stream',
  md5: id,
  size: 2048,
  isSensitive: false,
  blurhash: null,
  properties: const DriveFileProperties(),
  url: 'https://example.test/$id',
  thumbnailUrl: null,
  comment: null,
  folderId: null,
  userId: 'u1',
);

DriveFolder _folder(String id, String name) =>
    DriveFolder(id: id, createdAt: DateTime(2026), name: name, parentId: null);

Future<List<String>?> _pumpPicker(
  WidgetTester tester, {
  required DriveListing listing,
  Set<String>? emptyFolders,
}) async {
  List<String>? result;
  final container = ProviderContainer(
    overrides: [
      driveListingProvider.overrideWith((ref, folderId) async {
        if (emptyFolders != null && emptyFolders.contains(folderId)) {
          return const DriveListing(
            files: [],
            folders: [],
            capacity: 0,
            usage: 0,
          );
        }
        return listing;
      }),
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
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showDriveFilePicker(context);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('lists folders and files and returns the picked ids', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpPicker(
      tester,
      listing: DriveListing(
        files: [_file('f1', 'one.png'), _file('f2', 'two.pdf')],
        folders: [_folder('d1', 'Photos')],
        capacity: 100,
        usage: 10,
      ),
    );

    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('one.png'), findsOneWidget);
    // 2048 bytes renders one decimal below 10 KB.
    expect(find.text('2.0 KB'), findsNWidgets(2));

    // The attach action stays disabled until something is selected.
    final attach = find.widgetWithText(FilledButton, 'Attach');
    expect(tester.widget<FilledButton>(attach).onPressed, isNull);

    await tester.tap(find.text('one.png'));
    await tester.pumpAndSettle();
    expect(find.text('Selected 1'), findsOneWidget);

    await tester.tap(find.text('two.pdf'));
    await tester.pumpAndSettle();
    expect(find.text('Selected 2'), findsOneWidget);

    // Tapping a selected row deselects it.
    await tester.tap(find.text('two.pdf'));
    await tester.pumpAndSettle();
    expect(find.text('Selected 1'), findsOneWidget);

    await tester.tap(attach);
    await tester.pumpAndSettle();
    // The sheet pops with the surviving selection.
    expect(find.text('one.png'), findsNothing);
  });

  testWidgets('descends into a folder and shows its empty state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpPicker(
      tester,
      listing: DriveListing(
        files: [_file('f1', 'root.txt')],
        folders: [_folder('d1', 'Empty')],
        capacity: 100,
        usage: 10,
      ),
      emptyFolders: {'d1'},
    );

    await tester.tap(find.text('Empty'));
    await tester.pumpAndSettle();

    // The header names the folder and offers the way back.
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('root.txt'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('the folder action asks for a name and cancels cleanly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpPicker(
      tester,
      listing: const DriveListing(
        files: [],
        folders: [],
        capacity: 0,
        usage: 0,
      ),
    );

    await tester.tap(find.byIcon(Icons.create_new_folder_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Folder name'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Folder name'), findsNothing);
  });
}
