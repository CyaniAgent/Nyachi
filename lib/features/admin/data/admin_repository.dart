// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/client_provider.dart';

part 'admin_repository.g.dart';

/// Server administration, mapped one method per endpoint.
///
/// Reached through `client.raw.admin`: the SDK keeps generated admin endpoints
/// on the raw surface rather than a typed `client.admin` facade, because they
/// are a moving target across server versions.
///
/// Nothing here caches or pre-checks. Every call reads the server's current
/// state or writes exactly the field a control names. The server decides
/// whether the session may do it — a non-moderator gets a 403, which
/// `mapFailure` reports as `forbidden` rather than as an expired session.
class AdminRepository {
  AdminRepository(this.client);

  final MisskeyClient client;

  // `RawAdminApi` is not exported by the package (only `MisskeyRawClient` is),
  // so the facade is held as an inferred `late final` field: the type stays
  // fully checked, it just cannot be written out here.
  late final _admin = client.raw.admin;

  // --- Reports -------------------------------------------------------------

  /// Reports newest first. [state] is `unresolved` for the queue the moderation
  /// team works through, `resolved` for history, or null for both.
  Future<List<AdminAbuseUserReportsResponseItem>> reports({
    int limit = 20,
    String? sinceId,
    String? untilId,
    String? state,
  }) {
    return _admin.abuseUserReports(
      AdminAbuseUserReportsRequest(
        limit: limit,
        sinceId: sinceId,
        untilId: untilId,
        state: state,
      ),
    );
  }

  /// Closes a report. Accepting means "this broke the rules", rejecting
  /// dismisses it. Neither punishes the reported user; that is a separate
  /// moderation action taken on the account.
  Future<void> resolveReport({
    required String reportId,
    required AdminResolveAbuseUserReportRequestResolvedAs resolvedAs,
  }) {
    return _admin.resolveAbuseUserReport(
      AdminResolveAbuseUserReportRequest(
        reportId: reportId,
        resolvedAs: resolvedAs,
      ),
    );
  }

  /// Leaves a note on the report, separate from the account's moderation note.
  Future<void> setReportNote(String reportId, String? note) {
    return _admin.updateAbuseUserReport(
      AdminUpdateAbuseUserReportRequest(
        reportId: reportId,
        moderationNote: note,
      ),
    );
  }

  /// Sends the report on to the instance hosting the reported user.
  Future<void> forwardReport(String reportId) {
    return _admin.forwardAbuseUserReport(
      AdminForwardAbuseUserReportRequest(reportId: reportId),
    );
  }

  // --- Users ---------------------------------------------------------------

  Future<List<UserDetailed>> users({
    int limit = 20,
    int offset = 0,
    String? query,
    AdminShowUsersRequestState state = AdminShowUsersRequestState.all,
    AdminShowUsersRequestSort? sort,
  }) {
    // `username` is a prefix match and the host is a separate field, so
    // `@alice@remote.example` is split rather than passed through whole.
    final parsed = _parseUserQuery(query);
    return _admin.showUsers(
      AdminShowUsersRequest(
        limit: limit,
        offset: offset,
        username: parsed.username,
        hostname: parsed.hostname,
        state: state,
        sort: sort,
      ),
    );
  }

  Future<AdminShowUserResponse> user(String userId) {
    return _admin.showUser(AdminShowUserRequest(userId: userId));
  }

  Future<void> suspendUser(String userId) {
    return _admin.suspendUser(AdminSuspendUserRequest(userId: userId));
  }

  Future<void> unsuspendUser(String userId) {
    return _admin.unsuspendUser(AdminUnsuspendUserRequest(userId: userId));
  }

  /// The moderation note is the running record attached to an account: what
  /// another moderator reads before acting on the same user.
  Future<void> setUserNote(String userId, String note) {
    return _admin.updateUserNote(
      AdminUpdateUserNoteRequest(userId: userId, text: note),
    );
  }

  /// Returns the new password the server generated.
  Future<AdminResetPasswordResponse> resetPassword(String userId) {
    return _admin.resetPassword(AdminResetPasswordRequest(userId: userId));
  }

  Future<void> unsetMfa(String userId) {
    return _admin.unsetMfa(AdminUnsetMfaRequest(userId: userId));
  }

  Future<void> unsetAvatar(String userId) {
    return _admin.unsetUserAvatar(AdminUnsetUserAvatarRequest(userId: userId));
  }

  Future<void> unsetBanner(String userId) {
    return _admin.unsetUserBanner(AdminUnsetUserBannerRequest(userId: userId));
  }

  Future<List<AdminShowModerationLogsResponseItem>> moderationLogs({
    int limit = 20,
    String? sinceId,
    String? untilId,
    String? userId,
  }) {
    return _admin.showModerationLogs(
      AdminShowModerationLogsRequest(
        limit: limit,
        sinceId: sinceId,
        untilId: untilId,
        userId: userId,
      ),
    );
  }

  // --- Content -------------------------------------------------------------

  /// Every file on the instance, newest first, for drive-side takedowns.
  Future<List<DriveFile>> files({
    int limit = 20,
    String? sinceId,
    String? untilId,
    String? userId,
  }) {
    return _admin.driveFiles(
      AdminDriveFilesRequest(
        limit: limit,
        sinceId: sinceId,
        untilId: untilId,
        userId: userId,
      ),
    );
  }

  Future<AdminDriveShowFileResponse> file(String fileId) {
    // The endpoint accepts either a file id or a URL; this admin surface only
    // ever has the id.
    return _admin.driveShowFile(
      AdminDriveShowFileRequestByFileId(fileId: fileId),
    );
  }

  /// Files belong to the user's drive, so removal goes through the ordinary
  /// drive endpoint rather than an admin-only one.
  Future<void> deleteFile(String fileId) {
    return client.raw.drive.filesDelete(
      DriveFilesDeleteRequest(fileId: fileId),
    );
  }

  // --- Instance settings ---------------------------------------------------

  Future<AdminMetaResponse> meta() => _admin.meta();

  /// Only non-null fields are written, so a form can send just what it edited.
  Future<void> updateMeta({
    String? name,
    String? description,
    String? maintainerName,
    String? maintainerEmail,
    bool? disableRegistration,
    bool? emailRequiredForSignup,
  }) {
    return _admin.updateMeta(
      AdminUpdateMetaRequest(
        name: name,
        description: description,
        maintainerName: maintainerName,
        maintainerEmail: maintainerEmail,
        disableRegistration: disableRegistration,
        emailRequiredForSignup: emailRequiredForSignup,
      ),
    );
  }

  // --- Announcements -------------------------------------------------------

  Future<List<AdminAnnouncementsListResponseItem>> announcements({
    int limit = 20,
    AdminAnnouncementsListRequestStatus status =
        AdminAnnouncementsListRequestStatus.active,
  }) {
    return _admin.announcementsList(
      AdminAnnouncementsListRequest(limit: limit, status: status),
    );
  }

  Future<AdminAnnouncementsCreateResponse> createAnnouncement({
    required String title,
    required String text,
    String? imageUrl,
  }) {
    return _admin.announcementsCreate(
      AdminAnnouncementsCreateRequest(
        title: title,
        text: text,
        imageUrl: imageUrl,
      ),
    );
  }

  Future<void> deleteAnnouncement(String id) {
    return _admin.announcementsDelete(AdminAnnouncementsDeleteRequest(id: id));
  }

  Future<void> updateAnnouncement({
    required String id,
    String? title,
    String? text,
    bool? isActive,
  }) {
    return _admin.announcementsUpdate(
      AdminAnnouncementsUpdateRequest(
        id: id,
        title: title,
        text: text,
        isActive: isActive,
      ),
    );
  }

  // --- Emoji ---------------------------------------------------------------

  Future<List<EmojiDetailed>> emoji({int limit = 30, String? query}) {
    return _admin.emojiList(AdminEmojiListRequest(limit: limit, query: query));
  }

  /// Registers a custom emoji. The image must already exist in the drive: the
  /// endpoint references it by [fileId], so a caller uploads first.
  Future<EmojiDetailed> addEmoji(
    String name, {
    required String fileId,
    String? category,
    List<String>? aliases,
  }) {
    return _admin.emojiAdd(
      AdminEmojiAddRequest(
        name: name,
        fileId: fileId,
        category: category,
        aliases: aliases,
      ),
    );
  }

  /// Emoji are identified by id, not by name, on this endpoint.
  Future<void> deleteEmoji(String id) {
    return _admin.emojiDelete(AdminEmojiDeleteRequest(id: id));
  }

  // --- Roles ---------------------------------------------------------------

  Future<List<Role>> roles() => _admin.rolesList();

  Future<void> assignRole({
    required String roleId,
    required String userId,
    int? expiresAt,
  }) {
    return _admin.rolesAssign(
      AdminRolesAssignRequest(
        roleId: roleId,
        userId: userId,
        expiresAt: expiresAt,
      ),
    );
  }

  Future<void> unassignRole({required String roleId, required String userId}) {
    return _admin.rolesUnassign(
      AdminRolesUnassignRequest(roleId: roleId, userId: userId),
    );
  }

  // --- Invites -------------------------------------------------------------

  Future<List<InviteCode>> invites({int limit = 20}) {
    return _admin.inviteList(AdminInviteListRequest(limit: limit));
  }

  /// Creates [count] invite codes and returns them.
  Future<List<InviteCode>> createInvite({int count = 1}) {
    return _admin.inviteCreate(AdminInviteCreateRequest(count: count));
  }

  // --- System --------------------------------------------------------------

  Future<AdminServerInfoResponse> serverInfo() => _admin.serverInfo();

  /// The queues the server is running, with their counts and whether each is
  /// paused — the first thing to check when delivery stalls.
  Future<List<AdminQueueQueuesResponseItem>> queues() => _admin.queueQueues();

  Future<AdminQueueQueueStatsResponse> queueStats(
    AdminQueueQueueStatsRequestQueue queue,
  ) {
    return _admin.queueQueueStats(AdminQueueQueueStatsRequest(queue: queue));
  }

  /// A page of jobs in [queue], filtered by [state]. The endpoint takes the
  /// state as a list, so callers pass the one they want to look at.
  Future<List<QueueJob>> jobs({
    required AdminQueueJobsRequestQueue queue,
    List<AdminQueueJobsRequestStateItem> state = const [
      AdminQueueJobsRequestStateItem.failed,
    ],
    String? search,
  }) {
    return _admin.queueJobs(
      AdminQueueJobsRequest(queue: queue, state: state, search: search),
    );
  }

  /// The server returns a free-form map here rather than a typed model, so the
  /// caller renders rows instead of fields.
  Future<JsonMap> tableStats() => _admin.getTableStats();

  Future<List<AdminGetIndexStatsResponseItem>> indexStats() {
    return _admin.getIndexStats();
  }

  Future<List<AdminRelaysListResponseItem>> relays() => _admin.relaysList();

  Future<void> addRelay(String inbox) {
    return _admin.relaysAdd(AdminRelaysAddRequest(inbox: inbox));
  }

  Future<void> removeRelay(String inbox) {
    return _admin.relaysRemove(AdminRelaysRemoveRequest(inbox: inbox));
  }

  /// A username query may carry a host; the endpoint takes them separately.
  static ({String? username, String? hostname}) _parseUserQuery(String? query) {
    final trimmed = query?.trim().replaceFirst(RegExp(r'^@'), '');
    if (trimmed == null || trimmed.isEmpty) {
      return (username: null, hostname: null);
    }
    final at = trimmed.indexOf('@');
    if (at <= 0) return (username: trimmed, hostname: null);
    return (
      username: trimmed.substring(0, at),
      hostname: trimmed.substring(at + 1),
    );
  }
}

@Riverpod(keepAlive: true)
AdminRepository adminRepository(Ref ref) =>
    AdminRepository(ref.watch(misskeyClientProvider));

/// Whether the signed-in account may use the admin surface at all.
///
/// Read from the server, not stored with the account: moderator rights can be
/// granted or revoked while the session stays signed in, and a stale local flag
/// would either hide the entry point from a new moderator or offer it to a
/// demoted one. A failure means "no", because the only cost of being wrong that
/// way is a missing entry point.
@Riverpod(keepAlive: true)
Future<bool> canModerate(Ref ref) async {
  try {
    final me = await ref.watch(misskeyClientProvider).account.me();
    return me.isAdmin || me.isModerator;
  } catch (_) {
    return false;
  }
}
