import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nyachi/src/features/misskey/application/misskey_notifier.dart';
import 'package:nyachi/src/features/misskey/domain/channel.dart';
import 'package:nyachi/src/features/misskey/presentation/pages/misskey_channel_details_page.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';

/// Misskey 频道页面组件
///
/// 显示频道列表，支持精选、收藏、关注和管理分类。
class MisskeyChannelsPage extends ConsumerStatefulWidget {
  /// 创建一个新的MisskeyChannelsPage实例
  const MisskeyChannelsPage({super.key});

  @override
  ConsumerState<MisskeyChannelsPage> createState() =>
      _MisskeyChannelsPageState();
}

class _MisskeyChannelsPageState extends ConsumerState<MisskeyChannelsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('misskey_page_channels'.tr()),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'channels_tab_featured'.tr()),
            Tab(text: 'channels_tab_favorites'.tr()),
            Tab(text: 'channels_tab_following'.tr()),
            Tab(text: 'channels_tab_managing'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChannelGrid(MisskeyChannelListType.featured),
          _buildChannelGrid(MisskeyChannelListType.favorites),
          _buildChannelGrid(MisskeyChannelListType.following),
          _buildChannelGrid(MisskeyChannelListType.managing),
        ],
      ),
    );
  }

  Widget _buildChannelGrid(MisskeyChannelListType type, {String? query}) {
    if (type == MisskeyChannelListType.search &&
        (query == null || query.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text('channels_search_hint'.tr()),
          ],
        ),
      );
    }

    final channelsAsync = ref.watch(
      misskeyChannelsProvider(type: type, query: query),
    );

    return channelsAsync.when(
      data: (channels) {
        if (channels.isEmpty) {
          return _buildEmptyState(context, type);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // 响应式布局：桌面端3列，平板端2列，手机端1列（流体）
            int crossAxisCount = 1;
            if (constraints.maxWidth > 1200) {
              crossAxisCount = 3;
            } else if (constraints.maxWidth > 700) {
              crossAxisCount = 2;
            }

            return RefreshIndicator(
              onRefresh: () => ref
                  .read(
                    misskeyChannelsProvider(type: type, query: query).notifier,
                  )
                  .refresh(),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: crossAxisCount == 1 ? 2.2 : 1.3,
                ),
                itemCount: channels.length,
                itemBuilder: (context, index) {
                  if (index == channels.length - 1) {
                    Future.microtask(
                      () => ref
                          .read(
                            misskeyChannelsProvider(
                              type: type,
                              query: query,
                            ).notifier,
                          )
                          .loadMore(),
                    );
                  }
                  final channel = channels[index];
                  return _buildChannelCard(context, channel);
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CyaniLoadingIndicator()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
              onPressed: () => ref
                  .read(
                    misskeyChannelsProvider(type: type, query: query).notifier,
                  )
                  .refresh(),
              icon: const Icon(Icons.refresh),
              label: Text('common_reload'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelCard(BuildContext context, Channel channel) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MisskeyChannelDetailsPage(channel: channel),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Image or Placeholder
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (channel.bannerUrl != null)
                    Image.network(
                      channel.bannerUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    )
                  else
                    Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.forum_outlined,
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        size: 32,
                      ),
                    ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Channel Name on Banner
                  Positioned(
                    bottom: 8,
                    left: 12,
                    right: 12,
                    child: Text(
                      channel.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.surface,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Description & Stats
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.description ?? 'channels_no_description'.tr(),
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildStat(
                          context,
                          Icons.people_outline,
                          '${channel.usersCount}',
                          theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        _buildStat(
                          context,
                          Icons.article_outlined,
                          '${channel.notesCount}',
                          theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    IconData icon,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, MisskeyChannelListType type) {
    String message = 'search_no_results'.tr();
    if (type == MisskeyChannelListType.featured) {
      message = 'search_no_results'.tr();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
