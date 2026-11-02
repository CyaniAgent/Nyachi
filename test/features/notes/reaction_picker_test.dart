// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/features/notes/application/emoji_catalog.dart';
import 'package:nyachi/features/notes/presentation/reaction_picker.dart';

import '../../support/fixtures.dart';

EmojiSimple _emoji(String name, {String? category}) => EmojiSimple(
  aliases: const [],
  name: name,
  category: category,
  url: 'https://example.test/emoji/$name.png',
);

Future<void> _pumpHost(WidgetTester tester, Widget home) async {
  await tester.pumpWidget(home);
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

// Riverpod 3 does not export the `Override` type publicly, so the provider
// overrides live inline in each test's ProviderScope.
Widget _materialApp(Widget home) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  testWidgets(
    'renders catalogue entries alongside the built-in unicode set',
    (tester) async {
      // The bottom sheet route is pushed on the root navigator, so the scope
      // must sit above MaterialApp for the sheet to find it.
      await _pumpHost(
        tester,
        ProviderScope(
          overrides: [
            emojiCatalogProvider.overrideWith(
              (ref) async => [
                _emoji('nyan', category: 'fun'),
                _emoji('kawaii'),
              ],
            ),
          ],
          child: _materialApp(_OpenButton(onPicked: (_) {})),
        ),
      );

      // The catalogue entries are grouped in the grid.
      expect(find.byTooltip('nyan'), findsOneWidget);
      expect(find.byTooltip('kawaii'), findsOneWidget);
      // The built-in unicode fallback row is still offered.
      for (final reaction in defaultReactions) {
        expect(find.text(reaction), findsOneWidget);
      }
    },
  );

  testWidgets('tapping a catalogue entry returns that emoji', (tester) async {
    String? picked;
    await _pumpHost(
      tester,
      ProviderScope(
        overrides: [
          emojiCatalogProvider.overrideWith((ref) async => [_emoji('nyan')]),
        ],
        child: _materialApp(_OpenButton(onPicked: (r) => picked = r)),
      ),
    );

    await tester.tap(find.byTooltip('nyan'));
    await tester.pumpAndSettle();

    expect(picked, ':nyan:');
  });

  testWidgets('catalogue errors show a retry affordance', (tester) async {
    await _pumpHost(
      tester,
      ProviderScope(
        overrides: [
          emojiCatalogProvider.overrideWith(
            (ref) async => throw Exception('network down'),
          ),
        ],
        child: _materialApp(_OpenButton(onPicked: (_) {})),
      ),
    );

    // The built-in unicode fallback row is always offered.
    expect(find.text('❤️'), findsOneWidget);
    // The failure is explicit, not silently collapsed to the fallback row.
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    // Retrying surfaces the error again (the override keeps failing), which
    // keeps the retry affordance visible.
    expect(find.text('Retry'), findsOneWidget);
  });
}

class _OpenButton extends StatelessWidget {
  const _OpenButton({required this.onPicked});

  final ValueChanged<String?> onPicked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () async {
            final reaction = await showReactionPicker(
              context,
              note: makeNote('n1'),
            );
            onPicked(reaction);
          },
          child: const Text('open'),
        ),
      ),
    );
  }
}
