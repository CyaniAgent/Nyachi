import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nyachi/src/shared/widgets/adaptive_sheet.dart';
import 'package:nyachi/src/shared/widgets/expressive_slider.dart';

/// 底部弹窗滑块组件
class SettingsSliderBottomSheet extends StatefulWidget {
  final String title;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final int? step;
  final String Function(int value) valueFormatter;
  final Function(int value) onConfirm;
  final IconData? icon;

  const SettingsSliderBottomSheet({
    super.key,
    required this.title,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    this.step,
    required this.valueFormatter,
    required this.onConfirm,
    this.icon,
  });

  @override
  State<SettingsSliderBottomSheet> createState() => _SettingsSliderBottomSheetState();

  static Future<void> show({
    required BuildContext context,
    required String title,
    required int initialValue,
    required int minValue,
    required int maxValue,
    int? step,
    required String Function(int value) valueFormatter,
    required Function(int value) onConfirm,
    IconData? icon,
  }) async {
    await showAdaptiveSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SettingsSliderBottomSheet(
        title: title,
        initialValue: initialValue,
        minValue: minValue,
        maxValue: maxValue,
        step: step,
        valueFormatter: valueFormatter,
        onConfirm: onConfirm,
        icon: icon,
      ),
    );
  }
}

class _SettingsSliderBottomSheetState extends State<SettingsSliderBottomSheet> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和图标
            Row(
              children: [
                if (widget.icon != null) Icon(widget.icon, color: theme.colorScheme.primary),
                if (widget.icon != null) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 数值显示
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.valueFormatter(_currentValue),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 滑块
            ExpressiveSlider(
              value: _currentValue.toDouble(),
              min: widget.minValue.toDouble(),
              max: widget.maxValue.toDouble(),
              divisions: widget.step != null ? (widget.maxValue - widget.minValue) ~/ widget.step! : null,
              showIndicator: false,
              onChanged: (value) {
                setState(() {
                  if (widget.step != null) {
                    _currentValue = ((value / widget.step!).round() * widget.step!).clamp(widget.minValue, widget.maxValue);
                  } else {
                    _currentValue = value.round();
                  }
                });
              },
            ),

            // 最小值/最大值标签
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.valueFormatter(widget.minValue), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                Text(widget.valueFormatter(widget.maxValue), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),

            const SizedBox(height: 32),

            // 确定按钮
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  widget.onConfirm(_currentValue);
                  Navigator.pop(context);
                },
                child: Text('Confirm'.tr(), style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
