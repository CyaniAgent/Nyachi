/// 后台服务管理
///
/// 该文件包含后台服务的初始化和管理逻辑，
/// 负责在应用后台运行时保持连接活跃和执行轻量级任务。
library;

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 初始化后台服务
///
/// 配置并启动应用的后台服务，仅支持Android和iOS平台。
/// 在Android上使用前台服务确保后台运行稳定性，
/// 在iOS上配置后台执行权限。
///
/// @return 无返回值，后台服务启动后完成
Future<void> initializeBackgroundService() async {
  // 仅在移动平台上初始化后台服务
  if (!Platform.isAndroid && !Platform.isIOS) {
    return;
  }

  final service = FlutterBackgroundService();

  // Android notification channel setup
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'nyachi_backstage_channel',
    'Nyachi Backstage Service',
    description: 'This channel is used for Nyachi background process.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'nyachi_backstage_channel',
      initialNotificationTitle: 'Nyachi Backstage',
      initialNotificationContent: 'Running in background to ensure stability',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  await service.startService();
}

/// iOS后台执行回调函数
///
/// iOS平台特有的后台执行回调，确保在后台环境中正确初始化Flutter绑定。
///
/// @param service 后台服务实例
/// @return 返回true表示后台执行成功
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

/// 后台服务启动回调函数
///
/// 后台服务启动时的回调函数，负责初始化服务并设置事件监听。
/// 包含定期执行的后台任务逻辑，确保连接保持活跃。
///
/// @param service 后台服务实例
/// @return 无返回值
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Background logic here
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Nyachi Backstage",
          content: "Keep your connection alive (≧▽≦)",
        );
      }
    }

    // Perform light background tasks if needed
    debugPrint('Nyachi Backstage is humming... desu!');
  });
}
