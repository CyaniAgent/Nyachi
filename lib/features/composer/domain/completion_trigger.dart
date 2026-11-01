// SPDX-License-Identifier: AGPL-3.0-or-later

/// The kind of inline completion a token starts.
enum CompletionKind { mention, hashtag, emoji }

/// The trigger token under the caret, as the user is typing it.
///
/// [start] is the offset of the trigger character itself; [query] is the text
/// between the trigger and [end] (never including the trigger). [end] equals
/// the caret offset, so a completion replaces exactly `text[start..end]`.
class CompletionTrigger {
  const CompletionTrigger({
    required this.kind,
    required this.start,
    required this.end,
    required this.query,
  });

  final CompletionKind kind;
  final int start;
  final int end;
  final String query;

  /// Replaces this token with [replacement] inside [source].
  ///
  /// [replacement] includes its own trigger character so each caller decides
  /// the completion syntax (`@name`, `#tag`, `:emoji:`). The returned caret
  /// sits after the inserted text, and a separating space is only added when
  /// the source does not already continue with one - completing in the middle
  /// of a sentence must not leave a double space.
  ({String text, int caret}) apply(String source, String replacement) {
    final needsSpace = end >= source.length || source[end] != ' ';
    final suffix = needsSpace ? ' ' : '';
    final text = source.replaceRange(start, end, '$replacement$suffix');
    return (text: text, caret: start + replacement.length + suffix.length);
  }

  @override
  String toString() => 'CompletionTrigger($kind, $start..$end, "$query")';
}

/// Characters that end a token: whitespace plus the trigger characters, so a
/// sentence continues normally and a second trigger starts its own token.
bool _isTokenBreak(String char) =>
    char == ' ' ||
    char == '\n' ||
    char == '\t' ||
    char == '@' ||
    char == '#' ||
    char == ':';

/// Emoji shortcodes are ASCII names; anything else is prose with a colon.
final _emojiQuery = RegExp(r'^[a-zA-Z0-9_+\-]+$');

/// Finds the completion token that the caret at [caret] sits at the end of.
///
/// Returns null when the caret is not immediately after a non-empty trigger
/// query, which keeps a bare `@` from opening the panel before a character is
/// typed. [text] is the whole field content.
CompletionTrigger? triggerAt(String text, int caret) {
  if (caret <= 0 || caret > text.length) return null;
  for (var start = caret - 1; start >= 0; start--) {
    final char = text[start];
    if (char == '@' || char == '#' || char == ':') {
      final query = text.substring(start + 1, caret);
      if (query.isEmpty) return null;
      final kind = switch (char) {
        '@' => CompletionKind.mention,
        '#' => CompletionKind.hashtag,
        _ => CompletionKind.emoji,
      };
      // Whitespace or a further trigger character ends every token. A remote
      // mention ("@user@host") therefore resolves to no token, which is
      // correct: the completion would otherwise replace only the host.
      if (query.split('').any(_isTokenBreak)) return null;
      // Emoji shortcodes are ASCII names; anything else is prose.
      if (kind == CompletionKind.emoji && !_emojiQuery.hasMatch(query)) {
        return null;
      }
      // A trigger glued to a preceding word ("foo@bar", "C#") is prose.
      if (start > 0) {
        final before = text[start - 1];
        if (before != ' ' && before != '\n' && before != '\t') return null;
      }
      return CompletionTrigger(
        kind: kind,
        start: start,
        end: caret,
        query: query,
      );
    }
    final isBreak = char == ' ' || char == '\n' || char == '\t';
    if (isBreak) return null;
  }
  return null;
}
