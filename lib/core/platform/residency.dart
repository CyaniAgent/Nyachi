// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

part 'residency.g.dart';

/// Keeps Nyachi resident outside the browser: a tray icon and close-to-tray on
/// desktop, a foreground service and system notifications on Android.
///
/// Everything is guarded per platform, and every step is best-effort: a desktop
/// without a tray implementation or an Android device that denies the
/// notification permission must still run the app normally.
class ResidencyService {
  ResidencyService();

  var _initialized = false;
  final _notifications = FlutterLocalNotificationsPlugin();

  /// The desktop tray handle; the package keeps no global instance.
  final _systemTray = SystemTray();

  /// Registered with `windowManager` while residency is active.
  ResidencyWindowListener? _windowListener;

  /// Whether residency is active, i.e. closing the window hides it instead of
  /// Whether residency is active, i.e. closing the window hides it instead of
  /// quitting and the process keeps running.
  bool get closeToTray =>
      _initialized &&
      (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// Prepares the platform surfaces. Safe to call more than once.
  Future<void> initialize() async {
    if (_initialized) return;
    if (Platform.isAndroid) {
      await _initializeAndroid();
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await _initializeDesktop();
    }
    _initialized = true;
  }

  Future<void> _initializeDesktop() async {
    try {
      await windowManager.ensureInitialized();
      await _systemTray.initSystemTray(
        title: 'Nyachi',
        iconPath: _trayIconPath(),
        toolTip: 'Nyachi',
      );
      await _systemTray.setContextMenu([
        MenuItem(
          label: 'Show Nyachi',
          onClicked: () => unawaited(showWindow()),
        ),
        MenuItem(label: 'Quit', onClicked: () => unawaited(quit())),
      ]);
      _systemTray.registerSystemTrayEventHandler((eventName) {
        // The tray reports a click as "click"; everything else (the menu) is
        // handled by the item callbacks above.
        if (eventName == 'click') unawaited(showWindow());
      });
      // Without a close handler `setPreventClose` would leave the window
      // unclosable; the listener turns the close into a hide instead.
      _windowListener = ResidencyWindowListener(this);
      windowManager.addListener(_windowListener!);
      await windowManager.setPreventClose(true);
    } catch (error) {
      // A platform without tray support still runs; residency just degrades
      // to a normal window.
      debugPrint('Nyachi residency unavailable: $error');
    }
  }

  /// The bundled app icon, which the tray reads from disk.
  String _trayIconPath() => 'assets/brand/app_icon_full.png';

  Future<void> showWindow() async {
    if (Platform.isAndroid) return;
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> hideToTray() async {
    if (Platform.isAndroid) return;
    await windowManager.hide();
  }

  Future<void> quit() async {
    if (Platform.isAndroid) return;
    // The tray goes away with the process; only the window needs closing.
    await windowManager.destroy();
  }

  Future<void> _initializeAndroid() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    try {
      // Taps are delivered to the app through the callback below; nothing
      // here needs to route them yet, so the handler is intentionally empty.
      await _notifications.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {},
      );
      final permission =
          await FlutterForegroundTask.checkNotificationPermission();
      if (permission != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    } catch (error) {
      debugPrint('Nyachi notification setup failed: $error');
    }
  }

  /// Starts the Android foreground service that keeps the websocket alive.
  Future<void> startAndroidService() async {
    if (!Platform.isAndroid) return;
    try {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'nyachi_resident',
          channelName: 'Nyachi',
          channelDescription: 'Keeps Nyachi connected in the background',
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.nothing(),
        ),
      );
      await FlutterForegroundTask.startService(
        serviceId: 1001,
        notificationTitle: 'Nyachi',
        notificationText: 'Connected in the background',
      );
    } catch (error) {
      debugPrint('Nyachi foreground service failed: $error');
    }
  }

  Future<void> stopAndroidService() async {
    if (!Platform.isAndroid) return;
    await FlutterForegroundTask.stopService();
  }

  Future<void> dispose() async {
    final listener = _windowListener;
    if (listener != null) {
      windowManager.removeListener(listener);
      _windowListener = null;
    }
    _initialized = false;
  }
}

/// Intercepts a window close request so the app hides to the tray instead of
/// quitting while a resident session is running.
class ResidencyWindowListener with WindowListener {
  ResidencyWindowListener(this._service);

  final ResidencyService _service;

  @override
  void onWindowClose() => unawaited(_service.hideToTray());
}

@Riverpod(keepAlive: true)
ResidencyService residency(Ref ref) {
  final service = ResidencyService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
}
