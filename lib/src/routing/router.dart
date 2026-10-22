// 应用程序路由配置
//
// 该文件包含应用程序的路由配置，使用go_router管理导航，
// 定义了应用程序的各个页面路由和初始位置。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyachi/src/core/utils/logger.dart';
import 'package:nyachi/src/features/auth/presentation/pages/login_page.dart';
import 'package:nyachi/src/features/cloud/presentation/cloud_page.dart';
import 'package:nyachi/src/features/messaging/presentation/chat_page.dart';
import 'package:nyachi/src/features/messaging/presentation/messaging_page.dart';
import 'package:nyachi/src/features/misskey/domain/chat_room.dart';
import 'package:nyachi/src/features/misskey/domain/misskey_user.dart';
import 'package:nyachi/src/features/misskey/presentation/misskey_page.dart';
import 'package:nyachi/src/features/misskey/presentation/pages/misskey_notifications_page.dart';
import 'package:nyachi/src/features/misskey/presentation/pages/misskey_user_profile_page.dart';
import 'package:nyachi/src/features/profile/application/developer_settings_provider.dart';
import 'package:nyachi/src/shared/widgets/cyani_error_widget.dart';
import 'package:nyachi/src/features/profile/presentation/profile_page.dart';
import 'package:nyachi/src/features/profile/presentation/settings/about_page.dart';
import 'package:nyachi/src/features/profile/presentation/settings/developer_settings_page.dart';
import 'package:nyachi/src/features/profile/presentation/settings/licenses_page.dart';
import 'package:nyachi/src/features/profile/presentation/settings/settings_page.dart';
import 'package:nyachi/src/features/search/presentation/search_page.dart';
import 'package:nyachi/src/features/welcome/application/welcome_state.dart';
import 'package:nyachi/src/features/welcome/presentation/welcome_page.dart';
import 'package:nyachi/src/shared/widgets/coming_soon_page.dart';
import 'package:nyachi/src/shared/widgets/cyani_loading_indicator.dart';
import 'package:nyachi/src/shared/widgets/responsive_shell.dart';

part 'router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final routerRefreshNotifier = ValueNotifier<int>(0);

/// 自定义安全转换页面，防止 Windows AXTree 报错
Page<T> _buildSafePage<T>({
  required LocalKey key,
  required Widget child,
  bool fullScreenDialog = false,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    fullscreenDialog: fullScreenDialog,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(0.0, 0.02),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: ExcludeSemantics(
            // 动画进行中完全屏蔽语义，防止 Windows AXTree 报错
            excluding:
                !animation.isCompleted || !secondaryAnimation.isDismissed,
            child: child,
          ),
        ),
      );
    },
  );
}

/// 根据开发者模式状态返回合适的消息页面
Widget _buildMessagingPage(BuildContext context, GoRouterState state) {
  // 这里需要使用 ConsumerWidget 来访问 provider
  return Consumer(
    builder: (context, ref, child) {
      final developerModeAsync = ref.watch(developerSettingsProvider);
      
      return developerModeAsync.when(
        data: (developerMode) {
          if (developerMode) {
            return const MessagingPage();
          }
          return const ComingSoonPage();
        },
        loading: () => const Scaffold(
          body: Center(child: CyaniLoadingIndicator()),
        ),
        error: (err, stack) => Scaffold(
          body: CyaniErrorWidget(message: err.toString()),
        ),
      );
    },
  );
}

/// 提供应用程序的GoRouter实例
///
/// 定义了应用程序的所有路由配置，包括初始位置和各个页面的路由路径。
/// 使用StatefulShellRoute实现底部导航栏的状态保持。
///
/// [ref] - Riverpod的Ref，用于访问和监听状态
///
/// 返回配置好的GoRouter实例
@riverpod
GoRouter goRouter(Ref ref) {
  logger.info('Router: Initializing GoRouter');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/misskey',
    refreshListenable: routerRefreshNotifier,
    redirect: (context, state) {
      final welcomeDone = ref.read(welcomeCompletedProvider).asData?.value ?? false;
      final location = state.uri.toString();

      // 未完成欢迎页 → 强制跳转 /welcome
      if (!welcomeDone && location != '/welcome') {
        return '/welcome';
      }
      // 已完成欢迎页但在 /welcome → 跳转首页
      if (welcomeDone && location == '/welcome') {
        return '/misskey';
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          logger.debug(
            'Router: StatefulShellRoute builder called for path: ${state.path}',
          );
          return ResponsiveShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/misskey',
                pageBuilder: (context, state) => _buildSafePage(
                  key: state.pageKey,
                  child: const MisskeyPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cloud',
                pageBuilder: (context, state) => _buildSafePage(
                  key: state.pageKey,
                  child: const CloudPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messaging',
                pageBuilder: (context, state) => _buildSafePage(
                  key: state.pageKey,
                  child: _buildMessagingPage(context, state),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => _buildSafePage(
                  key: state.pageKey,
                  child: const ProfilePage(),
                ),
              ),
            ],
          ),
        ],
      ),
      // Top-level routes that don't have the navigation shell
      GoRoute(
        path: '/welcome',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildSafePage(key: state.pageKey, child: const WelcomePage()),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildSafePage(key: state.pageKey, child: const LoginPage()),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildSafePage(key: state.pageKey, child: const SearchPage()),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildSafePage(
          key: state.pageKey,
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: '/about',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildSafePage(key: state.pageKey, child: const AboutPage()),
      ),
      GoRoute(
        path: '/licenses',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildSafePage(key: state.pageKey, child: const LicensesPage()),
      ),
      GoRoute(
        path: '/developer',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildSafePage(
          key: state.pageKey,
          child: const DeveloperSettingsPage(),
        ),
      ),
      GoRoute(
        path: '/misskey/notifications',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _buildSafePage(
          key: state.pageKey,
          child: const MisskeyNotificationsPage(),
        ),
      ),
      GoRoute(
        path: '/misskey/user/:userId',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final user = state.extra as MisskeyUser?;
          return _buildSafePage(
            key: state.pageKey,
            child: MisskeyUserProfilePage(userId: userId, initialUser: user),
          );
        },
      ),
      GoRoute(
        path: '/messaging/chat/:userId',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final user = state.extra as MisskeyUser?;
          return _buildSafePage(
            key: state.pageKey,
            child: ChatPage(
              id: userId,
              type: ChatType.direct,
              initialData: user,
            ),
          );
        },
      ),
      GoRoute(
        path: '/messaging/chat/room/:roomId',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          final room = state.extra as ChatRoom?;
          return _buildSafePage(
            key: state.pageKey,
            child: ChatPage(id: roomId, type: ChatType.room, initialData: room),
          );
        },
      ),
    ],
  );
}
