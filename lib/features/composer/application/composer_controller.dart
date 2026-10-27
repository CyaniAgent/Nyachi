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
    final acceptance = _acceptanceFromName(reactionAcceptance);
    final receivedAcceptance = switch (reactionAcceptance) {
      null => null,
      'likeOnly' => NotesDraftsCreateRequestReactionAcceptance.likeOnly,
      'likeOnlyForRemote' =>
        NotesDraftsCreateRequestReactionAcceptance.likeOnlyForRemote,
      'nonSensitiveOnly' =>
        NotesDraftsCreateRequestReactionAcceptance.nonSensitiveOnly,
      _ =>
        NotesDraftsCreateRequestReactionAcceptance
            .nonSensitiveOnlyForLocalLikeOnlyForRemote,
    };
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

NotesCreateRequestReactionAcceptance? _acceptanceFromName(String? name) {
  if (name == null) return null;
  for (final option in NotesCreateRequestReactionAcceptance.values) {
    if (option.name == name) return option;
  }
  return null;
}

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
    @Default(NotesCreateRequestVisibility.public)
    NotesCreateRequestVisibility visibility,
    @Default(false) bool localOnly,
    @Default(false) bool restored,
    @Default(false) bool posting,
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

  Future<void> _restoreDraft() async {
    final active = ref.read(activeAccountProvider);
    if (active == null) return;
    final draft = await ref.read(draftDaoProvider).read(active.id);
    if (_disposed || draft == null) return;
    if (draft.replyId != _replyId) return;
    final visibility = _parseVisibility(draft.visibility);
    final pollChoices = _decodeStringList(draft.pollChoices);
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
      showPoll: pollChoices != null,
      pollChoices: pollChoices ?? const ['', ''],
      pollMultiple: draft.pollMultiple,
      pollExpiresAt: draft.pollExpiresAt,
      reactionAcceptance: draft.reactionAcceptance,
      visibleUserIds: _decodeStringList(draft.visibleUserIds) ?? const [],
      scheduledAt: draft.scheduledAt,
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
    _lastLocalOnly = value;
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
      pollChoices: state.showPoll ? _encodeStringList(state.pollChoices) : null,
      pollMultiple: state.pollMultiple,
      pollExpiresAt: state.pollExpiresAt,
      reactionAcceptance: state.reactionAcceptance,
      visibleUserIds: state.visibleUserIds.isEmpty
          ? null
          : _encodeStringList(state.visibleUserIds),
      scheduledAt: state.scheduledAt,
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
    if (!canPost()) return false;
    final active = ref.read(activeAccountProvider);
    if (active == null) return false;
    await _persist(force: true);
    state = state.copyWith(posting: true, error: null);
    try {
      final choices = validPollChoices();
      final scheduled = state.scheduledAt;
      await ref.read(composerSenderProvider)(
        text: state.text,
        cw: state.cw,
        visibility: state.visibility,
        localOnly: state.localOnly,
        replyId: _replyId,
        fileIds: state.fileIds,
        pollChoices: choices.isEmpty ? null : choices,
        pollMultiple: state.pollMultiple,
        pollExpiresAt: state.pollExpiresAt,
        reactionAcceptance: state.reactionAcceptance,
        visibleUserIds: state.visibleUserIds,
        scheduledAt: scheduled,
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
