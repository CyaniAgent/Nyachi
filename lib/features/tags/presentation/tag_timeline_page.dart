// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

import '../../notes/domain/note_feed_source.dart';
import '../../notes/presentation/note_list.dart';

class TagTimelinePage extends StatelessWidget {
  const TagTimelinePage({required this.tag, super.key});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('#$tag')),
      body: NoteList(source: NoteFeedSource.tag(tag)),
    );
  }
}
