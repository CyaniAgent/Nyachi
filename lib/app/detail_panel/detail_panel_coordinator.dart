// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'detail_location.dart';
import 'detail_panel_controller.dart';

const _tabRoots = {
  '/home',
  '/notifications',
  '/explore',
  '/chat',
  '/profile',
  '/settings',
};

bool isTabRootPath(String path) => _tabRoots.contains(path);

/// Reconciles the detail-panel stack with the `detail` query parameter.
class DetailPanelCoordinator {
  DetailPanelCoordinator({
    required this.container,
    required this.router,
    required Uri initialUri,
  }) : _baseUri = initialUri;

  final ProviderContainer container;
  final GoRouter router;
  Uri _baseUri;

  /// Bumped whenever the coordinator changes the stack itself.
  ///
  /// The panel host also reacts to pages disappearing from its Navigator,
  /// which is how a back gesture surfaces; without this counter a programmatic
  /// pop (closing the panel on a tab switch, say) would look like a user back
  /// and pop a second time.
  int _programmaticChange = 0;
  int get programmaticChange => _programmaticChange;

  DetailPanelController get _controller =>
      container.read(detailPanelControllerProvider.notifier);
  DetailPanelState get _state => container.read(detailPanelControllerProvider);

  void openFromFeed(DetailLocation location) {
    if (!isTabRootPath(_baseUri.path)) {
      router.push(location.location);
      return;
    }
    _programmaticChange++;
    _controller.replaceStack(location);
    _writeCurrent();
  }

  void pushFromPanel(DetailLocation location) {
    if (!isTabRootPath(_baseUri.path)) {
      router.push(location.location);
      return;
    }
    _programmaticChange++;
    _controller.push(location);
    _writeCurrent();
  }

  void popFromPanel() {
    _programmaticChange++;
    _controller.pop();
    _writeCurrent();
  }

  void closeFromPanel() {
    _programmaticChange++;
    _controller.close();
    _writeCurrent();
  }

  void syncFromUri(Uri uri, {required double width, required int breakpoint}) {
    _baseUri = uri;
    if (!isTabRootPath(uri.path)) {
      _programmaticChange++;
      _controller.close();
      if (uri.queryParameters.containsKey('detail')) {
        final next = _withoutDetail(uri);
        _baseUri = next;
        router.replace(next.toString());
      }
      return;
    }

    final raw = uri.queryParameters['detail'];
    if (raw == null) {
      _programmaticChange++;
      _controller.close();
      return;
    }
    final parsed = DetailLocation.parse(raw);
    if (parsed == null) {
      final next = _withoutDetail(uri);
      _baseUri = next;
      _controller.close();
      router.replace(next.toString());
      return;
    }
    if (width < breakpoint) {
      downgradeToFullPage(parsed);
      return;
    }
    if (_state.top == parsed) return;
    _controller.replaceStack(parsed);
  }

  void downgradeToFullPage(DetailLocation location) {
    _programmaticChange++;
    _controller.close();
    router.go(location.location);
  }

  void _writeCurrent() {
    if (!isTabRootPath(_baseUri.path)) return;
    final query = Map<String, String>.of(_baseUri.queryParameters);
    final top = _state.top;
    if (top == null) {
      query.remove('detail');
    } else {
      query['detail'] = top.location;
    }
    final next = _withQuery(_baseUri, query);
    if (next.toString() == _baseUri.toString()) return;
    _baseUri = next;
    router.replace(next.toString());
  }

  Uri _withoutDetail(Uri uri) {
    final query = Map<String, String>.of(uri.queryParameters)..remove('detail');
    return _withQuery(uri, query);
  }

  Uri _withQuery(Uri uri, Map<String, String> query) {
    if (query.isNotEmpty) return uri.replace(queryParameters: query);
    if (!uri.hasAuthority) {
      return Uri(
        path: uri.path,
        fragment: uri.hasFragment ? uri.fragment : null,
      );
    }
    return Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
      fragment: uri.hasFragment ? uri.fragment : null,
    );
  }
}

/// Publishes the coordinator owned by the live shell.
///
/// Back handling runs with the root navigator's context, which sits above the
/// shell and therefore cannot reach [DetailPanelScope]; going through a
/// provider keeps the single coordinator reachable from there.
final detailPanelCoordinatorProvider =
    Provider<ValueNotifier<DetailPanelCoordinator?>>((ref) {
      final notifier = ValueNotifier<DetailPanelCoordinator?>(null);
      ref.onDispose(notifier.dispose);
      return notifier;
    });
