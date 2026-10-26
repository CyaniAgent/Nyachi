// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/network/instance_repository.dart';
import '../../../core/storage/storage_models.dart';
import '../../../core/storage/storage_providers.dart';
import '../../notes/application/note_detail_controller.dart';
import '../../notes/application/note_list_controller.dart';
import '../../notes/application/note_providers.dart';

part 'composer_controller.freezed.dart';
part 'composer_controller.g.dart';

typedef ComposerSender = Future<void> Function({
  required String text,
  String? cw,
  required NotesCreateRequestVisibility visibility,
  required bool localOnly,
  String? replyId,
});

final composerSenderProvider = Provider<ComposerSender>((ref) {
  return ({
    required text,
    cw,
    required visibility,
    required localOnly,
    replyId,
  }) => ref
      .read(misskeyClientProvider)
      .notes
      .create(
        text: text,
        cw: cw,
        visibility: visibility,
        localOnly: localOnly,
        replyId: replyId,
      );
});

@freezed
abstract class ComposerState with _$ComposerState {
  const factory ComposerState({
    @Default('') String text,
    String? cw,
    @Default(NotesCreateRequestVisibility.public)
    NotesCreateRequestVisibility visibility,
    @Default(false) bool localOnly,
    @Default(false) bool restored,
    @Default(false) bool posting,
    AppFailure? error,
  }) = _ComposerState;
}

@riverpod
class ComposerController extends _$ComposerController {
  Timer? _debounce;
  var _dirty = false;
  var _disposed = false;
  late String? _replyId;
  var _lastText = '';
  String? _lastCw;
  var _lastVisibility = NotesCreateRequestVisibility.public;
  var _lastLocalOnly = false;

  @override
  ComposerState build(String? replyId) {
    _replyId = replyId;
    _lastText = '';
    _lastCw = null;
    _lastVisibility = NotesCreateRequestVisibility.public;
    _lastLocalOnly = false;
    _disposed = false;
    _debounce?.cancel();
    _dirty = false;
    ref.watch(activeAccountProvider)?.id;
    final drafts = ref.read(draftDaoProvider);
    final account = ref.read(activeAccountProvider);
    ref.onDispose(() {
      _disposed = true;
      _debounce?.cancel();
      if (_dirty && account != null) {
        unawaited(
          drafts.save(
            ComposerDraft(
              accountId: account.id,
              text: _lastText,
              cw: _lastCw,
              visibility: _lastVisibility.name,
              localOnly: _lastLocalOnly,
              replyId: _replyId,
              updatedAt: DateTime.now(),
            ),
          ),
        );
      }
    });
    unawaited(Future<void>.microtask(_restoreDraft));
    return const ComposerState();
  }

  int get maxLength =>
      ref.read(instanceInfoProvider).value?.maxNoteTextLength ?? 3000;

  bool get canPost =>
      !state.posting &&
      state.text.trim().isNotEmpty &&
      state.text.runes.length <= maxLength;

  Future<void> _restoreDraft() async {
    final active = ref.read(activeAccountProvider);
    if (active == null) return;
    final draft = await ref.read(draftDaoProvider).read(active.id);
    if (_disposed || draft == null) return;
    if (draft.replyId != _replyId) return;
    final visibility = _parseVisibility(draft.visibility);
    _lastText = draft.text;
    _lastCw = draft.cw;
    _lastVisibility = visibility;
    _lastLocalOnly = draft.localOnly;
    state = state.copyWith(
      text: draft.text,
      cw: draft.cw,
      visibility: visibility,
      localOnly: draft.localOnly,
      restored: true,
    );
  }

  void setText(String value) {
    _lastText = value;
    state = state.copyWith(text: value, error: null);
    _scheduleSave();
  }

  void setCw(String? value) {
    final cw = value == null || value.trim().isEmpty ? null : value;
    _lastCw = cw;
    state = state.copyWith(cw: cw);
    _scheduleSave();
  }

  void setVisibility(NotesCreateRequestVisibility value) {
    _lastVisibility = value;
    state = state.copyWith(visibility: value);
    _scheduleSave();
  }

  void setLocalOnly(bool value) {
    _lastLocalOnly = value;
    state = state.copyWith(localOnly: value);
    _scheduleSave();
  }

  void _scheduleSave() {
    _dirty = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(_persist());
    });
  }

  Future<void> _persist({bool force = false}) async {
    final active = ref.read(activeAccountProvider);
    if (active == null) return;
    if (!_dirty && !force) return;
    _dirty = false;
    final draft = ComposerDraft(
      accountId: active.id,
      text: state.text,
      cw: state.cw,
      visibility: state.visibility.name,
      localOnly: state.localOnly,
      replyId: _replyId,
      updatedAt: DateTime.now(),
    );
    await ref.read(draftDaoProvider).save(draft);
  }

  Future<void> deleteDraft() async {
    final active = ref.read(activeAccountProvider);
    if (active == null) return;
    _debounce?.cancel();
    _dirty = false;
    await ref.read(draftDaoProvider).deleteDraft(active.id);
    _lastText = '';
    _lastCw = null;
    _lastLocalOnly = false;
    state = state.copyWith(
      text: '',
      cw: null,
      localOnly: false,
      restored: false,
      error: null,
    );
  }

  Future<bool> post() async {
    if (!canPost) return false;
    final active = ref.read(activeAccountProvider);
    if (active == null) return false;
    await _persist(force: true);
    state = state.copyWith(posting: true, error: null);
    try {
      await ref.read(composerSenderProvider)(
        text: state.text,
        cw: state.cw,
        visibility: state.visibility,
        localOnly: state.localOnly,
        replyId: _replyId,
      );
      _dirty = false;
      await ref.read(draftDaoProvider).deleteDraft(active.id);
      ref.invalidate(noteListControllerProvider);
      final replyId = _replyId;
      if (replyId != null) {
        ref.invalidate(noteDetailControllerProvider(replyId));
      }
      if (!_disposed) state = state.copyWith(posting: false, restored: false);
      return true;
    } catch (error) {
      if (!_disposed) {
        state = state.copyWith(posting: false, error: mapFailure(error));
      }
      return false;
    }
  }

  NotesCreateRequestVisibility _parseVisibility(String value) {
    for (final option in NotesCreateRequestVisibility.values) {
      if (option.name == value) return option;
    }
    return NotesCreateRequestVisibility.public;
  }
}

/// Loads the note being replied to, for the composer's reply-target preview.
@riverpod
Future<Note?> composerReplyNote(Ref ref, String noteId) async {
  final override = ref.watch(noteOverridesProvider)[noteId];
  if (override != null) return override;
  try {
    return await ref.watch(noteRepositoryProvider).fetch(noteId);
  } catch (_) {
    return null;
  }
}
