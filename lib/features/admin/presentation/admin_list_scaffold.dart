// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/error_mapper.dart';
import '../../../core/ui/content_width.dart';
import '../../../core/ui/failure_action.dart';
import '../../../core/ui/l10n_ext.dart';

/// One page of an admin list: loads on open, reloads on retry, and shows the
/// failure with the standard retry action.
///
/// The admin screens are all "read a list from the server, act on one row", so
/// the loading/error scaffolding lives here once instead of in each page. The
/// builder receives the loaded rows and a reload callback so an action can
/// refresh in place.
class AdminListScaffold<T> extends ConsumerStatefulWidget {
  const AdminListScaffold({
    required this.title,
    required this.load,
    required this.builder,
    this.actions,
    this.emptyMessage,
    super.key,
  });

  final String title;
  final Future<List<T>> Function(WidgetRef ref) load;
  final Widget Function(
    BuildContext context,
    List<T> items,
    VoidCallback reload,
  )
  builder;
  final List<Widget>? actions;

  /// Shown instead of an empty list; defaults to the generic empty text.
  final String? emptyMessage;

  @override
  ConsumerState<AdminListScaffold<T>> createState() =>
      _AdminListScaffoldState<T>();
}

class _AdminListScaffoldState<T> extends ConsumerState<AdminListScaffold<T>> {
  List<T>? _items;
  Object? _error;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await widget.load(ref);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: widget.actions),
      body: switch ((_loading, error, _items)) {
        (true, _, _) => const Center(child: CircularProgressIndicator()),
        (_, final e?, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mapFailure(e).message(l10n), textAlign: TextAlign.center),
              FailureAction(failure: mapFailure(e), onRetry: _load),
            ],
          ),
        ),
        (_, _, final items?) => _buildBody(items),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildBody(List<T> items) {
    if (items.isEmpty) {
      return Center(
        child: Text(widget.emptyMessage ?? context.l10n.nothingHere),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: appMaxContentWidth),
        child: widget.builder(context, items, _load),
      ),
    );
  }
}
