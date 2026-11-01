// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/client_provider.dart';
import '../../../core/network/instance_repository.dart';
import '../../../core/network/silent_fallback.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/storage/storage_models.dart';
import '../../../core/storage/storage_providers.dart';

part 'draft_store.g.dart';

/// Hybrid draft persistence.
///
/// The server's `notes/drafts` queue is the primary store when the instance
/// probe passes; the local Drift table is the fallback for instances without
/// the endpoints or while offline. Attachments live only in server drafts:
/// uploading a file already requires connectivity, so a locally written
/// draft can never carry one. Server and local rows share one id namespace
/// in [ComposerDraft]; local rows prefix their UUID with [localPrefix].
class DraftStore {
  DraftStore({
    required this.client,
    required this.dao,
    required this.draftsSupported,
    required this.accountId,
  });

  final MisskeyClient client;
  final LocalDraftsDao dao;
  final bool draftsSupported;
  final String accountId;

  /// Local fallback rows are marked so deletes route to the right store.
  static const localPrefix = 'local:';

  /// The account's drafts, newest first: server drafts merged over the
  /// local fallback rows. Failures degrade to the local list.
  Future<List<ComposerDraft>> list() async {
    final local = await dao.list(accountId);
    if (!draftsSupported) return local;
    try {
      final server = await client.notes.draftsList(limit: 100);
      final drafts = [for (final draft in server) _fromServer(draft), ...local]
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return drafts;
    } catch (error) {
      if (error is MisskeyAuthenticationException) rethrow;
      logSilentFallback('draft_store.list', error);
      return local;
    }
  }

  /// Persists [draft] when it has substantive content and deletes the
  /// stored row otherwise. Returns the id backing the content, or null when
  /// nothing is stored.
  Future<String?> save(ComposerDraft draft) async {
    if (!hasSubstantiveContent(draft)) {
      final id = draft.id;
      if (id != null) await delete(id);
      return null;
    }
    if (draftsSupported) {
      try {
        return await _saveServer(draft);
      } catch (error) {
        if (error is MisskeyAuthenticationException) rethrow;
        // A transient failure must not lose the content: fall back to the
        // local table (the server copy, if any, stays as an older draft).
        logSilentFallback('draft_store.save.server', error);
      }
    }
    return _saveLocal(draft);
  }

  Future<void> delete(String id) async {
    if (id.startsWith(localPrefix)) {
      await dao.deleteById(id);
      return;
    }
    if (!draftsSupported) return;
    try {
      await client.notes.draftsDelete(draftId: id);
    } catch (error) {
      if (error is MisskeyAuthenticationException) rethrow;
      logSilentFallback('draft_store.delete', error);
    }
  }

  Future<String> _saveServer(ComposerDraft draft) async {
    final choices = _pollChoices(draft);
    final multiple = draft.pollMultiple ? true : null;
    final expiresAt = draft.pollExpiresAt?.millisecondsSinceEpoch;
    final scheduledAt = draft.scheduledAt?.millisecondsSinceEpoch;
    final isActuallyScheduled = draft.scheduledAt != null;
    final id = draft.id;
    if (id != null && !id.startsWith(localPrefix)) {
      final response = await client.notes.draftsUpdate(
        draftId: id,
        visibility: _updateVisibility(draft.visibility),
        visibleUserIds: _visibleUsers(draft),
        cw: draft.cw,
        localOnly: draft.localOnly,
        reactionAcceptance: _updateAcceptance(draft.reactionAcceptance),
        replyId: draft.replyId,
        text: draft.text.isEmpty ? null : draft.text,
        fileIds: draft.fileIds.isEmpty ? null : draft.fileIds,
        poll: choices == null
            ? null
            : NotesDraftsUpdateRequestPoll(
                choices: choices,
                multiple: multiple,
                expiresAt: expiresAt,
              ),
        scheduledAt: scheduledAt,
        isActuallyScheduled: isActuallyScheduled,
      );
      return response.updatedDraft.id;
    }
    final response = await client.notes.draftsCreate(
      visibility: _createVisibility(draft.visibility),
      visibleUserIds: _visibleUsers(draft),
      cw: draft.cw,
      localOnly: draft.localOnly,
      reactionAcceptance: _createAcceptance(draft.reactionAcceptance),
      replyId: draft.replyId,
      text: draft.text.isEmpty ? null : draft.text,
      fileIds: draft.fileIds.isEmpty ? null : draft.fileIds,
      poll: choices == null
          ? null
          : NotesDraftsCreateRequestPoll(
              choices: choices,
              multiple: multiple,
              expiresAt: expiresAt,
            ),
      scheduledAt: scheduledAt,
      isActuallyScheduled: isActuallyScheduled,
    );
    return response.createdDraft.id;
  }

  Future<String> _saveLocal(ComposerDraft draft) async {
    final existing = draft.id;
    final id = existing != null && existing.startsWith(localPrefix)
        ? existing
        : '$localPrefix${const Uuid().v4()}';
    // Local rows cannot carry attachments; see the class documentation.
    await dao.save(draft.copyWith(id: id, fileIds: const []));
    await dao.prune(accountId, keep: 50);
    return id;
  }

  /// A draft is only stored when it carries something worth keeping:
  /// non-empty text, at least one attachment, or a poll with two non-empty
  /// choices. Blank drafts do not exist.
  static bool hasSubstantiveContent(ComposerDraft draft) {
    if (draft.text.trim().isNotEmpty) return true;
    if (draft.fileIds.isNotEmpty) return true;
    final choices = _pollChoices(draft);
    return choices != null && choices.length >= 2;
  }

  static List<String>? _pollChoices(ComposerDraft draft) {
    final raw = draft.pollChoices;
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<String>()
          .map((choice) => choice.trim())
          .where((choice) => choice.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  static List<String>? _visibleUsers(ComposerDraft draft) {
    final raw = draft.visibleUserIds;
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      final users = decoded.whereType<String>().toList();
      return users.isEmpty ? null : users;
    } catch (_) {
      return null;
    }
  }

  static NotesDraftsCreateRequestVisibility _createVisibility(String name) =>
      NotesDraftsCreateRequestVisibility.values.byName(name);

  static NotesDraftsUpdateRequestVisibility _updateVisibility(String name) =>
      NotesDraftsUpdateRequestVisibility.values.byName(name);

  static NotesDraftsCreateRequestReactionAcceptance? _createAcceptance(
    String? name,
  ) {
    if (name == null) return null;
    for (final option in NotesDraftsCreateRequestReactionAcceptance.values) {
      if (option.name == name) return option;
    }
    return null;
  }

  static NotesDraftsUpdateRequestReactionAcceptance? _updateAcceptance(
    String? name,
  ) {
    if (name == null) return null;
    for (final option in NotesDraftsUpdateRequestReactionAcceptance.values) {
      if (option.name == name) return option;
    }
    return null;
  }

  ComposerDraft _fromServer(NoteDraft draft) {
    final poll = draft.poll;
    return ComposerDraft(
      id: draft.id,
      accountId: accountId,
      text: draft.text ?? '',
      cw: draft.cw,
      visibility: draft.visibility.name,
      localOnly: draft.localOnly,
      replyId: draft.replyId,
      updatedAt: draft.createdAt,
      fileIds: draft.fileIds,
      pollChoices: poll == null ? null : jsonEncode(poll.choices),
      pollMultiple: poll?.multiple ?? false,
      pollExpiresAt: poll?.expiresAt,
      reactionAcceptance: draft.reactionAcceptance?.name,
      visibleUserIds: draft.visibleUserIds.isEmpty
          ? null
          : jsonEncode(draft.visibleUserIds),
      scheduledAt: draft.scheduledAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(draft.scheduledAt!.toInt()),
    );
  }
}

@Riverpod(keepAlive: true)
DraftStore draftStore(Ref ref) {
  final active = ref.watch(activeAccountProvider);
  if (active == null) throw StateError('No active account.');
  return DraftStore(
    client: ref.watch(misskeyClientProvider),
    dao: ref.watch(localDraftsDaoProvider),
    draftsSupported:
        ref.watch(instanceInfoProvider).value?.draftsSupported ?? false,
    accountId: active.id,
  );
}
