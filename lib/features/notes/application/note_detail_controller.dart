// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/error_mapper.dart';
import '../data/note_repository.dart';

part 'note_detail_controller.freezed.dart';
part 'note_detail_controller.g.dart';

@Riverpod(keepAlive: true)
class NoteOverrides extends _$NoteOverrides {
  @override
  Map<String, Note> build() {
    ref.watch(sessionControllerProvider).active?.id;
    return const {};
  }

  void put(Note note) {
    state = {...state, note.id: note};
  }
}

@freezed
abstract class NoteDetailState with _$NoteDetailState {
  const factory NoteDetailState({
    Note? note,
    @Default(true) bool loading,
    @Default(false) bool mutating,
    AppFailure? error,
    @Default(false) bool usingCache,
  }) = _NoteDetailState;
}

@riverpod
class NoteDetailController extends _$NoteDetailController {
  late String _noteId;
  var _disposed = false;

  @override
  NoteDetailState build(String noteId) {
    _noteId = noteId;
    _disposed = false;
    ref.watch(sessionControllerProvider).active?.id;
    ref.onDispose(() => _disposed = true);
    final override = ref.read(noteOverridesProvider)[noteId];
    if (override != null) {
      return NoteDetailState(note: override, loading: false);
    }
    unawaited(Future<void>.microtask(_load));
    return const NoteDetailState();
  }

  Future<void> _load() async {
    try {
      final note = await ref.read(noteRepositoryProvider).fetch(_noteId);
      if (_disposed) return;
      state = state.copyWith(note: note, loading: false, error: null);
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(loading: false, error: mapFailure(error));
    }
  }

  Future<void> toggleReaction(String reaction) async {
    final note = state.note;
    if (note == null || state.mutating) return;
    state = state.copyWith(mutating: true, error: null);
    try {
      final updated = note.myReaction == reaction
          ? await ref.read(noteRepositoryProvider).unreact(note.id)
          : await ref.read(noteRepositoryProvider).react(note.id, reaction);
      if (_disposed) return;
      ref.read(noteOverridesProvider.notifier).put(updated);
      state = state.copyWith(note: updated, mutating: false);
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(mutating: false, error: mapFailure(error));
    }
  }

  Future<void> renote() async {
    final note = state.note;
    if (note == null || state.mutating) return;
    state = state.copyWith(mutating: true, error: null);
    try {
      final updated = await ref.read(noteRepositoryProvider).renote(note.id);
      if (_disposed) return;
      ref.read(noteOverridesProvider.notifier).put(updated);
      state = state.copyWith(note: updated, mutating: false);
    } catch (error) {
      if (_disposed) return;
      state = state.copyWith(mutating: false, error: mapFailure(error));
    }
  }
}
