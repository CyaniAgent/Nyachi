// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:misskey_dart_api/misskey_dart_api.dart';

abstract interface class NoteRepository {
  Future<Note> fetch(String noteId);

  Future<CursorPage<Note>> childrenPage(
    String noteId, {
    int limit = 10,
    String? untilId,
  });

  Future<Note> react(String noteId, String reaction);

  Future<Note> unreact(String noteId);

  Future<Note> renote(String noteId);
}
