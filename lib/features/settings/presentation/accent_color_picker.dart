// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/ui/l10n_ext.dart';

/// The fixed accent swatches, as `#rrggbb` plus their label key.
const accentSwatches = [
  ('#3F51B5', 'indigo'),
  ('#E91E63', 'pink'),
  ('#4CAF50', 'green'),
  ('#2196F3', 'blue'),
  ('#FF9800', 'orange'),
];

/// The accent colour choices shared by Settings and the OOBE wizard.
///
/// Two of the swatches follow a source rather than naming a colour — the
/// platform palette and the instance's own branding — so every swatch carries
/// its name underneath. Naming them in a tooltip alone made them
/// indistinguishable from plain colour dots on touch devices.
class AccentColorPicker extends StatelessWidget {
  const AccentColorPicker({
    super.key,
    required this.selected,
    required this.instanceColor,
    required this.onSelected,
  });

  /// The stored value: `system`, `instance`, or a `#rrggbb` swatch.
  final String selected;

  /// Colour to preview for the `instance` swatch, which may be absent before
  /// the instance metadata has loaded.
  final String? instanceColor;

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        // The preview has to match what the app will apply: the platform
        // palette where one exists, the fallback seed where none is reported.
        final dynamicScheme = Theme.of(context).brightness == Brightness.dark
            ? darkDynamic
            : lightDynamic;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _AccentDot(
              label: l10n.systemColor,
              color: dynamicScheme?.primary ?? appFallbackSeed,
              selected: selected == 'system',
              onTap: () => onSelected('system'),
            ),
            _AccentDot(
              label: l10n.instanceColor,
              color: parseThemeColor(instanceColor),
              selected: selected == 'instance',
              onTap: () => onSelected('instance'),
            ),
            for (final (hex, key) in accentSwatches)
              _AccentDot(
                label: _accentLabel(l10n, key),
                color: parseThemeColor(hex),
                selected: selected == hex,
                onTap: () => onSelected(hex),
              ),
          ],
        );
      },
    );
  }
}

String _accentLabel(AppLocalizations l10n, String key) {
  return switch (key) {
    'indigo' => l10n.colorIndigo,
    'pink' => l10n.colorPink,
    'green' => l10n.colorGreen,
    'blue' => l10n.colorBlue,
    'orange' => l10n.colorOrange,
    _ => key,
  };
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  static const double _swatchSize = 38;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(appBorderRadius / 2),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: SizedBox(
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: _swatchSize,
                  height: _swatchSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? scheme.onSurface
                          : scheme.outlineVariant,
                      width: selected ? 2.5 : 1,
                    ),
                  ),
                  child: selected
                      ? Icon(
                          Icons.check,
                          size: 18,
                          color:
                              ThemeData.estimateBrightnessForColor(color) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        )
                      : null,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
