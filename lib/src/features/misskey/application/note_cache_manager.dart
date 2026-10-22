import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:nyachi/src/features/misskey/domain/note.dart';
import '/src/core/core.dart';

/// 笔记缓存项
class NoteCacheItem {
  /// 笔记数据
  Note note;

  /// 缓存时间
  DateTime cachedAt;

  /// 是否已从服务器验证过
  bool isValidated;

  NoteCacheItem({
    required this.note,
    required this.cachedAt,
    this.isValidated = false,
  });

  /// 检查缓存是否过期（超过5分钟）
  bool get isExpired {
    return DateTime.now().difference(cachedAt) > const Duration(minutes: 5);
  }
}

/// 笔记缓存管理器
///
/// 负责管理笔记数据的缓存，支持后台比对和自动更新。
/// 使用混合缓存策略：内存中保留最近访问的笔记，超过限制时将旧笔记移到持久化存储。
/// 最大内存缓存 100 条笔记，持久化存储最多 1000 条笔记。
/// 支持持久化存储（文件系统），应用重启后缓存依然有效。
/// 支持按账户隔离缓存，每个账户有独立的缓存文件。
///
/// ⚠️ 写入策略：仅在应用进入后台或退出时保存，不实时写入。
class NoteCacheManager {
  /// 内存缓存存储，key为笔记ID
  final Map<String, NoteCacheItem> _cache = {};

  /// 最大内存缓存数量
  static const int _maxMemoryCacheSize = 100;

  /// 最大持久化缓存数量
  static const int _maxPersistentCacheSize = 1000;

  /// 缓存访问顺序，用于LRU淘汰
  final List<String> _accessOrder = [];

  /// 比对定时器
  Timer? _validationTimer;

  /// 最后比对时间
  DateTime _lastValidation = DateTime.now();

  /// 最小比对间隔（30秒）
  static const Duration _minValidationInterval = Duration(seconds: 30);

  /// 缓存文件
  File? _cacheFile;

  /// 缓存目录
  String? _cacheDirectoryPath;

  /// 当前账户ID
  String? _currentAccountId;

  /// 账户切换异步加载 Future，用于跟踪和错误处理
  Future<void>? _loadFuture;

  /// 已删除笔记ID黑名单（持久化，防残留）
  final Set<String> _deletedIds = {};

  /// 已删除笔记黑名单文件
  File? _deletedIdsFile;

  /// 黑名单条目 TTL
  static const Duration _deletedIdsTtl = Duration(days: 7);

  /// 获取持久化缓存文件名
  String get _cacheFileName {
    if (_currentAccountId != null && _currentAccountId!.isNotEmpty) {
      return 'note_cache_$_currentAccountId.json';
    }
    return 'note_cache_default.json';
  }

  /// 获取删除黑名单文件名
  String get _deletedIdsFileName {
    if (_currentAccountId != null && _currentAccountId!.isNotEmpty) {
      return 'deleted_ids_$_currentAccountId.json';
    }
    return 'deleted_ids_default.json';
  }

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化缓存管理器
  ///
  /// 从持久化存储加载缓存数据，并清理过期项。
  Future<void> initialize() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();
    _cacheDirectoryPath = dir.path;
    _cacheFile = File('$dir.path/$_cacheFileName');
    _deletedIdsFile = File('$dir.path/$_deletedIdsFileName');

    await _loadDeletedIds();
    await _loadFromStorage();
    _filterDeletedFromCache();
    cleanupExpiredCache();
    _isInitialized = true;
  }

  /// 设置当前账户ID
  ///
  /// 设置后，所有缓存操作将在该账户的独立缓存中进行。
  ///
  /// @param accountId 账户ID，格式为"用户ID@主机名"
  void setCurrentAccountId(String? accountId) {
    if (_currentAccountId == accountId) return;

    _currentAccountId = accountId;
    logger.debug('NoteCacheManager: Current account ID set to $accountId');

    _cache.clear();
    _accessOrder.clear();
    _deletedIds.clear();
    _cacheFile = _cacheDirectoryPath != null
        ? File('$_cacheDirectoryPath/$_cacheFileName')
        : null;
    _deletedIdsFile = _cacheDirectoryPath != null
        ? File('$_cacheDirectoryPath/$_deletedIdsFileName')
        : null;
    // 跟踪异步加载 Future，确保错误被记录
    _loadFuture = Future.wait<void>([
      _loadFromStorage(),
      _loadDeletedIds(),
    ]).catchError((e) {
      logger.warning('NoteCacheManager: Account switch load failed: $e');
      return <void>[];
    });
  }

  /// 获取当前账户ID
  String? getCurrentAccountId() {
    return _currentAccountId;
  }

  /// 获取账户切换异步加载 Future（外部可 await 确保缓存加载完成）
  Future<void>? get loadFuture => _loadFuture;

  /// 从持久化存储加载缓存
  Future<void> _loadFromStorage() async {
    if (_cacheFile == null) return;

    try {
      if (!await _cacheFile!.exists()) return;
      final cacheJson = await _cacheFile!.readAsString();

      if (cacheJson.isNotEmpty) {
        _loadCacheFromJson(cacheJson);
      }
    } catch (e) {
      logger.warning('NoteCacheManager: Failed to load cache from file: $e');
      _cache.clear();
      _accessOrder.clear();
    }
  }

  /// 从JSON加载缓存
  void _loadCacheFromJson(String cacheJson) {
    try {
      final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
      final notesData = cacheData['notes'] as Map<String, dynamic>?;
      final accessOrderData = cacheData['accessOrder'] as List<dynamic>?;

      if (notesData != null) {
        for (final entry in notesData.entries) {
          try {
            final noteJson = entry.value as Map<String, dynamic>;
            final note = Note.fromJson(noteJson);
            final cachedAt = DateTime.parse(noteJson['cachedAt'] as String);
            final isValidated = noteJson['isValidated'] as bool? ?? false;

            _cache[entry.key] = NoteCacheItem(
              note: note,
              cachedAt: cachedAt,
              isValidated: isValidated,
            );
          } catch (e) {
            continue;
          }
        }
      }

      if (accessOrderData != null) {
        _accessOrder.addAll(accessOrderData.cast<String>());
      }
    } catch (e) {
      logger.warning('NoteCacheManager: Failed to parse cache JSON: $e');
    }
  }

  /// 从持久化存储加载删除黑名单
  Future<void> _loadDeletedIds() async {
    if (_deletedIdsFile == null) return;

    try {
      if (!await _deletedIdsFile!.exists()) return;
      final content = await _deletedIdsFile!.readAsString();
      if (content.isEmpty) return;

      final data = jsonDecode(content) as Map<String, dynamic>;
      final ids = data['ids'] as List<dynamic>?;
      if (ids == null) return;

      final cutoff = DateTime.now().subtract(_deletedIdsTtl);

      for (final id in ids) {
        final entry = id as Map<String, dynamic>;
        final deletedAt = DateTime.parse(entry['deletedAt'] as String);
        if (deletedAt.isAfter(cutoff)) {
          _deletedIds.add(entry['id'] as String);
        }
      }

      logger.debug(
        'NoteCacheManager: Loaded ${_deletedIds.length} deleted note IDs',
      );
    } catch (e) {
      logger.warning('NoteCacheManager: Failed to load deleted IDs: $e');
    }
  }

  /// 从缓存中过滤掉已被删除的笔记
  void _filterDeletedFromCache() {
    if (_deletedIds.isEmpty || _cache.isEmpty) return;

    int removedCount = 0;
    for (final noteId in _deletedIds) {
      if (_cache.containsKey(noteId)) {
        _cache.remove(noteId);
        _accessOrder.remove(noteId);
        removedCount++;
      }
    }

    if (removedCount > 0) {
      logger.info(
        'NoteCacheManager: Removed $removedCount deleted notes from cache',
      );
    }
  }

  /// 将笔记ID加入删除黑名单
  void addToDeletedIds(String noteId) {
    _deletedIds.add(noteId);
  }

  /// 检查笔记ID是否在删除黑名单中
  bool isDeleted(String noteId) {
    return _deletedIds.contains(noteId);
  }

  /// 保存所有内容到持久化存储
  ///
  /// 包括缓存笔记和删除黑名单。
  Future<void> saveAllToStorage() async {
    if (_cacheFile == null) return;

    try {
      final allCacheData = <String, dynamic>{};
      final allAccessOrder = <String>[];

      final notesToSave = _accessOrder.length > _maxPersistentCacheSize
          ? _accessOrder.sublist(_accessOrder.length - _maxPersistentCacheSize)
          : _accessOrder;

      for (final noteId in notesToSave) {
        final cacheItem = _cache[noteId];
        if (cacheItem != null) {
          try {
            final noteJson = cacheItem.note.toJson();
            noteJson['cachedAt'] = cacheItem.cachedAt.toIso8601String();
            noteJson['isValidated'] = cacheItem.isValidated;
            allCacheData[noteId] = noteJson;
            allAccessOrder.add(noteId);
          } catch (e) {
            continue;
          }
        }
      }

      final allCacheJson = {
        'notes': allCacheData,
        'accessOrder': allAccessOrder,
      };

      await _cacheFile!.parent.create();
      await _cacheFile!.writeAsString(jsonEncode(allCacheJson));

      logger.debug(
        'NoteCacheManager: Saved ${allCacheData.length} notes to file',
      );

      await _saveDeletedIds();
    } catch (e) {
      logger.warning(
        'NoteCacheManager: Failed to save all notes to file: $e',
      );
    }
  }

  /// 保存删除黑名单到文件
  Future<void> _saveDeletedIds() async {
    if (_deletedIdsFile == null || _deletedIds.isEmpty) return;

    try {
      final now = DateTime.now();
      final entries = _deletedIds
          .map((id) => {'id': id, 'deletedAt': now.toIso8601String()})
          .toList();

      final data = {
        'ids': entries,
        'savedAt': now.toIso8601String(),
      };

      await _deletedIdsFile!.parent.create();
      await _deletedIdsFile!.writeAsString(jsonEncode(data));
    } catch (e) {
      logger.warning('NoteCacheManager: Failed to save deleted IDs: $e');
    }
  }

  /// 获取缓存中的笔记
  Note? getNote(String noteId) {
    final cacheItem = _cache[noteId];
    if (cacheItem == null) return null;

    _updateAccessOrder(noteId);
    return cacheItem.note;
  }

  /// 获取缓存中的所有笔记（仅内存缓存）
  List<Note> getAllNotes() {
    final notes = <Note>[];
    final startIndex = _accessOrder.length > _maxMemoryCacheSize
        ? _accessOrder.length - _maxMemoryCacheSize
        : 0;
    final notesToKeep = _accessOrder.sublist(startIndex);

    for (final noteId in notesToKeep) {
      final note = getNote(noteId);
      if (note != null) {
        notes.add(note);
      }
    }

    // 按创建时间倒序排列（最新的在前）
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  /// 从持久化存储加载笔记
  Future<List<Note>> loadNotesFromPersistentStorage() async {
    if (_cacheFile == null) return [];

    try {
      if (!await _cacheFile!.exists()) return [];
      final cacheJson = await _cacheFile!.readAsString();
      if (cacheJson.isEmpty) return [];

      final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
      final notesData = cacheData['notes'] as Map<String, dynamic>?;
      final accessOrderData = cacheData['accessOrder'] as List<dynamic>?;

      if (notesData == null) return [];

      final notes = <Note>[];

      if (accessOrderData != null && accessOrderData.isNotEmpty) {
        for (final noteId in accessOrderData.cast<String>()) {
          final noteJson = notesData[noteId] as Map<String, dynamic>?;
          if (noteJson != null) {
            try {
              final note = Note.fromJson(noteJson);
              notes.add(note);
            } catch (e) {
              continue;
            }
          }
        }
      }

      // 按创建时间倒序排列（最新的在前）
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes;
    } catch (e) {
      logger.warning(
        'NoteCacheManager: Failed to load notes from persistent storage: $e',
      );
      return [];
    }
  }

  /// 获取缓存中的笔记（按ID列表）
  List<Note> getNotesByIds(List<String> noteIds) {
    final notes = <Note>[];
    for (final noteId in noteIds) {
      final note = getNote(noteId);
      if (note != null) {
        notes.add(note);
      }
    }
    return notes;
  }

  /// 添加或更新笔记缓存
  void putNote(Note note) {
    final noteId = note.id;

    if (_cache.containsKey(noteId)) {
      _cache[noteId]!.note = note;
      _cache[noteId]!.cachedAt = DateTime.now();
    } else {
      if (_cache.length >= _maxMemoryCacheSize + _maxPersistentCacheSize) {
        _evictLRU();
      }
      _cache[noteId] = NoteCacheItem(note: note, cachedAt: DateTime.now());
    }

    _updateAccessOrder(noteId);
  }

  /// 批量添加笔记到缓存
  void putNotes(List<Note> notes) {
    for (final note in notes) {
      final noteId = note.id;

      if (_cache.containsKey(noteId)) {
        _cache[noteId]!.note = note;
        _cache[noteId]!.cachedAt = DateTime.now();
      } else {
        if (_cache.length >= _maxMemoryCacheSize + _maxPersistentCacheSize) {
          _evictLRU();
        }
        _cache[noteId] = NoteCacheItem(note: note, cachedAt: DateTime.now());
      }

      _updateAccessOrder(noteId);
    }
  }

  /// 从缓存中移除笔记
  void removeNote(String noteId) {
    _cache.remove(noteId);
    _accessOrder.remove(noteId);
  }

  /// 仅保留指定 ID 集合中的缓存笔记，移除其余所有条目
  ///
  /// 用于在获取最新时间线数据后，清除已被服务器删除的残留缓存。
  void retainOnly(Set<String> noteIds) {
    final toRemove = _cache.keys.where((id) => !noteIds.contains(id)).toList();
    for (final id in toRemove) {
      _cache.remove(id);
      _accessOrder.remove(id);
    }
  }

  /// 将不在指定活跃集合中的缓存笔记标记为未验证并过期
  ///
  /// 用于在获取最新时间线数据后，标记那些未出现在返回结果中的笔记，
  /// 让后续的 `_validateAllCachedNotes` 能捕获并验证它们（遇到 404 即删除）。
  void invalidateAbsentNotes(Set<String> activeIds) {
    for (final entry in _cache.entries) {
      if (!activeIds.contains(entry.key)) {
        entry.value.isValidated = false;
        entry.value.cachedAt =
            DateTime.now().subtract(const Duration(minutes: 10));
      }
    }
  }

  /// 清空所有缓存
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  /// 获取缓存大小
  int get size => _cache.length;

  /// 检查笔记是否在缓存中
  bool hasNote(String noteId) {
    return _cache.containsKey(noteId);
  }

  /// 获取需要验证的笔记列表
  List<String> getNotesToValidate() {
    final notesToValidate = <String>[];

    for (final entry in _cache.entries) {
      final cacheItem = entry.value;

      if (!cacheItem.isValidated || cacheItem.isExpired) {
        notesToValidate.add(entry.key);
      }
    }

    return notesToValidate;
  }

  /// 标记笔记为已验证
  void markAsValidated(String noteId) {
    final cacheItem = _cache[noteId];
    if (cacheItem != null) {
      cacheItem.isValidated = true;
      cacheItem.cachedAt = DateTime.now();
    }
  }

  /// 批量标记笔记为已验证
  void markAsValidatedBatch(List<String> noteIds) {
    for (final noteId in noteIds) {
      markAsValidated(noteId);
    }
  }

  /// 更新访问顺序（LRU）
  void _updateAccessOrder(String noteId) {
    _accessOrder.remove(noteId);
    _accessOrder.add(noteId);
  }

  /// 淘汰最近最少使用的缓存项
  void _evictLRU() {
    if (_accessOrder.isEmpty) return;

    for (int i = 0; i < _accessOrder.length; i++) {
      final noteId = _accessOrder[i];
      final cacheItem = _cache[noteId];

      if (cacheItem != null && cacheItem.isExpired) {
        _accessOrder.removeAt(i);
        _cache.remove(noteId);
        logger.debug('NoteCacheManager: Evicted expired note: $noteId');
        return;
      }
    }

    final lruNoteId = _accessOrder.removeAt(0);
    _cache.remove(lruNoteId);
    logger.debug('NoteCacheManager: Evicted LRU note: $lruNoteId');
  }

  /// 启动后台比对定时器
  void startValidationTimer(
    Future<void> Function(List<String> noteIds) validationCallback,
  ) {
    _validationTimer?.cancel();
    _validationTimer = Timer.periodic(const Duration(seconds: 60), (_) async {
      await _performValidation(validationCallback);
    });
  }

  /// 停止后台比对定时器
  void stopValidationTimer() {
    _validationTimer?.cancel();
    _validationTimer = null;
  }

  /// 执行比对操作
  Future<void> _performValidation(
    Future<void> Function(List<String> noteIds) validationCallback,
  ) async {
    final now = DateTime.now();
    final timeSinceLastValidation = now.difference(_lastValidation);

    if (timeSinceLastValidation < _minValidationInterval) return;

    _lastValidation = now;

    final notesToValidate = getNotesToValidate();
    if (notesToValidate.isEmpty) return;

    try {
      await validationCallback(notesToValidate);
    } catch (e) {
      rethrow;
    }
  }

  /// 清理过期缓存
  void cleanupExpiredCache() {
    final expiredNoteIds = <String>[];

    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredNoteIds.add(entry.key);
      }
    }

    for (final noteId in expiredNoteIds) {
      removeNote(noteId);
    }

    if (expiredNoteIds.isNotEmpty) {
      logger.debug(
        'NoteCacheManager: Cleaned up ${expiredNoteIds.length} expired notes',
      );
    }
  }

  /// 启动时清理过期项
  void cleanupStartup() {
    cleanupExpiredCache();
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    final validatedCount = _cache.values
        .where((item) => item.isValidated)
        .length;
    final expiredCount = _cache.values.where((item) => item.isExpired).length;

    return {
      'total': _cache.length,
      'validated': validatedCount,
      'expired': expiredCount,
      'unvalidated': _cache.length - validatedCount,
    };
  }
}
