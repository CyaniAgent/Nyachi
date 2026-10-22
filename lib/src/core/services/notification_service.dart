import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'navigation_service.dart';

/// 通知服务类
///
/// 负责处理通知权限请求和通知显示，支持多平台通知管理。
/// 使用单例模式，确保应用中只有一个通知服务实例。
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 初始化通知服务
  ///
  /// 配置各平台的通知设置，包括图标、权限请求等。
  ///
  /// @return 无返回值，初始化完成后通知服务即可使用
  Future<void> initialize() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      'launcher_icon',
    );
    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
      windows: WindowsInitializationSettings(
        appName: 'Nyachi',
        appUserModelId: 'app.CyaniAgent.Talk',
        guid: '3F2504E0-4F89-11D3-9A0C-0305E82C3301',
      ),
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint(
          'Notification tapped: ${details.id}, payload: ${details.payload}',
        );
        // 处理通知点击事件，使用导航服务处理跳转
        final payload = details.payload;
        if (payload != null) {
          // 使用导航服务处理跳转，支持通过ID直接跳转
          navigationService.navigateFromPayload(payload).then((success) {
            if (success) {
              debugPrint('Navigation successful');
            } else {
              debugPrint('Navigation failed');
            }
          });
        }
      },
    );

    // 在 Android 上显式创建通知通道，避免后续显示通知时可能出现的警告或延迟
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        const channel = AndroidNotificationChannel(
          'nyachi_general_channel',
          'Nyachi Notifications',
          description: 'General notifications for Nyachi',
          importance: Importance.max,
        );
        await androidImplementation.createNotificationChannel(channel);
      }
    }
  }

  /// 请求通知权限
  ///
  /// 在移动设备上会弹出权限请求对话框
  /// 在桌面设备上通常自动授予
  ///
  /// @return 返回权限请求的结果，true表示权限已授予，false表示权限被拒绝
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? granted = await androidImplementation
          ?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS || Platform.isMacOS) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    // 桌面端（Windows/Linux）通常不需要动态请求权限
    return true;
  }

  /// 检查权限状态
  ///
  /// 检查应用是否已获得通知权限，不同平台的检查方式不同。
  ///
  /// @return 返回权限状态，true表示已获得权限，false表示未获得权限
  Future<bool> checkPermissionStatus() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    // iOS/macOS 暂时通过重新请求（非静默）或者假设已授权
    // 桌面端默认返回 true
    return true;
  }

  /// 显示通知
  ///
  /// 在设备上显示本地通知，支持自定义标题、内容和附加数据。
  ///
  /// @param id 通知的唯一标识符
  /// @param title 通知标题
  /// @param body 通知内容
  /// @param payload 可选的附加数据，点击通知时会传回
  /// @param groupKey 可选的通知分组键，用于将相关通知分组显示
  /// @return 无返回值，通知显示后完成
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? groupKey,
  }) async {
    // 桌面端（Windows/macOS/Linux）禁用通知显示
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      debugPrint('Notifications are disabled on desktop platforms.');
      return;
    }

    final androidNotificationDetails = AndroidNotificationDetails(
      'nyachi_general_channel',
      'Nyachi Notifications',
      channelDescription: 'General notifications for Nyachi',
      importance: Importance.max,
      priority: Priority.high,
      groupKey: groupKey,
    );

    final darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      threadIdentifier: groupKey,
    );

    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }
}
