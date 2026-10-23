// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/storage/storage_providers.dart';

part 'note_repository.g.dart';

abstract interface class NoteRepository {
  Future<Note> fetch(String noteId);

  Future<Note> react(String noteId, String reaction);

  Future<Note> unreact(String noteId);

  Future<Note> renote(String noteId);
}

class MisskeyNoteRepository implements NoteRepository {
  MisskeyNoteRepository({
    required this.client,
    required this.cache,
    required this.accountId,
  });

  final MisskeyClient client;
  final CacheDao cache;
  final String accountId;

  String _key(String noteId) => 'note:$noteId';

  @override
  Future<Note> fetch(String noteId) async {
    try {
      final note = await client.notes.show(noteId: noteId);
      await _write(note);
      return note;
    } catch (_) {
      final cached = await cache.read(accountId, _key(noteId));
      if (cached != null) {
        try {
          final json = jsonDecode(cached.payload);
          if (json is Map<String, dynamic>) return Note.fromJson(json);
          if (json is Map) {
            return Note.fromJson(Map<String, dynamic>.from(json));
          }
        } catch (_) {
          // Fall through to the original network failure.
        }
      }
      rethrow;
    }
  }

  @override
  Future<Note> react(String noteId, String reaction) async {
    await client.notes.reactionsCreate(noteId: noteId, reaction: reaction);
    return _refresh(noteId);
  }

  @override
  Future<Note> unreact(String noteId) async {
    await client.notes.reactionsDelete(noteId: noteId);
    return _refresh(noteId);
  }

  @override
  Future<Note> renote(String noteId) async {
    await client.notes.create(renoteId: noteId, text: null);
    return _refresh(noteId);
  }

  Future<Note> _refresh(String noteId) async {
    final note = await client.notes.show(noteId: noteId);
    await _write(note);
    return note;
  }

  Future<void> _write(Note note) {
    return cache.write(accountId, _key(note.id), jsonEncode(note.toJson()));
  }
}

@Riverpod(keepAlive: true)
NoteRepository noteRepository(Ref ref) {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) throw StateError('No active account.');
  return MisskeyNoteRepository(
    client: ref.watch(misskeyClientProvider),
    cache: ref.watch(cacheDaoProvider),
    accountId: active.id,
  );
}
