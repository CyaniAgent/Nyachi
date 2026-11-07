// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/detail_panel/detail_location.dart';
import '../../../app/detail_panel/open_detail.dart';
import '../../../core/ui/l10n_ext.dart';
import 'emoji_text.dart';

/// A note's body, selectable and copyable.
///
/// Links and hashtags are real text spans rather than embedded widgets, so a
/// copied note contains the URL the note contains instead of an object
/// replacement character. Custom emoji still need an embedded image, which
/// Flutter flattens to `U+FFFC`; the copy action maps each one back to its
/// shortcode so the copied text stays faithful.
class NoteContent extends StatefulWidget {
  const NoteContent({required this.text, this.emojis, this.style, super.key});

  final String text;

  /// The note's `emojis` map — the authoritative source for custom emoji,
  /// including those hosted on remote instances.
  final Map<String, String>? emojis;

  final TextStyle? style;

  @override
  State<NoteContent> createState() => _NoteContentState();
}

class _NoteContentState extends State<NoteContent> {
  static final _pattern = RegExp(
    r'https?://[^\s]+|#[^\s#]+|:[A-Za-z0-9_+-]+(?:@[^\s:]+)?:',
  );

  /// Tap handlers attached to link and hashtag spans. Text spans own their
  /// recognizer, so these live as long as the spans built from them.
  final List<TapGestureRecognizer> _recognizers = [];

  List<InlineSpan> _spans = const [];

  /// Where each embedded emoji sits in the flattened plain text, paired with
  /// the shortcode the user should get when copying that character.
  List<({int offset, String shortcode})> _placeholders = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuild();
  }

  @override
  void didUpdateWidget(NoteContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.emojis != widget.emojis ||
        oldWidget.style != widget.style) {
      _rebuild();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  void _rebuild() {
    _disposeRecognizers();
    final theme = Theme.of(context);
    final effective = widget.style ?? theme.textTheme.bodyLarge;
    final linkStyle = effective?.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
    );
    final spans = <InlineSpan>[];
    final placeholders = <({int offset, String shortcode})>[];
    var plain = 0;
    var cursor = 0;
    void addText(String value, TextStyle? style, {GestureRecognizer? tap}) {
      if (value.isEmpty) return;
      spans.add(TextSpan(text: value, style: style, recognizer: tap));
      plain += value.length;
    }

    for (final match in _pattern.allMatches(widget.text)) {
      addText(widget.text.substring(cursor, match.start), null);
      final token = match.group(0)!;
      if (token.startsWith(':')) {
        final url = EmojiText.resolveUrl(token, emojis: widget.emojis);
        if (url == null) {
          addText(token, effective);
        } else {
          // The image is a placeholder in the flattened text; remember which
          // shortcode it stands for so a copy can restore it.
          placeholders.add((offset: plain, shortcode: token));
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: EmojiText(emoji: token, emojis: widget.emojis, size: 18),
              ),
            ),
          );
          plain += 1;
        }
      } else if (token.startsWith('#')) {
        final recognizer = TapGestureRecognizer()
          ..onTap = () =>
              openDetail(context, TagDetailLocation(token.substring(1)));
        _recognizers.add(recognizer);
        addText(token, linkStyle, tap: recognizer);
      } else {
        final recognizer = TapGestureRecognizer()
          ..onTap = () => _open(context, token);
        _recognizers.add(recognizer);
        addText(token, linkStyle, tap: recognizer);
      }
      cursor = match.end;
    }
    addText(widget.text.substring(cursor), null);

    _spans = spans;
    _placeholders = placeholders;
  }

  /// Rewrites the flattened selection so embedded emoji read as their
  /// shortcodes instead of `U+FFFC`.
  String _restorePlaceholders(String selected) =>
      restoreEmojiPlaceholders(selected, _plainText(), _placeholders);

  /// The note's text as the selection sees it: embedded widgets collapsed to
  /// one object replacement character each.
  String _plainText() {
    final buffer = StringBuffer();
    for (final span in _spans) {
      if (span is TextSpan) {
        buffer.write(span.text ?? '');
      } else {
        buffer.write('\uFFFC');
      }
    }
    return buffer.toString();
  }

  /// The most recent selection, kept so the copy action can rewrite embedded
  /// placeholders before the clipboard sees them.
  String _selection = '';

  Widget _contextMenu(BuildContext context, SelectableRegionState state) {
    final items = [
      for (final item in state.contextMenuButtonItems)
        if (item.type == ContextMenuButtonType.copy)
          ContextMenuButtonItem(
            type: item.type,
            label: item.label,
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: _restorePlaceholders(_selection)),
              );
              ContextMenuController.removeAny();
            },
          )
        else
          item,
    ];
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: state.contextMenuAnchors,
      buttonItems: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effective = widget.style ?? Theme.of(context).textTheme.bodyLarge;
    return SelectionArea(
      contextMenuBuilder: _contextMenu,
      onSelectionChanged: (content) => _selection = content?.plainText ?? '',
      child: Text.rich(
        TextSpan(style: effective, children: _spans),
        softWrap: true,
      ),
    );
  }

  Future<void> _open(BuildContext context, String token) async {
    final uri = Uri.tryParse(token);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.externalLinkFailed)));
    }
  }
}

/// Rewrites a selection of [flattened] text so each embedded emoji — one
/// `U+FFFC` in the flattened string, at the offsets in [placeholders] — reads
/// as its shortcode.
///
/// The selection is a slice of [flattened], so locating it there gives every
/// placeholder inside the selection an absolute position. When the slice
/// cannot be located the selection is returned unchanged, which is preferable
/// to inventing emoji the user did not select.
String restoreEmojiPlaceholders(
  String selected,
  String flattened,
  List<({int offset, String shortcode})> placeholders,
) {
  if (placeholders.isEmpty || !selected.contains('\uFFFC')) return selected;
  final start = flattened.indexOf(selected);
  if (start < 0) return selected;
  final buffer = StringBuffer();
  var cursor = 0;
  for (final placeholder in placeholders) {
    final relative = placeholder.offset - start;
    if (relative < 0 || relative >= selected.length) continue;
    buffer
      ..write(selected.substring(cursor, relative))
      ..write(placeholder.shortcode);
    cursor = relative + 1;
  }
  buffer.write(selected.substring(cursor));
  return buffer.toString();
}
