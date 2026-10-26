// SPDX-License-Identifier: AGPL-3.0-or-later

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

  DetailPanelController get _controller =>
      container.read(detailPanelControllerProvider.notifier);
  DetailPanelState get _state => container.read(detailPanelControllerProvider);

  void openFromFeed(DetailLocation location) {
    if (!isTabRootPath(_baseUri.path)) {
      router.push(location.location);
      return;
    }
    _controller.replaceStack(location);
    _writeCurrent();
  }

  void pushFromPanel(DetailLocation location) {
    if (!isTabRootPath(_baseUri.path)) {
      router.push(location.location);
      return;
    }
    _controller.push(location);
    _writeCurrent();
  }

  void popFromPanel() {
    _controller.pop();
    _writeCurrent();
  }

  void closeFromPanel() {
    _controller.close();
    _writeCurrent();
  }

  void syncFromUri(Uri uri, {required double width, required int breakpoint}) {
    _baseUri = uri;
    if (!isTabRootPath(uri.path)) {
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
