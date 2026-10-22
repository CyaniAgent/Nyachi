import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:nyachi/src/core/core.dart';

/// Controller for the custom title bar.
///
/// Pages can use [CustomTitleBar.of] to access the controller and update the
/// title bar's title and actions.
class TitleBarController extends ChangeNotifier {
  String _title = 'Nyachi';
  List<Widget> _actions = const [];

  String get title => _title;
  List<Widget> get actions => _actions;

  /// Set the title displayed in the center of the title bar.
  void setTitle(String title) {
    if (_title != title) {
      _title = title;
      notifyListeners();
    }
  }

  /// Set action widgets displayed in the title bar (Windows/Linux only).
  void setActions(List<Widget> actions) {
    _actions = actions;
    notifyListeners();
  }

  /// Reset title bar to defaults.
  void reset() {
    _title = 'Nyachi';
    _actions = const [];
    notifyListeners();
  }
}

class _TitleBarInherited extends InheritedWidget {
  final TitleBarController controller;

  const _TitleBarInherited({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(_TitleBarInherited oldWidget) =>
      controller != oldWidget.controller;
}

/// Desktop custom title bar with window controls and [TitleBarController]
/// integration.
class CustomTitleBar extends StatelessWidget {
  final TitleBarController controller;

  const CustomTitleBar({super.key, required this.controller});

  /// Access the [TitleBarController] from the widget tree.
  static TitleBarController of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_TitleBarInherited>();
    assert(inherited != null, 'No _TitleBarInherited found in context');
    return inherited!.controller;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.m3eTitleBar;
    final isMacOS = Platform.isMacOS;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: tokens.height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return Row(
            children: [
              if (isMacOS) ...[
                SizedBox(width: tokens.macOSTrafficLightInset),
                _MacOSTrafficLights(),
                const Spacer(),
                _TitleLabel(title: controller.title),
                const Spacer(),
              ] else ...[
                Expanded(
                  child: DragToMoveArea(
                    child: Center(child: _TitleLabel(title: controller.title)),
                  ),
                ),
                ...controller.actions,
                _WindowControls(),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Wraps the app with [TitleBarController] access.
///
/// Must be placed above [MaterialApp] so that [CustomTitleBar.of] works
/// everywhere.
class TitleBarScope extends StatelessWidget {
  final TitleBarController controller;
  final Widget child;

  const TitleBarScope({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _TitleBarInherited(controller: controller, child: child);
  }
}

class _TitleLabel extends StatelessWidget {
  final String title;
  const _TitleLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _MacOSTrafficLights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.m3eTitleBar;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MacOSTrafficLightButton(
          defaultColor: const Color(0xFFFF5F56),
          hoverColor: const Color(0xFFFF3333),
          hoverIcon: Icons.close,
          onTap: windowManager.close,
        ),
        SizedBox(width: tokens.macOSTrafficLightSpacing),
        _MacOSTrafficLightButton(
          defaultColor: const Color(0xFFFFBD2E),
          hoverColor: const Color(0xFFFFAA00),
          hoverIcon: Icons.remove,
          onTap: windowManager.minimize,
        ),
        SizedBox(width: tokens.macOSTrafficLightSpacing),
        _MacOSTrafficLightButton(
          defaultColor: const Color(0xFF27C93F),
          hoverColor: const Color(0xFF00AA00),
          hoverIcon: Icons.fullscreen,
          onTap: () async {
            if (await windowManager.isMaximized()) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
        ),
      ],
    );
  }
}

class _MacOSTrafficLightButton extends StatefulWidget {
  final Color defaultColor;
  final Color hoverColor;
  final IconData hoverIcon;
  final VoidCallback onTap;

  const _MacOSTrafficLightButton({
    required this.defaultColor,
    required this.hoverColor,
    required this.hoverIcon,
    required this.onTap,
  });

  @override
  State<_MacOSTrafficLightButton> createState() =>
      _MacOSTrafficLightButtonState();
}

class _MacOSTrafficLightButtonState extends State<_MacOSTrafficLightButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.m3eTitleBar;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: tokens.macOSTrafficLightSize,
          height: tokens.macOSTrafficLightSize,
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverColor : widget.defaultColor,
            shape: BoxShape.circle,
          ),
          child: _isHovered
              ? Icon(widget.hoverIcon, size: 8, color: Colors.black54)
              : null,
        ),
      ),
    );
  }
}

class _WindowControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = context.m3eTitleBar;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: tokens.windowButtonMargin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _WindowControlButton(
            icon: Icons.minimize,
            onTap: windowManager.minimize,
          ),
          SizedBox(width: tokens.windowButtonSpacing),
          _MaximizeControlButton(),
          SizedBox(width: tokens.windowButtonSpacing),
          _WindowControlButton(
            icon: Icons.close,
            hoverBgColor: colorScheme.error,
            hoverIconColor: colorScheme.onError,
            onTap: windowManager.close,
          ),
        ],
      ),
    );
  }
}

class _MaximizeControlButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: windowManager.isMaximized(),
      builder: (context, snapshot) {
        final isMaximized = snapshot.data ?? false;
        return _WindowControlButton(
          icon: isMaximized ? Icons.close_fullscreen : Icons.open_in_full,
          iconSize: 14,
          onTap: () async {
            if (await windowManager.isMaximized()) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
        );
      },
    );
  }
}

class _WindowControlButton extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final Color? hoverBgColor;
  final Color? hoverIconColor;
  final VoidCallback onTap;

  const _WindowControlButton({
    required this.icon,
    this.iconSize = 12,
    this.hoverBgColor,
    this.hoverIconColor,
    required this.onTap,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.m3eTitleBar;
    final colorScheme = Theme.of(context).colorScheme;

    final bgColor = _isHovered
        ? (widget.hoverBgColor ?? colorScheme.surfaceContainerHighest)
        : Colors.transparent;
    final iconColor = _isHovered
        ? (widget.hoverIconColor ?? colorScheme.onSurface)
        : colorScheme.onSurfaceVariant;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: tokens.windowButtonSize,
          height: tokens.windowButtonSize,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: tokens.windowButtonBorderRadius,
          ),
          child: Icon(widget.icon, size: widget.iconSize, color: iconColor),
        ),
      ),
    );
  }
}
