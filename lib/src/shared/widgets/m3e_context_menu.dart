import 'package:flutter/material.dart';
import 'package:nyachi/src/core/theme/design_tokens.dart';

/// Data for one menu item in an [M3EContextMenu].
class M3EMenuItemData<T> {
  final T? value;
  final IconData icon;
  final String label;
  final bool enabled;
  final Color? iconColor;
  final Color? textColor;
  final Widget? trailing;
  final bool isSeparator;

  const M3EMenuItemData({
    this.value,
    required this.icon,
    required this.label,
    this.enabled = true,
    this.iconColor,
    this.textColor,
    this.trailing,
    this.isSeparator = false,
  });

  /// A gap separator (M3E "with gap" style — no visible divider, just space).
  const M3EMenuItemData.separator()
      : value = null,
        icon = Icons.add,
        label = '',
        enabled = false,
        iconColor = null,
        textColor = null,
        trailing = null,
        isSeparator = true;
}

/// Material 3 Expressive context menu.
///
/// Uses an [OverlayEntry] with a 300 ms fade-in/out animation,
/// rounded corners (from [M3EMenuTokens.menuRadius]),
/// low‑saturation primary hover and full‑saturation ripple,
/// and gap‑based grouping ("with gap") instead of full‑width dividers.
class M3EContextMenu<T> {
  /// Show the menu at [position].
  static void show<T>({
    required BuildContext context,
    required Offset position,
    required List<M3EMenuItemData<T>> items,
    required void Function(T) onSelected,
    VoidCallback? onDismissed,
  }) {
    final tokens = context.m3eMenu;
    final theme = Theme.of(context);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _M3EPopupOverlay<T>(
        position: position,
        menuColor: theme.colorScheme.surfaceContainerHigh,
        primaryColor: theme.colorScheme.primary,
        tokens: tokens,
        items: items,
        onSelected: (value) {
          onSelected(value);
          entry.remove();
        },
        onDismissed: () {
          entry.remove();
          onDismissed?.call();
        },
      ),
    );

    Overlay.of(context).insert(entry);
  }
}

class _M3EPopupOverlay<T> extends StatefulWidget {
  final Offset position;
  final Color menuColor;
  final Color primaryColor;
  final M3EMenuTokens tokens;
  final List<M3EMenuItemData<T>> items;
  final void Function(T) onSelected;
  final VoidCallback onDismissed;

  const _M3EPopupOverlay({
    required this.position,
    required this.menuColor,
    required this.primaryColor,
    required this.tokens,
    required this.items,
    required this.onSelected,
    required this.onDismissed,
  });

  @override
  State<_M3EPopupOverlay<T>> createState() => _M3EPopupOverlayState<T>();
}

class _M3EPopupOverlayState<T> extends State<_M3EPopupOverlay<T>>
    with TickerProviderStateMixin {
  final GlobalKey _menuKey = GlobalKey();
  Offset _calculatedPosition = Offset.zero;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Rect? _menuBounds;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.tokens.animationDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePosition();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculatePosition() {
    final renderBox = _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final menuSize = renderBox.size;
      final screenSize = MediaQuery.of(context).size;
      var dx = widget.position.dx;
      var dy = widget.position.dy;

      if (dx + menuSize.width > screenSize.width) {
        dx = screenSize.width - menuSize.width - 8;
      }
      if (dy + menuSize.height > screenSize.height) {
        dy = screenSize.height - menuSize.height - 8;
      }
      if (dx < 0) dx = 8;
      if (dy < 0) dy = 8;

      setState(() {
        _calculatedPosition = Offset(dx, dy);
        _menuBounds = Rect.fromLTWH(dx, dy, menuSize.width, menuSize.height);
      });
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_isDismissing) return;
    if (_menuBounds != null &&
        !_menuBounds!.contains(event.position)) {
      _dismiss();
    }
  }

  Future<void> _dismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;
    await _animationController.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      child: Stack(
        children: [
          Positioned(
            left: _calculatedPosition.dx,
            top: _calculatedPosition.dy,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                key: _menuKey,
                constraints: const BoxConstraints(
                  maxWidth: 280,
                  minWidth: 200,
                ),
                decoration: BoxDecoration(
                  color: widget.menuColor,
                  borderRadius:
                      BorderRadius.circular(widget.tokens.menuRadius),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildItems(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItems() {
    final list = <Widget>[];
    for (final item in widget.items) {
      if (item.isSeparator) {
        list.add(SizedBox(height: widget.tokens.gapHeight));
      } else {
        list.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: _M3EMenuItemWidget(
              icon: item.icon,
              label: item.label,
              enabled: item.enabled,
              iconColor: item.iconColor,
              textColor: item.textColor,
              trailing: item.trailing,
              primaryColor: widget.primaryColor,
              itemRadius: widget.tokens.itemRadius,
              onTap: item.enabled && item.value != null
                  ? () {
                      widget.onSelected(item.value as T);
                    }
                  : null,
            ),
          ),
        );
      }
    }
    return list;
  }
}

class _M3EMenuItemWidget extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final Color? iconColor;
  final Color? textColor;
  final Widget? trailing;
  final Color primaryColor;
  final double itemRadius;
  final VoidCallback? onTap;

  const _M3EMenuItemWidget({
    required this.icon,
    required this.label,
    this.enabled = true,
    this.iconColor,
    this.textColor,
    this.trailing,
    required this.primaryColor,
    required this.itemRadius,
    this.onTap,
  });

  @override
  State<_M3EMenuItemWidget> createState() => _M3EMenuItemWidgetState();
}

class _M3EMenuItemWidgetState extends State<_M3EMenuItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.itemRadius),
          hoverColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _isHovered && widget.enabled
                  ? theme.colorScheme.primary
                      .withValues(alpha: isDark ? 0.15 : 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(widget.itemRadius),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 20,
                    color: widget.enabled
                        ? (_isHovered
                            ? theme.colorScheme.primary
                            : (widget.iconColor ??
                                theme.colorScheme.onSurfaceVariant))
                        : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.enabled
                            ? (widget.textColor ?? theme.colorScheme.onSurface)
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.38),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 8),
                    widget.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
