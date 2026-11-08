// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart' hide Clip;

import '../../../core/ui/l10n_ext.dart';
import '../../../core/ui/network_image.dart';
import '../../../core/ui/time_format.dart';
import 'emoji_text.dart';

/// A note's poll, in both states it can be in: votable and read-only.
///
/// A single-answer poll is cast on tap, which is what the server offers (one
/// choice per request). A multiple-answer poll collects a selection first,
/// because the server only accepts the choices one call at a time and casting
/// them as they are tapped would make every tap a vote that cannot be taken
/// back — the API has no way to undo a single choice.
///
/// Results are hidden until the viewer has voted, the poll closed, or they
/// asked for them: showing counts while voting pushes people to follow the
/// majority instead of answering.
class NotePollView extends StatefulWidget {
  const NotePollView({
    required this.note,
    required this.onVote,
    this.detailMode = false,
    super.key,
  });

  /// Carries the poll and the emoji map for its choice text.
  final Note note;

  /// Casts [choices]; the caller refreshes the note and publishes the result.
  final Future<void> Function(List<int> choices) onVote;

  final bool detailMode;

  @override
  State<NotePollView> createState() => _NotePollViewState();
}

class _NotePollViewState extends State<NotePollView> {
  /// Selected indices while a multiple-answer poll is being filled in.
  final Set<int> _selected = <int>{};

  /// Set when the viewer asks to see results before voting.
  var _showResults = false;

  var _busy = false;

  NotePoll get _poll => widget.note.poll!;

  bool get _voted => _poll.choices.any((choice) => choice.isVoted);

  bool get _closed {
    final expiresAt = _poll.expiresAt;
    return expiresAt != null && expiresAt.isBefore(DateTime.now());
  }

  /// Whether counts and bars are on screen.
  bool get _revealVotes => _voted || _closed || _showResults;

  /// Whether the choice rows still accept taps.
  bool get _votable => !_voted && !_closed && !_showResults && !_busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final poll = _poll;
    final total = poll.choices.fold<num>(
      0,
      (sum, choice) => sum + choice.votes,
    );
    final multiple = _poll.multiple;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, choice) in poll.choices.indexed)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 6),
            child: _PollChoiceRow(
              text: choice.text,
              emojis: widget.note.emojis,
              revealed: _revealVotes,
              total: total,
              votes: choice.votes,
              mine: choice.isVoted,
              selected: _selected.contains(index),
              onTap: _votable ? () => _onChoiceTap(index) : null,
              height: widget.detailMode ? 44 : 40,
            ),
          ),
        if (multiple && !_revealVotes && _selected.isNotEmpty) ...[
          const SizedBox(height: 10),
          FilledButton(
            onPressed: _busy ? null : () => _submit(_selected.toList()..sort()),
            child: Text(context.l10n.pollVote),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                _footnote(multiple, total),
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!_voted && !_closed)
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _showResults = !_showResults),
                child: Text(
                  _showResults
                      ? context.l10n.pollBackToVote
                      : context.l10n.pollViewResults,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// The line under the choices: state, or the tally once it is revealed.
  String _footnote(bool multiple, num total) {
    if (_closed) return context.l10n.pollClosed;
    if (!_revealVotes) {
      return multiple ? context.l10n.pollSelectMultiple : '';
    }
    return context.l10n.pollVoteCount(total.toInt());
  }

  void _onChoiceTap(int index) {
    if (_poll.multiple) {
      setState(() {
        if (!_selected.remove(index)) _selected.add(index);
      });
      return;
    }
    _submit([index]);
  }

  Future<void> _submit(List<int> choices) async {
    if (_busy || choices.isEmpty) return;
    setState(() => _busy = true);
    try {
      await widget.onVote(choices);
      if (!mounted) return;
      setState(() => _selected.clear());
    } on Object {
      // The caller has already told the viewer what went wrong; the selection
      // survives so the vote can be retried without re-picking the answers.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// One choice: a bar whose fill is the share of votes, with the text on top.
///
/// Before results are revealed the bar is empty and the row reads as a plain
/// option, so nothing about the current tally leaks into the choice.
class _PollChoiceRow extends StatelessWidget {
  const _PollChoiceRow({
    required this.text,
    required this.emojis,
    required this.revealed,
    required this.total,
    required this.votes,
    required this.mine,
    required this.selected,
    required this.onTap,
    required this.height,
  });

  final String text;
  final Map<String, String>? emojis;
  final bool revealed;
  final num total;
  final num votes;

  /// The viewer voted for this choice.
  final bool mine;

  /// Chosen in a multiple-answer poll that has not been submitted yet.
  final bool selected;

  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fraction = total > 0 ? votes / total : 0.0;
    final highlighted = mine || selected;

    return Semantics(
      button: onTap != null,
      selected: highlighted,
      label: revealed ? '$text, ${compactCount(context, votes)}' : text,
      child: Material(
        color: revealed
            ? scheme.surfaceContainerHighest
            : highlighted
            ? scheme.secondaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (revealed && fraction > 0)
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: ColoredBox(
                      color: mine
                          ? scheme.primaryContainer
                          : scheme.secondaryContainer,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ChoiceText(
                          text: text,
                          emojis: emojis,
                          selected: highlighted && !revealed,
                        ),
                      ),
                      if (revealed)
                        Text(
                          '${compactCount(context, votes)}'
                          ' · ${(fraction * 100).round()}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
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

/// Choice text with its custom emoji resolved through the note's emoji map.
///
/// Misskey writes poll choices as plain text containing `:name:` shortcodes,
/// and `EmojiText.resolveUrl` is what turns one into an image URL here.
class _ChoiceText extends StatelessWidget {
  const _ChoiceText({
    required this.text,
    required this.emojis,
    required this.selected,
  });

  final String text;
  final Map<String, String>? emojis;
  final bool selected;

  static final _shortcode = RegExp(r':([A-Za-z0-9_+\-]+):');

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 14,
    );
    // A choice without shortcodes is the common case and needs no spans.
    if (!text.contains(':')) {
      return Text(text, style: style, maxLines: 2);
    }
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _shortcode.allMatches(text)) {
      final url = EmojiText.resolveUrl(match.group(0)!, emojis: emojis);
      if (url == null) continue;
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: NyachiImage(
              url: url,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    if (spans.isEmpty) return Text(text, style: style, maxLines: 2);
    return Text.rich(TextSpan(style: style, children: spans), maxLines: 2);
  }
}
