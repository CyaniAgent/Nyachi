# Nyachi 优化最佳实践指南

## 目录
1. [API 层优化](#api-层优化)
2. [Widget 优化](#widget-优化)
3. [状态管理优化](#状态管理优化)
4. [性能优化](#性能优化)
5. [代码风格优化](#代码风格优化)

---

## API 层优化

### 1. 使用 BaseApi 抽象类
所有 API 类都应该继承 `BaseApi`，这提供了统一的错误处理和日志记录。

**正确做法** ✓
```dart
class MyApi extends BaseApi {
  final Dio _dio;
  
  Future<MyData> fetchData() => executeApiCall(
    'MyApi.fetchData',
    () => _dio.get('/api/data'),
    (response) => MyData.fromJson(response.data),
  );
}
```

**不推荐做法** ✗
```dart
// 不要重复写 try-catch 块
Future<MyData> fetchData() async {
  try {
    final response = await _dio.get('/api/data');
    if (response.statusCode == 200) {
      return MyData.fromJson(response.data);
    }
    throw Exception('Failed');
  } catch (e) {
    // 重复的错误处理...
  }
}
```

### 2. 集中 API 配置
使用常量类集中管理 API 配置：

```dart
class ApiConstants {
  static const baseUrl = 'https://api.example.com';
  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 10);
  
  // 端点常量
  static const endpoint = '/api/notes';
}
```

### 3. 使用响应包装器
创建通用的响应包装类：

```dart
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;
  
  ApiResponse({required this.data, this.error})
    : isSuccess = error == null;
}
```

---

## Widget 优化

### 1. 使用提供的 UI 扩展
```dart
// 使用 ui_extensions.dart 中的便捷方法

// ✓ 推荐
Text('Hello').padding(EdgeInsets.all(16)).centered();

// ✗ 不推荐
Padding(
  padding: EdgeInsets.all(16),
  child: Center(
    child: Text('Hello'),
  ),
)
```

### 2. 响应式设计
```dart
// ✓ 推荐：使用 responsiveValue
Widget build(BuildContext context) {
  return context.responsiveValue(
    mobile: MobileLayout(),
    tablet: TabletLayout(),
    desktop: DesktopLayout(),
  );
}

// 或使用 ResponsiveBuilder
ResponsiveBuilder(
  builder: (context, screenType) {
    return screenType == ScreenType.mobile
      ? MobileView()
      : DesktopView();
  },
)
```

### 3. StatefulWidget 生命周期
```dart
// ✓ 推荐：使用 ConsumerStatefulWidget (Riverpod)
class MyWidget extends ConsumerStatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

// ✗ 避免：直接管理复杂的状态
```

### 4. 优化 ListViews
```dart
// ✓ 推荐：使用 ListView.builder
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemTile(item: items[index]),
)

// ✗ 不推荐：立即加载所有项
ListView(
  children: items.map((item) => ItemTile(item: item)).toList(),
)
```

---

## 状态管理优化

### 1. 使用 Riverpod 提供者
```dart
// ✓ 推荐
final userProvider = FutureProvider<User>((ref) async {
  return await api.getUser();
});

// 使用缓存
final cachedUserProvider = FutureProvider<User>((ref) async {
  return await api.getUser(); // 自动缓存
});

// ✗ 避免
// 直接在 Widget 中进行异步调用
```

### 2. 分离关注点
```dart
// ✓ 推荐：将业务逻辑分离到 Notifier
class UserNotifier extends AutoDisposeAsyncNotifier<User> {
  @override
  Future<User> build() => _fetchUser();
}

// ✗ 不推荐：在 Widget 中混合 UI 和业务逻辑
```

---

## 性能优化

### 1. 图片加载
```dart
// ✓ 推荐：使用 RetryableNetworkImage
RetryableNetworkImage(
  url: imageUrl,
  maxRetries: 3,
)

// 可以考虑未来升级到 CachedNetworkImage
```

### 2. 减少重建
```dart
// ✓ 推荐：使用 RepaintBoundary
RepaintBoundary(
  child: ExpensiveWidget(),
)

// ✓ 使用 const 构造函数
const SizedBox(width: 16, height: 16)

// 使用 key 管理列表
ListView(
  key: ValueKey(listId),
  children: items,
)
```

### 3. 内存管理
```dart
// ✓ 推荐：合理释放资源
@override
void dispose() {
  _controller.dispose();
  _streamSubscription?.cancel();
  super.dispose();
}

// ✓ 使用 FutureProvider 的自动清理
final dataProvider = FutureProvider.autoDispose<Data>((ref) async {
  return await fetchData();
});
```

---

## 代码风格优化

### 1. 使用数据转换工具
```dart
// ✓ 推荐：使用 data_conversion.dart 中的安全转换
final age = jsonData.getInt('age');
final name = jsonData.getString('name') ?? 'Unknown';

// ✗ 不推荐：不安全的类型转换
final age = jsonData['age'] as int; // 可能崩溃
```

### 2. 日志记录
```dart
// ✓ 推荐：使用 LoggerExtension
logger.apiStart('getUserInfo', params: {'id': '123'});
logger.apiSuccess('getUserInfo', result: user);
logger.apiError('getUserInfo', error);

// ✗ 不推荐：重复的日志代码
logger.info('Api: 开始登录，用户: $identification');
// ... 重复的错误处理...
```

### 3. 空值处理
```dart
// ✓ 推荐：使用 NullableHandling 扩展
value.ifNotNull((v) => print('Value: $v'));
final result = value.orElse(defaultValue);
final mapped = value.mapIfNotNull((v) => v.toUpperCase());

// ✗ 不推荐：冗长的空值检查
if (value != null) {
  print('Value: $value');
}
```

---

## 优化检查清单

### API 开发
- [ ] 所有 API 类都继承 BaseApi
- [ ] 使用 `executeApiCall()` 替代手动 try-catch
- [ ] API 常量集中在 `ApiConstants` 中
- [ ] 错误消息清晰且一致

### Widget 开发
- [ ] 使用 UI 扩展简化代码
- [ ] 实现响应式设计
- [ ] 使用 const 构造函数
- [ ] 列表使用 builder 模式

### 状态管理
- [ ] 使用 Riverpod 管理状态
- [ ] 业务逻辑在 Notifier 中
- [ ] 不要在 Widget 中混合关注点
- [ ] 合理使用缓存和自动清理

### 性能
- [ ] 使用 RepaintBoundary
- [ ] 图片加载优化
- [ ] 内存管理正确
- [ ] 列表优化（builder）

### 代码质量
- [ ] 没有不必要的重复代码
- [ ] 日志记录一致
- [ ] 类型安全的转换
- [ ] 合理的空值处理

---

## 常见错误和解决方案

### 问题 1: 过度日志记录
**症状**: 日志输出混乱，性能下降
**解决**: 使用日志级别，在 debug 模式下记录详细信息
```dart
logger.debugOnly('Detailed info'); // 仅在 debug 模式显示
logger.info('Important info');      // 总是显示
```

### 问题 2: 内存泄漏
**症状**: 应用随着时间变慢
**解决**: 在 dispose 中清理资源
```dart
@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

### 问题 3: 列表性能下降
**症状**: 长列表滚动卡顿
**解决**: 使用 builder 和 addAutomaticKeepAlives
```dart
ListView.builder(
  itemBuilder: (context, index) => Item(items[index]),
)
```

### 问题 4: 重复网络请求
**症状**: 同样的请求发送多次
**解决**: 使用 Riverpod 的缓存机制
```dart
final dataProvider = FutureProvider<Data>((ref) async {
  return await api.fetchData();
}); // 自动缓存
```

---

## 更新日志

### v1.0 (2026-02-01)
- ✓ BaseApi 基类创建
- ✓ MisskeyApi 优化 (减少 43% 代码)
- ✓ LoggerExtension 创建
- ✓ DataConversion 工具创建
- ✓ UIExtensions 创建
- ✓ 最佳实践文档创建

---

## 参考资源

- [Riverpod 官方文档](https://riverpod.dev)
- [Flutter 性能指南](https://flutter.dev/docs/perf)
- [Dart 编码风格](https://dart.dev/guides/language/effective-dart/style)
- [Clean Code 原则](https://clean-code-guide.github.io/)

---

**最后更新**: 2026年2月1日
**维护者**: Development Team
