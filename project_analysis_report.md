# Nyachi 项目分析报告

> 生成日期: 2026-06-30
> SDK: Flutter 3.44.3
> 扫描范围: `lib/src/` 下所有 `.dart` 文件

---

## 一、MD3 (Material Design 3) 合规性分析

### 1.1 硬编码颜色使用（不通过 colorScheme）

#### 1.1.1 设置页颜色常量（应抽取为共享常量）

| 文件                              | 行号    | 问题                                                  |
| --------------------------------- | ------- | ----------------------------------------------------- |
| `sound_settings_page.dart`        | 320-330 | 11 个硬编码颜色常量 (`_blue`, `_green`, `_orange` 等) |
| `settings_page.dart`              | 55-65   | 12 个硬编码颜色常量                                   |
| `notification_settings_page.dart` | 14-15   | 2 个颜色常量                                          |
| `network_settings_page.dart`      | 21-23   | 3 个颜色常量                                          |
| `log_settings_page.dart`          | 86-88   | 3 个颜色常量                                          |
| `developer_settings_page.dart`    | 23-24   | 2 个颜色常量                                          |
| `cache_settings_page.dart`        | 47-55   | 9 个颜色常量                                          |
| `appearance_page.dart`            | 235-236 | 2 个颜色常量                                          |

> **建议**: 抽取到 `core/theme/` 下的共享常量文件，统一管理。

#### 1.1.2 装饰性硬编码颜色（应使用 colorScheme 角色颜色）

| 文件                    | 行号    | 硬编码值                                | 建议替代                                             |
| ----------------------- | ------- | --------------------------------------- | ---------------------------------------------------- |
| `appearance_page.dart`  | 296     | `const Color(0xFF42A5F5)`               | `colorScheme.primary`                                |
| `about_page.dart`       | 328     | `const Color(0xFF42A5F5)`               | `colorScheme.primary`                                |
| `about_page.dart`       | 335     | `const Color(0xFFEC407A)`               | `colorScheme.error` 或 `colorScheme.tertiary`        |
| `misskey_page.dart`     | 294-296 | 可见性指示器颜色 (绿/蓝/橙)             | `colorScheme` 角色                                   |
| `misskey_page.dart`     | 311     | `Color(0xFF16D9C5)`                     | `colorScheme.primary`                                |
| `modern_note_card.dart` | 459     | `Color(0xFF1A1A1A) / Color(0xFFFFFFFF)` | `colorScheme.surface` / `colorScheme.inverseSurface` |
| `poll_card.dart`        | 56      | `Color(0xFF39C5BB)`                     | `colorScheme.primary`                                |

#### 1.1.3 `Colors.xxx` 直接引用（应使用 colorScheme）

| 文件                               | 行号                  | 使用的颜色                                                 |
| ---------------------------------- | --------------------- | ---------------------------------------------------------- |
| `misskey_timeline_page.dart`       | 288                   | `Colors.red`                                               |
| `welcome_page.dart`                | 773, 775, 780, 786    | `Colors.amber`                                             |
| `associated_accounts_section.dart` | 198, 199, 387         | `Colors.red`                                               |
| `network_settings_page.dart`       | 168-169               | `Colors.green`, `Colors.red`                               |
| `log_settings_page.dart`           | 134, 452-462          | `Colors.red`, `Colors.redAccent`, `Colors.orangeAccent` 等 |
| `cache_settings_page.dart`         | 429, 517              | `Colors.red`, `Colors.grey.shade300`                       |
| `appearance_page.dart`             | 278, 505-509          | `Colors.amber[800]`, 18 个 `Colors.*` 预设色               |
| `modern_note_card.dart`            | 1565-1566, 1688, 1697 | `Colors.red`, `Colors.grey`                                |
| `audio_player_widget.dart`         | 36, 149               | `Colors.red`                                               |
| `global_search_delegate.dart`      | 93                    | `Colors.green`                                             |
| `safe_mfm_widget.dart`             | 133                   | `Colors.blue`                                              |
| `attachment_card.dart`             | 177, 231, 317-327     | `Colors.green`, `Colors.black54`                           |

> **建议**: 状态/错误指示色使用 `colorScheme.error`、`colorScheme.errorContainer`；分割/次要色使用 `colorScheme.outlineVariant`、`colorScheme.surfaceContainerHighest`。

---

### 1.2 可使用 MD3 风格替代品的组件（非弃用，仅风格推荐）

以下组件均**无 deprecation warning**，但 MD3 提供了更符合设计规范的替代品：

#### 1.2.1 `Chip()` — 可考虑 `InputChip` / `FilterChip` / `ChoiceChip` / `ActionChip`

| 文件                          | 行号    | 详情                              |
| ----------------------------- | ------- | --------------------------------- |
| `user_details_view.dart`      | 239     | `Chip(label: Text(r))`            |
| `design_playground_page.dart` | 395-396 | 演示页面的 2 个 `Chip`            |
| `licenses_page.dart`          | 222     | `Chip(label: SelectableText(id))` |

#### 1.2.2 `PopupMenuButton` — 可考虑 `MenuAnchor`

| 文件                     | 行号          |
| ------------------------ | ------------- |
| `misskey_post_page.dart` | 254, 273, 307 |
| `misskey_page.dart`      | 316           |
| `cloud_page.dart`        | 968           |

#### 1.2.3 `DropdownButton` / `DropdownButtonFormField` — 可考虑 `DropdownMenu`

| 文件                      | 行号 |
| ------------------------- | ---- |
| `log_settings_page.dart`  | 195  |
| `poll_time_selector.dart` | 241  |

---

### 1.3 Card 使用 elevation 而非 MD3 surface variant 颜色

| 文件                     | 行号    | 当前                        | 建议                                                      |
| ------------------------ | ------- | --------------------------- | --------------------------------------------------------- |
| `misskey_post_page.dart` | 198-199 | `Card(elevation: 4)`        | `Card(elevation: 0, color: colorScheme.surfaceContainer)` |
| `user_details_view.dart` | 232     | `Card()` (默认 elevation 1) | `Card(elevation: 0)`                                      |
| `user_details_view.dart` | 253     | `Card()` (默认 elevation 1) | `Card(elevation: 0)`                                      |

---

### 1.4 Material widget 有 elevation 但缺少 surfaceTintColor

| 文件                       | 行号    | elevation | 问题                                                   |
| -------------------------- | ------- | --------- | ------------------------------------------------------ |
| `adaptive_sheet.dart`      | 77-78   | 8         | `Material(elevation: 8)` 无 `surfaceTintColor`         |
| `profile_page.dart`        | 456-459 | 10        | `Material(elevation: 10)` 无 `surfaceTintColor`        |
| `verification_window.dart` | 149-152 | 8         | `Material(elevation: 8)` 无 `surfaceTintColor`         |
| `chat_page.dart`           | 368-373 | 2         | `Material(elevation: 2)` 无 `surfaceTintColor`         |
| `ui_extensions.dart`       | 56      | 默认 4    | `Material(elevation: elevation)` 无 `surfaceTintColor` |

---

### 1.5 使用过时的主题 API（非 colorScheme）

| 文件                    | 行号 | 当前代码                           | 应改为                               |
| ----------------------- | ---- | ---------------------------------- | ------------------------------------ |
| `theme_extensions.dart` | 15   | `scaffoldBackgroundColor`          | `colorScheme.surface`                |
| `theme_extensions.dart` | 18   | `cardColor`                        | `colorScheme.surfaceContainer`       |
| `theme_extensions.dart` | 22   | `bodyLarge?.color ?? Colors.black` | `colorScheme.onSurface`              |
| `theme_extensions.dart` | 26   | `bodySmall?.color ?? Colors.grey`  | `colorScheme.onSurfaceVariant`       |
| `theme_extensions.dart` | 32   | `disabledColor`                    | `colorScheme.onSurface` with opacity |
| `theme_extensions.dart` | 35   | `hintColor`                        | `colorScheme.onSurfaceVariant`       |
| `cloud_page.dart`       | 814  | `primaryColor`                     | `colorScheme.primary`                |

---

### 1.6 硬编码间距不符合 MD3 4dp 网格

| 文件                            | 行号 | 当前值                        | 标准值          |
| ------------------------------- | ---- | ----------------------------- | --------------- |
| `welcome_page.dart`             | 225  | `vertical: 14`                | 12 或 16        |
| `welcome_page.dart`             | 339  | `vertical: 14`                | 12 或 16        |
| `modern_note_card.dart`         | 658  | `horizontal: 10, vertical: 6` | h: 8/12, v: 4/8 |
| `navigation_settings_page.dart` | 219  | `SizedBox(width: 2)`          | 4 (最小单位)    |

> **建议**: 引入 `SpacingTokens` 设计令牌系统（`Spacing.xs: 4`, `Spacing.sm: 8`, `Spacing.md: 16` 等），统一管理间距。

---

### 1.7 大文件（>500 行，建议拆分）

| 文件                             | 行数     | 建议                       |
| -------------------------------- | -------- | -------------------------- |
| `cloud_page.dart`                | **2178** | 强烈建议拆分，超过 2000 行 |
| `modern_note_card.dart`          | **1729** | 强烈建议拆分               |
| `design_playground_page.dart`    | **1445** | 演示页面可保留，但建议拆分 |
| `misskey_repository.dart`        | **1314** | 建议按功能拆分 Repository  |
| `welcome_page.dart`              | **1013** | 建议拆分 Stepper 各步骤    |
| `misskey_post_page.dart`         | **906**  | 建议拆分                   |
| `misskey_notifier.dart`          | **877**  | 建议按用途拆分             |
| `misskey_user_profile_page.dart` | **815**  | 建议拆分                   |

---

### 1.8 自定义组件样式不一致及水波纹问题

项目中多处使用自定义组件替代原生 Material 组件，但存在样式不到位、水波纹（Ink ripple）不一致的问题：

#### 1.8.1 `GestureDetector` 替代 `InkWell` — 无水波纹反馈

| 文件                         | 行号   | 当前实现                               | 问题                                                                                              |
| ---------------------------- | ------ | -------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `cached_misskey_avatar.dart` | 84     | `GestureDetector(onTap: widget.onTap)` | **头像点击无涟漪反馈**。`CircleAvatar` 外包裹 `GestureDetector` 完全无法产生 Material ripple 效果 |
| `media_viewer.dart`          | 71, 88 | `GestureDetector(onTap: ...)`          | 媒体浏览页关闭/导航手势 — 可接受（全屏页面关闭不需要 ripple）                                     |
| `video_viewer.dart`          | 166    | `GestureDetector(onTap: ...)`          | 视频切换控制显隐 — 可接受（控制栏切换）                                                           |

> **建议**: `cached_misskey_avatar.dart` 的 `GestureDetector` 应替换为 `InkWell` + `customBorder: CircleBorder()`，保持与其他可点击头像的 ripple 效果一致。

#### 1.8.2 自定义窗口按钮 — 无 Material 样式（桌面端特有）

| 文件                    | 行号     | 问题                                                                                                                                                                            |
| ----------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `custom_title_bar.dart` | 130, 238 | 窗口控制按钮（最小化/最大化/关闭）使用 `MouseRegion` + `GestureDetector`，无 `InkWell`，hover 变色是手动实现的。**与页面内 `CircleIconButton`（使用 InkWell）的交互反馈不一致** |
| `custom_title_bar.dart` | 217-251  | 最大化按钮也是同上模式                                                                                                                                                          |

> **说明**: 窗口控制按钮（最小化/最大化/关闭）通常确实不需要 Material ripple（桌面原生窗口控件无此设计），但最大的问题是：标题栏内的元素交互风格**与页面内元素不一致**。页面内的 `CircleIconButton` 有 `InkWell` ripple，而标题栏的窗口按钮只有 hover 变色无 ripple。

#### 1.8.3 `SettingsSwitchTile` — 自定义组件缺少 M3 Switch 样式

| 文件                    | 行号 | 问题                                                                                                                         |
| ----------------------- | ---- | ---------------------------------------------------------------------------------------------------------------------------- |
| `settings_widgets.dart` | 全局 | 自定义 `SettingsSwitchTile` 组件 — 需验证其 `Switch` 是否使用了 M3 的 `SwitchTheme`，或使用了自定义的 `CupertinoSwitch` 风格 |

#### 1.8.4 可见性指示器 — 自定义色调非 colorScheme

| 文件                | 行号    | 问题                                                                      |
| ------------------- | ------- | ------------------------------------------------------------------------- |
| `misskey_page.dart` | 294-296 | 帖子可见性指示器图标颜色硬编码（绿色/蓝色/橙色），与 `colorScheme` 不一致 |

#### 1.8.5 风格不一致总结

| 组件层级                      | 交互反馈         | 风格                      |
| ----------------------------- | ---------------- | ------------------------- |
| 页面内按钮 `CircleIconButton` | ✅ InkWell ripple | Material 风格             |
| 设置项 `SettingsTile`         | ✅ InkWell ripple | Material 风格             |
| 标题栏窗口按钮                | ❌ 仅 hover 变色  | 原生桌面风格 ← **不一致** |
| 头像点击                      | ❌ 无反馈         | 无风格 ← **不一致**       |
| AppBar 按钮                   | ❌ 各页面自行实现 | 无统一规范                |

> **根因**: 缺少统一的**组件设计规范**和**按钮体系**。当前是逐页自建组件的"野蛮生长"模式，到后期维护成本会越来越高。Desktop 和 Mobile 的交互反馈风格不一致尤为突出。

---

## 二、配色与主题生成分析

### 2.1 `SaucePalette.lightScheme()` + `MaterialTheme` — 两套代码均死代码 🔴

`SaucePalette` 定义了手写的完整亮/暗色 `ColorScheme`（[sauce_palette.dart](file:///d:/Users/li/Documents/GitHub/Nyachi/lib/src/core/theme/sauce_palette.dart#L79-L154)），`MaterialTheme` 使用了它们（[material_theme.dart](file:///d:/Users/li/Documents/GitHub/Nyachi/lib/src/core/theme/material_theme.dart#L19-L25)），但**没有任何地方调用 `MaterialTheme`**：

- `app.dart` 的 `_buildTheme` 方法（第 330-392 行）直接使用 `ColorScheme.fromSeed()` 构建配色
- `SaucePalette.lightScheme()` 和 `SaucePalette.darkScheme()` 从未被执行

→ 这意味着：**两套硬编码的亮/暗色配色方案纯属摆设**，项目实际使用的是 `ColorScheme.fromSeed` 的动态生成方案。

### 2.2 两套配色之间存在色差 🟡

`SaucePalette` 的硬编码值是以 `Color(0xff006a64)`（深青色）为基准生成的：
```dart
static const lightPrimary = Color(0xff006a64);
```

而实际运行时代码使用的是：
```dart
final seedColor = const Color(0xFF39C5BB);  // mikuGreen
```

`ColorScheme.fromSeed(seedColor: Color(0xFF39C5BB))` 生成的色值与 `SaucePalette` 硬编码的色值**完全不同**。

> **影响**: 如果有人以后想复用 `SaucePalette` 的硬编码色值，会跟实际渲染的颜色不一致。

### 2.3 `useDynamicColor` 命名误导 + secondary 硬编码风格断裂 🟡

在 [app.dart](file:///d:/Users/li/Documents/GitHub/Nyachi/lib/src/app.dart#L330-L337) 中：
```dart
colorScheme: settings.useDynamicColor
    ? ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness)
    : ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
        primary: seedColor,
        secondary: const Color(0xFF6366F1),  // ← 靛蓝色，与青色系完全不搭
      ),
```

问题有三：

1. **`useDynamicColor: false` 并非关闭动态色**——它仍然调用 `ColorScheme.fromSeed()`。真正关闭动态色应该是用固定色值的 `ColorScheme(...)` 构造函数。
2. **`secondary: Color(0xFF6366F1)`（靛蓝/紫色）与 Miku 青绿色系不搭配**。MD3 的 secondary 本应是从 seed 衍生出的互补色，硬编码为紫色会让整体调色板失去协调性。
3. 值为 `false` 时额外传了 `primary: seedColor`，这是多余的——`fromSeed` 的第一个参数 `seedColor` 已经指定了种子色。

### 2.4 Welcome 页硬编码 `SaucePalette.mikuGreen` — 不响应主题切换 🟡

[welcome_page.dart](file:///d:/Users/li/Documents/GitHub/Nyachi/lib/src/features/welcome/presentation/welcome_page.dart) 中 **19 处**使用了 `SaucePalette.mikuGreen` 硬编码颜色，而非 `Theme.of(context).colorScheme.primary`：

| 行号                         | 使用方式           |
| ---------------------------- | ------------------ |
| 80, 131                      | 导航点颜色         |
| 228, 232, 247                | 步骤选择指示器     |
| 342, 346, 352, 363           | 步骤图标           |
| 389, 406, 496                | 更多选择指示器     |
| 670, 729, 926, 962, 969, 985 | 按钮、背景色、边框 |

> **影响**: 用户在设置中更换 primary 主色后，Welcome 页的颜色**不会随之变化**，因为它绕过了 colorScheme。

### 2.5 `desktopNullAppBar` 函数 — 多余抽象 🟢

[platform_app_bar.dart](file:///d:/Users/li/Documents/GitHub/Nyachi/lib/src/shared/widgets/platform_app_bar.dart) 中定义了两个函数：
- `desktopNullAppBar(AppBar? appBar)`: 桌面端返回 null，移动端返回传入的 AppBar
- `rootAppBar(AppBar? appBar)`: 始终返回传入的 AppBar

`rootAppBar` 是一个恒等函数，不做任何处理——这种抽象没有实际价值。

---

### 2.6 Dio 异常处理 — 三处绕过中心化网络基础设施

项目中存在 **3 处直接创建 `Dio()` 实例**的代码，绕过了 `NetworkClient` 提供的中心化网络基础设施（重试拦截器、性能监控、日志、限流等）。

#### 2.6.1 `update_notifier.dart` — 每次检查更新时新建裸 Dio

| 文件                   | 行号 | 代码                                    |
| ---------------------- | ---- | --------------------------------------- |
| `update_notifier.dart` | 44   | `final response = await Dio().get(...)` |

```dart
final response = await Dio().get(
  'https://api.github.com/repos/CyaniAgent/Nyachi/releases/latest',
  // 无超时、无重试、无日志拦截器、无限流
);
```

- 每次调用 `checkForUpdate` 都 **new 一个全新的 Dio 实例**
- 无 `connectTimeout`、`receiveTimeout` — 若 GitHub API 无响应会**无限挂起**
- 无 `RetryInterceptor` — 网络闪断直接失败
- 外层有 `try-catch`（line 76），异常不会崩溃，但用户体验差（手动触发检查时才报错）

#### 2.6.2 `cache_manager.dart` — 下载文件时创建半配置 Dio

| 文件                 | 行号 | 代码                                                           |
| -------------------- | ---- | -------------------------------------------------------------- |
| `cache_manager.dart` | 493  | `final dio = Dio()..options.connectTimeout = downloadTimeout;` |

```dart
final dio = Dio()..options.connectTimeout = downloadTimeout;
dio.options.receiveTimeout = downloadTimeout;
// 配置了 SSL 绕过和超时
// 但：无重试、无日志追踪、无限流
await dio.download(url, cacheFilePath);
```

- 只设置了超时和 SSL 绕过，缺失重试机制
- 大文件下载中断后不会自动重试
- 外层有 `try-catch`（line 521），会 `throw Exception('缓存文件失败: $e')`

#### 2.6.3 `misskey_image_cache_service.dart` — 静态裸 Dio 实例

| 文件                               | 行号 | 代码                             |
| ---------------------------------- | ---- | -------------------------------- |
| `misskey_image_cache_service.dart` | 23   | `static final Dio _dio = Dio();` |

```dart
static final Dio _dio = Dio();
// 完全无配置：无超时、无重试、无限流、无 SSL 策略
final response = await _dio.get<List<int>>(imageUrl, ...);
```

- **最危险的一处**：`static` 实例完全无 `connectTimeout` / `receiveTimeout`。若图片服务器 hang 住，请求**永久挂起**，占用资源不释放
- 无重试机制：图片缓存失败不会自动重试
- 外层有 `try-catch`（line 83），失败返回 null，但内部等待永远不超时

#### 总结

| 位置                               | Dio 来源                      | 超时   | 重试 | 日志 | 限流 | 风险等级 |
| ---------------------------------- | ----------------------------- | ------ | ---- | ---- | ---- | -------- |
| `MisskeyApi._dio`                  | `NetworkClient().createDio()` | ✅      | ✅    | ✅    | ✅    | ✅ 安全   |
| `update_notifier.dart`             | `Dio()`                       | ❌      | ❌    | ❌    | ❌    | 🟡 中     |
| `cache_manager.dart`               | `Dio()`                       | ✅ 部分 | ❌    | ❌    | ❌    | 🟡 中     |
| `misskey_image_cache_service._dio` | `Dio()`                       | ❌      | ❌    | ❌    | ❌    | 🔴 高     |

> **建议**: 上述三处应改用 `NetworkClient().createDio()` 或至少设置超时。特别是 `misskey_image_cache_service` 的静态 Dio，缺少超时配置可能导致请求永不释放，长期运行下造成资源泄漏。

### 2.7 服务端异常传播链 — 异常未被上层捕获 🔴

部分 API 调用虽然在底层捕获了异常，但通过 `rethrow` 重新抛出后，**上层调用方缺少 try-catch**，导致 DioException 传播到 Widget 层造成崩溃。

#### 2.7.1 `getOnlineUsersCount` 的异常传播链

```
misskey_api.dart:639  _dio.post() → catch + rethrow
    ↓
misskey_repository.dart:708  api.getOnlineUsersCount() → catch + rethrow
    ↓
misskey_notifier.dart:819  repository.getOnlineUsersCount() → ❌ 无 try-catch
```

| 层              | 文件                      | 行号    | 行为                                                                  |
| --------------- | ------------------------- | ------- | --------------------------------------------------------------------- |
| API 层          | `misskey_api.dart`        | 648-650 | `catch (e) { logger.warning(...); rethrow; }`                         |
| Repository 层   | `misskey_repository.dart` | 709-711 | `catch (e) { logger.error(...); rethrow; }`                           |
| **Notifier 层** | `misskey_notifier.dart`   | **819** | **`return await repository.getOnlineUsersCount();` — 无 try-catch！** |

`_fetchCount()`（line 819）如果网络不可达，DioException 将直接向上冒泡。如果调用 `_fetchCount()` 的地方也没有 try-catch，就会触发 Flutter 的错误页面。

而 `refresh()` 方法（line 827）使用了 `AsyncValue.guard`，异常能被安全捕获——**同一文件内两个调用点，一个安全一个不安全**。

#### 2.7.2 `readMessagingMessage` — 空 catch 吞异常

| 文件               | 行号    | 代码                                                               |
| ------------------ | ------- | ------------------------------------------------------------------ |
| `misskey_api.dart` | 780-785 | `try { await _dio.post(...); } catch (e) { logger.warning(...); }` |

`readMessagingMessage` 捕获异常后只打了一行日志，没有任何回退行为。若此操作是关键路径（如标记已读后依赖状态变更），静默吞掉异常可能导致 UI 状态与服务器状态不一致。

#### 2.7.3 download_utils — 有重试但无异常类型区分

| 文件                  | 行号    | 说明                                                              |
| --------------------- | ------- | ----------------------------------------------------------------- |
| `download_utils.dart` | 161-176 | `_dio.download()` 在 while 循环中，内层 catch（line 179）处理重试 |

下载工具实现了重试机制（line 159: `while (retryCount <= config.maxRetries)`），但未区分异常类型。对 4xx 客户端错误也进行重试，这些错误重试多少次都会失败。

#### 总结

| 问题                                                      | 文件                        | 风险                   |
| --------------------------------------------------------- | --------------------------- | ---------------------- |
| `_fetchCount()` 未捕获 `getOnlineUsersCount` 的 `rethrow` | `misskey_notifier.dart:819` | 🔴 可能造成 Widget 崩溃 |
| `readMessagingMessage` 静默吞异常                         | `misskey_api.dart:780`      | 🟡 状态不一致           |
| `download_utils` 重试未区分 4xx vs 5xx                    | `download_utils.dart:159`   | 🟢 资源浪费             |

> **建议**: 
> - `_fetchCount()` 外包裹 try-catch，失败时返回 0
> - `readMessagingMessage` 至少应允许调用方感知失败（返回 `Future<bool>` 或抛出特定异常）
> - `download_utils` 重试循环中增加对 `DioException.response?.statusCode` 的判断，4xx 不重试

---

### 2.8 UI 层无错误处理 — API 异常在 Widget 层被吞没或裸展示 🔴

大部分页面通过 Riverpod 的 `AsyncValue` 获取数据，但 UI 层的错误处理模式普遍不足：

#### 2.8.1 模式一：`.asData?.value` — 错误被静默吞没 ❌

多处使用 `.asData?.value` 代替 `.when()`，当 API 失败时**页面会显示为空或保留旧数据**，用户完全感知不到出错。

| 文件                | 行号  | 代码                                                 |
| ------------------- | ----- | ---------------------------------------------------- |
| `profile_page.dart` | 45-47 | `ref.watch(misskeyMeProvider).asData?.value`         |
| `cloud_page.dart`   | 158   | `ref.watch(misskeyDriveProvider)` 上游使用，不直接吞 |
| `welcome_page.dart` | 2 处  | `asData?.value` 模式                                 |

**最典型**: `profile_page.dart` line 45-47：
```dart
final misskeyUser = primaryAccount?.platform == 'misskey'
    ? ref.watch(misskeyMeProvider).asData?.value  // ← 错误时 = null，不显示用户信息
    : null;
```
如果 `misskeyMeProvider` 请求失败（网络不可达），页面直接渲染无用户信息的状态，没有任何错误提示。

#### 2.8.2 模式二：`Text('Error: $err')` — 裸抛异常信息给用户 🟡

绝大多数 `.when()` 的 `error:` 分支仅展示原始错误文本：

| 文件                                       | 行号 | 错误展示                             |
| ------------------------------------------ | ---- | ------------------------------------ |
| `cloud_page.dart`                          | 258  | `Center(child: Text('Error: $err'))` |
| `associated_accounts_section.dart`         | 63   | `Center(child: Text('Error: $err'))` |
| `associated_accounts_section.dart`         | 350  | `Text('Error: $err')`                |
| `settings/network_settings_page.dart`      | —    | 同上模式                             |
| `settings/notification_settings_page.dart` | —    | 同上模式                             |
| `settings/developer_settings_page.dart`    | —    | 同上模式                             |

问题是：
- `DioException` 的 `toString()` 包含 `type`、`message`、`stackTrace` 等技术细节，**用户看到的是** `"DioException [connectionTimeout]: connection timed out"` 这类信息
- 没有 i18n 中文化
- 大多数错误状态**没有重试按钮**

#### 2.8.3 例外：时间线页面有完整的错误 UX ✅

`misskey_timeline_page.dart` line 276-308 的 `_buildErrorState`：

```dart
Widget _buildErrorState(Object err) {
  return Center(
    child: Column(
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        Text('Error: $err'),
        ElevatedButton(
          onPressed: () => ref.read(...).refresh(),
          child: Text('common_reload'.tr()),
        ),
      ],
    ),
  );
}
```

虽然是唯一一个有重试按钮的页面，但**错误信息仍然裸显示了 DioException 原文**，没有中文化或包装。

#### 2.8.4 profile_page.dart — 多层数据依赖无错误传播

`profile_page.dart` 的核心数据流：
```
selectedMisskeyAccountProvider
    ↓ .asData?.value   ← 错误吞没
primaryAccount
    ↓
misskeyMeProvider
    ↓ .asData?.value   ← 错误吞没
misskeyUser
```

上游 `selectedMisskeyAccountProvider` 失败 → `primaryAccount` = null → `misskeyUser` = null → **页面显示"未登录"状态**。用户原本已登录，却看到"请登录"，完全无法分辨是网络问题还是真的未登录。

#### 总结

| 问题                               | 影响页面数           | 严重程度                        |
| ---------------------------------- | -------------------- | ------------------------------- |
| `.asData?.value` 静默吞错误        | 4+ 页                | 🔴 用户完全看不到错误            |
| `Text('Error: $err')` 裸抛异常信息 | 8+ 页                | 🟡 无 i18n、无重试、技术信息暴露 |
| 多层数据依赖无错误传播             | 1 处（profile_page） | 🔴 状态误判                      |
| 错误状态无重试按钮                 | 几乎所有页面         | 🟡 用户只能强行返回              |

> **建议**:
> 1. 所有 `.asData?.value` 替换为 `.when()` 或至少使用 `error` 回调展示提示
> 2. 封装一个通用 `ErrorWidget` 组件，包含错误图标 + i18n 消息 + 可选的 `onRetry` 回调，统一所有页面的错误展示
> 3. `profile_page.dart` 增加数据依赖状态，当 login 成功但 user 加载失败时，显示"数据加载失败"而非"未登录"
> 4. 避免在单个 widget build 中嵌套多个 `.when()`（如 cloud_page 的 3 层 driveState.when）

### 2.9 UI 层整体不一致性 — 页面结构、组件、交互缺乏统一规范 🔴

项目中 40+ 个页面在 widget 类型、导航栏、loading、空状态、按钮、刷新机制等方面存在显著不一致。

#### 2.9.1 页面 Widget 类型混乱

| 类别                     | 使用的页面                                                                               | 问题                                                          |
| ------------------------ | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| `ConsumerStatefulWidget` | 大多数页面                                                                               | 标准做法 ✅                                                    |
| `StatefulWidget`         | `MisskeyFollowRequestsPage`, `MisskeyExplorePage`, `MisskeyAntennasPage`, `SettingsPage` | ❌ **无法直接使用 Riverpod `ref`**，需通过外层 `Consumer` 迂回 |
| `ConsumerWidget`         | `MisskeyNotificationsPage`, `SoundSettingsPage`, `NotificationSettingsPage`              | 可接受（无本地状态）                                          |
| `StatelessWidget`        | `SponsorPage`, `DesignPlaygroundPage`, `AccountsPage`                                    | 可接受（纯展示）                                              |

`MisskeyFollowRequestsPage` 等使用 `StatefulWidget` 而非 `ConsumerStatefulWidget` 是一个明显的架构不一致——同一模块（misskey）的其他功能页面都在用 Riverpod。

#### 2.9.2 导航栏结构三种模式

| 模式                                   | 使用页面                                                | 说明          |
| -------------------------------------- | ------------------------------------------------------- | ------------- |
| **A: Scaffold + AppBar**               | 大多数设置页、消息页云盘页                              | 标准 ✅        |
| **B: CustomScrollView + SliverAppBar** | `ProfilePage`, `AccountsPage`, `MisskeyUserProfilePage` | 可折叠 AppBar |
| **C: NestedScrollView + SliverAppBar** | `MisskeyPage`（唯一）                                   | 内部 Tab 切换 |

关键问题：`surfaceTintColor` 只有 `MisskeyPage`（line 139）设为 `Colors.transparent`，**其他所有页面的 AppBar/SliverAppBar 都没有设置**。M3 默认会在滚动后给 AppBar 叠加 `surfaceTint` 色，导致：
- `ProfilePage` / `AccountsPage` → 滚动后 AppBar 变色
- `MisskeyPage` → 滚动后 AppBar 保持透明
- **同 App 内用户体验不一致**

#### 2.9.3 Empty State 三套并行方案

| 方案                               | 实现                                               | 使用页面                                                             |
| ---------------------------------- | -------------------------------------------------- | -------------------------------------------------------------------- |
| A: 共享 `LoginReminder`            | `shared/widgets/login_reminder.dart`               | `CloudPage`, `ForumPage`                                             |
| B: 本地 `ProfileLoginReminder`     | `features/profile/.../profile_login_reminder.dart` | `ProfilePage`                                                        |
| C: 内联 `Center(child: Text(...))` | 散落在各页面                                       | `MisskeyClipNotesPage`, `MisskeyChannelDetailsPage`, `SearchPage` 等 |

**差异核心**: 方案 A 是共享可配置组件（可设 title/message/icon），方案 B 是硬编码 UI 内容的本地副本——**功能重复**。方案 C 则是每次手写。

#### 2.9.4 按钮样式混用 M2/M3

项目主体已使用 M3 按钮（`FilledButton`、`OutlinedButton`、`TextButton`），但仍有 4 处使用 M2 的 `ElevatedButton`：

| 文件                              | 行号 |
| --------------------------------- | ---- |
| `misskey_timeline_page.dart`      | 292  |
| `misskey_notifications_page.dart` | 96   |
| `misskey_clip_notes_page.dart`    | 150  |
| `retryable_network_image.dart`    | 306  |

#### 2.9.5 `RefreshIndicator` 缺失

数据列表类页面中，以下页面缺少下拉刷新：

| 页面                     | 缺失的影响                    |
| ------------------------ | ----------------------------- |
| `MisskeyUserProfilePage` | 用户信息+帖子列表不可下拉刷新 |
| `ChatPage`               | 消息不可刷新                  |
| `SearchPage`             | 搜索结果不可刷新              |

而同类的 `MisskeyTimelinePage`、`MisskeyChannelsPage`、`MisskeyNotificationsPage` 等都有 `RefreshIndicator`。

#### 2.9.6 BottomSheet 全部使用自定义实现

项目**完全未使用** `showModalBottomSheet`，所有底部弹出都通过 `showDialog` + `DraggableScrollableSheet` 实现。导致：
- 丢失 M3 BottomSheet 的原生安全区域适配
- 丢失手势拖拽关闭行为
- 丢失 M3 的 `surfaceTintColor` 支持

#### 2.9.7 `showAdaptiveSheet` — 桌面端使用 `showGeneralDialog` 弹出诡异侧边栏 🔴

最特殊的是 `AddAccountBottomSheet`（登录/添加账户弹窗），它通过 `showAdaptiveSheet()`（[adaptive_sheet.dart](file:///d:/Users/li/Documents/GitHub/Nyachi/lib/src/shared/widgets/adaptive_sheet.dart)） 弹出：

```dart
// mobile  → showModalBottomSheet (正常)
// desktop → showGeneralDialog (诡异)
```

桌面端的实现路径：
```
AddAccountBottomSheet.show()
  → showAdaptiveSheet()
    → _showSideSheet()
      → showGeneralDialog(pageBuilder: ...)
```

`showGeneralDialog` 是一个**极低层的通用对话框 API**，通常用于自定义 alert dialog。用它来实现侧边栏导致的后果：

| 问题                    | 代码                                                     | 影响                                          |
| ----------------------- | -------------------------------------------------------- | --------------------------------------------- |
| **全屏遮罩**            | `barrierColor: Colors.black.withAlpha(0.32)`             | 整个桌面屏幕变暗，像 modal 对话框而非侧边面板 |
| **右侧空出大片空白**    | `Align(alignment: Alignment.centerRight)` + `width: 400` | 400dp 宽的侧边栏 + 遮罩 + 左侧空白            |
| **桌面端显示拖拽条**    | `_SideSheetHandle`（line 86）                            | 桌面鼠标操作不需要触摸拖拽指示器              |
| **无 surfaceTintColor** | `Material(elevation: 8)`（line 78）                      | M3 有 elevation 无 tint                       |
| **布局硬编码圆角**      | `BorderRadius.horizontal(left: Radius.circular(20))`     | 仅在左侧有圆角，和 M3 标准的圆角矩形不一致    |

与 `showDialog` + `DraggableScrollableSheet` 模式不同——至少那些还保持全屏遮罩+居中弹窗的语义。`showGeneralDialog` 做侧边栏既不是 dialog 也不是 sheet，是个"四不像"。

> **建议**: 
> - 桌面端改用 `showDialog` + 自定义 layout（居中弹窗或侧面板），不要用 `showGeneralDialog` 拼凑
> - 或直接对桌面端用独立 page/route 代替弹窗

#### 2.9.8 间距不一致

设置页列表 padding 使用的是 `EdgeInsets.only(top: 8, bottom: 32)`，而弹窗/卡片内 padding 使用 12/16/20/24 不等，缺乏统一的间距令牌系统。

#### 总结

| 问题                          | 影响范围          | 严重程度               |
| ----------------------------- | ----------------- | ---------------------- |
| `surfaceTintColor` 未统一设置 | 所有 AppBar 页面  | 🔴 滚动后颜色变化不一致 |
| Empty State 三套并行          | 多个页面          | 🔴 重复代码、差异体验   |
| `StatefulWidget` 无 `ref`     | 3 个 misskey 页面 | 🟡 无法直连 Riverpod    |
| `ElevatedButton` M2 残留      | 4 处              | 🟡 风格不统一           |
| `RefreshIndicator` 缺失       | 3 个数据页面      | 🟡 功能缺失             |
| `showModalBottomSheet` 未使用 | 全局              | 🟢 交互方式受限         |
| 间距值不统一                  | 全局              | 🟢 无设计令牌系统       |

> **建议**:
> 1. 在 `app.dart` 或全局主题中统一设置 `AppBarTheme(surfaceTintColor: Colors.transparent)`，一劳永逸
> 2. 删除 `ProfileLoginReminder`，统一使用共享的 `LoginReminder`
> 3. 将 3 个 `StatefulWidget` 页面改为 `ConsumerStatefulWidget`
> 4. 将 4 处 `ElevatedButton` 替换为 `FilledButton`
> 5. 为 `MisskeyUserProfilePage` 等添加 `RefreshIndicator`

### 2.10 依赖包使用不足 — 自行实现替代可用包

#### 2.10.1 `flutter_adaptive_scaffold` 是死依赖 🔴

`pubspec.yaml` line 51 声明了 `flutter_adaptive_scaffold: ^0.3.3+1`，并有 TODO 注释表示它已弃用需替换（line 50）。但更重要的是——**整个 `lib/` 下没有任何代码 `import` 这个包**。它是一个**完全的僵尸依赖**，占空间但不执行任何功能。

同时项目自建了一套自适应布局：
- `ResponsiveShell` — 自定义导航壳，管理 NavigationRail/Drawer
- `DesktopPageShell` — 另一个导航壳，设置页专用
- `RootNavigationDrawer` — 自定义抽屉导航
- 手动实现 `NavigationBar` ↔ `NavigationRail` 切换逻辑

这些手写代码**正好可以被 `adaptive_shell` 替代**。`adaptive_shell ^2.0.0` 提供：

| 功能 | 当前自定义实现 | adaptive_shell |
|------|-------------|---------------|
| NavigationBar ↔ NavigationRail 自适应切换 | `ResponsiveShell` 手动实现 | `AdaptiveShell` 自动处理 |
| Master-detail 双栏布局 | 无（需自行拼装） | `child1` + `child2` 内建 |
| 响应式断点 | 硬编码 `isDesktop` 检查 | M3 window size classes |
| 键盘快捷键 | 无 | `keyboardShortcuts: { Ctrl+1, ... }` |
| 导航栏折叠 | `NavigationRail` 不折叠 | `railCollapsible: true` |
| 上下文扩展 | 自建 `DesktopSemanticColors` | `context.isCompact`, `context.isTwoPane` 等 |
| 主题化 NavBar/Rail | 各自独立 | `AdaptiveShellTheme` 统一配置 |
| 布局变更回调 | 无 | `onLayoutModeChanged` |
| Hero 动画 | 无 | `enableHeroAnimations` |

> **建议**: 
> 1. 删除 `flutter_adaptive_scaffold` 依赖
> 2. 添加 `adaptive_shell: ^2.0.0`（用户指定 ^1.0.0+2，但最新版为 2.0.0，API 更完整）
> 3. 用 `AdaptiveShell` 替换 `ResponsiveShell` + `DesktopPageShell` + `RootNavigationDrawer`
> 4. 利用 `context.adaptivePadding()` 统一间距

#### 2.10.2 其他可考虑引入的包

| 当前自定义实现 | 替代包 | 说明 |
|-------------|--------|------|
| `showAdaptiveSheet` + `_showSideSheet` | `adaptive_shell` 或标准 `showModalBottomSheet` | 桌面端侧边栏改用 route 或原生 dialog |
| `CustomTitleBar` | `window_manager`（已有） | 已在使用，持续跟进 |
| `ErrorWidget` 缺失 | 自建复用组件 | 无现成包，建议自建共享组件 |
| `CircleIconButton` | M3 `IconButton` + 主题配置 | 如果能满足需求，优先用 M3 原生 |
| 间距无令牌系统 | `adaptive_shell` 的 `context.adaptivePadding()` | 引入后天然支持 |

> **核心原则**: 能用包的别自建，用包的参数定制而非重写组件。

## 三、编码规范分析

### 3.1 导入风格严重不一致 🔴 HIGH

项目中混用 **三种** 不同的导入风格，甚至同文件内混用：

| 风格                 | 示例                                                    | 使用文件数 |
| -------------------- | ------------------------------------------------------- | ---------- |
| **A - 相对路径**     | `import '../widgets/settings_slider_bottom_sheet.dart'` | 少量       |
| **B - 绝对 `/src/`** | `import '/src/core/utils/logger.dart'`                  | 大量       |
| **C - package**      | `import 'package:nyachi/src/...'`                    | 约 24 处   |

**严重混用示例**:
- `settings_page.dart`: 风格 A + 风格 B 混用
- `cache_settings_page.dart`: 风格 A + 风格 C 混用
- `misskey_clip_notes_page.dart` 等: 风格 C

> **建议**: 统一为一种风格。Dart 官方推荐使用 `package:` 导入，GoRouter 也推荐此方式。建议全量迁移为风格 C。

---

### 3.2 空 catch 块（吞没异常）🔴 HIGH

发现 **11 处** 完全空的 catch 块：

| 文件                               | 行号          |
| ---------------------------------- | ------------- |
| `welcome_page.dart`                | 868, 884, 887 |
| `settings_page.dart`               | 51            |
| `appearance_page.dart`             | 151           |
| `verification_window.dart`         | 126           |
| `misskey_repository.dart`          | 804, 1286     |
| `auth_service.dart`                | 294           |
| `cache_manager.dart`               | 667           |
| `misskey_image_cache_service.dart` | 185           |

> **建议**: 每个 catch 块至少应 `logger.error('message', error)`。关键路径应有回退逻辑。

---

### 3.3 接口命名使用 `I` 前缀 🟡 MEDIUM

Dart 推荐使用 `abstract interface class` 关键字而非 `I` 前缀标记接口。

| 文件                                | 行号 | 当前                                                |
| ----------------------------------- | ---- | --------------------------------------------------- |
| `misskey_repository_interface.dart` | 17   | `abstract interface class IMisskeyRepository`       |
| `streaming_service_interface.dart`  | 22   | `abstract interface class IStreamingService`        |
| `streaming_service_interface.dart`  | 34   | `abstract interface class IMisskeyStreamingService` |

> **建议**: 去掉 `I` 前缀，改为 `MisskeyRepository`、`StreamingService`、`MisskeyStreamingService`。

---

### 3.4 `dynamic` 滥用 🟡 MEDIUM

多处使用 `dynamic` 而非具体类型：

| 文件                          | 行号                 | 当前                  | 建议           |
| ----------------------------- | -------------------- | --------------------- | -------------- |
| `misskey_timeline_page.dart`  | 198                  | `List<dynamic>`       | 具体类型       |
| `user_navigation_header.dart` | 433, 447             | `dynamic misskeyUser` | 具体 User 类型 |
| `user_details_view.dart`      | 17, 68, 95, 223, 252 | `dynamic` 多处        | 具体类型       |
| `about_page.dart`             | 44                   | `List<dynamic>`       | 具体类型       |
| `messaging_page.dart`         | 233                  | `List<dynamic>`       | 具体类型       |
| `chat_page.dart`              | 17                   | `dynamic initialData` | 具体类型       |

---

### 3.5 过长参数列表 🟡 MEDIUM

`SafeMfmWidget` 参数超过 **30 个**：

```dart
// modern_note_card.dart (SafeMfmWidget)
class SafeMfmWidget extends StatefulWidget {
  final String mfmText;
  final Widget Function(...)? emojiBuilder;
  final Widget Function(...)? codeBlockBuilder;
  // ... 30+ 个参数
}
```

> **建议**: 使用 Builder 模式或配置对象（Config Object）模式重构。

---

### 3.6 缺少 `const` 构造函数 📋 LOW

| 文件                             | 行号 | 类名              | 问题                  |
| -------------------------------- | ---- | ----------------- | --------------------- |
| `misskey_user_profile_page.dart` | 791  | `_TabBarDelegate` | 缺少 `const` 构造函数 |

---

### 3.7 过度注释 📋 LOW

多处对显而易见的代码写了中文注释：

| 文件                                | 行号                                        | 注释内容                                        |
| ----------------------------------- | ------------------------------------------- | ----------------------------------------------- |
| `settings_slider_bottom_sheet.dart` | 84, 104, 124, 143, 154                      | `// 标题和图标` `// 数值显示` `// 滑块` 等      |
| `sponsor_page.dart`                 | 26, 52                                      | `// 说明内容` `// 赞助选项`                     |
| `user_details_view.dart`            | `associated_accounts_section.dart` 102, 115 | `// Section Title` `// Horizontal Account List` |

> **建议**: 文档注释应解释"为什么"而非"是什么"。去除过度注释，或提升为更有意义的描述。

---

### 3.8 使用 `debugPrint` 而非 Logger 📋 LOW

| 文件                       | 行号                   | 代码                |
| -------------------------- | ---------------------- | ------------------- |
| `cache_settings_page.dart` | 83, 126, 145, 228, 268 | `debugPrint('...')` |

> **建议**: 项目中已有 `logger` 实例，应统一使用 `logger.info` / `logger.error`。

---

### 3.9 `analysis_options.yaml` 配置简略 📋 LOW

```yaml
analyzer:
  errors:
    use_null_aware_elements: ignore
include: package:flutter_lints/flutter.yaml
linter:
  rules: {}
```

仅使用了 `flutter_lints` 默认规则集，未启用任何额外规则。

> **建议**: 考虑启用以下常用规则：
> - `always_declare_return_types`
> - `unnecessary_lambdas`
> - `prefer_const_constructors`
> - `prefer_const_declarations`
> - `sort_child_properties_last`
> - `avoid_dynamic_calls`（配合 `dynamic` 修复）

---

## 四、综合优先修复建议

### 4.1 高优先级（影响维护性和稳定性）

| 优先级 | 问题                                                                                        | 涉及文件数 | 预估工作量 |
| ------ | ------------------------------------------------------------------------------------------- | ---------- | ---------- |
| 🔴 P0   | 统一导入风格                                                                                | ~40+       | Medium     |
| 🔴 P1   | 填充空 catch 块 + 日志                                                                      | ~11 处     | Small      |
| 🔴 P2   | `_fetchCount()` 未捕获 `getOnlineUsersCount` 的 `rethrow`（可能崩溃）                       | 1 处       | Small      |
| 🔴 P3   | UI 层错误被吞没/裸展示（`.asData?.value` + `Text('Error: $err')`）                          | 12+ 页     | Medium     |
| 🔴 P4   | Dio 裸实例无超时/无重试（尤其是 `misskey_image_cache_service._dio`）                        | 3 处       | Small      |
| 🔴 P5   | 自定义组件交互反馈不一致 + 水波纹                                                           | ~8 处      | Medium     |
| 🔴 P6   | 清理死代码（`MaterialTheme`、`SaucePalette.lightScheme/darkScheme` 两套未使用的硬编码配色） | 2 个       | Small      |
| 🔴 P7   | UI 层整体不一致（surfaceTintColor、Empty State、RefreshIndicator 等）                       | 40+ 页     | Large      |
| 🔴 P8   | 大文件拆分（>1000 行）                                                                      | 5 个       | Large      |
| 🔴 P9   | SafeMfmWidget 参数重构                                                                      | 1 个       | Medium     |

### 4.2 中优先级（影响设计一致性和类型安全）

| 优先级 | 问题                                                          | 涉及文件数 | 预估工作量 |
| ------ | ------------------------------------------------------------- | ---------- | ---------- |
| 🟡 P10  | 硬编码颜色迁移至 colorScheme                                  | ~20+       | Medium     |
| 🟡 P11  | `useDynamicColor` 命名修正 + `secondary` 色值修复             | 1 个       | Small      |
| 🟡 P12  | Welcome 页 `SaucePalette.mikuGreen` → `colorScheme.primary`   | 19 处      | Medium     |
| 🟡 P13  | `dynamic` → 具体类型                                          | ~11 处     | Medium     |
| 🟡 P14  | 接口 `I` 前缀重命名                                           | 3 个       | Small      |
| 🟡 P15  | `Card`/`Material` elevation + `surfaceTintColor` 修复         | ~7 处      | Small      |
| 🟡 P16  | MD3 风格组件迁移（`Chip`/`PopupMenuButton`/`DropdownButton`） | ~10 处     | Medium     |

### 4.3 低优先级（代码整洁）

| 优先级 | 问题                                 | 预估工作量 |
| ------ | ------------------------------------ | ---------- |
| 📋 P17  | 过度注释清理                         | Small      |
| 📋 P18  | `debugPrint` → Logger                | Small      |
| 📋 P19  | 颜色常量抽取共享                     | Small      |
| 📋 P20  | `analysis_options.yaml` 增强规则     | Small      |
| 📋 P21  | `const` 构造函数补充                 | Small      |
| 📋 P22  | 间距设计令牌系统                     | Large      |
| 📋 P23  | 非4dp间距修正                        | Small      |
| 📋 P24  | 删除 `rootAppBar` 恒等函数等多余抽象 | Small      |

---

*报告完 — 39！*
