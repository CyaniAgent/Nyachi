import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';

/// 跨平台动态取色服务
///
/// - Windows: 通过原生 WM_DWMCOLORIZATIONCOLORCHANGED 消息实时监听系统主题色变化
/// - macOS/Linux/Android/iOS: App 回到前台时轮询对比
/// - 提供 [accentColor] ValueNotifier 供主题系统监听
class DynamicColorService extends WidgetsBindingObserver {
  DynamicColorService._();
  static final instance = DynamicColorService._();

  /// MethodChannel — 接收 Windows 原生推送的强调色变化
  static const _channel = MethodChannel('com.nyachi/accent_color');

  /// 当前系统强调色（null 表示平台不支持或尚未获取）
  final ValueNotifier<Color?> accentColor = ValueNotifier<Color?>(null);

  /// 当前完整的动态 ColorScheme（light）
  ColorScheme? lightScheme;

  /// 当前完整的动态 ColorScheme（dark）
  ColorScheme? darkScheme;

  Timer? _pollTimer;
  Color? _lastKnownColor;
  bool _initialized = false;

  /// 初始化服务：注册监听器并获取初始颜色
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // 注册生命周期观察者（跨平台轮询）
    WidgetsBinding.instance.addObserver(this);

    // Windows 平台：监听原生颜色变化推送
    if (Platform.isWindows) {
      _channel.setMethodCallHandler(_onMethodCall);
    }

    // 获取初始颜色
    await _fetchAccentColor();
  }

  /// 销毁服务
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _channel.setMethodCallHandler(null);
  }

  /// 处理来自 Windows 原生的 MethodChannel 调用
  Future<void> _onMethodCall(MethodCall call) async {
    if (call.method == 'onAccentColorChanged') {
      final argb = call.arguments as int?;
      if (argb != null) {
        final newColor = Color(argb);
        _updateColor(newColor);
      }
    }
  }

  /// 从系统获取强调色（跨平台）
  Future<void> _fetchAccentColor() async {
    try {
      final color = await DynamicColorPlugin.getAccentColor();
      if (color != null) {
        _updateColor(color);
      } else {
        // 平台不支持动态取色，使用 Miku Green 作为 fallback
        _updateColor(const Color(0xFF39C5BB));
      }
    } catch (e) {
      _updateColor(const Color(0xFF39C5BB));
    }
  }

  /// 更新颜色并重建 ColorScheme
  void _updateColor(Color color) {
    // 避免重复更新
    if (_lastKnownColor != null && _lastKnownColor!.toARGB32() == color.toARGB32()) {
      return;
    }
    _lastKnownColor = color;

    // 从种子色生成完整的 Material 3 ColorScheme
    lightScheme = ColorScheme.fromSeed(seedColor: color, brightness: Brightness.light);
    darkScheme = ColorScheme.fromSeed(seedColor: color, brightness: Brightness.dark);

    // 通知监听者
    accentColor.value = color;

    debugPrint('DynamicColorService: accent color updated — #${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}');
  }

  // ── WidgetsBindingObserver: App 回到前台时轮询 ──────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App 回到前台：重新获取系统强调色（覆盖后台期间的系统设置变化）
      _fetchAccentColor();
    }
  }
}
