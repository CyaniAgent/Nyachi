import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nyachi/src/core/services/search/global_search_service.dart';
import 'package:nyachi/src/core/utils/logger.dart';
import 'package:nyachi/src/shared/widgets/circle_icon_button.dart';
import 'package:nyachi/src/shared/widgets/cyani_loading_indicator.dart';
import 'package:nyachi/src/shared/widgets/toast_helper.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await ref
          .read(globalSearchProvider.notifier)
          .search(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.error('SearchPage: 搜索错误: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showToast(title: 'Error: $e', type: ToastificationType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text;
    final misskeyUsers = _results
        .where((r) => r.source == 'misskey' && r.type == 'User')
        .toList();
    final misskeyNotes = _results
        .where((r) => r.source == 'misskey' && r.type == 'Note')
        .toList();
    final misskeyChannels = _results
        .where((r) => r.source == 'misskey' && r.type == 'Channel')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'search_enter_query'.tr(),
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            CircleIconButton(
              icon: Icons.clear,
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _results = [];
                });
              },
            ),
          CircleIconButton(
            icon: Icons.search,
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _performSearch(_searchController.text),
        child: _isLoading
            ? const Center(child: CyaniLoadingIndicator())
            : _results.isEmpty
            ? Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'search_enter_query'.tr()
                      : 'search_no_results'.tr(),
                ),
              )
            : ListView(
                children: [
                  if (misskeyUsers.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      'search_misskey_users_related'.tr(
                        namedArgs: {'search_result': query},
                      ),
                    ),
                    ...misskeyUsers.map((r) => _buildResultTile(context, r)),
                  ],
                  if (misskeyNotes.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      'search_misskey_posts_related'.tr(
                        namedArgs: {'search_result': query},
                      ),
                    ),
                    ...misskeyNotes.map((r) => _buildResultTile(context, r)),
                  ],
                  if (misskeyChannels.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      'search_misskey_channels_related'.tr(
                        namedArgs: {'search_result': query},
                      ),
                    ),
                    ...misskeyChannels.map((r) => _buildResultTile(context, r)),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, SearchResult result) {
    if (result.isDisabledMessage) {
      return ListTile(
        leading: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
        title: Text(result.title),
        subtitle: Text('search_feature_disabled_hint'.tr()),
      );
    }

    final sourceText = 'search_source_misskey'.tr();

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          result.type == 'User' ? Icons.person : result.type == 'Channel' ? Icons.forum : Icons.public,
          size: 20,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(result.title),
      subtitle: Text('$sourceText • ${result.type}\n${result.subtitle}'),
      isThreeLine: true,
      onTap: () {
        logger.info('SearchPage: 选择搜索结果: ${result.title}');
        // TODO: 实现导航到结果详情
      },
    );
  }
}
