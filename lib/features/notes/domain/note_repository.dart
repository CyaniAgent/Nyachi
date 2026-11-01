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

  Future<void> favorite(String noteId);

  Future<void> unfavorite(String noteId);

  Future<void> delete(String noteId);

  Future<({bool isFavorited, bool isMutedThread})> state(String noteId);

  Future<void> setThreadMuted(String noteId, {required bool muted});

  /// Reports the note's author, not the note itself: the server endpoint
  /// (`users/report-abuse`) only accepts a user and a comment.
  Future<void> reportUser({required String userId, required String comment});

  /// The per-user memo is stored on the user, so reading it requires the
  /// user detail that `Note.user` (a UserLite) does not carry.
  Future<String?> userMemo(String userId);

  Future<void> updateMemo({required String userId, required String memo});
}
