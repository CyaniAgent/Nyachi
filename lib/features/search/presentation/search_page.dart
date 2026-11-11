// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/ui/compact_tab_bar.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
import '../../../core/ui/scroll_edge_loader.dart';
import '../../explore/application/explore_controllers.dart';
import '../../notes/domain/note_feed_source.dart';
import '../../notes/presentation/note_list.dart';

/// Note and user search. Reached from the tab AppBar magnifier (and the MFM
/// `search` function); the discovery tab holds the trends instead.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({this.initialQuery, super.key});

  /// A query carried in from elsewhere (an MFM `$[search ...]` function, say),
  /// so the page opens on its results instead of the empty field.
  final String? initialQuery;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _text = TextEditingController();
  var _query = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery;
    if (initial != null && initial.isNotEmpty) {
      _query = initial;
      _text.text = initial;
    }
  }

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
        appBar: AppBar(title: Text(l10n.search)),
        body: Column(
          children: [
            if (_query.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                child: CompactTabBar(labels: [l10n.notesTab, l10n.usersTab]),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
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
            Expanded(
              child: _query.isEmpty
                  ? Center(
                      child: Text(
                        l10n.searchHint,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
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
    return ScrollEdgeLoader(
      canLoad: () {
        final current = ref.read(userSearchControllerProvider(query));
        return current.hasMore && !current.loadingMore;
      },
      onEdge: controller.loadMore,
      child: ListView.separated(
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
            return const SizedBox(height: 24);
          }
          final user = state.items[index];
          return _UserTile(user: user);
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: nyachiImageProvider(user.avatarUrl),
      ),
      title: Text(user.name ?? user.username),
      subtitle: Text(
        '@${user.username}${user.host == null ? '' : '@${user.host}'}',
      ),
      onTap: () => openDetail(context, UserDetailLocation(user.id)),
    );
  }
}
