// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/announcements/presentation/announcements_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/chat/domain/chat_models.dart';
import '../../features/chat/presentation/chat_pages.dart';
import '../../features/composer/presentation/compose_page.dart';
import '../../features/explore/presentation/explore_page.dart';
import '../../features/notifications/presentation/notifications_page.dart';
import '../../features/notes/presentation/note_detail_page.dart';
import '../../features/oobe/presentation/oobe_page.dart';
import '../../features/profile/presentation/profile_pages.dart';
import '../../features/drive/presentation/drive_page.dart';
import '../../features/settings/presentation/licenses_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/tags/presentation/tag_timeline_page.dart';
import '../../features/timeline/presentation/home_page.dart';
import 'navigator_keys.dart';

part 'routes.g.dart';

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LoginPage();
  }
}

@TypedGoRoute<AddAccountRoute>(path: '/add-account')
class AddAccountRoute extends GoRouteData with $AddAccountRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  const AddAccountRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LoginPage(addAccount: true);
  }
}

@TypedGoRoute<OobeRoute>(path: '/oobe')
class OobeRoute extends GoRouteData with $OobeRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  const OobeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const OobePage();
  }
}

@TypedGoRoute<NoteDetailRoute>(path: '/notes/:noteId')
class NoteDetailRoute extends GoRouteData with $NoteDetailRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const NoteDetailRoute(this.noteId);

  final String noteId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return NoteDetailPage(noteId: noteId);
  }
}

@TypedGoRoute<UserProfileRoute>(path: '/users/:userId')
class UserProfileRoute extends GoRouteData with $UserProfileRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const UserProfileRoute(this.userId);

  final String userId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return UserProfilePage(userId: userId);
  }
}

@TypedGoRoute<TagTimelineRoute>(path: '/tags/:tag')
class TagTimelineRoute extends GoRouteData with $TagTimelineRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const TagTimelineRoute(this.tag);

  final String tag;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return TagTimelinePage(tag: tag);
  }
}

@TypedGoRoute<ComposeRoute>(path: '/compose')
class ComposeRoute extends GoRouteData with $ComposeRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const ComposeRoute({this.replyId});

  final String? replyId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ComposePage(replyId: replyId);
  }
}

@TypedGoRoute<ChatUserRoute>(path: '/chat/user/:userId')
class ChatUserRoute extends GoRouteData with $ChatUserRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const ChatUserRoute(this.userId);

  final String userId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChatThreadPage(target: ChatTarget.user(userId));
  }
}

@TypedGoRoute<ChatRoomRoute>(path: '/chat/room/:roomId')
class ChatRoomRoute extends GoRouteData with $ChatRoomRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const ChatRoomRoute(this.roomId);

  final String roomId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChatThreadPage(target: ChatTarget.room(roomId));
  }
}

@TypedGoRoute<DriveRoute>(path: '/drive')
class DriveRoute extends GoRouteData with $DriveRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const DriveRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const DrivePage();
}

@TypedGoRoute<AnnouncementsRoute>(path: '/announcements')
class AnnouncementsRoute extends GoRouteData with $AnnouncementsRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const AnnouncementsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AnnouncementsPage();
  }
}

@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with $SettingsRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsPage();
  }
}

@TypedGoRoute<SettingsAccountsRoute>(path: '/settings/accounts')
class SettingsAccountsRoute extends GoRouteData with $SettingsAccountsRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const SettingsAccountsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AccountsSettingsPage();
  }
}

@TypedGoRoute<SettingsNavigationRoute>(path: '/settings/navigation')
class SettingsNavigationRoute extends GoRouteData
    with $SettingsNavigationRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const SettingsNavigationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const NavigationSettingsPage();
  }
}

@TypedGoRoute<SettingsAppearanceRoute>(path: '/settings/appearance')
class SettingsAppearanceRoute extends GoRouteData
    with $SettingsAppearanceRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const SettingsAppearanceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AppearanceSettingsPage();
  }
}

@TypedGoRoute<SettingsLicensesRoute>(path: '/settings/licenses')
class SettingsLicensesRoute extends GoRouteData with $SettingsLicensesRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const SettingsLicensesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LicensesPage();
  }
}

@TypedGoRoute<SettingsAboutRoute>(path: '/settings/about')
class SettingsAboutRoute extends GoRouteData with $SettingsAboutRoute {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(key: state.pageKey, child: build(context, state));

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      appShellNavigatorKey;

  const SettingsAboutRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AboutSettingsPage();
  }
}

@TypedStatefulShellRoute<AppShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<HomeBranchData>(
      routes: <TypedRoute<RouteData>>[TypedGoRoute<HomeRoute>(path: '/home')],
    ),
    TypedStatefulShellBranch<NotificationsBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<NotificationsRoute>(path: '/notifications'),
      ],
    ),
    TypedStatefulShellBranch<ExploreBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ExploreRoute>(path: '/explore'),
      ],
    ),
    TypedStatefulShellBranch<ChatBranchData>(
      routes: <TypedRoute<RouteData>>[TypedGoRoute<ChatRoute>(path: '/chat')],
    ),
    TypedStatefulShellBranch<ProfileBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ProfileRoute>(path: '/profile'),
      ],
    ),
  ],
)
class AppShellRouteData extends StatefulShellRouteData {
  const AppShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return AppShell(navigationShell: navigationShell);
  }
}

class HomeBranchData extends StatefulShellBranchData {
  const HomeBranchData();
}

class NotificationsBranchData extends StatefulShellBranchData {
  const NotificationsBranchData();
}

class ExploreBranchData extends StatefulShellBranchData {
  const ExploreBranchData();
}

class ChatBranchData extends StatefulShellBranchData {
  const ChatBranchData();
}

class ProfileBranchData extends StatefulShellBranchData {
  const ProfileBranchData();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}

class NotificationsRoute extends GoRouteData with $NotificationsRoute {
  const NotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const NotificationsPage();
  }
}

class ExploreRoute extends GoRouteData with $ExploreRoute {
  const ExploreRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ExplorePage();
  }
}

class ChatRoute extends GoRouteData with $ChatRoute {
  const ChatRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ChatPage();
  }
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfilePage();
  }
}
