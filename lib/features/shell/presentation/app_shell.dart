// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/shell_navigation.dart';

/// Binds the active [StatefulNavigationShell] to [shellNavigationProvider].
///
/// The persistent navigation chrome lives in `RootShell`, above the shell
/// navigator, so pushed detail routes cannot cover it.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  ValueNotifier<StatefulNavigationShell?> get _notifier =>
      ref.read(shellNavigationProvider);

  @override
  void initState() {
    super.initState();
    _bind();
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.navigationShell, widget.navigationShell)) {
      _bind();
    }
  }

  void _bind() {
    final notifier = _notifier;
    if (identical(notifier.value, widget.navigationShell)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) notifier.value = widget.navigationShell;
    });
  }

  @override
  Widget build(BuildContext context) => widget.navigationShell;
}
