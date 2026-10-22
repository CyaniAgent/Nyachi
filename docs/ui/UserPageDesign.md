# 用户页面重构设计文档 (User Page Redesign Blueprint)

> 基于用户蓝图 + Misskey API 架构 + 现有代码分析

---

## 1. 蓝图总览

用户页面采用**左右分栏 + 标签页**的经典社交网络布局：

```
┌─────────────────────────────────────────────────────────────────┐
│  ← (返回)                                          ··· (更多)    │
──────────────┬──────────────────────────────────────────────────┤
│              │  概览  帖子  文件  活动  成就  回应  便签  列表    │
│  背景图片    │  页面  Play  相册  原始数据                        │
│  {bannerUrl} │                                                  │
│              │  ┌────────────────────────────────────────────  │
│  ┌────┐      │  │                                            │  │
│  │头像│  昵称 │  │          相应显示的页面内容                   │  │
│  │    │  @{用户名}@{相关实例}  [关注]                          │  │
│  └────┘      │  │                                            │  │
│  {角色标签}  │  │                                            │  │
│  (头像挂件)  │  │                                            │  │
│              │  │                                            │  │
│  {个人简介}  │  │                                            │  │
│              │  │                                            │  │
│  注册时间:   │  │                                            │  │
│  年/月/日 时:分:秒                                            │  │
│  (距离现在的时间差)                                           │  │
│              │  └────────────────────────────────────────────┘  │
│  发帖数  关注中  关注者                                         │
└──────────────┴──────────────────────────────────────────────────┘
```

---

## 2. 左侧信息面板 (User Info Panel)

### 2.1 背景图片 (Banner)
- **数据源**: `user.bannerUrl`
- **行为**: 全屏宽度展示，支持 Hero 动画过渡
- **降级**: 无 banner 时显示渐变色背景 (primaryContainer → primary)
- **高度**: 窄屏 200px / 宽屏 (>900px) 350px

### 2.2 头像区域
- **数据源**: `user.avatarUrl`
- **头像挂件**: 同时展示头像挂件（Misskey 自定义装饰）
- **Hero 动画**: 头像与列表页之间支持 Hero 过渡
- **边框**: 3px 圆形边框 + 阴影，颜色跟随主题 surface

### 2.3 用户基本信息
| 元素 | 数据源 | 说明 |
|------|--------|------|
| 昵称 | `user.name ?? user.username` | 优先显示昵称，无则显示用户名 |
| 用户名 | `@{username}@{host}` | 联邦实例用户显示 `@user@instance.host` |
| 角色标签 | `user.badgeRoles[]` | 药丸形标签，显示角色名称 |
| 关注按钮 | 动态状态 | 未关注 → "关注" / 已关注 → "已关注" / 自己 → 隐藏 |

### 2.4 个人简介
- **数据源**: `user.description`
- **渲染**: 使用 MFM 渲染器 (支持 emoji、链接、mention 等)
- **位置**: 头像下方

### 2.5 注册时间
- **数据源**: `user.createdAt`
- **格式**: `年/月/日 时:分:秒`
- **辅助信息**: 显示距离现在的时间差（如 "3年前"）

### 2.6 统计数据
| 指标 | 数据源 | 行为 |
|------|--------|------|
| 发帖数 | `user.notesCount` | 点击可查看用户帖子列表 |
| 关注中 | `user.followingCount` | 点击可查看关注列表 |
| 关注者 | `user.followersCount` | 点击可查看粉丝列表 |

---

## 3. 标签页系统 (Tab System)

蓝图定义了 **12 个标签页**，每个标签页对应不同的内容区域：

### Tab 1: 概览 (Overview)
**内容**: 用户信息的综合概览
- 个人简介 (MFM 渲染)
- 附加信息字段 (`user.fields[]`)
- 位置 (`user.location`)
- 生日 (`user.birthday`)
- 语言 (`user.lang`)
- 给关注者的消息 (`user.followedMessage`)
- 置顶帖子 (Pinned Notes) — 需要 API 支持
- 最近活动摘要

### Tab 2: 帖子 (Notes/Posts)
**内容**: 用户发布的所有帖子列表
- **API**: `users/notes` (Misskey: `/api/users/notes`)
- **功能**: 无限滚动加载、时间线视图
- **筛选**: 可筛选回复/非回复、仅媒体帖子
- **组件**: 复用 `ModernNoteCard`

### Tab 3: 文件 (Files/Drive)
**内容**: 用户上传到云盘的文件
- **API**: `drive/files` (Misskey: `/api/drive/files`)
- **参数**: `userId` 过滤指定用户的文件
- **展示**: 网格视图 / 列表视图切换
- **支持**: 图片预览、文件下载、文件信息

### Tab 4: 活动 (Activity)
**内容**: 用户的活跃动态
- 最近的点赞/反应记录
- 最近的关注/被关注动态
- 最近的帖子互动
- **API**: 组合 `notes/reactions` + 关注列表 + 时间线

### Tab 5: 成就 (Achievements)
**内容**: 用户在 Misskey 实例上获得的成就
- **API**: `users/achievements` (Misskey: `/api/users/achievements`)
- **展示**: 成就卡片列表，包含成就名称、图标、获得时间
- **注意**: 仅本地用户可见成就（联邦用户可能无数据）

### Tab 6: 回应 (Reactions)
**内容**: 用户最近收到的反应/回应
- **API**: `users/reactions` (Misskey: `/api/users/reactions`)
- **展示**: 反应列表，显示谁对哪条帖子做了什么反应
- **组件**: 反应卡片 + 帖子预览

### Tab 7: 便签 (Memos)
**内容**: 用户的便签/备忘录
- **API**: `users/memos` 或自定义端点
- **展示**: 便签列表，支持 MFM 渲染
- **注意**: 此功能取决于 Misskey 实例是否支持

### Tab 8: 列表 (Lists)
**内容**: 用户创建的公开列表
- **API**: `users/lists` (Misskey: `/api/users/lists`)
- **展示**: 列表名称 + 成员数量
- **交互**: 点击可查看列表详情和成员

### Tab 9: 页面 (Pages)
**内容**: 用户创建的 Misskey 页面
- **API**: `pages/list` (Misskey: `/api/pages/list`, 参数 `userId`)
- **展示**: 页面标题、摘要、封面图
- **交互**: 点击打开页面详情

### Tab 10: Play
**内容**: Misskey Play (小游戏/互动内容)
- **API**: `play/featured` 或用户创建的 Play 内容
- **展示**: Play 卡片列表
- **注意**: 此功能为 Misskey 特色功能

### Tab 11: 相册 (Gallery)
**内容**: 用户发布的画廊帖子
- **API**: `gallery/posts` (Misskey: `/api/gallery/posts`, 参数 `userId`)
- **展示**: 图片网格布局
- **交互**: 点击放大查看、点赞

### Tab 12: 原始数据 (Raw Data)
**内容**: 用户对象的原始 JSON 数据
- **数据源**: 完整的 `MisskeyUser` JSON 序列化
- **展示**: 语法高亮的 JSON 视图，可折叠/展开
- **用途**: 调试、开发者工具、数据导出

---

## 4. 现有代码分析

### 4.1 当前实现状态
文件: `lib/src/features/misskey/presentation/pages/misskey_user_profile_page.dart`

**已有标签页 (9个)**:
1. ✅ 信息 (Info) — 已实现，但需重构为"概览"
2. ⏳ 帖子 — `_buildComingSoon('帖子')`
3. ⏳ 文件 — `_buildComingSoon('文件')`
4. ⏳ 活动 — `_buildComingSoon('活动')`
5. ⏳ 便签 — `_buildComingSoon('便签')`
6. ⏳ 列表 — `_buildComingSoon('列表')`
7. ⏳ 页面 — `_buildComingSoon('页面')`
8. ⏳ Play — `_buildComingSoon('Play')`
9. ⏳ 图集 — `_buildComingSoon('图集')`

**缺失标签页 (3个)**:
-  成就 (Achievements)
- ❌ 回应 (Reactions)
- ❌ 原始数据 (Raw Data)

### 4.2 需要新增的 API 接口
```dart
// 需要在 MisskeyApi 中添加:
Future<List<dynamic>> getUserNotes(String userId, {int limit, String? untilId});
Future<List<dynamic>> getUserReactions(String userId, {int limit, String? untilId});
Future<List<dynamic>> getUserAchievements(String userId);
Future<List<dynamic>> getUserGalleryPosts(String userId, {int limit, String? untilId});
Future<List<dynamic>> getUserPages(String userId, {int limit});
Future<List<dynamic>> getUserLists(String userId);
Future<List<dynamic>> getUserMemos(String userId);
```

### 4.3 需要修改的 MisskeyUser 模型
```dart
// 可能需要添加的字段:
List<Note>? pinnedNotes;        // 置顶帖子
List<Achievement>? achievements; // 成就列表
```

---

## 5. 交互设计要点

### 5.1 关注按钮状态
```dart
enum FollowState {
  notFollowing,   // 未关注 → 显示"关注"
  following,      // 已关注 → 显示"已关注" (可取消)
  pending,        // 待批准 (私密账户) → 显示"请求中"
  self,           // 自己 → 隐藏按钮
}
```

### 5.2 标签页滚动行为
- 使用 `NestedScrollView` + `SliverPersistentHeader`
- 标签栏在滚动时吸顶 (pinned)
- 每个标签页独立滚动状态

### 5.3 响应式布局
- **窄屏 (<900px)**: 单列布局，头像在左，信息在右
- **宽屏 (≥900px)**: 左侧固定信息面板 (320px)，右侧标签页内容自适应

### 5.4 下拉刷新
- 每个标签页支持下拉刷新
- 刷新时显示 `CyaniLoadingIndicator`

---

## 6. 技术实现建议

### 6.1 状态管理
```dart
// 使用 Riverpod 管理用户页面状态
@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  Future<void> loadUser(String userId) async { ... }
  Future<void> loadNotes(String userId) async { ... }
  Future<void> loadFiles(String userId) async { ... }
  Future<void> loadReactions(String userId) async { ... }
  Future<void> loadAchievements(String userId) async { ... }
  Future<void> loadGallery(String userId) async { ... }
  Future<void> toggleFollow(String userId) async { ... }
}
```

### 6.2 组件拆分
```
misskey_user_profile_page.dart          # 主页面
├── widgets/
│   ├── user_banner.dart                # 背景图片组件
│   ├── user_avatar.dart                # 头像组件 (含挂件)
│   ├── user_info_header.dart           # 用户信息头部
│   ├── user_stats_bar.dart             # 统计数据栏
│   ├── user_follow_button.dart         # 关注按钮
│   ├── tabs/
│   │   ├── overview_tab.dart           # 概览标签页
│   │   ├── notes_tab.dart              # 帖子标签页
│   │   ├── files_tab.dart              # 文件标签页
│   │   ├── activity_tab.dart           # 活动标签页
│   │   ├── achievements_tab.dart       # 成就标签页
│   │   ├── reactions_tab.dart          # 回应标签页
│   │   ├── memos_tab.dart              # 便签标签页
│   │   ├── lists_tab.dart              # 列表标签页
│   │   ├── pages_tab.dart              # 页面标签页
│   │   ├── play_tab.dart               # Play 标签页
│   │   ├── gallery_tab.dart            # 相册标签页
│   │   └── raw_data_tab.dart           # 原始数据标签页
│   └── ...
```

### 6.3 性能优化
- 标签页懒加载：切换到标签页时才加载数据
- 图片缓存：使用 `CachedNetworkImage` 或自定义缓存
- 列表虚拟化：使用 `ListView.builder` 或 `SliverList`
- 数据预取：切换到相邻标签页时预取数据

---

## 7. 与 Misskey Web 的对比

| 功能 | Misskey Web | Nyachi (计划) |
|------|-------------|------------------|
| 标签页数量 | 12+ | 12 |
| 概览页 | ✅ 包含简介+字段+置顶 | ✅ 计划实现 |
| 帖子页 | ✅ 时间线视图 | ✅ 计划实现 |
| 文件页 | ✅ 网格/列表视图 | ✅ 计划实现 |
| 成就页 | ✅ 成就列表 | ✅ 计划实现 |
| 回应页 | ✅ 反应列表 | ✅ 计划实现 |
| 原始数据 | ✅ JSON 查看器 | ✅ 计划实现 |
| 响应式布局 | ✅ 自适应 | ✅ 计划实现 |

---

## 8. 实施优先级

### Phase 1: 核心功能 (P0)
- [ ] 重构左侧信息面板（按蓝图布局）
- [ ] 实现"概览"标签页（替换现有"信息"）
- [ ] 实现"帖子"标签页
- [ ] 实现关注按钮状态管理

### Phase 2: 常用功能 (P1)
- [ ] 实现"文件"标签页
- [ ] 实现"回应"标签页
- [ ] 实现"相册"标签页
- [ ] 实现"成就"标签页

### Phase 3: 扩展功能 (P2)
- [ ] 实现"活动"标签页
- [ ] 实现"便签"标签页
- [ ] 实现"列表"标签页
- [ ] 实现"页面"标签页
- [ ] 实现"Play"标签页
- [ ] 实现"原始数据"标签页

### Phase 4: 优化 (P3)
- [ ] 响应式布局优化
- [ ] 性能优化（懒加载、预取）
- [ ] 动画效果（Hero、过渡）
- [ ] 无障碍支持

---

## 9. 注意事项

1. **联邦用户限制**: 远程实例的用户可能不支持某些功能（如成就、便签）
2. **API 兼容性**: 不同 Misskey 版本 API 可能有差异，需要版本检测
3. **隐私设置**: 部分用户可能设置了隐私保护，需要处理权限不足的情况
4. **国际化**: 所有文本需要支持多语言（i18n）
5. **主题适配**: 需要适配亮色/暗色主题

---

## 10. 参考资源

- Misskey API 文档: https://misskey-hub.net/api/
- Misskey Web 源码: https://github.com/misskey-dev/misskey
- Flutter Material 3 设计规范: https://m3.material.io/

---

*文档创建时间: 2026-05-22*
*最后更新: 2026-05-22*
