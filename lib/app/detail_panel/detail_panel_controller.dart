// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/storage/storage_providers.dart';
import '../theme/app_theme.dart';
import 'detail_location.dart';

part 'detail_panel_controller.g.dart';

@immutable
class DetailPanelState {
  const DetailPanelState({required this.stack, required this.width});

  final List<DetailLocation> stack;
  final double width;

  bool get isOpen => stack.isNotEmpty;
  DetailLocation? get top => stack.isEmpty ? null : stack.last;

  DetailPanelState copyWith({List<DetailLocation>? stack, double? width}) {
    return DetailPanelState(
      stack: stack ?? this.stack,
      width: width ?? this.width,
    );
  }
}

@Riverpod(keepAlive: true)
class DetailPanelController extends _$DetailPanelController {
  static const widthKey = 'layout.detailPanelWidth';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  DetailPanelState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getDouble(widthKey) ?? appDetailPanelDefaultWidth;
    return DetailPanelState(
      stack: const [],
      width: stored
          .clamp(appDetailPanelMinWidth, appDetailPanelMaxWidth)
          .toDouble(),
    );
  }

  void replaceStack(DetailLocation location) {
    state = state.copyWith(stack: [location]);
  }

  void push(DetailLocation location) {
    if (state.top == location) return;
    state = state.copyWith(stack: [...state.stack, location]);
  }

  void pop() {
    if (state.stack.isEmpty) return;
    if (state.stack.length == 1) {
      close();
      return;
    }
    state = state.copyWith(
      stack: state.stack.sublist(0, state.stack.length - 1),
    );
  }

  void close() {
    if (state.stack.isEmpty) return;
    state = state.copyWith(stack: const []);
  }

  void setWidth(double value) {
    state = state.copyWith(
      width: value
          .clamp(appDetailPanelMinWidth, appDetailPanelMaxWidth)
          .toDouble(),
    );
  }

  Future<void> persistWidth() => _prefs.setDouble(widthKey, state.width);

  void resetWidth() {
    state = state.copyWith(width: appDetailPanelDefaultWidth);
  }
}
