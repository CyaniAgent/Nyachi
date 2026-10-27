// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';

part 'storage_models.freezed.dart';

@freezed
abstract class LocalAccount with _$LocalAccount {
  const factory LocalAccount({
    required String id,
    required String host,
    required String userId,
    required String username,
    String? displayName,
    String? avatarUrl,
    required DateTime addedAt,
    required DateTime lastUsedAt,
  }) = _LocalAccount;
}

@freezed
abstract class ComposerDraft with _$ComposerDraft {
  const factory ComposerDraft({
    required String accountId,
    required String text,
    String? cw,
    required String visibility,
    @Default(false) bool localOnly,
    String? replyId,
    required DateTime updatedAt,

    /// JSON list of poll choices; null when the draft has no poll.
    String? pollChoices,
    @Default(false) bool pollMultiple,
    DateTime? pollExpiresAt,
    String? reactionAcceptance,

    /// JSON list of user ids for the `specified` visibility.
    String? visibleUserIds,
    DateTime? scheduledAt,
  }) = _ComposerDraft;
}

@freezed
abstract class CachedPayload with _$CachedPayload {
  const factory CachedPayload({
    required String payload,
    required DateTime updatedAt,
  }) = _CachedPayload;
}
