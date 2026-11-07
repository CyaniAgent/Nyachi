// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:mfm_parser/mfm_parser.dart';

/// Parses MFM once per distinct source text.
///
/// Notes are re-rendered constantly — every scroll frame rebuilds the same
/// cards — while their text almost never changes, so parsing on each rebuild
/// is wasted work. The cache is bounded: entries are evicted in the order they
/// were first inserted, which is enough because a feed's hot set is small and
/// the oldest entry is the least likely to come back.
abstract final class MfmDocument {
  static const nestLimit = 20;
  static const _limit = 500;

  static final _cache = <String, List<MfmNode>>{};

  static List<MfmNode> parse(String text) {
    if (text.isEmpty) return const [];
    final cached = _cache.remove(text);
    if (cached != null) {
      // Re-inserting moves the entry to the end, so eviction stays FIFO on
      // insertion order rather than on first use.
      _cache[text] = cached;
      return cached;
    }
    final nodes = _parse(text);
    _cache[text] = nodes;
    if (_cache.length > _limit) {
      _cache.remove(_cache.keys.first);
    }
    return nodes;
  }

  static List<MfmNode> _parse(String text) {
    try {
      return const MfmParser().parse(text, nestLimit: nestLimit);
    } catch (_) {
      // The parser throws on input it cannot consume; showing the note as
      // plain text is always better than failing to render it at all.
      return [MfmText(text)];
    }
  }

  /// Drops every cached parse. Tests use this so one case cannot leak its
  /// documents into the next.
  static void clearCacheForTest() => _cache.clear();
}
