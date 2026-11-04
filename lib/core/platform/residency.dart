// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nativeapi/nativeapi.dart';
import 'package:path_provider/path_provider.dart';
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

  /// The tray icon and its click listener; both live for the app's lifetime.
  TrayIcon? _tray;
  ListenerId? _trayListenerId;

  /// Registered with `windowManager` while residency is active.
  ResidencyWindowListener? _windowListener;

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
      // The service is what keeps the websocket alive while the app is
      // backgrounded; without it notifications only arrive in the foreground.
      await startAndroidService();
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      await _initializeDesktop();
    }
    _initialized = true;
  }

  Future<void> _initializeDesktop() async {
    try {
      await windowManager.ensureInitialized();
      await _initializeDesktopNotifications();
      // The tray goes through nativeapi's own implementation rather than the
      // old libappindicator C library: on Linux that means the
      // StatusNotifierItem D-Bus standard, which Ubuntu still ships.
      final tray = TrayIcon.create();
      if (tray == null) {
        debugPrint('Nyachi: the platform refused to create a tray icon');
      } else {
        _tray = tray;
        tray.setTooltip('Nyachi');
        final icon = await _loadTrayIcon();
        if (icon != null) tray.icon = icon;
        final menu = Menu.create();
        if (menu != null) {
          final show = MenuItem.createWithLabelAndType(
            'Show Nyachi',
            MenuItemType.normal,
          );
          final quitItem = MenuItem.createWithLabelAndType(
            'Quit',
            MenuItemType.normal,
          );
          show?.addListener((event) {
            if (event is MenuItemClickedEvent) unawaited(showWindow());
          });
          quitItem?.addListener((event) {
            if (event is MenuItemClickedEvent) unawaited(quit());
          });
          menu.addItem(show);
          menu.addSeparator();
          menu.addItem(quitItem);
          tray.setContextMenu(menu);
        }
        _trayListenerId = tray.addListener((event) {
          if (event is TrayIconClickedEvent) unawaited(showWindow());
        });
      }
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

  /// Loads the tray icon from the bundled assets.
  ///
  /// The tray API takes a file path, but a packaged app has no such file on
  /// disk until it is extracted, so the asset is copied to a temp file first.
  /// Returns null when the icon cannot be prepared, leaving the tray without
  /// one rather than failing the whole setup.
  Future<Image?> _loadTrayIcon() async {
    try {
      final data = await rootBundle.load('assets/brand/app_icon_full.png');
      final file = File(
        '${(await getTemporaryDirectory()).path}/nyachi-tray.png',
      );
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      return Image.fromFile(file.path);
    } catch (error) {
      debugPrint('Nyachi: tray icon unavailable: $error');
      return null;
    }
  }

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
    try {
      await _initializeNotifications(
        InitializationSettings(
          android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
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

  /// Prepares the notification channel for the desktop targets.
  ///
  /// Windows needs a distinct app-user-model id and a stable GUID so toasts
  /// survive restarts instead of stacking a new entry per launch; Linux only
  /// needs the channel itself.
  Future<void> _initializeDesktopNotifications() async {
    try {
      if (Platform.isWindows) {
        await _initializeNotifications(
          const InitializationSettings(
            windows: WindowsInitializationSettings(
              appName: 'Nyachi',
              appUserModelId: 'CyaniAgent.Nyachi.Client',
              guid: '6d1f1d1e-6f4a-4a3e-9d0e-8ad1f5f0c9b2',
            ),
          ),
        );
      } else if (Platform.isLinux) {
        await _initializeNotifications(
          const InitializationSettings(
            linux: LinuxInitializationSettings(defaultActionName: 'Open'),
          ),
        );
      }
    } catch (error) {
      debugPrint('Nyachi desktop notifications unavailable: $error');
    }
  }

  Future<void> _initializeNotifications(InitializationSettings settings) async {
    await _notifications.initialize(
      settings: settings,
      // Taps only need to bring the window forward; the in-app list is the
      // destination, and it is already open behind the toast.
      onDidReceiveNotificationResponse: (_) => unawaited(showWindow()),
    );
  }

  /// Whether this platform can raise a system notification.
  ///
  /// macOS is excluded: this build has no macOS notification setup, and
  /// claiming otherwise would silently drop events.
  bool get notificationsSupported =>
      Platform.isAndroid || Platform.isWindows || Platform.isLinux;

  static const _channel = AndroidNotificationDetails(
    'nyachi_activity',
    'Activity',
    channelDescription: 'Mentions, replies and reactions',
    importance: Importance.high,
    priority: Priority.high,
  );

  /// Raises a system notification for an event that arrived while the app was
  /// not in front of the user.
  ///
  /// [eventId] is the Misskey notification id: deriving the plugin id from it
  /// keeps same-title events (three reactions from one user) distinct instead
  /// of overwriting each other.
  ///
  /// Best-effort like everything else here: a refused permission or a platform
  /// without a notification channel must not interrupt the realtime stream.
  Future<void> showNotification({
    required String eventId,
    required String title,
    required String body,
  }) async {
    if (!notificationsSupported || !_initialized) return;
    try {
      await _notifications.show(
        id: eventId.hashCode & 0x7fffffff,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(android: _channel),
        payload: 'notifications',
      );
    } catch (error) {
      debugPrint('Nyachi notification failed: $error');
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
      _androidServiceRunning = true;
    } catch (error) {
      debugPrint('Nyachi foreground service failed: $error');
    }
  }

  /// Whether the Android foreground service is running; drives the realtime
  /// socket's keep-alive-in-background decision.
  bool get androidServiceRunning => _androidServiceRunning;
  var _androidServiceRunning = false;

  Future<void> stopAndroidService() async {
    if (!Platform.isAndroid) return;
    await FlutterForegroundTask.stopService();
    _androidServiceRunning = false;
  }

  Future<void> dispose() async {
    final tray = _tray;
    final listenerId = _trayListenerId;
    if (tray != null && listenerId != null) {
      tray.removeListener(listenerId);
    }
    _trayListenerId = null;
    tray?.dispose();
    _tray = null;
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
