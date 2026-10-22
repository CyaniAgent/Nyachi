import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_state_tracker.g.dart';

/// 导航路径状态
@riverpod
class NavigationPath extends _$NavigationPath {
  @override
  String build() => '';

  void navigate(String path) {
    state = path;
  }

  static const rootPaths = ['/misskey', '/cloud', '/messaging', '/profile'];

  String pageName(String path) {
    if (path.isEmpty) return 'Nyachi';

    for (final rootPath in rootPaths) {
      if (path == rootPath ||
          path.startsWith('$rootPath/') ||
          path.startsWith('$rootPath?')) {
        return _nameFromRootPath(rootPath);
      }
    }

    return _nameFromRoute(path);
  }

  bool isRootPage(String path) => rootPaths.contains(path);

  String _nameFromRootPath(String rootPath) {
    switch (rootPath) {
      case '/misskey':
        return 'Misskey';
      case '/cloud':
        return '云盘';
      case '/messaging':
        return '消息';
      case '/profile':
        return '我';
      default:
        return 'Nyachi';
    }
  }

  String _nameFromRoute(String location) {
    if (location == '/search') return '搜索';
    if (location == '/settings' || location.startsWith('/settings/')) {
      return '设置';
    }
    if (location == '/about') return '关于';
    if (location == '/licenses') return '开源许可';
    if (location == '/developer') return '开发者';
    if (location == '/login') return '登录';
    if (location == '/misskey/notifications') return '通知';
    if (location.startsWith('/misskey/user/')) return '用户资料';
    if (location.startsWith('/messaging/chat/')) return '聊天';
    return 'Nyachi';
  }
}
