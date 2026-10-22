import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

import '/src/features/auth/data/auth_repository.dart';
import '/src/features/auth/domain/account.dart';
import '/src/features/auth/domain/misskey_permissions.dart';
import '/src/core/api/network_client.dart';
import '/src/core/core.dart';
import '/src/features/misskey/application/misskey_notifier.dart';
import '/src/features/profile/application/network_settings_provider.dart';

part 'auth_service.g.dart';

/// 认证服务类
///
/// 负责处理用户认证流程，包括Misskey的MiAuth流程，
/// 管理认证状态和账户信息。
@Riverpod(keepAlive: true)
class AuthService extends _$AuthService {
  /// 初始化认证服务状态
  ///
  /// 从认证仓库中获取所有已保存的账户，并将其作为初始状态。
  ///
  /// 返回包含所有账户的Future列表
  @override
  FutureOr<List<Account>> build() async {
    logger.info('初始化认证服务');
    final repository = ref.watch(authRepositoryProvider);
    final accounts = await repository.getAccounts();
    logger.info('认证服务初始化完成，加载了 ${accounts.length} 个账户');
    return accounts;
  }

  /// 启动Misskey的MiAuth认证流程
  ///
  /// 开始Misskey平台的MiAuth认证流程，生成会话ID并打开浏览器进行授权。
  /// 会检查账户数量限制，最多支持10个Misskey账户。
  ///
  /// @param host Misskey实例的主机地址
  /// @return 返回会话ID，用于后续检查认证状态
  Future<String> startMiAuth(String host) async {
    final sanitizedHost = _sanitizeHost(host);
    logger.info('开始Misskey MiAuth认证流程，主机: $sanitizedHost (原始: $host)');
    final accounts = await ref.read(authRepositoryProvider).getAccounts();

    final misskeyAccounts = accounts
        .where((a) => a.platform == 'misskey')
        .length;

    logger.info('当前Misskey账户数量: $misskeyAccounts');
    if (misskeyAccounts >= 10) {
      logger.warning('Misskey账户数量达到上限 (10个)');
      throw Exception('You have reached the limit of 10 Misskey accounts.');
    }

    final session = const Uuid().v4();
    logger.debug('生成MiAuth会话ID: $session');

    final uri = Uri.https(sanitizedHost, '/miauth/$session', {
      'name': 'Nyachi',
      'permission': MisskeyPermissions.toMiAuthString(),
    });

    logger.debug('生成MiAuth URL: ${uri.toString()}');

    // On some Android versions, canLaunchUrl might return false even if it works.
    // We attempt to launch and catch errors for better reliability.
    try {
      logger.info('尝试启动浏览器进行MiAuth授权');
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        logger.info('MiAuth授权页面已成功打开');
        return session;
      } else {
        logger.error('启动URL返回失败: ${uri.toString()}');
        throw Exception('无法打开浏览器进行授权');
      }
    } catch (e) {
      logger.error('启动MiAuth URL时发生错误: $e', e);
      throw Exception('授权流程启动失败: 请检查您的设备是否安装了浏览器');
    }
  }

  /// 检查Misskey MiAuth认证状态

  ///

  /// [host] - Misskey实例的主机地址

  /// [session] - 认证会话ID

  ///

  /// 成功时保存账户信息并刷新状态，失败时抛出异常

  /// 检查Misskey MiAuth认证状态
  ///
  /// [host] - Misskey实例的主机地址
  /// [session] - 认证会话ID
  ///
  /// 成功时保存账户信息并刷新状态，失败时抛出异常
  Future<void> checkMiAuth(String host, String session) async {
    final sanitizedHost = _sanitizeHost(host);
    logger.info('检查Misskey MiAuth认证状态，主机: $sanitizedHost');

    final networkSettings = ref.read(networkSettingsProvider).value;
    final dio = NetworkClient().createDio(
      host: sanitizedHost,
      userAgent: networkSettings?.effectiveUserAgent,
    );

    int retryCount = 0;
    const maxRetries = 10; // Increased retries for better UX on Android

    while (retryCount < maxRetries) {
      try {
        if (retryCount > 0) {
          logger.debug('重试检查MiAuth状态 (${retryCount + 1}/$maxRetries)...');
          // Adaptive delay: wait longer between retries later on
          final delaySeconds = retryCount < 5 ? 2 : 4;
          await Future.delayed(Duration(seconds: delaySeconds));
        } else {
          // Initial wait
          await Future.delayed(const Duration(seconds: 1));
        }

        logger.debug('发送MiAuth状态检查请求: /api/miauth/$session/check');
        final response = await dio.post('/api/miauth/$session/check', data: {});
        logger.debug('收到MiAuth状态检查响应');

        final data = response.data;
        // Check for both 'ok' field and strict 'true' value
        if (data is Map && data['ok'] == true) {
          await _handleSuccessfulAuth(data, sanitizedHost);
          return;
        } else {
          // If 'ok' is false, it might mean 'pending' or 'denied'.
          // However, Misskey API usually returns ok: true if authorized, and separate error otherwise?
          // Actually, if it's still pending, it might just return ok: false or error.
          // We will retry if it's likely a timing issue, or throw if it's definitive.
          logger.debug('MiAuth检查未通过: $data');
        }
      } on DioException catch (e) {
        logger.warning('检查MiAuth HTTP错误 (尝试 ${retryCount + 1}): ${e.message}');
        if (e.response != null) {
          logger.warning('响应体: ${e.response?.data}');
        }
        // Don't rethrow immediately on network glitches, try again
      } catch (e) {
        logger.error('检查MiAuth非预期错误: $e');
      }

      retryCount++;
    }

    throw Exception('无法完成认证，请确认您已在浏览器中批准授权。');
  }

  Future<void> _handleSuccessfulAuth(
    Map<dynamic, dynamic> data,
    String sanitizedHost,
  ) async {
    final token = data['token'];
    final user = data['user'];

    if (token == null || user == null) {
      logger.error('MiAuth响应缺少必要字段 (token或user)');
      throw Exception('MiAuth响应缺少必要字段 (token或user)');
    }

    final accountId = '${user['id']}@$sanitizedHost';
    logger.info('MiAuth认证成功，用户: ${user['username']}, 账户ID: $accountId');

    final repository = ref.read(authRepositoryProvider);
    final accounts = await repository.getAccounts();

    final existingAccount = accounts
        .where((a) => a.id == accountId)
        .firstOrNull;

    if (existingAccount == null) {
      final misskeyAccounts = accounts
          .where((a) => a.platform == 'misskey')
          .length;

      if (misskeyAccounts >= 10) {
        logger.warning('Misskey账户数量达到上限 (10个)');
        throw Exception('You have reached the limit of 10 Misskey accounts.');
      }
    }

    final account = Account(
      id: accountId, // 复合ID
      platform: 'misskey',
      host: sanitizedHost,
      username: user['username'],
      name: user['name'],
      avatarUrl: user['avatarUrl'],
      token: token,
    );

    await repository.saveAccount(account);

    // Automatically select the new account by saving the ID to repository
    // We avoid calling the provider directly to prevent CircularDependencyError
    // as SelectedMisskeyAccount depends on AuthService.
    await repository.saveSelectedMisskeyId(account.id);

    // Upate state without re-initializing the whole Notifier
    final updatedAccounts = await repository.getAccounts();
    state = AsyncData(updatedAccounts);

    logger.info('Misskey MiAuth认证流程完成');
  }

  /// 删除指定ID的账户
  ///
  /// 删除指定ID的账户信息，删除后会刷新认证服务的状态。
  ///
  /// @param id 要删除的账户ID
  /// @return 无返回值，删除后刷新状态
  Future<void> removeAccount(String id) async {
    logger.info('删除账户，账户ID: $id');
    await ref.read(authRepositoryProvider).removeAccount(id);
    logger.debug('账户删除成功');

    logger.debug('更新认证服务状态');
    final updatedAccounts = await ref
        .read(authRepositoryProvider)
        .getAccounts();
    state = AsyncData(updatedAccounts);

    // Selected accounts will automatically re-evaluate since they watch authServiceProvider
    logger.debug('选中的账户将自动重新评估');
    logger.info('账户删除流程完成');
  }

  /// 清理主机地址，提取出域名部分
  String _sanitizeHost(String host) {
    return sanitizeHost(host);
  }
}

/// 选中的Misskey账户提供者
///
/// 管理当前选中的Misskey账户，支持账户切换和自动选择逻辑。
@Riverpod(keepAlive: true)
class SelectedMisskeyAccount extends _$SelectedMisskeyAccount {
  /// 初始化选中的Misskey账户
  ///
  /// 从存储中获取上次选中的Misskey账户ID，如果存在则返回对应的账户，
  /// 否则返回第一个可用的Misskey账户。
  /// 初始化时同时设置缓存管理器和笔记缓存管理器的当前账户ID。
  ///
  /// @return 返回选中的Misskey账户，如果没有则返回null
  @override
  FutureOr<Account?> build() async {
    final accounts = await ref.watch(authServiceProvider.future);

    final repository = ref.read(authRepositoryProvider);

    final selectedId = await repository.getSelectedMisskeyId();

    Account? selectedAccount;
    if (selectedId != null) {
      try {
        selectedAccount = accounts.firstWhere((a) => a.id == selectedId);
      } catch (e) {
        logger.warning('AuthService: Selected account not found, falling back', e);
      }
    }

    selectedAccount ??= accounts
          .where((a) => a.platform == 'misskey')
          .firstOrNull;

    // 设置缓存管理器的当前账户ID
    if (selectedAccount != null) {
      cacheManager.setCurrentAccountId(selectedAccount.id);
      MisskeyTimelineNotifier.cacheManager.setCurrentAccountId(
        selectedAccount.id,
      );
    } else {
      cacheManager.setCurrentAccountId(null);
      MisskeyTimelineNotifier.cacheManager.setCurrentAccountId(null);
    }

    return selectedAccount;
  }

  /// 选择Misskey账户
  ///
  /// 选择指定的Misskey账户作为当前活动账户，并保存选择状态。
  /// 同时更新缓存管理器和笔记缓存管理器的当前账户ID以实现缓存隔离。
  ///
  /// @param account 要选择的账户，必须是Misskey平台的账户
  /// @return 无返回值
  Future<void> select(Account account) async {
    if (account.platform != 'misskey') return;

    state = AsyncData(account);

    await ref.read(authRepositoryProvider).saveSelectedMisskeyId(account.id);

    // 设置缓存管理器的当前账户ID
    cacheManager.setCurrentAccountId(account.id);

    // 设置笔记缓存管理器的当前账户ID
    MisskeyTimelineNotifier.cacheManager.setCurrentAccountId(account.id);
  }
}

@riverpod
Account? selectedAccount(Ref ref) {
  final accountsAsync = ref.watch(authServiceProvider);

  return accountsAsync.maybeWhen(
    data: (accounts) => accounts.isNotEmpty ? accounts.first : null,

    orElse: () => null,
  );
}
