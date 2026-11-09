// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/detail_panel/detail_location.dart';
import '../../app/detail_panel/open_detail.dart';
import '../../features/notes/presentation/emoji_text.dart';
import '../../features/settings/application/app_settings.dart';
import '../ui/l10n_ext.dart';
import '../network/client_provider.dart';
import 'mfm_document.dart';
import 'mfm_motion.dart';

/// Where a widget span sits in the flattened text, and what it reads as.
typedef MfmPlaceholder = ({int offset, String text});

/// Renders MFM text: the body of a note, a profile description, a chat
/// message, an announcement.
///
/// Inline content becomes one `Text.rich` per contiguous run so text stays
/// copyable; block-level constructs (quote, code, maths, centring) get their
/// own widget so they can lay themselves out. The body sits in one
/// [SelectionArea] by default, which lets a selection span a paragraph and the
/// quote under it.
///
/// That container also claims taps for its own selection gestures, so a body
/// inside a tappable row must set [selectable] to false: otherwise tapping the
/// text selects instead of opening what the row opens.
class MfmBody extends ConsumerStatefulWidget {
  const MfmBody({
    required this.text,
    this.emojis,
    this.style,
    this.detail = false,
    this.maxLines,
    this.selectable = true,
    super.key,
  });

  final String text;

  /// The note's `emojis` map — the authoritative source for custom emoji,
  /// including those hosted on remote instances.
  final Map<String, String>? emojis;

  final TextStyle? style;

  /// Whether this is a detail view. Motion defaults to detail views only, so
  /// a timeline of many notes never repaints every frame.
  final bool detail;

  /// Clamps the body to this many lines and drops block layout; used by list
  /// rows that only preview a note.
  final int? maxLines;

  /// Whether the body is wrapped in a [SelectionArea].
  ///
  /// False where an ancestor handles the tap: the selection gestures win the
  /// arena against `InkWell` and `ListTile`, so text that can be selected
  /// cannot also open the row it belongs to.
  final bool selectable;

  @override
  ConsumerState<MfmBody> createState() => _MfmBodyState();
}

class _MfmBodyState extends ConsumerState<MfmBody> {
  final List<TapGestureRecognizer> _recognizers = [];

  List<Widget> _blocks = const [];
  List<MfmPlaceholder> _placeholders = const [];
  String _flattened = '';
  String _selection = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuild();
  }

  @override
  void didUpdateWidget(MfmBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.emojis != widget.emojis ||
        oldWidget.style != widget.style ||
        oldWidget.detail != widget.detail ||
        oldWidget.maxLines != widget.maxLines) {
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
    final settings = ref.watch(settingsControllerProvider);
    final policy = _MotionPolicy(
      mode: mfmMotionModeFrom(settings.mfmMotionMode),
      classes: {
        for (final name in settings.mfmMotionClasses)
          for (final value in MfmMotionClass.values)
            if (value.name == name) value,
      },
      detail: widget.detail,
    );
    final theme = Theme.of(context);
    final built = _BlockBuilder(
      emojis: widget.emojis,
      style: widget.style ?? theme.textTheme.bodyLarge ?? const TextStyle(),
      policy: policy,
      theme: theme,
      onRecognizer: _recognizers.add,
      onMention: _openMention,
      onUrl: _openUrl,
      onTag: (tag) => openDetail(context, TagDetailLocation(tag)),
      onSearch: _openSearch,
      compact: widget.maxLines != null,
      maxLines: widget.maxLines,
    ).build(MfmDocument.parse(widget.text));
    _blocks = built.widgets;
    _placeholders = built.placeholders;
    _flattened = built.flattened;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.externalLinkFailed)));
    }
  }

  void _openSearch(String query) {
    openDetail(context, SearchDetailLocation(query));
  }

  Future<void> _openMention(String username, String? host) async {
    try {
      final user = await ref
          .read(misskeyClientProvider)
          .users
          .showByUsername(username: username, host: host);
      if (mounted) openDetail(context, UserDetailLocation(user.id));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.userNotFound)));
      }
    }
  }

  Widget _contextMenu(BuildContext context, SelectableRegionState state) {
    final items = [
      for (final item in state.contextMenuButtonItems)
        if (item.type == ContextMenuButtonType.copy)
          ContextMenuButtonItem(
            type: item.type,
            label: item.label,
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text: restoreEmojiPlaceholders(
                    _selection,
                    _flattened,
                    _placeholders,
                  ),
                ),
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
    if (widget.text.isEmpty) return const SizedBox.shrink();
    // The blocks already space themselves; a Column keeps them in one
    // selection container.
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _blocks,
    );
    if (!widget.selectable) return body;
    return SelectionArea(
      contextMenuBuilder: _contextMenu,
      onSelectionChanged: (content) => _selection = content?.plainText ?? '',
      child: body,
    );
  }
}

/// Whether motion may run here, and which classes may run.
class _MotionPolicy {
  const _MotionPolicy({
    required this.mode,
    required this.classes,
    required this.detail,
  });

  final MfmMotionMode mode;
  final Set<MfmMotionClass> classes;
  final bool detail;

  bool allows(MfmMotionClass motionClass) =>
      mfmMotionEnabled(mode, detail: detail) &&
      mfmClassEnabled(classes, motionClass);
}

typedef _MentionHandler = Future<void> Function(String username, String? host);

class _Built {
  const _Built({
    required this.widgets,
    required this.placeholders,
    required this.flattened,
  });

  final List<Widget> widgets;
  final List<MfmPlaceholder> placeholders;
  final String flattened;
}

/// Turns a node list into widgets plus the flattened text a selection sees.
class _BlockBuilder {
  _BlockBuilder({
    required this.emojis,
    required this.style,
    required this.policy,
    required this.theme,
    required this.onRecognizer,
    required this.onMention,
    required this.onUrl,
    required this.onTag,
    required this.onSearch,
    required this.compact,
    required this.maxLines,
  });

  final Map<String, String>? emojis;
  final TextStyle style;
  final _MotionPolicy policy;
  final ThemeData theme;
  final void Function(TapGestureRecognizer) onRecognizer;
  final _MentionHandler onMention;
  final void Function(String) onUrl;
  final void Function(String) onTag;
  final void Function(String) onSearch;

  /// List rows render one clamped paragraph instead of the full block layout.
  final bool compact;

  /// Line clamp applied in compact mode.
  final int? maxLines;

  final _placeholders = <MfmPlaceholder>[];
  final _flattened = StringBuffer();
  final _pending = <String>[];

  /// Non-zero while building the inside of a widget span: whatever those
  /// children contain is invisible to the outer selection, which sees one
  /// `U+FFFC` for the whole widget.
  var _suppressPending = 0;

  /// Current `x2`/`x3`/`x4` nesting depth; the frontend halves the multiplier
  /// once and ignores it beyond that.
  var _scaleDepth = 0;

  _Built build(List<MfmNode> nodes) {
    final widgets = <Widget>[];
    final inline = <MfmNode>[];

    void flushInline() {
      if (inline.isEmpty) return;
      final spans = _spans(inline);
      inline.clear();
      _collect(spans, first: widgets.isEmpty);
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top: widgets.isEmpty ? 0 : 8),
          child: Text.rich(
            TextSpan(style: style, children: spans),
            maxLines: compact ? maxLines : null,
            overflow: compact ? TextOverflow.ellipsis : null,
          ),
        ),
      );
    }

    for (final node in nodes) {
      if (node is MfmBlock && !compact) {
        flushInline();
        widgets.add(_block(node, first: widgets.isEmpty));
      } else {
        inline.add(node);
      }
    }
    flushInline();
    return _Built(
      widgets: List.unmodifiable(widgets),
      placeholders: List.unmodifiable(_placeholders),
      flattened: _flattened.toString(),
    );
  }

  Widget _block(MfmNode node, {required bool first}) {
    final padding = EdgeInsets.only(top: first ? 0 : 8);
    switch (node) {
      case MfmQuote():
        if (!first) _flattened.write('\n');
        final inner = _spans(node.children ?? const []);
        _collectTrailing(inner);
        return Padding(
          padding: padding,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: style.color ?? theme.colorScheme.onSurface,
                  width: 3,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 6, 0, 6),
            child: Text.rich(TextSpan(style: style, children: inner)),
          ),
        );
      case MfmCodeBlock():
        if (!first) _flattened.write('\n');
        _flattened.write(node.code);
        return Padding(
          padding: padding,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Text(
              node.code,
              style: style.copyWith(
                fontFamily: 'monospace',
                fontSize: (style.fontSize ?? 14) * 0.9,
              ),
            ),
          ),
        );
      case MfmMathBlock():
        if (!first) _flattened.write('\n');
        _flattened.write(node.formula);
        return Padding(
          padding: padding,
          child: Center(child: _math(node.formula, display: true)),
        );
      case MfmCenter():
        if (!first) _flattened.write('\n');
        final inner = _spans(node.children ?? const []);
        _collectTrailing(inner);
        return Padding(
          padding: padding,
          child: Text.rich(
            TextSpan(style: style, children: inner),
            textAlign: TextAlign.center,
          ),
        );
      case MfmSearch():
        if (!first) _flattened.write('\n');
        _flattened.write(node.query);
        return Padding(
          padding: padding,
          child: GestureDetector(
            onTap: () => onSearch(node.query),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    node.query,
                    style: style.copyWith(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// Appends a block's spans that were built before the block itself.
  void _collectTrailing(List<InlineSpan> spans) {
    for (final span in spans) {
      if (span is TextSpan) {
        final plain = span.toPlainText(includeSemanticsLabels: false);
        _flattened.write(plain);
      } else {
        _flattened.write('\uFFFC');
        _placeholders.add((
          offset: _flattened.length - 1,
          text: _pending.isEmpty ? '' : _pending.removeAt(0),
        ));
      }
    }
  }

  /// Appends one paragraph's spans to the flattened text, recording each
  /// widget span so the copy action can restore what it stands for.
  void _collect(List<InlineSpan> spans, {required bool first}) {
    if (!first) _flattened.write('\n');
    for (final span in spans) {
      if (span is TextSpan) {
        _flattened.write(span.toPlainText(includeSemanticsLabels: false));
      } else {
        _flattened.write('\uFFFC');
        _placeholders.add((
          offset: _flattened.length - 1,
          text: _pending.isEmpty ? '' : _pending.removeAt(0),
        ));
      }
    }
  }

  void _queuePlaceholder(String text) {
    if (_suppressPending > 0) return;
    _pending.add(text);
  }

  Widget _math(String formula, {required bool display}) {
    return Math.tex(
      formula,
      mathStyle: display ? MathStyle.display : MathStyle.text,
      textStyle: style,
      onErrorFallback: (_) => Text(
        display ? formula : '\$$formula\$',
        style: style.copyWith(fontFamily: 'monospace'),
      ),
    );
  }

  List<InlineSpan> _spans(List<MfmNode> nodes, {TextStyle? inherited}) {
    final spans = <InlineSpan>[];
    final base = inherited ?? style;
    for (final node in nodes) {
      spans.addAll(_span(node, base));
    }
    return spans;
  }

  /// Builds the children of a widget span, where placeholders are invisible.
  List<InlineSpan> _innerSpans(List<MfmNode> nodes, TextStyle base) {
    _suppressPending += 1;
    try {
      return _spans(nodes, inherited: base);
    } finally {
      _suppressPending -= 1;
    }
  }

  TapGestureRecognizer _recognizer(VoidCallback onTap) {
    final recognizer = TapGestureRecognizer()..onTap = onTap;
    onRecognizer(recognizer);
    return recognizer;
  }

  TextStyle _linkStyle(TextStyle base) => base.copyWith(
    color: theme.colorScheme.primary,
    decoration: TextDecoration.underline,
    decorationColor: theme.colorScheme.primary,
  );

  List<InlineSpan> _span(MfmNode node, TextStyle base) {
    switch (node) {
      case MfmText():
        return [TextSpan(text: node.text, style: base)];
      case MfmPlain():
        return [TextSpan(text: node.text, style: base)];
      case MfmUnicodeEmoji():
        return [TextSpan(text: node.emoji, style: base)];
      case MfmBold():
        return _spans(
          node.children ?? const [],
          inherited: base.copyWith(fontWeight: FontWeight.bold),
        );
      case MfmSmall():
        // The frontend renders <small> at 70% opacity, so it dims as well as
        // shrinking.
        return _spans(
          node.children ?? const [],
          inherited: base.copyWith(
            fontSize: (base.fontSize ?? 14) * 0.8,
            color: (base.color ?? theme.colorScheme.onSurface).withValues(
              alpha: 0.7,
            ),
          ),
        );
      case MfmStrike():
        return _spans(
          node.children ?? const [],
          inherited: base.copyWith(decoration: TextDecoration.lineThrough),
        );
      // The package labels italic nodes with type "small"; the runtime type is
      // the only reliable discriminator.
      case MfmItalic():
        return _spans(
          node.children ?? const [],
          inherited: base.copyWith(fontStyle: FontStyle.italic),
        );
      case MfmInlineCode():
        return [
          TextSpan(
            text: node.code,
            style: base.copyWith(
              fontFamily: 'monospace',
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ];
      case MfmEmojiCode():
        final shortcode = ':${node.name}:';
        if (EmojiText.resolveUrl(shortcode, emojis: emojis) == null) {
          return [TextSpan(text: shortcode, style: base)];
        }
        _queuePlaceholder(shortcode);
        return [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: EmojiText(emoji: shortcode, emojis: emojis, size: 18),
            ),
          ),
        ];
      case MfmMathInline():
        _queuePlaceholder('\$${node.formula}\$');
        return [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _math(node.formula, display: false),
          ),
        ];
      case MfmMention():
        return [
          TextSpan(
            text: node.acct,
            style: _linkStyle(base),
            recognizer: _recognizer(() => onMention(node.username, node.host)),
          ),
        ];
      case MfmHashTag():
        return [
          TextSpan(
            text: '#${node.hashTag}',
            style: _linkStyle(base),
            recognizer: _recognizer(() => onTag(node.hashTag)),
          ),
        ];
      case MfmLink():
        final label = _plainOf(node.children ?? const []);
        return [
          TextSpan(
            text: node.silent ? label : '$label (${node.url})',
            style: node.silent ? base : _linkStyle(base),
            recognizer: _recognizer(() => onUrl(node.url)),
          ),
        ];
      case MfmURL():
        return [
          TextSpan(
            text: node.brackets == true ? '<${node.value}>' : node.value,
            style: _linkStyle(base),
            recognizer: _recognizer(() => onUrl(node.value)),
          ),
        ];
      case MfmFn():
        return _fn(node, base);
      case MfmQuote() ||
          MfmCodeBlock() ||
          MfmMathBlock() ||
          MfmCenter() ||
          MfmSearch():
        // A block nested inside an inline run: keep its content rather than
        // dropping it.
        return _spans(node.children ?? const [], inherited: base);
      default:
        return _spans(node.children ?? const [], inherited: base);
    }
  }

  List<InlineSpan> _fn(MfmFn node, TextStyle base) {
    final scaled = mfmScaleFactor(node, depth: _scaleDepth);
    if (scaled != null) {
      _scaleDepth += 1;
      try {
        return _spans(
          node.children ?? const [],
          inherited: base.copyWith(fontSize: (base.fontSize ?? 14) * scaled),
        );
      } finally {
        _scaleDepth -= 1;
      }
    }

    final color = mfmParseColor(node.args['color']);
    if (node.name == 'fg') {
      return _spans(
        node.children ?? const [],
        inherited: base.copyWith(color: color),
      );
    }
    if (node.name == 'bg') {
      return _spans(
        node.children ?? const [],
        inherited: base.copyWith(backgroundColor: color),
      );
    }
    if (node.name == 'font') {
      final key = node.args.keys.isEmpty ? '' : node.args.keys.first;
      final family = switch (key) {
        'serif' => 'serif',
        'monospace' => 'monospace',
        'cursive' => 'cursive',
        'fantasy' => 'fantasy',
        'emoji' => 'emoji',
        'math' => 'math',
        _ => null,
      };
      return _spans(
        node.children ?? const [],
        inherited: family == null ? base : base.copyWith(fontFamily: family),
      );
    }

    if (node.name == 'position' ||
        node.name == 'rotate' ||
        node.name == 'scale') {
      final children = node.children ?? const <MfmNode>[];
      final child = _innerSpans(children, base);
      _queuePlaceholder(_plainOf(children));
      final dxArg = double.tryParse('${node.args['x'] ?? 0}') ?? 0;
      final dyArg = double.tryParse('${node.args['y'] ?? 0}') ?? 0;
      // `position` is expressed in em, so it scales with the text.
      final em = dxArg * (base.fontSize ?? 14);
      final emY = dyArg * (base.fontSize ?? 14);
      final deg = double.tryParse('${node.args['deg'] ?? 90}') ?? 90;
      final sx = (double.tryParse('${node.args['x'] ?? 1}') ?? 1).clamp(
        0.0,
        5.0,
      );
      final sy = (double.tryParse('${node.args['y'] ?? 1}') ?? 1).clamp(
        0.0,
        5.0,
      );
      return [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: switch (node.name) {
            'position' => Transform.translate(
              offset: Offset(em, emY),
              child: _rich(child, base),
            ),
            'rotate' => Transform.rotate(
              angle: deg * 3.1415926535897932 / 180,
              child: _rich(child, base),
            ),
            _ => Transform.scale(
              scaleX: sx,
              scaleY: sy,
              child: _rich(child, base),
            ),
          },
        ),
      ];
    }

    if (node.name == 'flip') {
      final children = node.children ?? const <MfmNode>[];
      final child = _innerSpans(children, base);
      _queuePlaceholder(_plainOf(children));
      final flipX = node.args['h'] == true || node.args['x'] == true;
      final flipY = node.args['v'] == true || node.args['y'] == true;
      return [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Transform.flip(
            flipX: flipX,
            flipY: flipY,
            child: _rich(child, base),
          ),
        ),
      ];
    }

    final spec = mfmEffectOf(node);
    if (spec != null) {
      final children = node.children ?? const <MfmNode>[];
      if (spec.effect == MfmEffect.blur) {
        // Blur is a filter, not a cycle: it is blurred at rest and clears on
        // hover/press, so it renders the same whether motion is on or off.
        final child = _innerSpans(children, base);
        _queuePlaceholder(_plainOf(children));
        return [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MfmBlurred(style: base, child: child),
          ),
        ];
      }
      if (!policy.allows(spec.motionClass)) {
        // Each effect degrades to the part the stylesheet keeps when animation
        // is disabled: tada keeps its 150% size, rainbow keeps a gradient, and
        // the transform-only effects keep plain text.
        switch (spec.effect) {
          case MfmEffect.tada:
            return _spans(
              children,
              inherited: base.copyWith(fontSize: (base.fontSize ?? 14) * 1.5),
            );
          case MfmEffect.rainbow:
            final child = _innerSpans(children, base);
            _queuePlaceholder(_plainOf(children));
            return [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFFF0000),
                      Color(0xFFFFA500),
                      Color(0xFFFFFF00),
                      Color(0xFF00FF00),
                      Color(0xFF00FFFF),
                      Color(0xFF0000FF),
                      Color(0xFFFF00FF),
                    ],
                    stops: [0, 0.17, 0.33, 0.5, 0.67, 0.83, 1],
                  ).createShader(bounds),
                  child: _rich(child, base),
                ),
              ),
            ];
          default:
            return _spans(children, inherited: base);
        }
      }
      final child = _innerSpans(children, base);
      _queuePlaceholder(_plainOf(children));
      return [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: MfmMotion(spec: spec, style: base, children: child),
        ),
      ];
    }

    // Unknown function: show it as written so nothing silently disappears.
    final args = node.args.entries
        .map((e) => e.value == true ? e.key : '${e.key}=${e.value}')
        .join(' ');
    final inner = _plainOf(node.children ?? const []);
    final literal =
        '\$[${node.name}${args.isEmpty ? '' : ' $args'}'
        '${inner.isEmpty ? '' : ' $inner'}]';
    return [TextSpan(text: literal, style: base)];
  }

  Widget _rich(List<InlineSpan> spans, TextStyle base) => RichText(
    text: TextSpan(style: base, children: spans),
  );

  String _plainOf(List<MfmNode> nodes) {
    final buffer = StringBuffer();
    void walk(List<MfmNode> list) {
      for (final node in list) {
        switch (node) {
          case MfmText():
            buffer.write(node.text);
          case MfmPlain():
            buffer.write(node.text);
          case MfmUnicodeEmoji():
            buffer.write(node.emoji);
          case MfmEmojiCode():
            buffer.write(':${node.name}:');
          case MfmInlineCode():
            buffer.write(node.code);
          case MfmCodeBlock():
            buffer.write(node.code);
          case MfmMathInline():
            buffer.write('\$${node.formula}\$');
          case MfmMathBlock():
            buffer.write(node.formula);
          case MfmMention():
            buffer.write(node.acct);
          case MfmHashTag():
            buffer.write('#${node.hashTag}');
          case MfmURL():
            buffer.write(node.value);
          case MfmSearch():
            buffer.write(node.query);
          default:
            walk(node.children ?? const []);
        }
      }
    }

    walk(nodes);
    return buffer.toString();
  }
}

/// Rewrites a selection of [flattened] text so each embedded widget — one
/// `U+FFFC` at the offsets in [placeholders] — reads as the text it stands
/// for: an emoji's shortcode, a formula's source, an effect's words.
///
/// The selection is a slice of [flattened], so locating it there gives every
/// placeholder inside the selection an absolute position. When the slice
/// cannot be located the selection is returned unchanged, which is preferable
/// to inventing text the user did not select.
String restoreEmojiPlaceholders(
  String selected,
  String flattened,
  List<MfmPlaceholder> placeholders,
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
      ..write(placeholder.text);
    cursor = relative + 1;
  }
  buffer.write(selected.substring(cursor));
  return buffer.toString();
}
