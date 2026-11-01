// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/network/error_mapper.dart';
import '../../../core/network/instance_repository.dart';
import '../../../core/storage/storage_models.dart';
import '../../notes/application/note_detail_controller.dart';
import '../../notes/application/note_list_controller.dart';
import '../../notes/application/note_providers.dart';
import 'draft_store.dart';

part 'composer_controller.freezed.dart';
part 'composer_controller.g.dart';

typedef ComposerSender = Future<void> Function({
  required String text,
  String? cw,
  required NotesCreateRequestVisibility visibility,
  required bool localOnly,
  String? replyId,
  List<String> fileIds,
  List<String>? pollChoices,
  bool pollMultiple,
  DateTime? pollExpiresAt,
  String? reactionAcceptance,
  List<String> visibleUserIds,
  DateTime? scheduledAt,
});

final composerSenderProvider = Provider<ComposerSender>((ref) {
  return ({
    required text,
    cw,
    required visibility,
    required localOnly,
    replyId,
    fileIds = const [],
    pollChoices,
    pollMultiple = false,
    pollExpiresAt,
    reactionAcceptance,
    visibleUserIds = const [],
    scheduledAt,
  }) async {
    final client = ref.read(misskeyClientProvider);
    final acceptance = _createAcceptance(reactionAcceptance);
    final receivedAcceptance = _draftAcceptance(reactionAcceptance);
    // A scheduled post is parked in the server-side scheduled queue, which
    // only the drafts endpoints expose.
    if (scheduledAt != null) {
      await client.notes.draftsCreate(
        visibility: _draftVisibility(visibility),
        visibleUserIds: visibleUserIds.isEmpty ? null : visibleUserIds,
        cw: cw,
        localOnly: localOnly,
        reactionAcceptance: receivedAcceptance,
        replyId: replyId,
        text: text,
        fileIds: fileIds.isEmpty ? null : fileIds,
        poll: pollChoices == null
            ? null
            : NotesDraftsCreateRequestPoll(
                choices: pollChoices,
                multiple: pollMultiple ? true : null,
                expiresAt: pollExpiresAt?.millisecondsSinceEpoch,
              ),
        scheduledAt: scheduledAt.millisecondsSinceEpoch,
        isActuallyScheduled: true,
      );
      return;
    }
    await client.notes.create(
      text: text,
      cw: cw,
      visibility: visibility,
      localOnly: localOnly,
      replyId: replyId,
      visibleUserIds: visibleUserIds.isEmpty ? null : visibleUserIds,
      fileIds: fileIds.isEmpty ? null : fileIds,
      poll: pollChoices == null
          ? null
          : NotesCreateRequestPoll(
              choices: pollChoices,
              multiple: pollMultiple ? true : null,
              expiresAt: pollExpiresAt?.millisecondsSinceEpoch,
            ),
      reactionAcceptance: acceptance,
    );
  };
});

/// Explicit name → enum mapping shared with the draft store: no unknown name
/// is guessed into a value the user did not pick.
NotesCreateRequestReactionAcceptance? _createAcceptance(
  String? name,
) => switch (name) {
  null => null,
  'likeOnly' => NotesCreateRequestReactionAcceptance.likeOnly,
  'likeOnlyForRemote' => NotesCreateRequestReactionAcceptance.likeOnlyForRemote,
  'nonSensitiveOnly' => NotesCreateRequestReactionAcceptance.nonSensitiveOnly,
  'nonSensitiveOnlyForLocalLikeOnlyForRemote' =>
    NotesCreateRequestReactionAcceptance
        .nonSensitiveOnlyForLocalLikeOnlyForRemote,
  _ => null,
};

NotesDraftsCreateRequestReactionAcceptance? _draftAcceptance(String? name) =>
    switch (name) {
      null => null,
      'likeOnly' => NotesDraftsCreateRequestReactionAcceptance.likeOnly,
      'likeOnlyForRemote' =>
        NotesDraftsCreateRequestReactionAcceptance.likeOnlyForRemote,
      'nonSensitiveOnly' =>
        NotesDraftsCreateRequestReactionAcceptance.nonSensitiveOnly,
      'nonSensitiveOnlyForLocalLikeOnlyForRemote' =>
        NotesDraftsCreateRequestReactionAcceptance
            .nonSensitiveOnlyForLocalLikeOnlyForRemote,
      _ => null,
    };

NotesDraftsCreateRequestVisibility _draftVisibility(
  NotesCreateRequestVisibility visibility,
) => switch (visibility) {
  NotesCreateRequestVisibility.public =>
    NotesDraftsCreateRequestVisibility.public,
  NotesCreateRequestVisibility.home => NotesDraftsCreateRequestVisibility.home,
  NotesCreateRequestVisibility.followers =>
    NotesDraftsCreateRequestVisibility.followers,
  NotesCreateRequestVisibility.specified =>
    NotesDraftsCreateRequestVisibility.specified,
};

@freezed
abstract class ComposerState with _$ComposerState {
  const factory ComposerState({
    @Default('') String text,
    String? cw,

    /// The note being replied to. Starts as the composer's launch context and
    /// follows a draft loaded from the avatar panel, so every write below
    /// (persist, post, invalidate) stays in the loaded draft's context.
    String? replyId,
    @Default(NotesCreateRequestVisibility.public)
    NotesCreateRequestVisibility visibility,
    @Default(false) bool localOnly,
    @Default(false) bool restored,
    @Default(false) bool posting,

    /// Id of the stored draft backing this content: a server draft id or a
    /// `local:`-prefixed fallback row id; null until first persisted.
    String? draftId,
    @Default(<String>[]) List<String> fileIds,
    @Default(false) bool showPoll,
    @Default(<String>['', '']) List<String> pollChoices,
    @Default(false) bool pollMultiple,
    DateTime? pollExpiresAt,
    String? reactionAcceptance,
    @Default(<String>[]) List<String> visibleUserIds,
    DateTime? scheduledAt,
    @Default(false) bool showPreview,
    AppFailure? error,
  }) = _ComposerState;
}

@riverpod
class ComposerController extends _$ComposerController {
  Timer? _debounce;
  var _dirty = false;
  var _disposed = false;

  /// Captured in [build] so the dispose-persist can write without touching
  /// `ref` or reading `state` inside a riverpod lifecycle callback.
  late DraftStore? _store;
  late String? _accountId;

  /// The newest state this controller published, kept as a plain field so
  /// the dispose-persist has content to write after `state` is gone.
  ComposerState? _lastState;

  @override
  ComposerState build(String? replyId) {
    _disposed = false;
    _debounce?.cancel();
    _dirty = false;
    // Captured up front: riverpod forbids `ref.read` inside lifecycle
    // callbacks, and the dispose-persist needs both. An account switch
    // re-runs this build through the watch below, refreshing both.
    final account = ref.read(activeAccountProvider);
    _accountId = account?.id;
    _store = account == null ? null : ref.read(draftStoreProvider);
    ref.watch(activeAccountProvider)?.id;
    ref.onDispose(() {
      _disposed = true;
      _debounce?.cancel();
      final snapshot = _lastState;
      if (_dirty && snapshot != null) {
        // `state` is unreadable here; the snapshot carries the content.
        unawaited(_persist(snapshot: snapshot));
      }
    });
    final initial = ComposerState(replyId: replyId);
    _lastState = initial;
    unawaited(Future<void>.microtask(_restoreDraft));
    return initial;
  }

  int maxLength() =>
      ref.read(instanceInfoProvider).value?.maxNoteTextLength ?? 3000;

  bool canPost() {
    final limit = maxLength();
    final pollOk = !state.showPoll || validPollChoices().length >= 2;
    return !state.posting &&
        state.text.trim().isNotEmpty &&
        state.text.runes.length <= limit &&
        pollOk;
  }

  /// Non-empty poll choices, trimmed; empty when the poll is off.
  List<String> validPollChoices() => state.showPoll
      ? state.pollChoices
            .map((choice) => choice.trim())
            .where((choice) => choice.isNotEmpty)
            .toList()
      : const [];

  /// Restores the newest stored draft for this composer's context (same
  /// replyId); other drafts stay reachable through the avatar panel.
  Future<void> _restoreDraft() async {
    final store = _store;
    if (store == null) return;
    final drafts = await store.list();
    if (_disposed || drafts.isEmpty) return;
    final draft = drafts
        .where((candidate) => candidate.replyId == state.replyId)
        .firstOrNull;
    if (draft == null) return;
    _applyDraft(draft);
  }

  /// Loads [draft] from the avatar panel into this composer, replacing the
  /// current content and following the draft's own reply context.
  void loadDraft(ComposerDraft draft) {
    _debounce?.cancel();
    _dirty = false;
    _applyDraft(draft);
  }

  void _applyDraft(ComposerDraft draft) {
    final pollChoices = _decodeStringList(draft.pollChoices);
    final next = state.copyWith(
      text: draft.text,
      cw: draft.cw,
      replyId: draft.replyId,
      visibility: _parseVisibility(draft.visibility),
      localOnly: draft.localOnly,
      draftId: draft.id,
      restored: true,
      error: null,
      showPoll: pollChoices != null,
      pollChoices: pollChoices ?? const ['', ''],
      pollMultiple: draft.pollMultiple,
      pollExpiresAt: draft.pollExpiresAt,
      reactionAcceptance: draft.reactionAcceptance,
      visibleUserIds: _decodeStringList(draft.visibleUserIds) ?? const [],
      scheduledAt: draft.scheduledAt,
      fileIds: draft.fileIds,
    );
    _lastState = next;
    state = next;
  }

  void setText(String value) {
    state = state.copyWith(text: value, error: null);
    _scheduleSave();
  }

  void setCw(String? value) {
    state = state.copyWith(
      cw: value == null || value.trim().isEmpty ? null : value,
    );
    _scheduleSave();
  }

  void setVisibility(NotesCreateRequestVisibility value) {
    state = state.copyWith(visibility: value);
    _scheduleSave();
  }

  /// Adds an already-uploaded drive file to the post.
  void addFileId(String fileId) {
    if (state.fileIds.contains(fileId)) return;
    state = state.copyWith(fileIds: [...state.fileIds, fileId]);
  }

  /// Removes an attachment from the post.
  void removeFileId(String fileId) {
    state = state.copyWith(
      fileIds: state.fileIds.where((id) => id != fileId).toList(),
    );
  }

  void setLocalOnly(bool value) {
    state = state.copyWith(localOnly: value);
    _scheduleSave();
  }

  /// Toggles the poll editor. Turning it off clears the choices and drops any
  /// attachments, because Misskey rejects notes carrying both.
  void setShowPoll(bool value) {
    state = state.copyWith(
      showPoll: value,
      pollChoices: value && state.pollChoices.isEmpty
          ? const ['', '']
          : state.pollChoices,
      fileIds: value ? const <String>[] : state.fileIds,
    );
    _scheduleSave();
  }

  void setPollChoice(int index, String value) {
    if (index < 0 || index >= state.pollChoices.length) return;
    final choices = [...state.pollChoices];
    choices[index] = value;
    state = state.copyWith(pollChoices: choices);
    _scheduleSave();
  }

  void addPollChoice() {
    if (state.pollChoices.length >= 10) return;
    state = state.copyWith(pollChoices: [...state.pollChoices, '']);
    _scheduleSave();
  }

  void removePollChoice(int index) {
    if (state.pollChoices.length <= 2) return;
    final choices = [...state.pollChoices]..removeAt(index);
    state = state.copyWith(pollChoices: choices);
    _scheduleSave();
  }

  void setPollMultiple(bool value) {
    state = state.copyWith(pollMultiple: value);
    _scheduleSave();
  }

  void setPollExpiresAt(DateTime? value) {
    state = state.copyWith(pollExpiresAt: value);
    _scheduleSave();
  }

  void setReactionAcceptance(String? value) {
    state = state.copyWith(reactionAcceptance: value);
    _scheduleSave();
  }

  /// Adds a recipient for the `specified` (direct message) visibility.
  void addVisibleUser(String userId) {
    if (state.visibleUserIds.contains(userId)) return;
    state = state.copyWith(visibleUserIds: [...state.visibleUserIds, userId]);
    _scheduleSave();
  }

  void removeVisibleUser(String userId) {
    state = state.copyWith(
      visibleUserIds: state.visibleUserIds.where((id) => id != userId).toList(),
    );
    _scheduleSave();
  }

  void setScheduledAt(DateTime? value) {
    state = state.copyWith(scheduledAt: value);
    _scheduleSave();
  }

  void togglePreview() {
    state = state.copyWith(showPreview: !state.showPreview);
  }

  /// Saves the draft immediately, for the explicit "save draft" action.
  Future<void> saveDraftNow() async {
    _dirty = true;
    await _persist(force: true);
  }

  /// Clears every composer field and drops the stored draft.
  Future<void> reset() async {
    await deleteDraft();
    state = state.copyWith(
      showPoll: false,
      pollChoices: const ['', ''],
      pollMultiple: false,
      pollExpiresAt: null,
      reactionAcceptance: null,
      visibleUserIds: const <String>[],
      scheduledAt: null,
      showPreview: false,
      fileIds: const <String>[],
    );
  }

  static String _encodeStringList(List<String> values) => jsonEncode(values);

  static List<String>? _decodeStringList(String? raw) {
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded.whereType<String>().toList();
    } catch (_) {
      return null;
    }
  }

  void _scheduleSave() {
    _lastState = state;
    _dirty = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(_persist());
    });
  }

  /// Writes the current content to the draft store.
  ///
  /// [snapshot] is passed by the dispose path: riverpod forbids reading
  /// `state` inside a lifecycle callback, so the last known state is handed
  /// in from the last build instead. Returns the id of the stored draft.
  Future<String?> _persist({
    bool force = false,
    ComposerState? snapshot,
  }) async {
    final store = _store;
    final accountId = _accountId;
    final current = snapshot ?? (_disposed ? null : state);
    if (store == null || accountId == null || current == null) return null;
    if (!force && !_dirty) return current.draftId;
    _dirty = false;
    final draft = ComposerDraft(
      id: current.draftId,
      accountId: accountId,
      text: current.text,
      cw: current.cw,
      visibility: current.visibility.name,
      localOnly: current.localOnly,
      replyId: current.replyId,
      updatedAt: DateTime.now(),
      fileIds: current.fileIds,
      pollChoices: current.showPoll
          ? _encodeStringList(current.pollChoices)
          : null,
      pollMultiple: current.pollMultiple,
      pollExpiresAt: current.pollExpiresAt,
      reactionAcceptance: current.reactionAcceptance,
      visibleUserIds: current.visibleUserIds.isEmpty
          ? null
          : _encodeStringList(current.visibleUserIds),
      scheduledAt: current.scheduledAt,
    );
    final id = await store.save(draft);
    if (!_disposed) {
      _lastState = state.copyWith(draftId: id);
      state = _lastState!;
    }
    return id;
  }

  /// Drops the draft currently loaded in this composer and clears the content
  /// back to a blank post in the composer's reply context.
  Future<void> deleteDraft() async {
    await deleteStoredDraft(state.draftId);
    _debounce?.cancel();
    _dirty = false;
    if (_disposed) return;
    final next = state.copyWith(
      text: '',
      cw: null,
      localOnly: false,
      draftId: null,
      restored: false,
      error: null,
      showPoll: false,
      pollChoices: const ['', ''],
      pollMultiple: false,
      pollExpiresAt: null,
      reactionAcceptance: null,
      visibleUserIds: const <String>[],
      scheduledAt: null,
      fileIds: const <String>[],
    );
    _lastState = next;
    state = next;
  }

  /// Deletes a stored draft by id, whether or not it is the loaded one. Used
  /// by the avatar panel's rows.
  Future<void> deleteStoredDraft(String? id) async {
    if (id == null) return;
    await _store?.delete(id);
  }

  Future<bool> post() async {
    if (!canPost()) return false;
    final active = ref.read(activeAccountProvider);
    if (active == null) return false;
    await _persist(force: true);
    state = state.copyWith(posting: true, error: null);
    try {
      final replyId = state.replyId;
      final choices = validPollChoices();
      final scheduled = state.scheduledAt;
      await ref.read(composerSenderProvider)(
        text: state.text,
        cw: state.cw,
        visibility: state.visibility,
        localOnly: state.localOnly,
        replyId: replyId,
        fileIds: state.fileIds,
        pollChoices: choices.isEmpty ? null : choices,
        pollMultiple: state.pollMultiple,
        pollExpiresAt: state.pollExpiresAt,
        reactionAcceptance: state.reactionAcceptance,
        visibleUserIds: state.visibleUserIds,
        scheduledAt: scheduled,
      );
      _dirty = false;
      final draftId = state.draftId;
      if (draftId != null) {
        await _store?.delete(draftId);
      }
      ref.invalidate(noteListControllerProvider);
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
