import 'package:flutter/material.dart';
import 'package:nyachi/src/core/theme/design_tokens.dart';

class DesignPlaygroundPage extends StatelessWidget {
  const DesignPlaygroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final m3eShape = context.m3eShape;

    return Scaffold(
      appBar: AppBar(title: const Text('Design Playground')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        children: [
          const _SectionHeader(title: 'Color Scheme'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ColorRow(
                  label: 'Primary',
                  color: colorScheme.primary,
                  onColor: colorScheme.onPrimary,
                ),
                _ColorRow(
                  label: 'Secondary',
                  color: colorScheme.secondary,
                  onColor: colorScheme.onSecondary,
                ),
                _ColorRow(
                  label: 'Tertiary',
                  color: colorScheme.tertiary,
                  onColor: colorScheme.onTertiary,
                ),
                _ColorRow(
                  label: 'Error',
                  color: colorScheme.error,
                  onColor: colorScheme.onError,
                ),
                _ColorRow(
                  label: 'Surface',
                  color: colorScheme.surface,
                  onColor: colorScheme.onSurface,
                ),
                _ColorRow(
                  label: 'Surface Container High',
                  color: colorScheme.surfaceContainerHigh,
                  onColor: colorScheme.onSurface,
                ),
                _ColorRow(
                  label: 'Surface Container Highest',
                  color: colorScheme.surfaceContainerHighest,
                  onColor: colorScheme.onSurface,
                ),
                _ColorRow(
                  label: 'Primary Container',
                  color: colorScheme.primaryContainer,
                  onColor: colorScheme.onPrimaryContainer,
                ),
                _ColorRow(
                  label: 'Secondary Container',
                  color: colorScheme.secondaryContainer,
                  onColor: colorScheme.onSecondaryContainer,
                ),
                _ColorRow(
                  label: 'Tertiary Container',
                  color: colorScheme.tertiaryContainer,
                  onColor: colorScheme.onTertiaryContainer,
                ),
                _ColorRow(
                  label: 'Outline',
                  color: colorScheme.outline,
                  onColor: colorScheme.surface,
                ),
                _ColorRow(
                  label: 'Outline Variant',
                  color: colorScheme.outlineVariant,
                  onColor: colorScheme.surface,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Typography'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.displayLarge,
                  label: 'displayLarge',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.displayMedium,
                  label: 'displayMedium',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.displaySmall,
                  label: 'displaySmall',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.headlineLarge,
                  label: 'headlineLarge',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.headlineMedium,
                  label: 'headlineMedium',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.headlineSmall,
                  label: 'headlineSmall',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.titleLarge,
                  label: 'titleLarge',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.titleMedium,
                  label: 'titleMedium',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.titleSmall,
                  label: 'titleSmall',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.bodyLarge,
                  label: 'bodyLarge',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.bodyMedium,
                  label: 'bodyMedium',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.bodySmall,
                  label: 'bodySmall',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.labelLarge,
                  label: 'labelLarge',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.labelMedium,
                  label: 'labelMedium',
                ),
                _TypeRow(
                  textTheme: textTheme,
                  style: textTheme.labelSmall,
                  label: 'labelSmall',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'M3E Shape Tokens'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShapeExample(
                  label: 'bottomSheet (28)',
                  radius: m3eShape.bottomSheet,
                  size: 60,
                ),
                const SizedBox(height: 12),
                _ShapeExample(
                  label: 'button (16)',
                  radius: m3eShape.button,
                  size: 48,
                ),
                const SizedBox(height: 12),
                _ShapeExample(
                  label: 'sliderTrack (4)',
                  radius: m3eShape.sliderTrack,
                  size: 40,
                ),
                const SizedBox(height: 12),
                _ShapeExample(
                  label: 'container (24)',
                  radius: m3eShape.container,
                  size: 56,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'M3E Slider Tokens'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TokenRow(
                  label: 'trackHeight',
                  value: '${context.m3eSlider.trackHeight} dp',
                ),
                _TokenRow(
                  label: 'thumbRadius',
                  value: '${context.m3eSlider.thumbRadius} dp',
                ),
                _TokenRow(
                  label: 'overlayRadius',
                  value: '${context.m3eSlider.overlayRadius} dp',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'M3E Menu Tokens'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TokenRow(
                  label: 'menuRadius',
                  value: '${context.m3eMenu.menuRadius} dp',
                ),
                _TokenRow(
                  label: 'itemRadius',
                  value: '${context.m3eMenu.itemRadius} dp',
                ),
                _TokenRow(
                  label: 'animationDuration',
                  value:
                      '${context.m3eMenu.animationDuration.inMilliseconds} ms',
                ),
                _TokenRow(
                  label: 'gapHeight',
                  value: '${context.m3eMenu.gapHeight} dp',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'M3E Sound Picker Tokens'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TokenRow(
                  label: 'chipRadius',
                  value: '${context.m3eSoundPicker.chipRadius} dp',
                ),
                _TokenRow(
                  label: 'chipHeight',
                  value: '${context.m3eSoundPicker.chipHeight} dp',
                ),
                _TokenRow(
                  label: 'chipSpacing',
                  value: '${context.m3eSoundPicker.chipSpacing} dp',
                ),
                _TokenRow(
                  label: 'gapBetweenChips',
                  value: '${context.m3eSoundPicker.gapBetweenChips} dp',
                ),
                _TokenRow(
                  label: 'iconSize',
                  value: '${context.m3eSoundPicker.iconSize} dp',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'M3E Title Bar Tokens'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TokenRow(
                  label: 'height',
                  value: '${context.m3eTitleBar.height} dp',
                ),
                _TokenRow(
                  label: 'windowButtonSize',
                  value: '${context.m3eTitleBar.windowButtonSize} dp',
                ),
                _TokenRow(
                  label: 'windowButtonSpacing',
                  value: '${context.m3eTitleBar.windowButtonSpacing} dp',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Buttons'),
          const _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ButtonRow(
                  label: 'FilledButton',
                  child: FilledButton(
                    onPressed: null,
                    child: Text('Filled'),
                  ),
                ),
                _ButtonRow(
                  label: 'FilledTonalButton',
                  child: FilledButton.tonal(
                    onPressed: null,
                    child: Text('Tonal'),
                  ),
                ),
                _ButtonRow(
                  label: 'OutlinedButton',
                  child: OutlinedButton(
                    onPressed: null,
                    child: Text('Outlined'),
                  ),
                ),
                _ButtonRow(
                  label: 'TextButton',
                  child: TextButton(onPressed: null, child: Text('Text')),
                ),
                _ButtonRow(
                  label: 'IconButton',
                  child: IconButton(
                    onPressed: null,
                    icon: Icon(Icons.favorite),
                  ),
                ),
                _ButtonRow(
                  label: 'FilledButton (disabled)',
                  child: FilledButton(
                    onPressed: null,
                    child: Text('Disabled'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Google Expressive Sliders (custom paint)'),
          const _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ExpressiveSliderExample(
                  label: 'Standard slider',
                  initialValue: 45,
                ),
                SizedBox(height: 12),
                _ExpressiveSliderExample(
                  label: 'Centered slider',
                  centered: true,
                  initialValue: 70,
                ),
                SizedBox(height: 12),
                _ExpressiveSliderExample(
                  label: 'Discrete slider (10 divisions)',
                  initialValue: 40,
                  divisions: 10,
                  showIndicator: true,
                ),
                SizedBox(height: 12),
                _ExpressiveRangeSliderExample(label: 'Range slider'),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Chips'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Chip(label: Text('Assist')),
                    const Chip(
                      label: Text('Filter'),
                      deleteIcon: Icon(Icons.close, size: 18),
                      onDeleted: null,
                    ),
                    const InputChip(label: Text('Input'), selected: true),
                    FilterChip(
                      label: const Text('Filter'),
                      selected: true,
                      onSelected: (_) {},
                    ),
                    const ChoiceChip(label: Text('Choice'), selected: true),
                    const ActionChip(label: Text('Action'), onPressed: null),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Cards'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Elevated Card', style: textTheme.titleSmall),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'This is a standard Material 3 Card with elevation.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Filled Card', style: textTheme.titleSmall),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: colorScheme.surfaceContainerHighest,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'This card uses surfaceContainerHighest with no elevation.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Progress Indicators'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LinearProgressIndicator', style: textTheme.titleSmall),
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
                Text('CircularProgressIndicator', style: textTheme.titleSmall),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator()],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Dialogs (visual)'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AlertDialog preview — this is what a dialog looks like:',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text('Dialog Title', style: textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        'This is a dialog content preview. In a real dialog you would have action buttons below.',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: null,
                            child: Text('Cancel'),
                          ),
                          SizedBox(width: 8),
                          FilledButton(
                            onPressed: null,
                            child: Text('Confirm'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _ColorRow extends StatelessWidget {
  final String label;
  final Color color;
  final Color onColor;
  const _ColorRow({
    required this.label,
    required this.color,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Center(child: Icon(Icons.circle, size: 16, color: onColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  final TextTheme textTheme;
  final TextStyle? style;
  final String label;
  const _TypeRow({
    required this.textTheme,
    required this.style,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 2),
          Text('The quick brown fox jumps over the lazy dog.', style: style),
        ],
      ),
    );
  }
}

class _ShapeExample extends StatelessWidget {
  final String label;
  final double radius;
  final double size;
  const _ShapeExample({
    required this.label,
    required this.radius,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
        ),
        const Spacer(),
        Text(
          '${radius.toInt()} px',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _TokenRow extends StatelessWidget {
  final String label;
  final String value;
  const _TokenRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _ButtonRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}

class _ExpressiveSliderExample extends StatefulWidget {
  final String label;
  final bool centered;
  final double initialValue;
  final int? divisions;
  final bool showIndicator;

  const _ExpressiveSliderExample({
    required this.label,
    this.centered = false,
    this.initialValue = 50,
    this.divisions,
    this.showIndicator = false,
  });

  @override
  State<_ExpressiveSliderExample> createState() =>
      _ExpressiveSliderExampleState();
}

class _ExpressiveSliderExampleState extends State<_ExpressiveSliderExample> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        _GoogleExpressiveSlider(
          value: _value,
          min: 0,
          max: 100,
          divisions: widget.divisions,
          centered: widget.centered,
          showIndicator: widget.showIndicator,
          onChanged: (value) => setState(() => _value = value),
        ),
      ],
    );
  }
}

class _ExpressiveRangeSliderExample extends StatefulWidget {
  final String label;

  const _ExpressiveRangeSliderExample({required this.label});

  @override
  State<_ExpressiveRangeSliderExample> createState() =>
      _ExpressiveRangeSliderExampleState();
}

class _ExpressiveRangeSliderExampleState
    extends State<_ExpressiveRangeSliderExample> {
  RangeValues _values = const RangeValues(25, 75);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        _GoogleExpressiveRangeSlider(
          values: _values,
          min: 0,
          max: 100,
          onChanged: (values) => setState(() => _values = values),
        ),
      ],
    );
  }
}

class _GoogleExpressiveSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final bool centered;
  final ValueChanged<double>? onChanged;
  final bool showIndicator;

  const _GoogleExpressiveSlider({
    required this.value,
    required this.min,
    required this.max,
    this.onChanged,
    this.divisions,
    this.centered = false,
    this.showIndicator = false,
  });

  @override
  State<_GoogleExpressiveSlider> createState() =>
      _GoogleExpressiveSliderState();
}

class _GoogleExpressiveSliderState extends State<_GoogleExpressiveSlider> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final geometry = _ExpressiveSliderGeometry(tokens: context.m3eSlider);
    final enabled = widget.onChanged != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Semantics(
          slider: true,
          value: widget.value.round().toString(),
          increasedValue: _formatSemanticValue(_nextValue(1)),
          decreasedValue: _formatSemanticValue(_nextValue(-1)),
          onIncrease:
              enabled ? () => widget.onChanged!(_nextValue(1)) : null,
          onDecrease:
              enabled ? () => widget.onChanged!(_nextValue(-1)) : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled
                ? (details) =>
                    _updateFromDx(details.localPosition.dx, width)
                : null,
            onHorizontalDragStart: enabled
                ? (details) {
                    setState(() => _dragging = true);
                    _updateFromDx(details.localPosition.dx, width);
                  }
                : null,
            onHorizontalDragUpdate: enabled
                ? (details) =>
                    _updateFromDx(details.localPosition.dx, width)
                : null,
            onHorizontalDragEnd: enabled
                ? (_) => setState(() => _dragging = false)
                : null,
            onHorizontalDragCancel:
                enabled ? () => setState(() => _dragging = false) : null,
            child: CustomPaint(
              size: Size(width, geometry.height),
              painter: _ExpressiveSliderPainter(
                colorScheme: colorScheme,
                geometry: geometry,
                value: widget.value,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                centered: widget.centered,
                dragging: _dragging,
                showIndicator: widget.showIndicator,
                disabled: !enabled,
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateFromDx(double dx, double width) {
    widget.onChanged?.call(_valueFromDx(dx, width));
  }

  double _valueFromDx(double dx, double width) {
    final geometry = _ExpressiveSliderGeometry(tokens: context.m3eSlider);
    final fraction = geometry.fractionFromDx(dx, width);
    final rawValue = widget.min + (widget.max - widget.min) * fraction;
    return _snapValue(rawValue, widget.min, widget.max, widget.divisions);
  }

  double _nextValue(int direction) {
    final step = widget.divisions == null
        ? (widget.max - widget.min) / 100
        : (widget.max - widget.min) / widget.divisions!;
    return _snapValue(
      widget.value + step * direction,
      widget.min,
      widget.max,
      widget.divisions,
    );
  }

  String _formatSemanticValue(double value) => value.round().toString();
}

class _GoogleExpressiveRangeSlider extends StatefulWidget {
  final RangeValues values;
  final double min;
  final double max;
  final ValueChanged<RangeValues>? onChanged;

  const _GoogleExpressiveRangeSlider({
    required this.values,
    required this.min,
    required this.max,
    this.onChanged,
  });
  @override
  State<_GoogleExpressiveRangeSlider> createState() =>
      _GoogleExpressiveRangeSliderState();
}

class _GoogleExpressiveRangeSliderState
    extends State<_GoogleExpressiveRangeSlider> {
  _RangeThumb? _activeThumb;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final geometry = _ExpressiveSliderGeometry(tokens: context.m3eSlider);
    final enabled = widget.onChanged != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Semantics(
          slider: true,
          value:
              '${widget.values.start.round()} - ${widget.values.end.round()}',
          increasedValue: _formatSemanticValue(_nextValue(1, _RangeThumb.end)),
          decreasedValue: _formatSemanticValue(_nextValue(-1, _RangeThumb.start)),
          onIncrease: enabled
              ? () => widget.onChanged!(_nextValue(1, _RangeThumb.end))
              : null,
          onDecrease: enabled
              ? () => widget.onChanged!(_nextValue(-1, _RangeThumb.start))
              : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled
                ? (details) {
                    _activeThumb =
                        _nearestThumb(details.localPosition.dx, width);
                    _updateFromDx(details.localPosition.dx, width);
                  }
                : null,
            onHorizontalDragStart: enabled
                ? (details) {
                    setState(
                      () => _activeThumb = _nearestThumb(
                        details.localPosition.dx,
                        width,
                      ),
                    );
                    _updateFromDx(details.localPosition.dx, width);
                  }
                : null,
            onHorizontalDragUpdate: enabled
                ? (details) =>
                    _updateFromDx(details.localPosition.dx, width)
                : null,
            onHorizontalDragEnd: enabled
                ? (_) => setState(() => _activeThumb = null)
                : null,
            onHorizontalDragCancel:
                enabled ? () => setState(() => _activeThumb = null) : null,
            child: CustomPaint(
              size: Size(width, geometry.height),
              painter: _ExpressiveRangeSliderPainter(
                colorScheme: colorScheme,
                geometry: geometry,
                values: widget.values,
                min: widget.min,
                max: widget.max,
                activeThumb: _activeThumb,
                disabled: !enabled,
              ),
            ),
          ),
        );
      },
    );
  }

  _RangeThumb _nearestThumb(double dx, double width) {
    final geometry = _ExpressiveSliderGeometry(tokens: context.m3eSlider);
    final startX = geometry.dxForValue(
      widget.values.start,
      widget.min,
      widget.max,
      width,
    );
    final endX = geometry.dxForValue(
      widget.values.end,
      widget.min,
      widget.max,
      width,
    );
    return (dx - startX).abs() <= (dx - endX).abs()
        ? _RangeThumb.start
        : _RangeThumb.end;
  }

  void _updateFromDx(double dx, double width) {
    final activeThumb = _activeThumb;
    if (activeThumb == null) return;

    final geometry = _ExpressiveSliderGeometry(tokens: context.m3eSlider);
    final fraction = geometry.fractionFromDx(dx, width);
    final rawValue = widget.min + (widget.max - widget.min) * fraction;

    if (activeThumb == _RangeThumb.start) {
      widget.onChanged?.call(
        RangeValues(rawValue.clamp(widget.min, widget.values.end), widget.values.end),
      );
    } else {
      widget.onChanged?.call(
        RangeValues(widget.values.start, rawValue.clamp(widget.values.start, widget.max)),
      );
    }
  }

  RangeValues _nextValue(int direction, _RangeThumb thumb) {
    final step = (widget.max - widget.min) / 100;
    if (thumb == _RangeThumb.start) {
      final next = _snapValue(
        widget.values.start + step * direction, widget.min, widget.values.end, null,
      );
      return RangeValues(next, widget.values.end);
    } else {
      final next = _snapValue(
        widget.values.end + step * direction, widget.values.start, widget.max, null,
      );
      return RangeValues(widget.values.start, next);
    }
  }

  String _formatSemanticValue(RangeValues values) =>
      '${values.start.round()} - ${values.end.round()}';
}

enum _RangeThumb { start, end }

class _ExpressiveSliderGeometry {
  final double height;
  final double horizontalPadding;
  final double trackCenterY;
  final double trackHeight;
  final double handleWidth;
  final double handleHeight;
  final double handleRadius;
  final double stopIndicatorRadius;
  final double haloRadius;
  final double trackGap;
  final double tickRadius;
  final double indicatorRadius;
  final double indicatorBottomGap;

  _ExpressiveSliderGeometry({required M3ESliderTokens tokens})
      : height = 96.0,
        horizontalPadding = 24.0,
        trackCenterY = 58.0,
        trackHeight = tokens.trackHeight * 3,
        handleWidth = tokens.thumbRadius * 0.5,
        handleHeight = tokens.thumbRadius * 5,
        handleRadius = tokens.thumbRadius * 0.25,
        stopIndicatorRadius = 2.0,
        haloRadius = tokens.overlayRadius * 1.25,
        trackGap = tokens.thumbRadius,
        tickRadius = 1.4,
        indicatorRadius = 15.0,
        indicatorBottomGap = 10.0;

  double get _trackOffset => trackHeight / 2;

  double effectiveLeft(double width) => horizontalPadding + _trackOffset;

  double effectiveRight(double width) => width - horizontalPadding - _trackOffset;

  double fractionFromDx(double dx, double width) {
    final left = effectiveLeft(width);
    final right = effectiveRight(width);
    return ((dx - left) / (right - left)).clamp(0.0, 1.0);
  }

  double dxForValue(double value, double min, double max, double width) {
    final fraction = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final left = effectiveLeft(width);
    final right = effectiveRight(width);
    return left + (right - left) * fraction;
  }
}

mixin _SliderPainterUtils on CustomPainter {
  _ExpressiveSliderGeometry get geometry;
  ColorScheme get colorScheme;
  bool get disabled;

  Color get _activeColor =>
      disabled ? colorScheme.outline.withValues(alpha: 0.38) : colorScheme.primary;

  Color get _inactiveColor =>
      disabled
          ? colorScheme.outline.withValues(alpha: 0.12)
          : colorScheme.primary.withValues(alpha: 0.18);

  void drawSegment(Canvas canvas, Paint paint, double start, double end, double y) {
    if (end - start <= 1) return;
    final rect = Rect.fromLTRB(
      start,
      y - geometry.trackHeight / 2,
      end,
      y + geometry.trackHeight / 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        Radius.circular(geometry.trackHeight / 2),
      ),
      paint,
    );
  }

  void drawTicks(
    Canvas canvas,
    Size size,
    double activeStart,
    double activeEnd,
    List<double> hiddenCenters,
    int? divisions,
  ) {
    if (divisions == null || divisions <= 0) return;

    final left = geometry.horizontalPadding;
    final right = size.width - geometry.horizontalPadding;
    final y = geometry.trackCenterY;

    for (var i = 0; i <= divisions; i++) {
      final x = left + (right - left) * i / divisions;
      final hidden = hiddenCenters.any(
        (center) => (x - center).abs() < geometry.trackGap + 3,
      );
      if (hidden) continue;

      final isActive = x >= activeStart && x <= activeEnd;
      canvas.drawCircle(
        Offset(x, y),
        geometry.tickRadius,
        Paint()
          ..color = isActive
              ? colorScheme.onPrimary.withValues(alpha: disabled ? 0.6 : 1.0)
              : _activeColor.withValues(alpha: disabled ? 0.3 : 0.45),
      );
    }
  }

  void drawThumb(Canvas canvas, double thumbX, bool isActive) {
    final center = Offset(thumbX, geometry.trackCenterY);
    if (!disabled) {
      canvas.drawCircle(
        center,
        geometry.haloRadius,
        Paint()
          ..color = colorScheme.primary
              .withValues(alpha: isActive ? 0.16 : 0.0),
      );
    }
    final rect = Rect.fromCenter(
      center: center,
      width: geometry.handleWidth,
      height: geometry.handleHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(geometry.handleRadius)),
      Paint()..color = _activeColor,
    );
  }

  void drawIndicator(Canvas canvas, double thumbX, String text) {
    if (disabled) return;
    final center = Offset(
      thumbX,
      geometry.trackCenterY -
          geometry.handleHeight / 2 -
          geometry.indicatorBottomGap -
          geometry.indicatorRadius,
    );
    final paint = Paint()..color = colorScheme.primary;
    canvas.drawCircle(center, geometry.indicatorRadius, paint);

    const notchWidth = 6.0;
    const notchHeight = 11.0;
    final notchConnectY = geometry.indicatorRadius - 4.0;
    final notchPath = Path()
      ..moveTo(center.dx - notchWidth, center.dy + notchConnectY)
      ..lineTo(center.dx + notchWidth, center.dy + notchConnectY)
      ..lineTo(center.dx, center.dy + notchConnectY + notchHeight)
      ..close();
    canvas.drawPath(notchPath, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void drawStopIndicator(Canvas canvas, double x) {
    canvas.drawCircle(
      Offset(x, geometry.trackCenterY),
      geometry.stopIndicatorRadius,
      Paint()..color = _activeColor,
    );
  }
}

class _ExpressiveSliderPainter extends CustomPainter with _SliderPainterUtils {
  @override
  final ColorScheme colorScheme;
  @override
  final _ExpressiveSliderGeometry geometry;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final bool centered;
  final bool dragging;
  final bool showIndicator;
  @override
  final bool disabled;

  const _ExpressiveSliderPainter({
    required this.colorScheme,
    required this.geometry,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.centered,
    required this.dragging,
    this.showIndicator = false,
    this.disabled = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final thumbX = geometry.dxForValue(value, min, max, size.width);
    final midX = geometry.dxForValue((min + max) / 2, min, max, size.width);

    late final double activeLeft, activeRight;
    if (centered) {
      activeLeft = thumbX < midX ? thumbX : midX;
      activeRight = thumbX < midX ? midX : thumbX;
    } else {
      activeLeft = geometry.horizontalPadding;
      activeRight = thumbX;
    }

    final left = geometry.horizontalPadding;
    final right = size.width - geometry.horizontalPadding;
    final gapStart = thumbX - geometry.trackGap;
    final gapEnd = thumbX + geometry.trackGap;
    final y = geometry.trackCenterY;

    final inactivePaint = Paint()
      ..color = _inactiveColor
      ..style = PaintingStyle.fill;
    final activePaint = Paint()
      ..color = _activeColor
      ..style = PaintingStyle.fill;

    drawSegment(canvas, inactivePaint, left, gapStart, y);
    drawSegment(canvas, inactivePaint, gapEnd, right, y);
    drawSegment(
      canvas, activePaint, activeLeft, gapStart.clamp(activeLeft, activeRight), y,
    );
    drawSegment(
      canvas, activePaint, gapEnd.clamp(activeLeft, activeRight), activeRight, y,
    );
    drawStopIndicator(canvas, geometry.effectiveLeft(size.width));
    drawStopIndicator(canvas, geometry.effectiveRight(size.width));
    drawTicks(canvas, size, activeLeft, activeRight, [thumbX], divisions);
    drawThumb(canvas, thumbX, dragging);

    if (showIndicator || dragging) {
      drawIndicator(canvas, thumbX, value.round().toString());
    }
  }

  @override
  bool shouldRepaint(covariant _ExpressiveSliderPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.dragging != dragging ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.centered != centered ||
        oldDelegate.disabled != disabled ||
        oldDelegate.showIndicator != showIndicator ||
        oldDelegate.geometry != geometry;
  }
}

class _ExpressiveRangeSliderPainter extends CustomPainter with _SliderPainterUtils {
  @override
  final ColorScheme colorScheme;
  @override
  final _ExpressiveSliderGeometry geometry;
  final RangeValues values;
  final double min;
  final double max;
  final _RangeThumb? activeThumb;
  @override
  final bool disabled;

  const _ExpressiveRangeSliderPainter({
    required this.colorScheme,
    required this.geometry,
    required this.values,
    required this.min,
    required this.max,
    this.activeThumb,
    this.disabled = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startX = geometry.dxForValue(values.start, min, max, size.width);
    final endX = geometry.dxForValue(values.end, min, max, size.width);
    final y = geometry.trackCenterY;
    final left = geometry.horizontalPadding;
    final right = size.width - geometry.horizontalPadding;
    final startGapStart = startX - geometry.trackGap;
    final startGapEnd = startX + geometry.trackGap;
    final endGapStart = endX - geometry.trackGap;
    final endGapEnd = endX + geometry.trackGap;

    final inactivePaint = Paint()
      ..color = _inactiveColor
      ..style = PaintingStyle.fill;
    final activePaint = Paint()
      ..color = _activeColor
      ..style = PaintingStyle.fill;

    drawSegment(canvas, inactivePaint, left, startGapStart, y);
    drawSegment(canvas, inactivePaint, endGapEnd, right, y);
    drawSegment(canvas, activePaint, startGapEnd, endGapStart, y);
    drawStopIndicator(canvas, geometry.effectiveLeft(size.width));
    drawStopIndicator(canvas, geometry.effectiveRight(size.width));
    drawTicks(canvas, size, startGapEnd, endGapStart, [startX, endX], null);
    drawThumb(canvas, startX, activeThumb == _RangeThumb.start);
    drawThumb(canvas, endX, activeThumb == _RangeThumb.end);

    if (activeThumb == _RangeThumb.start) {
      drawIndicator(canvas, startX, values.start.round().toString());
    } else if (activeThumb == _RangeThumb.end) {
      drawIndicator(canvas, endX, values.end.round().toString());
    }
  }

  @override
  bool shouldRepaint(covariant _ExpressiveRangeSliderPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.activeThumb != activeThumb ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.disabled != disabled ||
        oldDelegate.geometry != geometry;
  }
}

double _snapValue(double rawValue, double min, double max, int? divisions) {
  final clamped = rawValue.clamp(min, max);
  if (divisions == null || divisions <= 0) return clamped;

  final step = (max - min) / divisions;
  return min + ((clamped - min) / step).round() * step;
}
