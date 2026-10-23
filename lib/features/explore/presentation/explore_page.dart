// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/time_format.dart';
import '../../notes/domain/note_feed_source.dart';
import '../../notes/presentation/note_list.dart';
import '../application/explore_controllers.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final _text = TextEditingController();
  var _query = '';

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.explore),
          bottom: _query.isEmpty
              ? null
              : TabBar(
                  tabs: [
                    Tab(text: l10n.notesTab),
                    Tab(text: l10n.usersTab),
                  ],
                ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      decoration: InputDecoration(
                        hintText: l10n.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _submit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _submit(_text.text),
                    child: Text(l10n.searchSubmit),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _query.isEmpty
                  ? _Trends()
                  : TabBarView(
                      children: [
                        NoteList(
                          source: NoteFeedSource.search(_query),
                          emptyText: l10n.noSearchResults,
                        ),
                        _UserResults(query: _query),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(String value) {
    final query = value.trim();
    if (query == _query) return;
    setState(() => _query = query);
  }
}

class _Trends extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trends = ref.watch(trendsProvider);
    return trends.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(trendsProvider),
          child: Text(l10n.retry),
        ),
      ),
      data: (items) {
        if (items.isEmpty) return Center(child: Text(l10n.noTrends));
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final trend = items[index];
            return ListTile(
              leading: const Icon(Icons.tag),
              title: Text('#${trend.tag}'),
              trailing: Text(compactCount(context, trend.usersCount)),
              onTap: () =>
                  context.push('/tags/${Uri.encodeComponent(trend.tag)}'),
            );
          },
        );
      },
    );
  }
}

class _UserResults extends ConsumerWidget {
  const _UserResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(userSearchControllerProvider(query));
    final controller = ref.read(userSearchControllerProvider(query).notifier);
    if (state.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.items.isEmpty) {
      return Center(child: Text(state.error?.message(l10n) ?? l10n.noUsers));
    }
    return ListView.separated(
      itemCount: state.items.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          if (state.loadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.hasMore) {
            return Center(
              child: TextButton(
                onPressed: controller.loadMore,
                child: Text(l10n.loadMore),
              ),
            );
          }
          return const SizedBox(height: 24);
        }
        final user = state.items[index];
        return _UserTile(user: user);
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
      title: Text(user.name ?? user.username),
      subtitle: Text(
        '@${user.username}${user.host == null ? '' : '@${user.host}'}',
      ),
      onTap: () => context.push('/users/${user.id}'),
    );
  }
}
