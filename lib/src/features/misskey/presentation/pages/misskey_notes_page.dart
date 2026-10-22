import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nyachi/src/features/misskey/application/misskey_notifier.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';
import 'misskey_clip_notes_page.dart';

/// Misskey 笔记页面组件
///
/// 这里展示全域时间线（Global Timeline）作为探索发现页面。
class MisskeyNotesPage extends ConsumerStatefulWidget {
  const MisskeyNotesPage({super.key});

  @override
  ConsumerState<MisskeyNotesPage> createState() => _MisskeyNotesPageState();
}

class _MisskeyNotesPageState extends ConsumerState<MisskeyNotesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(misskeyClipsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final clipsAsync = ref.watch(misskeyClipsProvider);
    final hasMore = ref.watch(misskeyClipsProvider.notifier).hasMore;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(misskeyClipsProvider.notifier).refresh(),
        child: clipsAsync.when(
          data: (clips) {
            if (clips.isEmpty) {
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        '${'misskey_page_clips'.tr()} ${'search_no_results'.tr()}',
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              controller: _scrollController,
              itemCount: clips.length + (hasMore ? 1 : 0),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                if (index < clips.length) {
                  final clip = clips[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          clip.user.avatarUrl ?? '',
                        ),
                        child: clip.user.avatarUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        clip.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (clip.description != null &&
                              clip.description!.isNotEmpty)
                            Text(
                              clip.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Text(
                            'By ${clip.user.name ?? clip.user.username}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                MisskeyClipNotesPage(clip: clip),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: CyaniLoadingIndicator(size: 30),
                    ),
                  );
                }
              },
            );
          },
          loading: () => const CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                child: Center(
                  child: CyaniLoadingIndicator(size: 60),
                ),
              ),
            ],
          ),
          error: (err, stack) => CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'common_loading_failed'.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: $err',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(misskeyClipsProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh),
                        label: Text('common_reload'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
