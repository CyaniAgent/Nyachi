// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/network/error_mapper.dart';
import 'package:nyachi/core/ui/failure_action.dart';

class _SpySessionController extends SessionController {
  _SpySessionController(this.onExpire);

  final void Function() onExpire;

  @override
  SessionState build() =>
      const SessionState.initial().copyWith(initialized: true);

  @override
  Future<void> expireActiveAccount() async => onExpire();
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required AppFailure failure,
  required _SpySessionController session,
  required ValueChanged<int> onRetry,
}) async {
  final container = ProviderContainer(
    overrides: [sessionControllerProvider.overrideWith(() => session)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: FailureAction(failure: failure, onRetry: () => onRetry(1)),
        ),
      ),
    ),
  );
  return container;
}

void main() {
  testWidgets('auth failures expire the session automatically', (tester) async {
    var expires = 0;
    var retries = 0;
    await _pump(
      tester,
      failure: const AppFailure(AppFailureKind.auth),
      session: _SpySessionController(() => expires++),
      onRetry: (v) => retries += v,
    );
    await tester.pumpAndSettle();

    // The dead token is dropped without waiting for the tap.
    expect(expires, 1);
    expect(retries, 0);

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(expires, 2);
  });

  testWidgets('non-auth failures keep the retry affordance', (tester) async {
    var expires = 0;
    var retries = 0;
    await _pump(
      tester,
      failure: const AppFailure(AppFailureKind.network),
      session: _SpySessionController(() => expires++),
      onRetry: (v) => retries += v,
    );
    await tester.pumpAndSettle();

    expect(expires, 0);
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(retries, 1);
    expect(expires, 0);
  });
}
