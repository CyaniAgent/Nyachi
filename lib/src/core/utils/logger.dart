/// 日志工具类，负责应用中的日志输出和管理
///
/// 该类提供：
/// 1. 不同级别的日志输出（DEBUG, INFO, WARNING, ERROR）
/// 2. 控制台和文件双输出
/// 3. 动态日志级别调整
/// 4. 日志文件管理（大小限制、清理等）
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/src/core/config/constants.dart';

/// 日志工具类，管理应用中的所有日志输出
///
/// 提供多级别日志输出、文件和控制台双输出、日志文件管理等功能。
/// 使用单例模式，确保应用中只有一个日志实例。
class AppLogger {
  /// 单例实例
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  /// 日志实例
  late Logger _logger;

  /// 文件输出实例
  AppFileOutput? _fileOutput;

  /// 当前日志级别
  Level _currentLevel = Level.debug;

  /// 日志文件路径
  String? _logFilePath;

  /// 是否已经初始化了 debugPrint 拦截
  bool _debugPrintOverridden = false;

  /// 检查消息是否为干扰噪音（如 Windows AXTree 错误）
  static bool isNoise(String message) {
    if (!Platform.isWindows) return false;

    final noisePatterns = [
      'AXTree',
      'Accessibility Error',
      'flutter/shell/platform/windows',
      'render_accessibility_node',
    ];

    return noisePatterns.any((pattern) => message.contains(pattern));
  }

  /// 初始化日志配置
  ///
  /// 配置日志输出方式，包括控制台输出和文件输出。
  /// 会根据平台选择合适的日志文件存储位置。
  /// 如果是Release模式，默认日志级别会被覆盖为ERROR（与Constants.defaultLogLevel一致）。
  /// 如果提供了logLevel参数，会使用该值覆盖默认级别。
  ///
  /// @param logLevel 可选的日志级别字符串，如'debug'、'info'、'warning'、'error'
  /// @return 无返回值，初始化完成后日志系统即可使用
  Future<void> initialize({String? logLevel}) async {
    // 如果是Release模式，默认日志级别为ERROR（与Constants.defaultLogLevel一致）
    if (kReleaseMode) {
      _currentLevel = Level.error;
    }

    // 如果提供了日志级别参数，使用该值覆盖默认级别
    if (logLevel != null) {
      switch (logLevel.toLowerCase()) {
        case 'debug':
          _currentLevel = Level.debug;
          break;
        case 'info':
          _currentLevel = Level.info;
          break;
        case 'warning':
        case 'warn':
          _currentLevel = Level.warning;
          break;
        case 'error':
          _currentLevel = Level.error;
          break;
        default:
          // 无效的日志级别，保持当前级别
          break;
      }
    }

    // 在 Windows 上抑制原生 AXTree 报错（这些通常通过 debugPrint 输出）
    if (Platform.isWindows && !_debugPrintOverridden) {
      final DebugPrintCallback originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null && !isNoise(message)) {
          originalDebugPrint(message, wrapWidth: wrapWidth);
        }
      };
      _debugPrintOverridden = true;
    }

    // 创建控制台输出 (使用自定义过滤输出)
    final consoleOutput = FilteredConsoleOutput();

    // 创建文件输出
    _fileOutput = await _createFileOutput();

    // 先初始化输出目标，确保文件流已打开，再创建 Logger
    final multiOutput = AppMultiOutput([consoleOutput, _fileOutput!]);
    await multiOutput.init();

    // 初始化日志器
    _logger = Logger(
      level: _currentLevel,
      output: multiOutput,
      printer: SimplePrinter(),
    );

    // 输出初始化信息和当前日志级别
    debug('AppLogger: Initialized with log level: $_currentLevel');
    debug('AppLogger: Log file path: $_logFilePath');
    debug('AppLogger: Build mode: ${kReleaseMode ? 'Release' : 'Debug'}');
    debug('AppLogger: User log level: $logLevel');

    // 异步执行清理
    Future.microtask(cleanupLogs);
  }

  /// 为测试环境初始化日志配置
  ///
  /// 仅使用控制台输出，避免依赖 path_provider 等平台相关库。
  void setupForTesting() {
    final consoleOutput = FilteredConsoleOutput();
    _logger = Logger(
      level: Level.error,
      output: consoleOutput,
      printer: SimplePrinter(),
    );
  }

  /// 创建文件输出
  ///
  /// 根据平台创建合适的日志文件输出实例，处理不同平台的文件路径差异。
  ///
  /// @return 返回创建的AppFileOutput实例
  Future<AppFileOutput> _createFileOutput() async {
    try {
      final debugDir = await _getLogDirectory();
      final now = DateTime.now();
      final dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final timeStr =
          "${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}_${now.second.toString().padLeft(2, '0')}";
      final fileName = "${Constants.logFilePrefix}_${dateStr}_$timeStr.log";

      _logFilePath = "${debugDir.path}/$fileName";
      final file = File(_logFilePath!);

      // 确保文件存在
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }

      // 检查文件大小，超过限制则清理
      await _checkAndCleanLogFile(file);

      return AppFileOutput(
        file: file,
        overrideExisting: false,
        mode: FileMode.append,
      );
    } catch (e) {
      // 如果文件创建失败，返回本地控制台输出
      debugPrint('AppLogger Error: Failed to create file output: $e');
      const defaultPath = './${Constants.logFilePrefix}_logs.log';
      _logFilePath = defaultPath;
      return AppFileOutput(
        file: File(defaultPath),
        overrideExisting: false,
        mode: FileMode.append,
      );
    }
  }

  /// 获取日志目录 (私有统一方法)
  Future<Directory> _getLogDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // 使用应用支持目录，避免权限问题（如 Program Files）
      directory = await getApplicationSupportDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) throw Exception('无法获取存储目录');

    final debugDir = Directory(
      '${directory.path}/${Constants.logDirectoryName}',
    );
    if (!debugDir.existsSync()) {
      debugDir.createSync(recursive: true);
    }
    return debugDir;
  }

  /// 检查并清理日志文件
  ///
  /// 检查日志文件大小，超过限制则清理部分内容，保留最新的日志。
  ///
  /// @param file 要检查的日志文件
  /// @return 无返回值
  Future<void> _checkAndCleanLogFile(File file) async {
    try {
      final stat = await file.stat();
      const maxSize = Constants.defaultMaxLogSize * 1024 * 1024; // MB to bytes

      if (stat.size > maxSize) {
        // 超过限制，保留最后50%内容
        final lines = await file.readAsLines();
        final keepLines = (lines.length * 0.5).round();
        final newContent = lines.skip(lines.length - keepLines).join('\n');
        await file.writeAsString(newContent);
      }
    } catch (e) {
      // 忽略清理错误
    }
  }

  /// 设置日志级别
  ///
  /// 动态调整日志输出级别，支持的级别包括：debug、info、warning、error。
  ///
  /// @param level 要设置的日志级别字符串
  /// @return 无返回值
  Future<void> setLogLevel(String level) async {
    switch (level.toLowerCase()) {
      case 'debug':
        _currentLevel = Level.debug;
        break;
      case 'info':
        _currentLevel = Level.info;
        break;
      case 'warning':
      case 'warn':
        _currentLevel = Level.warning;
        break;
      case 'error':
        _currentLevel = Level.error;
        break;
      default:
        _currentLevel = Level.error;
    }

    // 创建控制台输出
    final consoleOutput = FilteredConsoleOutput();

    // 先初始化输出目标，确保文件流已打开
    final multiOutput = AppMultiOutput([consoleOutput, _fileOutput!]);
    await multiOutput.init();

    // 重新创建日志器以更新级别
    _logger = Logger(
      level: _currentLevel,
      output: multiOutput,
      printer: SimplePrinter(),
    );
  }

  /// 获取日志文件路径
  String? get logFilePath => _logFilePath;

  /// 查看日志内容
  ///
  /// 读取并返回当前日志文件的内容，按行分割。
  ///
  /// @return 返回日志文件的内容列表，每行一条日志
  Future<List<String>> viewLogs() async {
    try {
      if (_logFilePath == null) await initialize();
      final file = File(_logFilePath!);
      if (file.existsSync()) {
        return file.readAsLines();
      }
    } catch (e) {
      // 忽略错误
    }
    return [];
  }

  /// 导出日志
  ///
  /// 将当前日志文件复制到指定位置，生成导出文件。
  /// 会根据平台选择合适的导出路径。
  ///
  /// @return 返回导出的日志文件，失败则返回null
  Future<File?> exportLogs() async {
    try {
      if (_logFilePath == null) await initialize();
      final sourceFile = File(_logFilePath!);
      if (sourceFile.existsSync()) {
        final now = DateTime.now();
        final timestamp =
            "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
        final exportFileName =
            "${Constants.logFilePrefix}_export_$timestamp.log";

        final exportDir = await _getExportDirectory();
        if (!exportDir.existsSync()) {
          exportDir.createSync(recursive: true);
        }

        final exportPath = "${exportDir.path}/$exportFileName";
        final exportFile = File(exportPath);
        // 复制文件
        await sourceFile.copy(exportPath);
        return exportFile;
      }
    } catch (e) {
      debugPrint('AppLogger Error: Export failed: $e');
    }
    return null;
  }

  /// 获取导出目录
  Future<Directory> _getExportDirectory() async {
    if (Platform.isAndroid) {
      // Android 平台：/storage/emulated/0/Download/Nyachi Logs
      return Directory('/storage/emulated/0/Download/Nyachi Logs');
    }

    // 其他平台默认使用内部日志目录
    return await _getLogDirectory();
  }

  /// 删除日志
  ///
  /// 删除当前的日志文件，Android平台会删除debug目录下的所有文件，
  /// 其他平台会删除当前日志文件并重新初始化。
  ///
  /// @return 无返回值
  Future<void> deleteLogs() async {
    try {
      // 先关闭当前日志文件的 sink，释放文件锁
      await _fileOutput?.destroy();
      _fileOutput = null;

      final dir = await _getLogDirectory();
      if (dir.existsSync()) {
        final files = dir.listSync();
        for (final file in files) {
          if (file is File) {
            try {
              await file.delete();
            } catch (e) {
              // Windows 上文件可能仍被占用，忽略删除错误
            }
          }
        }
      }

      // 重新初始化以创建新的日志文件
      await initialize();
    } catch (e) {
      // 忽略错误
    }
  }

  /// 获取日志目录
  Future<Directory?> getLogDir() async {
    try {
      return await _getLogDirectory();
    } catch (e) {
      debugPrint('AppLogger Error: Failed to get log directory: $e');
    }
    return null;
  }

  /// 列出所有日志文件
  Future<List<File>> listLogFiles() async {
    try {
      final dir = await _getLogDirectory();
      if (dir.existsSync()) {
        final files = dir.listSync();
        return files
            .whereType<File>()
            .where(
              (f) =>
                  f.path.contains(Constants.logFilePrefix) &&
                  (f.path.endsWith('.log') || f.path.endsWith('.txt')),
            )
            .toList()
          ..sort(
            (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
          ); // 最新优先
      }
    } catch (e) {
      // 忽略错误
    }
    return [];
  }

  /// 执行日志清理（基于大小和天数）
  Future<void> cleanupLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final maxMB = prefs.getInt('log_max_size') ?? Constants.defaultMaxLogSize;      final autoClear = prefs.getBool('log_auto_clear') ?? true;
      final retentionDays = prefs.getInt('log_retention_days') ?? 7;

      final files = await listLogFiles();
      final now = DateTime.now();

      for (final file in files) {
        // 1. 基于天数的清理
        if (autoClear) {
          final lastModified = file.lastModifiedSync();
          if (now.difference(lastModified).inDays > retentionDays) {
            // 如果是当前正在使用的日志文件，跳过或截断
            if (file.path == _logFilePath) {
              await _checkAndCleanLogFile(file);
            } else {
              await file.delete();
            }
            continue;
          }
        }

        // 2. 基于大小的清理
        final stat = file.statSync();
        if (stat.size > maxMB * 1024 * 1024) {
          await _checkAndCleanLogFile(file);
        }
      }
    } catch (e) {
      debugPrint('AppLogger Error: Cleanup failed: $e');
    }
  }

  /// 设置最大日志大小
  ///
  /// 设置日志文件的最大大小，超过此大小会自动清理部分内容。
  ///
  /// @param maxSizeMB 最大日志文件大小，单位为MB
  /// @return 无返回值
  Future<void> setMaxLogSize(int maxSizeMB) async {
    try {
      if (_logFilePath == null) await initialize();
      final file = File(_logFilePath!);
      if (file.existsSync()) {
        final maxSize = maxSizeMB * 1024 * 1024; // MB to bytes
        final stat = await file.stat();
        if (stat.size > maxSize) {
          await _checkAndCleanLogFile(file);
        }
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 输出DEBUG级别的日志
  ///
  /// 输出调试级别的日志，通常用于开发和调试过程中的详细信息。
  ///
  /// @param message 日志消息内容
  /// @param error 可选的错误对象
  /// @param stackTrace 可选的堆栈跟踪信息
  /// @return 无返回值
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 输出INFO级别的日志
  ///
  /// 输出信息级别的日志，通常用于记录应用程序的正常运行状态和重要事件。
  ///
  /// @param message 日志消息内容
  /// @param error 可选的错误对象
  /// @param stackTrace 可选的堆栈跟踪信息
  /// @return 无返回值
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 输出WARNING级别的日志
  ///
  /// 输出警告级别的日志，通常用于记录可能导致问题但不会立即影响应用程序运行的情况。
  ///
  /// @param message 日志消息内容
  /// @param error 可选的错误对象
  /// @param stackTrace 可选的堆栈跟踪信息
  /// @return 无返回值
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 输出ERROR级别的日志
  ///
  /// 输出错误级别的日志，通常用于记录应用程序中的错误和异常情况。
  ///
  /// @param message 日志消息内容
  /// @param error 可选的错误对象
  /// @param stackTrace 可选的堆栈跟踪信息
  /// @return 无返回值
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

/// 全局日志实例，方便使用
final logger = AppLogger();

/// 文件输出类
///
/// 负责将日志输出到文件，支持文件创建、写入和管理。
class AppFileOutput extends LogOutput {
  final File file;
  final bool overrideExisting;
  final FileMode mode;
  IOSink? _sink;

  AppFileOutput({
    required this.file,
    this.overrideExisting = false,
    this.mode = FileMode.write,
  });

  /// 初始化文件输出
  ///
  /// 打开文件写入流，准备日志输出。
  ///
  /// @return 无返回值
  @override
  Future<void> init() async {
    if (_sink != null) return;
    try {
      if (overrideExisting) {
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
      file.createSync(recursive: true);
      _sink = file.openWrite(mode: mode);
    } catch (e) {
      // 使用调试输出，避免在生产代码中使用print
      debugPrint('AppFileOutput Error: Failed to init sink: $e');
    }
  }

  /// 输出日志到文件
  ///
  /// 将日志事件的每一行写入到文件中。
  ///
  /// @param event 日志输出事件，包含要输出的日志行
  /// @return 无返回值
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      _sink?.writeln(line);
    }
  }

  /// 销毁文件输出
  ///
  /// 关闭文件写入流，释放资源。
  ///
  /// @return 无返回值
  @override
  Future<void> destroy() async {
    await _sink?.close();
  }
}

/// 多输出类
///
/// 支持将日志输出到多个目标，如同时输出到控制台和文件。
class AppMultiOutput extends LogOutput {
  final List<LogOutput> outputs;

  AppMultiOutput(this.outputs);

  /// 初始化多个输出
  ///
  /// 初始化所有子输出目标。
  ///
  /// @return 无返回值
  @override
  Future<void> init() async {
    for (var output in outputs) {
      await output.init();
    }
  }

  /// 输出日志到多个目标
  ///
  /// 将日志事件输出到所有子输出目标。
  ///
  /// @param event 日志输出事件，包含要输出的日志行
  /// @return 无返回值
  @override
  void output(OutputEvent event) {
    for (var output in outputs) {
      output.output(event);
    }
  }

  /// 销毁多个输出
  ///
  /// 销毁所有子输出目标，释放资源。
  ///
  /// @return 无返回值
  @override
  Future<void> destroy() async {
    for (var output in outputs) {
      await output.destroy();
    }
  }
}

/// 自定义控制台输出，支持噪音过滤
class FilteredConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      if (!AppLogger.isNoise(line)) {
        // 使用 debugPrint 而不是 print，以便进一步被拦截
        debugPrint(line);
      }
    }
  }
}
