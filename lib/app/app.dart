// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/instance_repository.dart';
import '../core/ui/app_scroll_behavior.dart';
import '../core/ui/breakpoints.dart';
import '../core/ui/l10n_ext.dart';
import '../features/settings/application/app_settings.dart';
import 'bootstrap.dart';
import '../core/l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class NyachiApp extends ConsumerWidget {
  const NyachiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(bootstrapProvider);
    final settings = ref.watch(settingsControllerProvider);
    final instance = ref.watch(instanceInfoProvider).value;
    final seed = settings.accentColor == 'instance'
        ? parseThemeColor(instance?.themeColor)
        : parseThemeColor(settings.accentColor);
    final themeMode = parseThemeMode(settings.themeMode);
    final locale = _locale(settings.localeCode);
    final view = View.of(context);
    final isWide =
        view.physicalSize.width / view.devicePixelRatio >= kCompactBreakpoint;
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        // "Follow system" hands the palette to the platform: Android's Material
        // You wallpaper colours, the Windows accent colour, or the Linux
        // portal equivalent. Platforms that cannot report one yield null, and
        // the seed below is used instead.
        final followSystem = settings.accentColor == 'system';
        final theme = buildAppTheme(
          brightness: Brightness.light,
          seed: seed,
          isWide: isWide,
          colorScheme: followSystem ? lightDynamic : null,
        );
        final darkTheme = buildAppTheme(
          brightness: Brightness.dark,
          seed: seed,
          isWide: isWide,
          colorScheme: followSystem ? darkDynamic : null,
        );

        if (bootstrap.isLoading) {
          return MaterialApp(
            title: 'Nyachi',
            debugShowCheckedModeBanner: false,
            theme: theme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            scrollBehavior: const AppScrollBehavior(),
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const _BootstrapSplash(),
          );
        }
        if (bootstrap.hasError) {
          return MaterialApp(
            title: 'Nyachi',
            debugShowCheckedModeBanner: false,
            theme: theme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            scrollBehavior: const AppScrollBehavior(),
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: _BootstrapError(
              onRetry: () => ref.invalidate(bootstrapProvider),
            ),
          );
        }
        return MaterialApp.router(
          title: 'Nyachi',
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          scrollBehavior: const AppScrollBehavior(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: ref.watch(appRouterProvider),
        );
      },
    );
  }

  Locale? _locale(String code) {
    return switch (code) {
      'zh' => const Locale('zh'),
      'en' => const Locale('en'),
      'ja' => const Locale('ja'),
      _ => null,
    };
  }
}

class _BootstrapSplash extends StatelessWidget {
  const _BootstrapSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(context.l10n.loading),
          ],
        ),
      ),
    );
  }
}

class _BootstrapError extends StatelessWidget {
  const _BootstrapError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(context.l10n.errorGeneric),
            const SizedBox(height: 8),
            FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}
