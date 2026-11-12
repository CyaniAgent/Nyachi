// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A root back-button dispatcher that swallows back events arriving in a
/// burst.
///
/// Two rapid back presses race each other: the first pop is still settling
/// (route removal, shell rebuild) when the second arrives, so the router
/// pops one route further than the user asked — twice from a page above the
/// shell lands on the tab, and a pop from an empty root exits the app.
/// Rapid double-back "exits the app from a subpage" is exactly this race.
/// Within the throttle window the second event is reported as handled
/// without reaching the router.
class ThrottledBackButtonDispatcher extends RootBackButtonDispatcher {
  /// How long after a delivered back event further ones are dropped.
  static const _window = Duration(milliseconds: 250);

  int _lastHandledAt = 0;

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) {
    final now = DateTime.now().microsecondsSinceEpoch;
    final elapsed = now - _lastHandledAt;
    if (elapsed < _window.inMicroseconds) {
      return SynchronousFuture<bool>(true);
    }
    _lastHandledAt = now;
    return super.invokeCallback(defaultValue);
  }
}

/// A [RouterConfig] that delegates everything to [inner] but installs the
/// throttled dispatcher.
///
/// `MaterialApp.router` refuses a `backButtonDispatcher` alongside a
/// `routerConfig`, so the throttle has to travel inside the config. GoRouter
/// implements RouterConfig itself with no injection point for the dispatcher,
/// hence this wrapper.
class ThrottledRouterConfig<T> implements RouterConfig<T> {
  ThrottledRouterConfig({required this.inner})
    : backButtonDispatcher = ThrottledBackButtonDispatcher();

  final RouterConfig<T> inner;

  @override
  BackButtonDispatcher backButtonDispatcher;

  @override
  RouteInformationProvider? get routeInformationProvider =>
      inner.routeInformationProvider;

  @override
  RouteInformationParser<T>? get routeInformationParser =>
      inner.routeInformationParser;

  @override
  RouterDelegate<T> get routerDelegate => inner.routerDelegate;
}
