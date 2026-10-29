// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/network/instance_repository.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/features/auth/application/anonymous_meta.dart';
import 'package:nyachi/features/auth/application/login_controller.dart';
import 'package:nyachi/features/oobe/presentation/oobe_page.dart';
import 'package:nyachi/features/settings/application/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockMeta extends Mock implements MetaLite {}

MetaLite _meta() {
  final meta = _MockMeta();
  when(() => meta.name).thenReturn('Misskey Hub');
  when(() => meta.iconUrl).thenReturn(null);
  when(() => meta.serverRules).thenReturn(const ['Be nice']);
  when(() => meta.tosUrl).thenReturn('https://example.test/tos');
  when(() => meta.privacyPolicyUrl).thenReturn(null);
  when(() => meta.impressumUrl).thenReturn(null);
  return meta;
}

/// Sign-in stubbed out: the wizard flow test exercises step transitions,
/// not the network paths (covered by the login page tests).
class _FakeLoginController extends LoginController {
  @override
  LoginState build() => const LoginState();

  @override
  Future<bool> startMiAuth(String host) async => true;

  @override
  Future<bool> loginWithToken(String host, String token) async => true;
}

class _FakeSessionController extends SessionController {
  @override
  SessionState build() =>
      const SessionState(accounts: [], active: null, initialized: true);
}

Future<void> _pumpWizard(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final router = GoRouter(
    initialLocation: '/oobe',
    routes: [
      GoRoute(path: '/oobe', builder: (context, state) => const OobePage()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Text('HOME')),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Text('LOGIN')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sessionControllerProvider.overrideWith(_FakeSessionController.new),
        loginControllerProvider.overrideWith(_FakeLoginController.new),
        anonymousMetaProvider('misskey.io')
            .overrideWith((ref) => Future<MetaLite>.value(_meta())),
        instanceInfoProvider.overrideWith((ref) async => null),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          final settings = ref.watch(settingsControllerProvider);
          final code = settings.localeCode == 'system'
              ? 'en'
              : settings.localeCode;
          return MaterialApp.router(
            locale: Locale(code),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          );
        },
      ),
    ),
  );
  return;
}

void main() {
  testWidgets('wizard walks welcome+language → done and persists completion', (
    tester,
  ) async {
    await _pumpWizard(tester);
    await tester.pumpAndSettle();

    // Step 0 combines welcome and language; picking 中文 from the dropdown
    // re-renders the page in Chinese immediately.
    expect(find.text('Welcome to Nyachi'), findsOneWidget);
    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('简体中文').last);
    await tester.pumpAndSettle();
    expect(find.text('欢迎使用 Nyachi'), findsOneWidget);
    expect(find.text('选择语言'), findsOneWidget);

    // Step 1: compliance + sign-in. Enter host, commit, both consents.
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    expect(find.text('登录实例'), findsOneWidget);
    // The sign-in step cannot be bypassed: no bottom next button.
    expect(find.byIcon(Icons.arrow_forward), findsNothing);
    await tester.enterText(find.byType(TextField).first, 'misskey.io');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    // Compact card: display name only, no inline rules.
    expect(find.text('Misskey Hub'), findsOneWidget);
    expect(find.textContaining('Be nice'), findsNothing);

    // Only the checkbox toggles consent now (text is inert).
    final checkboxes = find.byType(Checkbox);
    await tester.ensureVisible(checkboxes.first);
    await tester.pumpAndSettle();
    await tester.tap(checkboxes.first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(checkboxes.at(1));
    await tester.pumpAndSettle();
    await tester.tap(checkboxes.at(1));
    await tester.pumpAndSettle();

    // Fake MiAuth succeeds → wizard advances to appearance.
    final miAuthButton = find.byIcon(Icons.login);
    await tester.ensureVisible(miAuthButton);
    await tester.pumpAndSettle();
    await tester.tap(miAuthButton);
    await tester.pumpAndSettle();
    expect(find.text('外观'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

    // Step 2 → step 3.
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    expect(find.text('一切就绪'), findsOneWidget);

    // Enter the app: unauthenticated session falls back to /login, and
    // completion is persisted.
    await tester.tap(find.text('进入 Nyachi'));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('oobe.completed'), isTrue);
  });

  testWidgets('back button returns to the previous step', (tester) async {
    await _pumpWizard(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    expect(find.text('Sign in to your instance'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Nyachi'), findsOneWidget);
  });
}
