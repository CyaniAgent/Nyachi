// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/auth/session_controller.dart';
import '../../core/ui/l10n_ext.dart';
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
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    routes: $appRoutes,
    redirect: (context, state) => authRedirect(
      ref.read(sessionControllerProvider),
      state.matchedLocation,
    ),
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.l10n.notFound)),
      );
    },
  );
}
