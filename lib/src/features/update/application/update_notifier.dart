import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '/src/core/utils/logger.dart';
import '/src/features/update/domain/app_update.dart';

part 'update_notifier.g.dart';

enum UpdateState {
  idle,
  checking,
  upToDate,
  updateAvailable,
  error,
}

class UpdateStateData {
  final UpdateState state;
  final AppUpdate? update;
  final String? errorMessage;

  const UpdateStateData({
    this.state = UpdateState.idle,
    this.update,
    this.errorMessage,
  });
}

@riverpod
class Update extends _$Update {
  @override
  UpdateStateData build() => const UpdateStateData();

  Future<void> checkForUpdate({bool silent = false}) async {
    if (state.state == UpdateState.checking) return;

    state = const UpdateStateData(state: UpdateState.checking);

    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;
      logger.info('UpdateNotifier: Current version: $currentVersion');

      final response = await Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ).get(
        'https://api.github.com/repos/CyaniAgent/Nyachi/releases/latest',
        options: Options(
          headers: {
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'Nyachi',
          },
        ),
      );

      final tagName = response.data['tag_name'] as String?;
      if (tagName == null) {
        state = const UpdateStateData(
          state: UpdateState.error,
          errorMessage: '无法获取最新版本信息',
        );
        return;
      }

      final latestVersion =
          tagName.startsWith('v') ? tagName.substring(1) : tagName;

      if (_isNewerVersion(latestVersion, currentVersion)) {
        logger.info('UpdateNotifier: New version available: $latestVersion');
        state = UpdateStateData(
          state: UpdateState.updateAvailable,
          update: AppUpdate(latestVersion: latestVersion),
        );
      } else {
        logger.info('UpdateNotifier: App is up to date');
        state = const UpdateStateData(state: UpdateState.upToDate);
      }
    } catch (e) {
      logger.error('UpdateNotifier: Check failed: $e');
      if (!silent) {
        state = UpdateStateData(
          state: UpdateState.error,
          errorMessage: '检查更新失败: $e',
        );
      } else {
        state = const UpdateStateData();
      }
    }
  }

  bool _isNewerVersion(String latestVersion, String currentVersion) {
    try {
      final latestParts = latestVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts = currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (var i = 0; i < 3; i++) {
        final l = i < latestParts.length ? latestParts[i] : 0;
        final c = i < currentParts.length ? currentParts[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }
      return false;
    } catch (e) {
      logger.error('UpdateNotifier: Version comparison error: $e');
      return latestVersion != currentVersion;
    }
  }

  void reset() {
    state = const UpdateStateData();
  }
}


