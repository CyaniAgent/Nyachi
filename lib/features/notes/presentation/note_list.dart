// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../core/ui/failure_action.dart';
import '../../../core/ui/l10n_ext.dart';
import '../application/note_list_controller.dart';
import '../domain/note_feed_source.dart';
import 'note_card.dart';

class NoteList extends ConsumerWidget {
  const NoteList({
    required this.source,
    this.header,
    this.emptyText,
    super.key,
  });

  final NoteFeedSource source;
  final Widget? header;
  final String? emptyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(noteListControllerProvider(source));
    final controller = ref.read(noteListControllerProvider(source).notifier);
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: _content(context, state, controller, l10n),
    );
  }

  Widget _content(
    BuildContext context,
    NoteListState state,
    NoteListController controller,
    AppLocalizations l10n,
  ) {
    if ((state.initialLoading || state.refreshing) && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final showEmpty = state.items.isEmpty && !state.refreshing;
    final bannerCount =
        (state.usingCache ? 1 : 0) +
        (state.error != null && state.items.isNotEmpty ? 1 : 0) +
        (header == null ? 0 : 1);
    final footer = state.items.isNotEmpty && state.hasMore ? 1 : 0;
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount:
          state.items.length + bannerCount + footer + (showEmpty ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        var cursor = 0;
        if (header != null) {
          if (index == cursor) return header!;
          cursor++;
        }
        if (state.usingCache) {
          if (index == cursor) {
            return _Banner(
              icon: Icons.cloud_off_outlined,
              text: l10n.usingCache,
            );
          }
          cursor++;
        }
        if (state.error != null && state.items.isNotEmpty) {
          if (index == cursor) {
            return _Banner(
              icon: Icons.error_outline,
              text: state.error!.message(l10n),
              action: FailureAction(
                failure: state.error!,
                onRetry: controller.refresh,
              ),
            );
          }
          cursor++;
        }
        if (showEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Center(
              child: Column(
                children: [
                  Text(emptyText ?? l10n.emptyTimeline),
                  if (state.error != null)
                    FailureAction(
                      failure: state.error!,
                      onRetry: controller.refresh,
                    ),
                ],
              ),
            ),
          );
        }
        final noteIndex = index - cursor;
        if (noteIndex < state.items.length) {
          return NoteCard(note: state.items[noteIndex]);
        }
        if (state.loadingMore) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: TextButton(
              onPressed: controller.loadMore,
              child: Text(l10n.loadMore),
            ),
          ),
        );
      },
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          ?action,
        ],
      ),
    );
  }
}
