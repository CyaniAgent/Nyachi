/// 应用常量配置
///
/// 该文件包含应用程序的各种常量配置，如默认值、限制值等
library;

/// 应用常量类
///
/// 包含应用程序的各种常量配置，如版本号、日志配置等。
/// 这些常量在整个应用程序中被广泛使用，确保配置的一致性。
class Constants {
  /// 应用版本号
  ///
  /// 当前应用程序的版本标识，用于显示和更新检查。
  static const String appVersion = '1.0.0';

  /// 默认最大日志文件大小（MB）
  ///
  /// 单个日志文件的最大大小，超过此大小会创建新的日志文件。
  static const int defaultMaxLogSize = 5;

  /// 日志目录名称
  ///
  /// 日志文件存储的目录名称，位于应用程序的文档目录中。
  static const String logDirectoryName = 'debug';

  /// 默认日志文件前缀
  ///
  /// 日志文件的命名前缀，后续会添加时间戳。
  static const String logFilePrefix = 'Nyachi_Console_log';

  /// 默认日志级别
  ///
  /// 应用程序启动时的默认日志级别，可选值包括：debug, info, warning, error
  static const String defaultLogLevel = 'error';

  /// 生成用户代理字符串
  ///
  /// 精简 UA，符合 RFC 7231 规范，不包含具体浏览器版本号。
  static String getUserAgent() {
    return 'Nyachi/$appVersion (Misskey Client; +https://github.com/CyaniAgent/Nyachi)';
  }
}
