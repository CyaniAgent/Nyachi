// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/ui/l10n_ext.dart';
import '../../notes/application/note_list_controller.dart';
import '../../notes/domain/note_feed_source.dart';
import '../../notes/presentation/note_list.dart';
import '../application/home_stream_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          actions: [
            IconButton(
              tooltip: l10n.compose,
              onPressed: () => context.push('/compose'),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.home),
              Tab(text: l10n.local),
              Tab(text: l10n.hybrid),
              Tab(text: l10n.global),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TimelineTab(kind: HomeFeedKind.home),
            _TimelineTab(kind: HomeFeedKind.local),
            _TimelineTab(kind: HomeFeedKind.hybrid),
            _TimelineTab(kind: HomeFeedKind.global),
          ],
        ),
      ),
    );
  }
}

class _TimelineTab extends ConsumerStatefulWidget {
  const _TimelineTab({required this.kind});

  final HomeFeedKind kind;

  @override
  ConsumerState<_TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends ConsumerState<_TimelineTab>
    with AutomaticKeepAliveClientMixin {
  StreamSubscription<Note>? _subscription;
  HomeStreamService? _service;

  NoteFeedSource get _source => NoteFeedSource.home(widget.kind);

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.kind == HomeFeedKind.home) {
      final service = ref.watch(homeStreamProvider);
      if (!identical(service, _service)) {
        unawaited(_subscription?.cancel());
        _service = service;
        _subscription = service.notes.listen((note) {
          ref
              .read(noteListControllerProvider(_source).notifier)
              .insertLiveNote(note);
        });
      }
    }
    return NoteList(
      source: _source,
      header: widget.kind == HomeFeedKind.home
          ? _StreamHeader(service: _service)
          : null,
    );
  }
}

class _StreamHeader extends StatelessWidget {
  const _StreamHeader({required this.service});

  final HomeStreamService? service;

  @override
  Widget build(BuildContext context) {
    final target = service;
    if (target == null) return const SizedBox.shrink();
    return ValueListenableBuilder<HomeStreamStatus>(
      valueListenable: target.status,
      builder: (context, status, _) {
        final text = switch (status) {
          HomeStreamStatus.reconnecting => context.l10n.liveReconnecting,
          HomeStreamStatus.offline => context.l10n.liveOffline,
          _ => null,
        };
        if (text == null) return const SizedBox.shrink();
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.wifi_off_outlined, size: 18),
              const SizedBox(width: 8),
              Text(text),
            ],
          ),
        );
      },
    );
  }
}
