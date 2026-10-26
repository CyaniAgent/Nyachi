// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:misskey_dart_api/misskey_dart_api.dart';

import 'note_feed_source.dart';

class NotePage {
  const NotePage({required this.items, required this.hasMore});

  final List<Note> items;
  final bool hasMore;
}

abstract interface class NoteFeedRepository {
  Future<NotePage> fetchPage(NoteFeedSource source, {String? untilId});

  Future<List<Note>> readCache(NoteFeedSource source);

  Future<void> writeCache(NoteFeedSource source, List<Note> notes);
}
