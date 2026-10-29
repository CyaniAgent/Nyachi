// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $loginRoute,
  $addAccountRoute,
  $oobeRoute,
  $noteDetailRoute,
  $userProfileRoute,
  $tagTimelineRoute,
  $composeRoute,
  $chatUserRoute,
  $chatRoomRoute,
  $driveRoute,
  $announcementsRoute,
  $settingsRoute,
  $settingsAccountsRoute,
  $settingsNavigationRoute,
  $settingsAppearanceRoute,
  $settingsLicensesRoute,
  $settingsAboutRoute,
  $appShellRouteData,
];

RouteBase get $loginRoute => GoRouteData.$route(
  path: '/login',
  hasOverriddenOnExit: false,
  factory: $LoginRoute._fromState,
);

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  @override
  String get location => GoRouteData.$location('/login');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $addAccountRoute => GoRouteData.$route(
  path: '/add-account',
  hasOverriddenOnExit: false,
  factory: $AddAccountRoute._fromState,
);

mixin $AddAccountRoute on GoRouteData {
  static AddAccountRoute _fromState(GoRouterState state) =>
      const AddAccountRoute();

  @override
  String get location => GoRouteData.$location('/add-account');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $oobeRoute => GoRouteData.$route(
  path: '/oobe',
  hasOverriddenOnExit: false,
  factory: $OobeRoute._fromState,
);

mixin $OobeRoute on GoRouteData {
  static OobeRoute _fromState(GoRouterState state) => const OobeRoute();

  @override
  String get location => GoRouteData.$location('/oobe');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $noteDetailRoute => GoRouteData.$route(
  path: '/notes/:noteId',
  hasOverriddenOnExit: false,
  parentNavigatorKey: NoteDetailRoute.$parentNavigatorKey,
  factory: $NoteDetailRoute._fromState,
);

mixin $NoteDetailRoute on GoRouteData {
  static NoteDetailRoute _fromState(GoRouterState state) =>
      NoteDetailRoute(state.pathParameters['noteId']!);

  NoteDetailRoute get _self => this as NoteDetailRoute;

  @override
  String get location =>
      GoRouteData.$location('/notes/${Uri.encodeComponent(_self.noteId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $userProfileRoute => GoRouteData.$route(
  path: '/users/:userId',
  hasOverriddenOnExit: false,
  parentNavigatorKey: UserProfileRoute.$parentNavigatorKey,
  factory: $UserProfileRoute._fromState,
);

mixin $UserProfileRoute on GoRouteData {
  static UserProfileRoute _fromState(GoRouterState state) =>
      UserProfileRoute(state.pathParameters['userId']!);

  UserProfileRoute get _self => this as UserProfileRoute;

  @override
  String get location =>
      GoRouteData.$location('/users/${Uri.encodeComponent(_self.userId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $tagTimelineRoute => GoRouteData.$route(
  path: '/tags/:tag',
  hasOverriddenOnExit: false,
  parentNavigatorKey: TagTimelineRoute.$parentNavigatorKey,
  factory: $TagTimelineRoute._fromState,
);

mixin $TagTimelineRoute on GoRouteData {
  static TagTimelineRoute _fromState(GoRouterState state) =>
      TagTimelineRoute(state.pathParameters['tag']!);

  TagTimelineRoute get _self => this as TagTimelineRoute;

  @override
  String get location =>
      GoRouteData.$location('/tags/${Uri.encodeComponent(_self.tag)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $composeRoute => GoRouteData.$route(
  path: '/compose',
  hasOverriddenOnExit: false,
  parentNavigatorKey: ComposeRoute.$parentNavigatorKey,
  factory: $ComposeRoute._fromState,
);

mixin $ComposeRoute on GoRouteData {
  static ComposeRoute _fromState(GoRouterState state) =>
      ComposeRoute(replyId: state.uri.queryParameters['reply-id']);

  ComposeRoute get _self => this as ComposeRoute;

  @override
  String get location => GoRouteData.$location(
    '/compose',
    queryParams: {if (_self.replyId != null) 'reply-id': _self.replyId},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $chatUserRoute => GoRouteData.$route(
  path: '/chat/user/:userId',
  hasOverriddenOnExit: false,
  parentNavigatorKey: ChatUserRoute.$parentNavigatorKey,
  factory: $ChatUserRoute._fromState,
);

mixin $ChatUserRoute on GoRouteData {
  static ChatUserRoute _fromState(GoRouterState state) =>
      ChatUserRoute(state.pathParameters['userId']!);

  ChatUserRoute get _self => this as ChatUserRoute;

  @override
  String get location =>
      GoRouteData.$location('/chat/user/${Uri.encodeComponent(_self.userId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $chatRoomRoute => GoRouteData.$route(
  path: '/chat/room/:roomId',
  hasOverriddenOnExit: false,
  parentNavigatorKey: ChatRoomRoute.$parentNavigatorKey,
  factory: $ChatRoomRoute._fromState,
);

mixin $ChatRoomRoute on GoRouteData {
  static ChatRoomRoute _fromState(GoRouterState state) =>
      ChatRoomRoute(state.pathParameters['roomId']!);

  ChatRoomRoute get _self => this as ChatRoomRoute;

  @override
  String get location =>
      GoRouteData.$location('/chat/room/${Uri.encodeComponent(_self.roomId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $driveRoute => GoRouteData.$route(
  path: '/drive',
  hasOverriddenOnExit: false,
  parentNavigatorKey: DriveRoute.$parentNavigatorKey,
  factory: $DriveRoute._fromState,
);

mixin $DriveRoute on GoRouteData {
  static DriveRoute _fromState(GoRouterState state) => const DriveRoute();

  @override
  String get location => GoRouteData.$location('/drive');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $announcementsRoute => GoRouteData.$route(
  path: '/announcements',
  hasOverriddenOnExit: false,
  parentNavigatorKey: AnnouncementsRoute.$parentNavigatorKey,
  factory: $AnnouncementsRoute._fromState,
);

mixin $AnnouncementsRoute on GoRouteData {
  static AnnouncementsRoute _fromState(GoRouterState state) =>
      const AnnouncementsRoute();

  @override
  String get location => GoRouteData.$location('/announcements');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsRoute => GoRouteData.$route(
  path: '/settings',
  hasOverriddenOnExit: false,
  parentNavigatorKey: SettingsRoute.$parentNavigatorKey,
  factory: $SettingsRoute._fromState,
);

mixin $SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsAccountsRoute => GoRouteData.$route(
  path: '/settings/accounts',
  hasOverriddenOnExit: false,
  parentNavigatorKey: SettingsAccountsRoute.$parentNavigatorKey,
  factory: $SettingsAccountsRoute._fromState,
);

mixin $SettingsAccountsRoute on GoRouteData {
  static SettingsAccountsRoute _fromState(GoRouterState state) =>
      const SettingsAccountsRoute();

  @override
  String get location => GoRouteData.$location('/settings/accounts');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsNavigationRoute => GoRouteData.$route(
  path: '/settings/navigation',
  hasOverriddenOnExit: false,
  parentNavigatorKey: SettingsNavigationRoute.$parentNavigatorKey,
  factory: $SettingsNavigationRoute._fromState,
);

mixin $SettingsNavigationRoute on GoRouteData {
  static SettingsNavigationRoute _fromState(GoRouterState state) =>
      const SettingsNavigationRoute();

  @override
  String get location => GoRouteData.$location('/settings/navigation');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsAppearanceRoute => GoRouteData.$route(
  path: '/settings/appearance',
  hasOverriddenOnExit: false,
  parentNavigatorKey: SettingsAppearanceRoute.$parentNavigatorKey,
  factory: $SettingsAppearanceRoute._fromState,
);

mixin $SettingsAppearanceRoute on GoRouteData {
  static SettingsAppearanceRoute _fromState(GoRouterState state) =>
      const SettingsAppearanceRoute();

  @override
  String get location => GoRouteData.$location('/settings/appearance');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsLicensesRoute => GoRouteData.$route(
  path: '/settings/licenses',
  hasOverriddenOnExit: false,
  parentNavigatorKey: SettingsLicensesRoute.$parentNavigatorKey,
  factory: $SettingsLicensesRoute._fromState,
);

mixin $SettingsLicensesRoute on GoRouteData {
  static SettingsLicensesRoute _fromState(GoRouterState state) =>
      const SettingsLicensesRoute();

  @override
  String get location => GoRouteData.$location('/settings/licenses');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsAboutRoute => GoRouteData.$route(
  path: '/settings/about',
  hasOverriddenOnExit: false,
  parentNavigatorKey: SettingsAboutRoute.$parentNavigatorKey,
  factory: $SettingsAboutRoute._fromState,
);

mixin $SettingsAboutRoute on GoRouteData {
  static SettingsAboutRoute _fromState(GoRouterState state) =>
      const SettingsAboutRoute();

  @override
  String get location => GoRouteData.$location('/settings/about');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appShellRouteData => StatefulShellRouteData.$route(
  factory: $AppShellRouteDataExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/home',
          hasOverriddenOnExit: false,
          factory: $HomeRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/notifications',
          hasOverriddenOnExit: false,
          factory: $NotificationsRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/explore',
          hasOverriddenOnExit: false,
          factory: $ExploreRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/chat',
          hasOverriddenOnExit: false,
          factory: $ChatRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/profile',
          hasOverriddenOnExit: false,
          factory: $ProfileRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $AppShellRouteDataExtension on AppShellRouteData {
  static AppShellRouteData _fromState(GoRouterState state) =>
      const AppShellRouteData();
}

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/home');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $NotificationsRoute on GoRouteData {
  static NotificationsRoute _fromState(GoRouterState state) =>
      const NotificationsRoute();

  @override
  String get location => GoRouteData.$location('/notifications');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ExploreRoute on GoRouteData {
  static ExploreRoute _fromState(GoRouterState state) => const ExploreRoute();

  @override
  String get location => GoRouteData.$location('/explore');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ChatRoute on GoRouteData {
  static ChatRoute _fromState(GoRouterState state) => const ChatRoute();

  @override
  String get location => GoRouteData.$location('/chat');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProfileRoute on GoRouteData {
  static ProfileRoute _fromState(GoRouterState state) => const ProfileRoute();

  @override
  String get location => GoRouteData.$location('/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
