import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nyachi/src/core/utils/cache_manager.dart';
import 'package:nyachi/src/core/utils/logger.dart';
import 'package:nyachi/src/core/services/app_reset_service.dart';
import 'package:nyachi/src/core/services/misskey_image_cache_database.dart';
import 'package:nyachi/src/core/services/timeline_cache_database.dart';
import 'package:nyachi/src/features/auth/application/auth_service.dart';
import 'package:nyachi/src/core/widgets/settings_widgets.dart';
import 'package:nyachi/src/features/profile/presentation/widgets/settings_slider_bottom_sheet.dart';
import 'package:nyachi/src/shared/widgets/cyani_loading_indicator.dart';
import 'package:nyachi/src/shared/widgets/toast_helper.dart';

class CacheSettingsPage extends ConsumerStatefulWidget {
  const CacheSettingsPage({super.key});

  @override
  ConsumerState<CacheSettingsPage> createState() => _CacheSettingsPageState();
}

class _CacheSettingsPageState extends ConsumerState<CacheSettingsPage> {
  String? _cachePath;
  int _totalCacheSize = 0;
  int _sqliteCacheSize = 0;
  int? _cacheTimeLimit;

  int _contentImageSize = 0;
  int _contentAudioSize = 0;
  int _contentTimelineSize = 0;
  int _contentOtherSize = 0;
  int _sqliteTimelineSize = 0;
  int _sqliteAvatarSize = 0;
  int _sqlitePostImageSize = 0;
  int _sqliteEmojiSize = 0;
  int _sqliteBannerSize = 0;
  int _sqliteThumbnailSize = 0;
  int _sqliteOtherSize = 0;

  int _touchedContentIndex = -1;
  int _touchedSqliteIndex = -1;

  bool _isBasicSettingsLoading = true;
  bool _isStatsLoading = true;

  /// Generate a palette of distinct colors from the current ColorScheme.
  List<Color> _chartPalette(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = HSLColor.fromColor(scheme.primary);
    return [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      base.withHue((base.hue + 60) % 360).toColor(),
      base.withHue((base.hue + 120) % 360).toColor(),
      base.withHue((base.hue + 180) % 360).toColor(),
      base.withHue((base.hue + 240) % 360).toColor(),
      base.withHue((base.hue + 300) % 360).toColor(),
      scheme.error,
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadCacheSettings();
  }

  Future<void> _loadCacheSettings() async {
    final selectedMisskeyAccount = await ref.read(
      selectedMisskeyAccountProvider.future,
    );
    final currentAccountId = selectedMisskeyAccount?.id;
    cacheManager.setCurrentAccountId(currentAccountId);

    try {
      final cacheDir = await cacheManager.getCacheDirectory();
      final cacheTimeLimit = await cacheManager.getCacheTimeLimit();

      if (mounted) {
        setState(() {
          _cachePath = cacheDir.path;
          _cacheTimeLimit = cacheTimeLimit;
          _isBasicSettingsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isBasicSettingsLoading = false);
      logger.error('Error loading basic cache settings', e);
    }

    try {
      final totalSize = await cacheManager.getTotalCacheSize();
      final sqliteSize = await MisskeyImageCacheDatabase().getTotalCacheSize();

      final contentImage = await cacheManager.getCategoryCacheSize(CacheCategory.image);
      final contentAudio = await cacheManager.getCategoryCacheSize(CacheCategory.audio);
      final contentTimeline = await cacheManager.getCategoryCacheSize(CacheCategory.timeline);
      final contentOther = await cacheManager.getCategoryCacheSize(CacheCategory.other);

      final imageDb = MisskeyImageCacheDatabase();
      final sqliteByType = await imageDb.getCacheSizeByType();
      final avatarSize = sqliteByType['avatar'] ?? 0;
      final postImageSize = sqliteByType['postImage'] ?? 0;
      final bannerSize = sqliteByType['banner'] ?? 0;
      final emojiSize = sqliteByType['emoji'] ?? 0;
      final thumbnailSize = sqliteByType['thumbnail'] ?? 0;
      final sqliteOther = sqliteSize - avatarSize - postImageSize - bannerSize - emojiSize - thumbnailSize;

      final timelineSize = await TimelineCacheDatabase().getTotalApproximateSize();

      if (mounted) {
        setState(() {
          _totalCacheSize = totalSize;
          _sqliteCacheSize = sqliteSize;
          _contentImageSize = contentImage;
          _contentAudioSize = contentAudio;
          _contentTimelineSize = contentTimeline;
          _contentOtherSize = contentOther;
          _sqliteTimelineSize = timelineSize;
          _sqliteAvatarSize = avatarSize;
          _sqlitePostImageSize = postImageSize;
          _sqliteEmojiSize = emojiSize;
          _sqliteBannerSize = bannerSize;
          _sqliteThumbnailSize = thumbnailSize;
          _sqliteOtherSize = sqliteOther;
          _isStatsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isStatsLoading = false);
      logger.error('Error loading storage stats', e);
    }
  }

  Future<void> _selectCustomCacheDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择缓存目录',
      );

      if (selectedDirectory != null && mounted) {
        await cacheManager.setCustomCacheDirectory(selectedDirectory);
        await _loadCacheSettings();

        if (mounted) {
          showToast(title: '缓存目录已更新', type: ToastificationType.success);
        }
      }
    } catch (e) {
      logger.error('Error selecting cache directory', e);
      if (mounted) {
        showToast(title: '选择缓存目录失败: $e', type: ToastificationType.error);
      }
    }
  }

  Future<void> _resetApp() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认重置应用'),
        content: Text('这将清除所有账户、设置 and 缓存数据，使应用恢复到首次打开的状态。此操作无法撤销，应用将自动退出。'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确认重置'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref.read(appResetProvider.notifier).resetApp();
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('重置成功'),
              content: const Text('应用数据已清空。为了完成重置，应用需要关闭。请手动重新启动应用。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('好的'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          showToast(title: '重置失败: $e', type: ToastificationType.error);
        }
      }
    }
  }

  Future<void> _clearContentCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清除内容缓存'),
        content: const Text('确定要清除所有内容缓存文件吗？SQLite 缓存数据不受影响。此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await cacheManager.clearAllCache();
        setState(() => _isStatsLoading = true);
        await _loadCacheSettings();
        if (mounted) {
          showToast(title: '内容缓存已清除', type: ToastificationType.success);
        }
      } catch (e) {
        logger.error('Error clearing content cache', e);
        if (mounted) {
          showToast(title: '清除内容缓存失败: $e', type: ToastificationType.error);
        }
      }
    }
  }

  Future<void> _clearAllCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('你确定要清理全部缓存？'),
        content: const Text('这将会清理所有的缓存文件，并清理在本地数据库存放的所有缓存数据。确定继续清理？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确定清理'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await cacheManager.clearAllCache();
        await MisskeyImageCacheDatabase().clearAllSqliteCache();
        setState(() => _isStatsLoading = true);
        await _loadCacheSettings();
        if (mounted) {
          showToast(title: '全部缓存已清除', type: ToastificationType.success);
        }
      } catch (e) {
        logger.error('Error clearing all cache', e);
        if (mounted) {
          showToast(title: '清除全部缓存失败: $e', type: ToastificationType.error);
        }
      }
    }
  }

  bool get _isUnlimited => _cacheTimeLimit == null || _cacheTimeLimit == 0;

  void _showCacheTimeLimitPicker() {
    SettingsSliderBottomSheet.show(
      context: context,
      title: '缓存时间上限',
      initialValue: _cacheTimeLimit ?? 0,
      minValue: 0,
      maxValue: 365,
      step: 1,
      valueFormatter: (value) => value == 0 ? '不限时长' : '$value 天',
      onConfirm: (value) async {
        final days = value == 0 ? null : value;
        cacheManager.setCacheTimeLimit(days);
        await _loadCacheSettings();
        if (mounted) {
          showToast(title: '缓存时间上限已更新', type: ToastificationType.success);
        }
      },
      icon: Icons.access_time,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('存储设置')),
      body: _isBasicSettingsLoading
          ? const Center(child: CyaniLoadingIndicator())
          : ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              children: [
                // ── 缓存路径 ──────────────────────────────────
                SettingsCardGroup(
                  children: [
                    _cachePathRow(colorScheme),
                  ],
                ),

                const SizedBox(height: 16),

                // ── 缓存概览 ──────────────────────────────────
                _isStatsLoading
                    ? const Center(child: CyaniLoadingIndicator())
                    : Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildSectorChart(
                                    slices: [
                                      _SectorSlice('图片', _contentImageSize, _chartPalette(context)[0]),
                                      _SectorSlice('音频', _contentAudioSize, _chartPalette(context)[1]),
                                      _SectorSlice('时间线文件', _contentTimelineSize, _chartPalette(context)[2]),
                                      _SectorSlice('其他', _contentOtherSize, _chartPalette(context)[3]),
                                    ],
                                    touchedIndex: _touchedContentIndex,
                                    onTouch: (i) => setState(() => _touchedContentIndex = i),
                                    label: '内容缓存',
                                  )),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildSectorChart(
                                    slices: [
                                      _SectorSlice('时间线', _sqliteTimelineSize, _chartPalette(context)[0]),
                                      _SectorSlice('用户头像', _sqliteAvatarSize, _chartPalette(context)[4]),
                                      _SectorSlice('帖文图片', _sqlitePostImageSize, _chartPalette(context)[5]),
                                      _SectorSlice('表情', _sqliteEmojiSize, _chartPalette(context)[6]),
                                      _SectorSlice('横幅/缩略图', _sqliteBannerSize + _sqliteThumbnailSize, _chartPalette(context)[7]),
                                      _SectorSlice('其他', _sqliteOtherSize, _chartPalette(context)[3]),
                                    ],
                                    touchedIndex: _touchedSqliteIndex,
                                    onTouch: (i) => setState(() => _touchedSqliteIndex = i),
                                    label: 'SQLite 缓存',
                                  )),
                                ],
                              ),
                              if (_touchedContentIndex >= 0 || _touchedSqliteIndex >= 0) ...[
                                const SizedBox(height: 12),
                                _buildTooltip(colorScheme),
                              ],
                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('总计', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                  Text(
                                    _formatBytes(_totalCacheSize + _sqliteCacheSize),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                const SizedBox(height: 16),

                // ── 缓存时间上限 ──────────────────────────────
                SettingsCardGroup(
                  children: [
                    SettingsTile(
                      icon: Icons.access_time,
                      iconColor: _chartPalette(context)[0],
                      title: '缓存时间上限',
                      subtitle: _isUnlimited ? '不限时长' : '$_cacheTimeLimit 天',
                      onTap: _showCacheTimeLimitPicker,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── 缓存管理 ──────────────────────────────────
                SettingsCardGroup(
                  children: [
                    SettingsTile(
                      icon: Icons.delete_outline,
                      iconColor: _chartPalette(context)[8],
                      title: '清理内容缓存',
                      subtitle: '清除文件缓存，SQLite 数据不受影响',
                      onTap: _clearContentCache,
                    ),
                    SettingsTile(
                      icon: Icons.cleaning_services_outlined,
                      iconColor: _chartPalette(context)[8],
                      title: '清理全部缓存',
                      subtitle: '清除所有缓存文件及数据库数据',
                      onTap: _clearAllCache,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── 危险区域 ──────────────────────────────────
                SettingsCardGroup(
                  children: [
                    SettingsTile(
                      icon: Icons.refresh,
                      iconColor: Colors.red,
                      title: '重置此应用',
                      subtitle: 'storage_reset_app_warning'.tr(),
                      onTap: _resetApp,
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _cachePathRow(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _chartPalette(context)[0].withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_outlined, color: _chartPalette(context)[0], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('缓存目录', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  _cachePath ?? '未知',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.tonal(
            onPressed: _selectCustomCacheDirectory,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('更改'),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    if (bytes < 1024 * 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(1)} TB';
  }

  Widget _buildSectorChart({
    required List<_SectorSlice> slices,
    required int touchedIndex,
    required ValueChanged<int> onTouch,
    required String label,
  }) {
    final nonZeroSlices = slices.where((s) => s.size > 0).toList();
    final sections = List<PieChartSectionData>.generate(nonZeroSlices.length, (i) {
      final isTouched = touchedIndex == i;
      return PieChartSectionData(
        value: nonZeroSlices[i].size.toDouble(),
        color: nonZeroSlices[i].color,
        radius: isTouched ? 42 : 36,
        title: '',
        showTitle: false,
      );
    });

    if (sections.isEmpty) {
      sections.add(PieChartSectionData(
        value: 1,
        color: Colors.grey.shade300,
        radius: 36,
        title: '',
        showTitle: false,
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 0,
              sectionsSpace: 1,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                  if (response == null || response.touchedSection == null) {
                    onTouch(-1);
                    return;
                  }
                  onTouch(response.touchedSection!.touchedSectionIndex);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ...nonZeroSlices.map((s) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(s.label, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(
                _formatBytes(s.size),
                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTooltip(ColorScheme colorScheme) {
    final contentSlices = [
      _SectorSlice('图片', _contentImageSize, _chartPalette(context)[0]),
      _SectorSlice('音频', _contentAudioSize, _chartPalette(context)[1]),
      _SectorSlice('时间线文件', _contentTimelineSize, _chartPalette(context)[2]),
      _SectorSlice('其他', _contentOtherSize, _chartPalette(context)[3]),
    ];
    final sqliteSlices = [
      _SectorSlice('时间线', _sqliteTimelineSize, _chartPalette(context)[0]),
      _SectorSlice('用户头像', _sqliteAvatarSize, _chartPalette(context)[4]),
      _SectorSlice('帖文图片', _sqlitePostImageSize, _chartPalette(context)[5]),
      _SectorSlice('表情', _sqliteEmojiSize, _chartPalette(context)[6]),
      _SectorSlice('横幅/缩略图', _sqliteBannerSize + _sqliteThumbnailSize, _chartPalette(context)[7]),
      _SectorSlice('其他', _sqliteOtherSize, _chartPalette(context)[3]),
    ];

    _SectorSlice? slice;
    if (_touchedContentIndex >= 0 && _touchedContentIndex < contentSlices.length) {
      slice = contentSlices[_touchedContentIndex];
    } else if (_touchedSqliteIndex >= 0 && _touchedSqliteIndex < sqliteSlices.length) {
      slice = sqliteSlices[_touchedSqliteIndex];
    }

    if (slice == null) return const SizedBox.shrink();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withAlpha(180),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(slice.label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text(
              _formatBytes(slice.size),
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectorSlice {
  final String label;
  final int size;
  final Color color;
  const _SectorSlice(this.label, this.size, this.color);
}
