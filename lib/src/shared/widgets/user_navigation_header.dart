import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nyachi/src/features/auth/application/auth_service.dart';
import 'package:nyachi/src/features/auth/data/auth_repository.dart';
import 'package:nyachi/src/features/auth/domain/account.dart';
import 'package:nyachi/src/features/auth/presentation/widgets/add_account_dialog.dart';
import 'package:nyachi/src/features/misskey/application/misskey_notifier.dart';
import 'package:nyachi/src/features/misskey/application/misskey_notifications_notifier.dart';
import 'package:nyachi/src/shared/widgets/cyani_loading_indicator.dart';

class UserNavigationHeader extends ConsumerStatefulWidget {
  final bool isExtended;
  final bool isDrawer;
  final bool isSelected;
  final VoidCallback? onTap;

  const UserNavigationHeader({
    super.key,
    this.isExtended = true,
    this.isDrawer = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  ConsumerState<UserNavigationHeader> createState() =>
      _UserNavigationHeaderState();
}

class _UserNavigationHeaderState extends ConsumerState<UserNavigationHeader> {
  /// 用于获取用户信息部分的位置
  final _userInfoKey = GlobalKey();

  /// 账户列表展开状态
  bool _isAccountListExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Accounts info
    final misskeyAccount = ref
        .watch(selectedMisskeyAccountProvider)
        .asData
        ?.value;

    final misskeyUser = misskeyAccount != null
        ? ref.watch(misskeyMeProvider).asData?.value
        : null;

    final bool isLoggedIn = misskeyAccount != null;
    final theme = Theme.of(context);

    if (!widget.isExtended && !widget.isDrawer) {
      const double radius = 24;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: InkWell(
          key: _userInfoKey,
          onTap: widget.onTap ?? () => _showUserMenu(context, ref, isLoggedIn),
          onLongPress: () => _showUserMenu(context, ref, isLoggedIn),
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? theme.colorScheme.secondaryContainer
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: _buildAvatar(
              context,
              misskeyAccount,
              misskeyUser,
              radius: radius,
            ),
          ),
        ),
      );
    }

    if (widget.isDrawer) {
      return _buildMobileDrawerHeader(context, ref, isLoggedIn, theme);
    }

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? theme.colorScheme.secondaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: widget.onTap,
              onLongPress: () => _showUserMenu(context, ref, isLoggedIn),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildAvatar(
                      context,
                      misskeyAccount,
                      misskeyUser,
                      radius: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isLoggedIn
                            ? _getUserName(
                                misskeyAccount,
                                misskeyUser,
                              )
                            : 'nav_no_account'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.isSelected
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            key: _userInfoKey,
            onTap: () => _showUserMenu(context, ref, isLoggedIn),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: widget.isSelected
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建移动端侧边栏头部
  Widget _buildMobileDrawerHeader(
    BuildContext context,
    WidgetRef ref,
    bool isLoggedIn,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAccountInfoSection(context, ref, isLoggedIn, theme),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _isAccountListExpanded
                ? _buildAccountListSection(context, ref, theme)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// 构建账户信息区域
  Widget _buildAccountInfoSection(
    BuildContext context,
    WidgetRef ref,
    bool isLoggedIn,
    ThemeData theme,
  ) {
    final misskeyAccount = ref
        .watch(selectedMisskeyAccountProvider)
        .asData
        ?.value;

    final misskeyUser = misskeyAccount != null
        ? ref.watch(misskeyMeProvider).asData?.value
        : null;

    final Account? primaryAccount = misskeyAccount;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(
                  context,
                  misskeyAccount,
                  misskeyUser,
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoggedIn
                            ? _getUserName(
                                misskeyAccount,
                                misskeyUser,
                              )
                            : 'nav_no_account'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (isLoggedIn)
                        Text(
                          '@${primaryAccount?.username ?? ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _isAccountListExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isAccountListExpanded = !_isAccountListExpanded;
                      });
                    },
                    icon: const Icon(Icons.expand_more),
                    color: theme.colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.all(8),
                    iconSize: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建账户列表区域
  Widget _buildAccountListSection(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final accountsAsync = ref.watch(authServiceProvider);

    return accountsAsync.when(
      data: (accounts) {
        final selectedMisskey = ref
            .read(selectedMisskeyAccountProvider)
            .asData
            ?.value;

        return Container(
          margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ...accounts.map((account) {
                final isMisskeyActive = account.id == selectedMisskey?.id;
                final isActive = isMisskeyActive;

                return InkWell(
                  onTap: isActive
                      ? null
                      : () => _switchAccount(context, ref, account),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: account.avatarUrl != null
                              ? NetworkImage(account.avatarUrl!)
                              : null,
                          child: account.avatarUrl == null
                              ? Text(
                                  account.username?[0].toUpperCase() ?? '?',
                                  style: const TextStyle(fontSize: 12),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                account.name ?? account.username ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '@${account.username}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isActive)
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                );
              }),
              InkWell(
                onTap: () => AddAccountBottomSheet.show(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'accounts_add_account'.tr(),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CyaniLoadingIndicator(),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  /// 切换账户
  void _switchAccount(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    if (account.platform == 'misskey') {
      ref.read(selectedMisskeyAccountProvider.notifier).select(account);
      ref.invalidate(misskeyTimelineProvider);
      ref.invalidate(misskeyMeProvider);
      ref.invalidate(misskeyNotificationsProvider);
    }

    if (!context.mounted) return;

    final GoRouter router = GoRouter.of(context);
    context.go(router.routeInformationProvider.value.uri.toString());

    setState(() {
      _isAccountListExpanded = false;
    });
  }

  String _getUserName(
    Account? misskeyAccount,
    dynamic misskeyUser,
  ) {
    if (misskeyAccount != null) {
      return misskeyUser?.name ??
          misskeyAccount.name ??
          misskeyAccount.username ??
          'Misskey User';
    }
    return 'CyaniUser';
  }

  Widget _buildAvatar(
    BuildContext context,
    Account? misskeyAccount,
    dynamic misskeyUser, {
    double radius = 32,
  }) {
    final avatarUrl =
        misskeyUser?.avatarUrl ??
        misskeyAccount?.avatarUrl;

    if (avatarUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Icon(
              Icons.account_circle,
              size: radius * 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Icon(
              Icons.account_circle,
              size: radius * 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.account_circle,
          size: radius * 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  /// 显示用户菜单
  void _showUserMenu(BuildContext context, WidgetRef ref, bool isLoggedIn) {
    final theme = Theme.of(context);

    // 获取用户信息部分的位置
    final RenderBox renderBox =
        _userInfoKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // 计算菜单位置
    final offset = Offset(position.dx, position.dy + size.height);

    if (!isLoggedIn) {
      // 未登录时显示登录选项
      showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy,
          offset.dx + size.width,
          offset.dy,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        items: <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'login',
            child: SizedBox(
              width: 280,
              child: Row(
                children: [
                  Icon(
                    Icons.login,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'menu_login'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ).then((value) {
        if (!context.mounted) return;
        if (value == 'login') {
          context.push('/profile');
        }
      });
      return;
    }

    // 获取所有账户
    final accountsAsync = ref.watch(authServiceProvider);

    accountsAsync.when(
      data: (accounts) {
        final selectedMisskey = ref
            .read(selectedMisskeyAccountProvider)
            .asData
            ?.value;

        // 按主机分组账户
        final Map<String, List<Account>> accountsByHost = {};
        for (final account in accounts) {
          final host = account.host;
          if (!accountsByHost.containsKey(host)) {
            accountsByHost[host] = [];
          }
          accountsByHost[host]!.add(account);
        }

        // 显示菜单
        showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy,
            offset.dx + size.width,
            offset.dy,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          items: _buildAccountMenuItems(
            context,
            accounts,
            selectedMisskey,
            accountsByHost,
          ),
        ).then((value) {
          if (!context.mounted) return;

          if (value != null) {
            if (value == 'logout') {
              _logout(context, ref);
            } else {
              // 切换账户
              final account = accounts.firstWhere((a) => a.id == value);
              if (account.platform == 'misskey') {
                ref
                    .read(selectedMisskeyAccountProvider.notifier)
                    .select(account);
                // 刷新Misskey相关provider
                ref.invalidate(misskeyTimelineProvider);
                ref.invalidate(misskeyMeProvider);
                ref.invalidate(misskeyNotificationsProvider);
                // 刷新当前路由
                if (context.mounted) {
                  final router = GoRouter.of(context);
                  context.go(
                    router.routeInformationProvider.value.uri.toString(),
                  );
                }
              }
            }
          }
        });
      },
      loading: () {},
      error: (err, stack) {},
    );
  }

  /// 构建账户菜单项
  List<PopupMenuEntry<String>> _buildAccountMenuItems(
    BuildContext context,
    List<Account> accounts,
    Account? selectedMisskey,
    Map<String, List<Account>> accountsByHost,
  ) {
    final theme = Theme.of(context);
    final List<PopupMenuEntry<String>> items = [];

    // 遍历每个主机的账户
    for (final host in accountsByHost.keys) {
      final hostAccounts = accountsByHost[host]!;

      // 添加主机分组标题
      items.add(
        PopupMenuItem<String>(
          enabled: false,
          height: 32,
          child: SizedBox(
            width: 280,
            child: Text(
              host,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

      // 添加该主机的账户
      for (final account in hostAccounts) {
        final isMisskeyActive = account.id == selectedMisskey?.id;
        final isActive = isMisskeyActive;

        items.add(
          PopupMenuItem<String>(
            value: account.id,
            enabled: !isActive,
            child: SizedBox(
              width: 280,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: account.avatarUrl != null
                        ? NetworkImage(account.avatarUrl!)
                        : null,
                    child: account.avatarUrl == null
                        ? Text(account.username?[0].toUpperCase() ?? '?')
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          account.name ?? account.username ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '@${account.username}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      }

      // 如果不是最后一个主机，添加分隔线
      if (host != accountsByHost.keys.last) {
        items.add(const PopupMenuDivider(height: 8));
      }
    }

    // 添加分隔线和退出登录选项
    items.addAll([
      const PopupMenuDivider(height: 16),
      PopupMenuItem<String>(
        value: 'logout',
        child: SizedBox(
          width: 280,
          child: Row(
            children: [
              Icon(Icons.logout, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text(
                'menu_logout'.tr(),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
      ),
    ]);

    return items;
  }

  /// 退出登录
  void _logout(BuildContext context, WidgetRef ref) {
    // 显示确认对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('menu_logout_confirm'.tr()),
        content: Text('menu_logout_confirm_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              // 退出所有账号
              final authRepository = ref.read(authRepositoryProvider);
              final accounts = await authRepository.getAccounts();

              // 逐个删除所有账户
              for (final account in accounts) {
                await authRepository.removeAccount(account.id);
              }

              // 清除选中的账户ID
              final prefs = ref.read(sharedPreferencesProvider);
              await prefs.remove('cyani_selected_misskey_id');

              // 刷新认证服务状态
              await ref.read(authServiceProvider.future);

              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            child: Text(
              'menu_logout'.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
