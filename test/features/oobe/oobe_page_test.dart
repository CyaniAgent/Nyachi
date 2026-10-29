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
  testWidgets('wizard walks language → done and persists completion', (
    tester,
  ) async {
    await _pumpWizard(tester);
    await tester.pumpAndSettle();

    // Step 0: switch language to Chinese; titles switch immediately.
    expect(find.text('Choose a language'), findsOneWidget);
    await tester.tap(find.text('简体中文'));
    await tester.pumpAndSettle();
    expect(find.text('选择语言'), findsOneWidget);
    expect(find.text('Choose a language'), findsNothing);

    // Step 1: welcome, in Chinese.
    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();
    expect(find.text('欢迎使用 Nyachi'), findsOneWidget);

    // Step 2: compliance + sign-in. Enter host, commit, both consents.
    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();
    expect(find.text('登录实例'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'misskey.io');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.textContaining('Be nice'), findsOneWidget);

    final appRow = find.text('我已阅读并同意应用条款与隐私政策');
    await tester.ensureVisible(appRow);
    await tester.pumpAndSettle();
    await tester.tap(appRow);
    await tester.pumpAndSettle();
    final instanceRow = find.text('我已阅读并同意该实例的服务条款');
    await tester.ensureVisible(instanceRow);
    await tester.pumpAndSettle();
    await tester.tap(instanceRow);
    await tester.pumpAndSettle();

    // Fake MiAuth succeeds → wizard advances to appearance.
    final miAuthButton = find.byIcon(Icons.login);
    await tester.ensureVisible(miAuthButton);
    await tester.pumpAndSettle();
    await tester.tap(miAuthButton);
    await tester.pumpAndSettle();
    expect(find.text('外观'), findsOneWidget);

    // Step 3 → step 4.
    await tester.tap(find.text('下一步'));
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

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Nyachi'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a language'), findsOneWidget);
  });
}
