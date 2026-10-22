// Nyachi应用程序的主入口文件
//
// 该文件包含应用程序的启动逻辑，负责初始化Flutter应用并运行主组件。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/src/app.dart';
import '/src/core/core.dart';
import '/src/core/utils/http_overrides.dart';
import '/src/features/auth/data/auth_repository.dart';
import '/src/core/services/background_service.dart';
import '/src/core/services/notification_service.dart';
import '/src/core/services/notification_manager.dart';
import '/src/core/services/audio_engine.dart';
import '/src/core/services/misskey_image_cache_database.dart';
import 'dart:io';
import 'package:window_manager/window_manager.dart';

/// 应用程序的入口点
///
/// 初始化应用程序的各种服务和配置，包括：
/// - 初始化Flutter绑定
/// - 初始化持久化存储
/// - 初始化日志系统
/// - 初始化国际化支持
/// - 创建Riverpod的ProviderContainer
/// - 初始化核心服务
/// - 运行NyachiApp组件
/// - 延迟加载非核心服务
///
/// 这是应用程序的启动点，负责所有必要的初始化工作。
/// 为了提高启动速度，将非核心服务的初始化延迟到应用启动后执行。
///
/// @return 无返回值，应用程序启动后会持续运行
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(1280, 720),
        minimumSize: Size(400, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  // 设置全局 HTTP 覆盖以处理自签名证书 (HandshakeException fix)
  HttpOverrides.global = CyaniHttpOverrides();

  // 初始化持久化存储
  final sharedPrefs = await SharedPreferences.getInstance();

  // 读取存储的日志级别设置
  final storedLogLevel = sharedPrefs.getString('log_level');

  // 初始化日志系统，传入用户的日志级别设置
  await logger.initialize(logLevel: storedLogLevel);
  logger.info('Nyachi app started');

  // 初始化性能监控
  performanceMonitor.initialize();

  await EasyLocalization.ensureInitialized();

  // 设置 timeago 的中文语言包
  timeago.setLocaleMessages('zh', timeago.ZhMessages());

  // 创建 ProviderContainer 以便在非 Widget 环境中使用 Provider
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
  );

  // 初始化核心服务（启动必需）
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 运行应用
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
        Locale('ja', 'JP'),
        Locale('zh', 'Miao'),
        Locale('ja', 'Miao'),
        Locale('en', 'Miao'),
        Locale('miao', 'Miao'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('ja', 'JP'),
      child: UncontrolledProviderScope(
        container: container,
        child: const NyachiApp(),
      ),
    ),
  );

  // 延迟加载非核心服务（提高启动速度）
  Future.microtask(() async {
    try {
      logger.info('Starting deferred initialization of non-core services');

      // 初始化音频引擎
      await container.read(audioEngineProvider).initialize();
      logger.info('Audio engine initialized');

      // 启动全局通知管理器
      container.read(notificationManagerProvider).start();
      logger.info('Notification manager started');

      // 初始化后台服务
      await initializeBackgroundService();
      logger.info('Background service initialized');

      // 初始化图片缓存数据库
      final imageCacheDb = MisskeyImageCacheDatabase();
      await imageCacheDb.database;
      logger.info('Misskey image cache database initialized');

      // 在移动端请求通知权限
      if (Platform.isAndroid || Platform.isIOS) {
        await notificationService.requestPermissions();
        logger.info('Notification permissions requested');
      }

      logger.info('All deferred services initialized successfully');
    } catch (e) {
      logger.error('Failed to initialize deferred services: $e');
    }
  });
}
