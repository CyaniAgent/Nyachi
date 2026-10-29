// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/auth/session_controller.dart';
import '../../core/ui/l10n_ext.dart';
import '../../features/settings/application/app_settings.dart';
import '../../features/shell/presentation/root_shell.dart';
import 'navigator_keys.dart';
import 'router_guards.dart';
import 'routes.dart';

part 'app_router.g.dart';

class _RouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = _RouterRefresh();
  ref.onDispose(refresh.dispose);
  ref.listen(sessionControllerProvider, (previous, next) {
    refresh.refresh();
  });
  ref.listen(settingsControllerProvider, (previous, next) {
    refresh.refresh();
  });
  final authenticatedRoutes = $appRoutes
      .where(
        (route) =>
            !(route is GoRoute &&
                (route.path == '/login' ||
                    route.path == '/add-account' ||
                    route.path == '/oobe')),
      )
      .toList(growable: false);
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    routes: [
      $loginRoute,
      $addAccountRoute,
      $oobeRoute,
      ShellRoute(
        navigatorKey: appShellNavigatorKey,
        builder: (context, state, child) =>
            RootShell(uri: state.uri, child: child),
        routes: authenticatedRoutes,
      ),
    ],
    redirect: (context, state) => authRedirect(
      ref.read(sessionControllerProvider),
      state.matchedLocation,
      oobeCompleted: ref.read(settingsControllerProvider).oobeCompleted,
    ),
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.l10n.notFound)),
      );
    },
  );
}
