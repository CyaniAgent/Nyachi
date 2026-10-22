// Nyachi应用程序的主组件文件
//
// 该文件包含应用程序的根组件NyachiApp，负责配置应用程序的主题、路由和整体结构。
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';
import 'core/core.dart';
import 'core/theme/font_manager.dart';
import 'core/theme/font_refresh_notifier.dart';
import 'core/services/dynamic_color_service.dart';
import 'routing/router.dart';
import 'features/misskey/application/misskey_streaming_service.dart';
import 'features/misskey/application/misskey_notifier.dart';
import 'features/misskey/application/misskey_notifications_notifier.dart';
import 'features/profile/presentation/settings/appearance_page.dart';
import 'features/welcome/application/welcome_state.dart';
import 'core/services/notification_manager.dart';
import 'features/update/application/update_notifier.dart';
import 'features/update/presentation/update_bottom_sheet.dart';
import 'core/services/audio_engine.dart';
import 'core/services/timeline_cache_database.dart';
import 'shared/widgets/custom_title_bar.dart';

/// Nyachi应用程序的根组件
///
/// 负责配置应用程序的主题、路由和整体结构，
/// 是整个应用程序的入口组件。
///
/// 主要功能：
/// - 管理应用程序的主题（支持亮色/暗色模式）
/// - 处理路由配置
/// - 初始化Misskey流媒体服务
/// - 响应外观设置的变化
class NyachiApp extends ConsumerStatefulWidget {
  const NyachiApp({super.key});

  @override
  ConsumerState<NyachiApp> createState() => _NyachiAppState();
}

/// NyachiApp的状态管理类
///
/// 负责管理应用程序的状态，包括主题缓存和外观设置。
class _NyachiAppState extends ConsumerState<NyachiApp>
    with WidgetsBindingObserver {
  /// 缓存的亮色主题
  ThemeData? _cachedLightTheme;

  /// 缓存的暗色主题
  ThemeData? _cachedDarkTheme;

  /// 缓存的亮色外观设置
  AppearanceSettings? _cachedLightSettings;

  /// 缓存的暗色外观设置
  AppearanceSettings? _cachedDarkSettings;

  /// 缓存的亮色动态 ColorScheme（用于缓存键比较）
  ColorScheme? _cachedLightDynamicScheme;

  /// 缓存的暗色动态 ColorScheme
  ColorScheme? _cachedDarkDynamicScheme;

  /// 标题栏 controller，仅创建一次
  final TitleBarController _titleBarController = TitleBarController();

  @override
  void initState() {
    super.initState();
    // 注册生命周期观察者
    WidgetsBinding.instance.addObserver(this);

    // 初始化动态取色服务（实时监听系统主题色变化）
    DynamicColorService.instance.initialize();

    // 初始化性能监控
    performanceMonitor.initialize();

    // 延迟检查更新（等待 UI 就绪）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(updateProvider.notifier).checkForUpdate(silent: true);
    });

    // 延迟检测 SQLite 并触发启动刷新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTimelinesOnStartup();
    });
  }

  @override
  void dispose() {
    // 移除生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    // 清理动态取色服务
    DynamicColorService.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    logger.debug('NyachiApp: 应用生命周期状态变化: $state');

    if (state == AppLifecycleState.resumed) {
      // 应用回到前台时刷新数据
      logger.info('NyachiApp: 应用回到前台，恢复实时心跳...');

      // 恢复前台心跳频率 (30s)
      ref
          .read(misskeyStreamingServiceProvider.notifier)
          .setBackgroundMode(false);

      // 重新连接 Misskey 流媒体服务
      ref.read(misskeyStreamingServiceProvider.notifier).reconnect();

      // 刷新 Misskey 各种 Provider (如果已挂载)
      ref.invalidate(misskeyNotificationsProvider);
      _refreshTimelinesOnStartup();
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // 应用进入后台：降低心跳频率省电，保留通知流/时间线流
      logger.info('NyachiApp: 应用进入后台，降低心跳频率...');
      ref
          .read(misskeyStreamingServiceProvider.notifier)
          .setBackgroundMode(true);
    }

    if (state == AppLifecycleState.detached) {
      // 应用完全退出时清理资源
      logger.info('NyachiApp: 应用正在退出，清理资源...');

      // 保存所有缓存到持久化存储
      try {
        MisskeyTimelineNotifier.cacheManager.saveAllToStorage();
        logger.info('NyachiApp: 缓存已保存到持久化存储');
      } catch (e) {
        logger.warning('NyachiApp: 保存缓存失败: $e');
      }

      // 清理Misskey流媒体服务
      ref.read(misskeyStreamingServiceProvider.notifier).dispose();
      // 清理通知管理器
      ref.read(notificationManagerProvider).stop();
      logger.info('NyachiApp: 资源清理完成');
    }
  }

  /// 启动时检测 SQLite 并触发时间线刷新
  Future<void> _refreshTimelinesOnStartup() async {
    try {
      final shouldRefresh = await TimelineCacheDatabase().shouldRefresh('Home');
      if (!shouldRefresh) return;

      logger.info('NyachiApp: SQLite 记录过期，触发 Home 时间线刷新');
      ref.read(misskeyTimelineProvider('Home').notifier).refresh();
    } catch (e) {
      if (e.toString().contains('disposed')) return;
      logger.warning('NyachiApp: 启动刷新失败: $e');
    }
  }

  /// 构建应用程序的UI
  ///
  /// 加载外观设置，初始化服务，并根据设置构建应用程序界面。
  ///
  /// @param context 构建上下文
  /// @return 返回MaterialApp.router组件，作为应用程序的根组件
  @override
  Widget build(BuildContext context) {
    logger.info('NyachiApp: 初始化应用程序');

    final goRouter = ref.watch(goRouterProvider);
    logger.debug('NyachiApp: 加载路由配置');

    // 监听欢迎页完成状态，触发路由刷新
    ref.listen(welcomeCompletedProvider, (prev, next) {
      routerRefreshNotifier.value++;
    });

    // Get appearance settings
    final appearanceSettingsAsync = ref.watch(appearanceSettingsProvider);

    // Initialize Misskey Streaming Service at app level
    logger.debug('NyachiApp: 初始化Misskey流媒体服务');
    ref.watch(misskeyStreamingServiceProvider);

    // 监听字体刷新状态以触发重建
    ref.watch(fontRefreshProvider);

    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    final toastConfig = ToastificationConfig(
      alignment: isDesktop ? Alignment.topRight : Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 300),
      applyMediaQueryViewInsets: false,
    );

    return appearanceSettingsAsync.when(
      loading: () => Container(color: Colors.white),
      error: (error, stack) {
        logger.error('NyachiApp: 加载外观设置失败', error);
        // 使用默认设置
        const defaultSettings = AppearanceSettings(
          displayMode: ThemeMode.system,
          useDynamicColor: true,
          useCustomColor: false,
          primaryColor: null,
        );
        final theme = _buildTheme(defaultSettings, Brightness.light);
        return GlobalFontRefresher(
          child: _UpdateHandler(
            child: ToastificationWrapper(
              config: toastConfig,
              child: MaterialApp.router(
                routerConfig: goRouter,
                title: 'Nyachi',
                theme: theme,
                darkTheme: _buildTheme(defaultSettings, Brightness.dark),
                themeMode: defaultSettings.displayMode,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                builder: (context, child) => child!,
              ),
            ),
          ),
        );
      },
      data: (appearanceSettings) {
        logger.debug(
          'NyachiApp: 加载外观设置 - 显示模式: ${appearanceSettings.displayMode}, 动态色彩: ${appearanceSettings.useDynamicColor}',
        );

        final colorService = DynamicColorService.instance;

        return ListenableBuilder(
          listenable: colorService.accentColor,
          builder: (context, _) {
            // 从 DynamicColorService 获取实时 ColorScheme
            final lightScheme = (appearanceSettings.useDynamicColor && colorService.lightScheme != null)
                ? colorService.lightScheme!.harmonized()
                : null;
            final darkScheme = (appearanceSettings.useDynamicColor && colorService.darkScheme != null)
                ? colorService.darkScheme!.harmonized()
                : null;

            // 构建主题
            final theme = _buildTheme(appearanceSettings, Brightness.light, dynamicColorScheme: lightScheme);
            final darkTheme = _buildTheme(appearanceSettings, Brightness.dark, dynamicColorScheme: darkScheme);

            final useCustomTitleBar =
                isDesktop && appearanceSettings.useCustomTitleBar;

            // 非自定义标题栏时恢复系统标题栏
            if (isDesktop && !useCustomTitleBar) {
              windowManager.setTitleBarStyle(TitleBarStyle.normal);
            }

            logger.debug('NyachiApp: 构建MaterialApp');

            Widget app = GlobalFontRefresher(
              child: _UpdateHandler(
                child: ToastificationWrapper(
                  config: toastConfig,
                  child: MaterialApp.router(
                    routerConfig: goRouter,
                    title: 'Nyachi',
                    theme: theme,
                    darkTheme: darkTheme,
                    themeMode: appearanceSettings.displayMode,
                    debugShowCheckedModeBanner: false,
                    localizationsDelegates: context.localizationDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,
                    builder: (context, child) {
                      if (useCustomTitleBar) {
                        return Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: M3ETitleBarTokens.standard.height,
                              ),
                              child: child!,
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: ListenableBuilder(
                                listenable: _titleBarController,
                                builder: (context, _) =>
                                    CustomTitleBar(controller: _titleBarController),
                              ),
                            ),
                          ],
                        );
                      }
                      return child!;
                    },
                  ),
                ),
              ),
            );

            if (useCustomTitleBar) {
              app = TitleBarScope(controller: _titleBarController, child: app);
            }

            return app;
          },
        );
      },
    );
  }

  /// 构建主题
  ///
  /// 根据用户的外观设置构建主题，支持深色模式、动态色彩和自定义颜色。
  /// 会缓存构建结果，避免重复计算。
  ///
  /// @param settings 用户的外观设置，包含显示模式、动态色彩和自定义颜色选项
  /// @param brightness 主题亮度，Brightness.light或Brightness.dark
  /// @param dynamicColorScheme 系统动态取色方案（可选）
  /// @return 返回构建的ThemeData对象
  ThemeData _buildTheme(AppearanceSettings settings, Brightness brightness, {ColorScheme? dynamicColorScheme}) {
    final isDark = brightness == Brightness.dark;
    final themeCache = isDark ? _cachedDarkTheme : _cachedLightTheme;
    final cachedSettings = isDark ? _cachedDarkSettings : _cachedLightSettings;
    final cachedScheme = isDark ? _cachedDarkDynamicScheme : _cachedLightDynamicScheme;

    // 缓存键 = settings + dynamicColorScheme（accent color 变化时 scheme 会变）
    final schemeMatch = dynamicColorScheme == null
        ? cachedScheme == null
        : (cachedScheme != null &&
            dynamicColorScheme.primary.toARGB32() == cachedScheme.primary.toARGB32());

    if (cachedSettings == settings && schemeMatch && themeCache != null) {
      return themeCache;
    }

    // 解析 ColorScheme：优先使用系统动态色，否则用种子色生成
    ColorScheme colorScheme;
    if (settings.useDynamicColor && dynamicColorScheme != null) {
      // Android 12+ / macOS / Windows / Linux → 使用系统动态色
      colorScheme = dynamicColorScheme;
    } else {
      // 回退：用种子色生成
      final seedColor = settings.useCustomColor && settings.primaryColor != null
          ? settings.primaryColor!
          : const Color(0xFF39C5BB);
      colorScheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
    }

    // 获取字体ID
    // 空字符串表示系统字体
    final fontFamilyId = settings.fontFamily ?? 'misans';
    final isSystemFont = fontFamilyId.isEmpty || fontFamilyId == 'system';

    // 获取基础 TextTheme
    final baseTextTheme = SauceTypography.createTextTheme(
      Theme.of(context).platform,
    );

    // 应用字体
    TextTheme textTheme;
    String? effectiveFontFamily;

    if (isSystemFont) {
      // 系统字体：不设置 fontFamily，使用系统默认
      textTheme = baseTextTheme.apply(
        bodyColor: isDark
            ? SaucePalette.darkOnSurface
            : SaucePalette.lightOnSurface,
        displayColor: isDark
            ? SaucePalette.darkOnSurface
            : SaucePalette.lightOnSurface,
      );
      effectiveFontFamily = null;
    } else if (fontFamilyId == 'misans') {
      // MiSans 内置字体
      textTheme = baseTextTheme.apply(
        bodyColor: isDark
            ? SaucePalette.darkOnSurface
            : SaucePalette.lightOnSurface,
        displayColor: isDark
            ? SaucePalette.darkOnSurface
            : SaucePalette.lightOnSurface,
      );
      effectiveFontFamily = 'MiSans';
    } else {
      // 动态加载的字体
      // 先应用颜色
      final coloredTextTheme = baseTextTheme.apply(
        bodyColor: isDark
            ? SaucePalette.darkOnSurface
            : SaucePalette.lightOnSurface,
        displayColor: isDark
            ? SaucePalette.darkOnSurface
            : SaucePalette.lightOnSurface,
      );

      // 尝试使用 FontManager 的 TextTheme
      final dynamicTextTheme = FontManager.getTextTheme(
        fontFamilyId,
        coloredTextTheme,
      );
      if (dynamicTextTheme != null) {
        textTheme = dynamicTextTheme;
        effectiveFontFamily = fontFamilyId;
      } else {
        // 回退到 MiSans
        textTheme = coloredTextTheme;
        effectiveFontFamily = 'MiSans';
      }
    }

    const capsuleShape = StadiumBorder();
    final smallRadiusShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    final theme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: effectiveFontFamily,
      textTheme: textTheme,
      bannerTheme: const MaterialBannerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 2,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: capsuleShape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: capsuleShape),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: smallRadiusShape),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: capsuleShape),
      ),
    );

    final platform = Theme.of(context).platform;
    final isDesktop =
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.macOS ||
        platform == TargetPlatform.linux;
    final semanticColors = DesktopSemanticColors.fromColorScheme(
      theme.colorScheme,
      isDesktop: isDesktop,
    );
    final adjustedTheme = isDesktop
        ? theme.copyWith(
            scaffoldBackgroundColor: semanticColors.appBackground,
            canvasColor: semanticColors.appBackground,
            extensions: [...theme.extensions.values, semanticColors],
          )
        : theme.copyWith(
            extensions: [...theme.extensions.values, semanticColors],
          );

    // 缓存主题和设置
    if (isDark) {
      _cachedDarkTheme = adjustedTheme;
      _cachedDarkSettings = settings;
      _cachedDarkDynamicScheme = dynamicColorScheme;
    } else {
      _cachedLightTheme = adjustedTheme;
      _cachedLightSettings = settings;
      _cachedLightDynamicScheme = dynamicColorScheme;
    }

    return adjustedTheme;
  }
}

class _UpdateHandler extends ConsumerStatefulWidget {
  final Widget child;

  const _UpdateHandler({required this.child});

  @override
  ConsumerState<_UpdateHandler> createState() => _UpdateHandlerState();
}

class _UpdateHandlerState extends ConsumerState<_UpdateHandler> {
  bool _hasShownUpdate = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(updateProvider, (prev, next) {
      if (next.state == UpdateState.updateAvailable && !_hasShownUpdate) {
        _hasShownUpdate = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            unawaited(
              ref
                  .read(audioEngineProvider)
                  .playAsset('sounds/App/update-available.ogg'),
            );
            showUpdateBottomSheet(context, next.update!);
          }
        });
      }
    });
    return widget.child;
  }
}
