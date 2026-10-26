// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/chat/domain/chat_models.dart';
import '../../features/chat/presentation/chat_pages.dart';
import '../../features/composer/presentation/compose_page.dart';
import '../../features/notes/presentation/note_detail_page.dart';
import '../../features/profile/presentation/profile_pages.dart';
import '../../features/drive/presentation/drive_page.dart';
import '../../features/settings/presentation/licenses_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/tags/presentation/tag_timeline_page.dart';

/// A page that can live inside the wide-screen detail panel.
sealed class DetailLocation {
  const DetailLocation();

  String get location;

  Widget build(BuildContext context);

  static DetailLocation? parse(String value) {
    if (!value.startsWith('/') || value.startsWith('//')) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || uri.hasScheme || uri.hasAuthority || uri.hasFragment) {
      return null;
    }
    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;
    return switch (segments.first) {
      'notes' when segments.length == 2 => NoteDetailLocation(segments[1]),
      'users' when segments.length == 2 => UserDetailLocation(segments[1]),
      'tags' when segments.length == 2 => TagDetailLocation(segments[1]),
      'compose' when segments.length == 1 => ComposeDetailLocation(
        _nullIfEmpty(uri.queryParameters['replyId']),
      ),
      'chat' when segments.length == 3 && segments[1] == 'user' =>
        ChatUserDetailLocation(segments[2]),
      'chat' when segments.length == 3 && segments[1] == 'room' =>
        ChatRoomDetailLocation(segments[2]),
      'settings' when segments.length == 1 => const SettingsDetailLocation(),
      'settings' when segments.length == 2 && segments[1] == 'drive' =>
        const DriveDetailLocation(),
      'settings' when segments.length == 2 && segments[1] == 'licenses' =>
        const SettingsLicensesLocation(),
      'settings' when segments.length == 2 && segments[1] == 'accounts' =>
        const SettingsAccountsLocation(),
      'settings' when segments.length == 2 && segments[1] == 'navigation' =>
        const SettingsNavigationLocation(),
      'settings' when segments.length == 2 && segments[1] == 'appearance' =>
        const SettingsAppearanceLocation(),
      'settings' when segments.length == 2 && segments[1] == 'about' =>
        const SettingsAboutLocation(),
      'add-account' when segments.length == 1 => const AddAccountLocation(),
      _ => null,
    };
  }

  static String? _nullIfEmpty(String? value) =>
      value == null || value.isEmpty ? null : value;

  @override
  bool operator ==(Object other) =>
      other is DetailLocation && other.location == location;

  @override
  int get hashCode => location.hashCode;
}

class NoteDetailLocation extends DetailLocation {
  const NoteDetailLocation(this.noteId);

  final String noteId;

  @override
  String get location => '/notes/${Uri.encodeComponent(noteId)}';

  @override
  Widget build(BuildContext context) => NoteDetailPage(noteId: noteId);
}

class UserDetailLocation extends DetailLocation {
  const UserDetailLocation(this.userId);

  final String userId;

  @override
  String get location => '/users/${Uri.encodeComponent(userId)}';

  @override
  Widget build(BuildContext context) => UserProfilePage(userId: userId);
}

class TagDetailLocation extends DetailLocation {
  const TagDetailLocation(this.tag);

  final String tag;

  @override
  String get location => '/tags/${Uri.encodeComponent(tag)}';

  @override
  Widget build(BuildContext context) => TagTimelinePage(tag: tag);
}

class ComposeDetailLocation extends DetailLocation {
  const ComposeDetailLocation(this.replyId);

  final String? replyId;

  @override
  String get location {
    final base = Uri(path: '/compose');
    if (replyId == null) return base.toString();
    return base.replace(queryParameters: {'replyId': replyId}).toString();
  }

  @override
  Widget build(BuildContext context) => ComposePage(replyId: replyId);
}

class ChatUserDetailLocation extends DetailLocation {
  const ChatUserDetailLocation(this.userId);

  final String userId;

  @override
  String get location => '/chat/user/${Uri.encodeComponent(userId)}';

  @override
  Widget build(BuildContext context) =>
      ChatThreadPage(target: ChatTarget.user(userId));
}

class ChatRoomDetailLocation extends DetailLocation {
  const ChatRoomDetailLocation(this.roomId);

  final String roomId;

  @override
  String get location => '/chat/room/${Uri.encodeComponent(roomId)}';

  @override
  Widget build(BuildContext context) =>
      ChatThreadPage(target: ChatTarget.room(roomId));
}

class SettingsDetailLocation extends DetailLocation {
  const SettingsDetailLocation();

  @override
  String get location => '/settings';

  @override
  Widget build(BuildContext context) => const SettingsPage();
}

class SettingsAccountsLocation extends DetailLocation {
  const SettingsAccountsLocation();

  @override
  String get location => '/settings/accounts';

  @override
  Widget build(BuildContext context) => const AccountsSettingsPage();
}

class SettingsNavigationLocation extends DetailLocation {
  const SettingsNavigationLocation();

  @override
  String get location => '/settings/navigation';

  @override
  Widget build(BuildContext context) => const NavigationSettingsPage();
}

class SettingsAppearanceLocation extends DetailLocation {
  const SettingsAppearanceLocation();

  @override
  String get location => '/settings/appearance';

  @override
  Widget build(BuildContext context) => const AppearanceSettingsPage();
}

class SettingsAboutLocation extends DetailLocation {
  const SettingsAboutLocation();

  @override
  String get location => '/settings/about';

  @override
  Widget build(BuildContext context) => const AboutSettingsPage();
}

class DriveDetailLocation extends DetailLocation {
  const DriveDetailLocation();

  @override
  String get location => '/settings/drive';

  @override
  Widget build(BuildContext context) => const DrivePage();
}

class SettingsLicensesLocation extends DetailLocation {
  const SettingsLicensesLocation();

  @override
  String get location => '/settings/licenses';

  @override
  Widget build(BuildContext context) => const LicensesPage();
}

class AddAccountLocation extends DetailLocation {
  const AddAccountLocation();

  @override
  String get location => '/add-account';

  @override
  Widget build(BuildContext context) => const LoginPage(addAccount: true);
}

String detailPathFor(DetailLocation location) => location.location;
