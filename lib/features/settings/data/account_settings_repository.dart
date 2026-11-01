// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/client_provider.dart';

part 'account_settings_repository.g.dart';

/// Server-side account settings operations shared by the settings pages.
///
/// Thin by design: each method maps to one documented endpoint, so a settings
/// control can always be traced to the API field it writes. Reads go through
/// `i` (the session's own account); nothing here caches, because these screens
/// must show the server's current state when opened.
class AccountSettingsRepository {
  AccountSettingsRepository(this.client);

  final MisskeyClient client;

  /// Reads the signed-in account fresh from the server.
  Future<MeDetailed> me() => client.account.me();

  /// Updates profile and preference fields; only non-null values are written.
  Future<MeDetailed> update({
    String? name,
    String? description,
    String? location,
    String? birthday,
    List<AccountUpdateRequestFieldsItem>? fields,
    bool? isBot,
    bool? isCat,
    bool? isLocked,
    bool? isExplorable,
    bool? hideOnlineStatus,
    bool? publicReactions,
    bool? noCrawle,
    bool? preventAiLearning,
    bool? autoSensitive,
    bool? alwaysMarkNsfw,
    bool? carefulBot,
    bool? autoAcceptFollowed,
    bool? injectFeaturedNote,
    bool? receiveAnnouncementEmail,
    bool? requireSigninToViewContents,
    String? avatarId,
    String? bannerId,
    AccountUpdateRequestNotificationRecieveConfig? notificationRecieveConfig,
  }) {
    return client.account.update(
      name: name,
      description: description,
      location: location,
      birthday: birthday,
      fields: fields,
      isBot: isBot,
      isCat: isCat,
      isLocked: isLocked,
      isExplorable: isExplorable,
      hideOnlineStatus: hideOnlineStatus,
      publicReactions: publicReactions,
      noCrawle: noCrawle,
      preventAiLearning: preventAiLearning,
      autoSensitive: autoSensitive,
      alwaysMarkNsfw: alwaysMarkNsfw,
      carefulBot: carefulBot,
      autoAcceptFollowed: autoAcceptFollowed,
      injectFeaturedNote: injectFeaturedNote,
      receiveAnnouncementEmail: receiveAnnouncementEmail,
      requireSigninToViewContents: requireSigninToViewContents,
      avatarId: avatarId,
      bannerId: bannerId,
      notificationRecieveConfig: notificationRecieveConfig,
    );
  }

  /// Uploads an avatar or banner and returns the new drive file id.
  Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final file = await client.drive.filesCreate(
      file: bytes,
      fileName: fileName,
    );
    return file.id;
  }

  Future<void> updateEmail({required String email, required String password}) {
    return client.account.updateEmail(email: email, password: password);
  }

  Future<bool> emailAvailable(String email) async {
    final response = await client.users.emailAddressAvailable(
      emailAddress: email,
    );
    return response.available;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return client.account.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<List<Signin>> signinHistory({int limit = 20}) {
    return client.account.signinHistory(limit: limit);
  }
}

@Riverpod(keepAlive: true)
AccountSettingsRepository accountSettingsRepository(Ref ref) =>
    AccountSettingsRepository(ref.watch(misskeyClientProvider));
