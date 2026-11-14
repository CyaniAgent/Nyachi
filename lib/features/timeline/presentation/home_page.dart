// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/ui/compact_tab_bar.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
import '../../announcements/data/announcement_repository.dart';
import '../../notes/application/note_list_controller.dart';
import '../../notes/domain/note_feed_source.dart';
import '../../notes/presentation/note_list.dart';
import '../../shell/presentation/app_sidebar.dart';
import '../application/home_stream_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  static const _kinds = [
    HomeFeedKind.home,
    HomeFeedKind.local,
    HomeFeedKind.hybrid,
    HomeFeedKind.global,
  ];

  Timer? _autoRefresh;
  var _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoRefresh = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _refreshCurrent(),
    );
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _foreground = true;
      _refreshCurrent();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _foreground = false;
    }
  }

  Future<void> _refreshCurrent() async {
    if (!mounted || !_foreground) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    final controller = DefaultTabController.maybeOf(context);
    if (controller == null) return;
    final source = NoteFeedSource.home(_kinds[controller.index]);
    await ref.read(noteListControllerProvider(source).notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [l10n.home, l10n.local, l10n.hybrid, l10n.global];
    // Surface unread dialog announcements once, after the first frame.
    ref.listen(pendingDialogAnnouncementsProvider, (previous, current) {
      if (current.isEmpty) return;
      final known = previous == null
          ? const <String>{}
          : {for (final item in previous) item.id};
      final fresh = current.where((item) => !known.contains(item.id));
      if (fresh.isEmpty) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showAnnouncementDialog(fresh.first);
      });
    });
    return DefaultTabController(
      length: labels.length,
      child: Builder(
        builder: (context) {
          final controller = DefaultTabController.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.appTitle),
              leading: appBarDrawerLeading(context),
              actions: [
                IconButton(
                  tooltip: l10n.search,
                  onPressed: () => GoRouter.of(context).push('/search'),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                  child: CompactTabBar(labels: labels),
                ),
                Expanded(
                  child: TabBarView(
                    controller: controller,
                    children: const [
                      _TimelineTab(kind: HomeFeedKind.home),
                      _TimelineTab(kind: HomeFeedKind.local),
                      _TimelineTab(kind: HomeFeedKind.hybrid),
                      _TimelineTab(kind: HomeFeedKind.global),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAnnouncementDialog(Announcement announcement) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 20,
              color: Theme.of(dialogContext).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                announcement.title.isEmpty
                    ? l10n.announcements
                    : announcement.title,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(announcement.text),
              if (announcement.imageUrl case final url?)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: NyachiImage(url: url, fit: BoxFit.contain),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final read = ref.read(readAnnouncementsProvider.notifier);
              Navigator.of(dialogContext).pop();
              await read.markRead(announcement.id);
            },
            child: Text(l10n.create),
          ),
        ],
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
              Expanded(child: Text(text)),
              if (status == HomeStreamStatus.offline)
                TextButton(
                  onPressed: target.reconnect,
                  child: Text(context.l10n.retry),
                ),
            ],
          ),
        );
      },
    );
  }
}
