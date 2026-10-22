# Nyachi UI/UX 审查发现清单（2026-07-17）

审查范围：lib/ 全部手写 Dart 文件（~180 个，5 个并行代理分区实读）。
统计：P0 ×2 · P1 ×24 · P2 ×55+ · P3 ×40+

---

## P0（功能完全不可用 / 死锁）

同一 bug 模式（WebView 鸡生蛋死锁）出现两处：`_isWebviewInitialized` 初始 false，body 仅在其为 true 时才构建 InAppWebView，而唯一置 true 的 `onLoadStop` 回调在 WebView 内部 → WebView 永不构建，永久 loading。

1. lib/src/core/utils/verification_window.dart:114-137 — WAF 验证窗口死锁，`barrierDismissible: false` 连关都关不掉，验证 cookie 永远拿不到。
2. lib/src/features/profile/presentation/settings/sponsor_page.dart:129,145-164 — iMikufans 赞助页永久卡 loading。

---

## P1

### A. 全局基础设施（影响全应用）
- app.dart:289-303,426-432 — 主题缓存逻辑错误：build light 主题时就写 `_cachedSettings = settings`，同帧 build dark 主题命中缓存返回旧值 → 暗色模式下修改任何外观设置不生效（直到重启）。
- app.dart:372-375 — "动态取色"开关两个分支代码完全相同，从未接入系统动态色，开关是摆设。
- app.dart:222-224 + shared/widgets/custom_title_bar.dart:50 — `TitleBarController()` 在 build 中每次重建 new 新实例 + `_TitleBarInherited.updateShouldNotify => false` → 页面 setTitle/setActions 写到废弃 controller，标题栏回退默认值。
- main.dart:49 + app.dart:220-273 — `titleBarStyle: hidden` 无条件设置；用户关闭"自定义标题栏"后无人调用 `setTitleBarStyle(normal)` → 窗口无标题栏、不可拖动、无窗口按钮。外观设置加载失败的 error 分支同样不渲染标题栏。
- routing/router.dart:102-108 — goRouter provider watch(welcomeCompletedProvider)，其任何变化重建整个 GoRouter → 导航栈/Shell 分支状态全丢、跳回 initialLocation；启动时有 loading→data 竞态。
- shared/widgets/fireworks_background.dart:40-67,385 — `shouldRepaint => true` 无 RepaintBoundary，整个欢迎页 60fps 全页重绘 + 每帧 130+ 个 MaskFilter.blur 辉光圆，CPU/GPU 持续高占用。

### B. 网络/服务层连锁失效
- core/api/network_client.dart:105-108 — `validateStatus: (s) => true` 连锁破坏三处：① misskey_api.dart 690-849 的新旧端点 try/catch 回退全部失效（旧版实例私信/群聊打不开）；② base_api.dart:243-252 的 5xx/429 重试是死代码；③ RetryInterceptor 的 502/503/504 分支永远走不到。
- core/services/navigation_service.dart:38-66 — 对 GoRouter 的 navigatorKey 调 `Navigator.pushNamed`（GoRouter 无 onGenerateRoute）必抛错被吞 → 点击系统通知永远无法跳转。
- core/api/api_request_manager.dart:53-56 — 全局单例请求去重键不含 host/token → 快速切换账号时新账号 UI 拿到旧账号数据。
- core/services/timeline_cache_database.dart:128 — 缓存 ID 固定 `default_$timelineType`，无账号隔离 → 切账号后显示上一账号时间线。
- core/utils/cache_manager.dart:392-411 — 缓存文件名只取 URL 最后 path segment 忽略 query → Misskey 代理图片（/proxy/image.webp?url=...）全部命中同一缓存文件，不同帖子串图。
- core/services/file_metadata_service.dart:96-109 — 为显示文件大小把整个文件下载一遍数字节（未用 HEAD/Content-Length），大视频附件触发整文件下载。
- core/services/database_path_helper.dart:12-23 — macOS 数据库路径硬编码 /Applications/...（不可写）→ macOS 全部缓存不可用；Android 硬编码 /data/user/0 多用户下错误。
- core/utils/logger.dart:32,109,340-357 — deleteLogs 后重新 initialize 对 `late final` 二次赋值抛错被吞 → 删除日志后文件日志静默失效；Windows 上日志文件被 IOSink 锁定删除失败。

### C. Misskey 模块
- domain/mfm_renderer.dart:684-709 — `_createLimitedMfmWidget` 忽略 maxLines/overflow 参数 → 昵称（maxLines:1）/回复预览（maxLines:3）截断全失效，超长内容撑爆卡片。
- presentation/widgets/reaction_display.dart:55-58,141 — FutureBuilder future 在 build 内联创建 → 每个 reaction chip 每次重建发一次 getNoteReactions，滚动时 API 请求风暴 + chip 闪烁。
- application/misskey_notifier.dart:49,116,434 — NoteCacheManager static 单例但 timeline notifier 是按 type 的 family → Home/Local/Global/Social 时间线数据互相串台。
- application/note_cache_manager.dart:107-108 — `'$dir.path/...'` 插值错误（应为 `${dir.path}`）→ 笔记持久化缓存读写全部静默失败。
- presentation/widgets/modern_note_card.dart:453-483,64-69 — OverlayEntry 菜单 dispose 不移除、非 Route 返回键不关 → 菜单永久残留屏幕。
- presentation/pages/misskey_channels_page.dart:119-131 + misskey_notifier.dart:603-640 — itemBuilder 内最后一项无条件 loadMore + notifier 无 hasMore 判断 → 列表到底后无限网络请求循环。
- misskey_channel_details_page.dart:154 + modern_note_card.dart:348-355 — 频道页把 channel.id 当 timelineType 传入 → 表情互动触发非法 getTimeline(channelId) 请求且频道时间线不刷新。
- application/file_upload_notifier.dart:109-130,215-229 — 本地文件上传重试永久卡"重试中"（file==null 时无操作）且 retrying 计入上传中导致永远无法发布；云盘文件重传直接硬编码"需要实现重新上传逻辑"。
- application/misskey_streaming_service.dart:106,242-249,418-419 — 断线自动重连只重订 main 频道不恢复时间线订阅、_channel==null 时静默丢弃订阅 → 重连后实时推送永久失效。
- presentation/widgets/poll_settings_sheet.dart:420-430 + misskey_post_page.dart:116-126 — "移除投票"pop 哨兵 Poll(choices:['']) 被当新投票赋值 → 投票无法移除，反而变成非法空投票可发布。

### D. 其他 feature
- messaging/presentation/chat_page.dart:41-51 — sendMessage fire-and-forget + 立即 clear 输入框 → 失败静默丢消息丢输入，无防连点。（misskey_messaging_notifier.dart:278-295 同根因）
- cloud/presentation/cloud_page.dart:595-605,1875-1887 — 下载底页可被关闭但 onProgress 继续对已 dispose 的 StatefulBuilder 调 setState；下载中"取消"按钮被禁用无法真取消。
- common/.../media/audio_viewer.dart:62-98 — await loadUrl 后无 mounted 检查即 play → 页面关闭后"幽灵播放"且 AudioSource 永不释放。
- common/.../media/video_viewer.dart:63-77 — 本地初始化失败回退网络时旧 VideoPlayerController 不 dispose，平台层播放器泄漏。

### E. Profile
- settings/appearance_page.dart:465-467 — "重置颜色"按钮实际调 resetSettings() 重置全部外观设置。
- settings/log_settings_page.dart:246,335 — TextEditingController 在 build 内联创建：泄漏 + 任何重建清掉用户正在输入的内容。
- settings/network_settings_page.dart:325-343,370-375 — "测试网络连接"/"清除 DNS 缓存"是空壳（仅 delay 后无条件报成功），误导用户。

---

## P2（分主题归组）

### 暗色模式下不可见/难看（colorScheme.surface 误用作前景色等）
- auth/login_page.dart:177-182 + login_form_components.dart:180-188 — ShaderMask modulate 下标题暗色几乎不可见
- shared/widgets/coming_soon_page.dart:43-53 — "Coming Soon" 文字用 surface 色
- common/.../image_viewer.dart:34-39 — 加载失败图标 surface 色叠黑背景
- misskey_channels_page.dart:236-237 — 频道横幅频道名 surface 色
- shared/widgets/expressive_slider.dart:428-437 — 指示气泡白字叠浅色 primary（应 onPrimary）
- app.dart:379-383 — bannerTheme 硬编码 Colors.white 写进 dark 主题
- profile appearance_page.dart:533-539 — 颜色选中态硬编码黑边框白对勾（P3 级）

### async gap 后缺 mounted 检查（setState/ref after dispose）
- profile: network_settings_page.dart:331-341、cache_settings_page.dart:223,263、settings_page.dart:42,44、about_page.dart:108
- misskey: safe_mfm_widget.dart:93-105、modern_note_card.dart:1998-2030
- shared: core/widgets/sound_picker.dart:112-120、user_navigation_header.dart:760-791
- welcome_page.dart:861,866；cloud_upload_sheet.dart:61-70（widget.ref 误用）

### 状态不刷新 / 显示错误数据
- misskey_notifier.dart:190-194（+notifications/messaging/announcements 同模式）— build() 出错先 AsyncError 又 return [] 覆盖为 AsyncData([]) → error UI 永不可达
- font_settings_notifier.dart:44,148-150 — copyWith 每次进度更新把 downloadingFontId 重置 null → 字体下载进度条立即消失
- custom_title_bar.dart:261-281 — 最大化按钮图标状态从不刷新（未监听 WindowListener）
- video_viewer.dart:239-245 — 播放时间冻结（无 addListener）；audio_viewer.dart:45-57 播放结束后无法重播
- search_page.dart:88-97 — 清除按钮不随输入出现（无 listener）
- cloud_page.dart:130-134 — 恢复前台自动刷新不触发 rebuild 基本失效
- modern_note_card.dart:80-88 — CW 展开状态列表复用时串到别的笔记
- modern_note_card.dart:891-924 — 表情选择器添加 reaction 后 UI 完全不刷新
- misskey_user_profile_page.dart:86-92 — "关注了你"徽章只查前 100 粉丝
- profile user_details_view.dart:127 — 粉丝数 null 时显示 '1'

### 布局溢出
- profile user_details_view.dart:204-222 — detail row 长值必然横向溢出
- profile profile_page.dart:581-588 — 用户统计 Row 窄屏必溢出
- about_page.dart:358-365 — 贡献者 GridView 固定 4 列底部溢出
- update_bottom_sheet.dart:33-97 — 固定 Column 小窗口必溢出且 scrollController 未接
- code_block_widget.dart:116-141 — 固定行高，字体缩放 >1 时代码被裁切
- mention_aware_text.dart:97-109 — 文本包 WidgetSpan 失去内联换行
- settings_page.dart:238-241 — 语言对话框 7 项不可滚动（P3 级）

### 交互损坏
- note_details_sheet.dart:705-715 — SelectableText 吞点击，复制功能名存实亡
- poll_card.dart:176-179,283-294 — 单选点 Radio 无法提交（提交按钮仅多选显示）
- search_page.dart:195-198 — 搜索结果点击只打日志（TODO）
- misskey_notifications_page.dart — 无滚动加载、点击无跳转、空态文案错误
- misskey_post_page.dart:785-786,254-271 — 纯附件帖静默不发布；账户菜单无 onSelected
- retryable_network_image.dart:187-198 — 重试未 evict ImageCache 基本无效
- drive_file_picker.dart:227-239 — 云盘选择器固定 limit 20 无分页
- cloud_page.dart:1297-1332 — 编辑描述不预填原值，保存即清空
- cloud_page.dart:1512-1529 — FAB 菜单 pop 后用已失效 context
- auth login_form.dart:75-77 — 主机为空静默 return 无提示；auth_service.dart:106-160 — MiAuth 轮询 30-40s 不可取消
- misskey_permissions_sheet.dart:149-151 — 相邻字符串拼接 bug 显示原始 key
- messaging_page.dart:117-138 — direct/groups 过滤下空白无空态
- chat_page.dart:216-236 — 列表非 reverse 无初始滚动到底；markAsRead 在 itemBuilder 内重复触发
- misskey_user_profile_page.dart:267-303 — NestedScrollView 无 SliverOverlapInjector，滚动不联动内容被遮挡
- misskey_notes_page.dart:78-84 — avatarUrl null 时空 URL NetworkImage 抛异常
- announcements markAsRead 失败整页变错误页（misskey_announcements_notifier.dart:66-72）
- media_viewer.dart:88-95 — 空列表点击 RangeError
- profile cache_settings_page.dart:497-523 — 饼图 tooltip 用过滤后下标索引未过滤列表，数据错位
- profile profile_page.dart:171-173 — 头像 Hero tag 重复（桌面多栏抛异常）
- root_navigation_drawer.dart:65-101 + navigation_service.dart:28-49 — 抽屉索引与分支索引体系不一致，'me' 重排后点错分支
- navigation_settings_notifier.dart:186-212 — 手写 JSON 解析按逗号 split，标题含逗号即错乱；:264 toast 乱码 '??????'
- adaptive_sheet.dart:50,76-81 — 桌面侧边栏忽略 backgroundColor/isScrollControlled，viewInsets 一次性捕获键盘遮挡
- custom_title_bar.dart:86-102 — macOS 无 DragToMoveArea 不可拖动
- user_navigation_header.dart:567 — 事件回调中 ref.watch（Riverpod 反模式）
- cloud_page.dart:1363-1364 — 右键菜单回调中 ref.watch
- animated_blob_background.dart:40-49 — 4 层 CustomPaint 每帧连带全页重绘
- mentioned_user_chip.dart:34-51 — 每个提及 chip 无缓存查询用户；正则误判邮箱/URL
- mfm_renderer.dart:207-268 — 表情加载失败无负缓存，滚动反复无效请求
- misskey_aiscript_console_page.dart:21 等 — TextEditingController 不 dispose（另 modern_note_card 554,841、cloud_page 1244,1302,1538）
- update_notifier / update_bottom_sheet / cloud_upload_sheet / media 组件 / profile 设置页 — 大面积中英硬编码与 .tr() 混用（全局横切）
- 安全：cache_manager.dart:497-504 与 misskey_streaming_service.dart:147 — badCertificateCallback => true 无条件禁用 TLS 校验
- auth_repository.dart:19,82-119 — token 明文存 SharedPreferences，secureStorage 定义了没用
- notification_manager.dart:58-125 — 只订阅一次旧流服务实例，切账号后通知失效；重复 start 叠加监听
- misskey_image_cache_database.dart:246-255 — 清理只删记录不删文件，缓存目录只增不减
- cache_manager.dart:1005-1019,509,221 — 账号目录过期缓存清不掉；硬编码 30 天无视用户设置；大小缓存 5 分钟后永久失效每次全盘扫描
- global_search_delegate.dart:70 — FutureBuilder future 每次 build 重建，重复发起搜索
- audio_engine.dart:14-20 + file_metadata_service.dart:49-51 — SoLoud 并发 init/deinit 状态不同步
- base_api/misskey_api：checkNoteExists 限流误判删除；getNote 404 把错误体当数据；api_request_manager 失败时 unhandled async exception

## P3（打磨项，按文件归组略——详见各代理原始报告要点）
- i18n：font_selector、forum_page、search_page、profile 多页、misskey 多处 中/英硬编码
- 死代码/无效逻辑：media_preloader.dart:118 恒真判断、note_details_sheet.dart:728 int.parse(aid) 恒失败、logger_extension.dart:27 参数遮蔽方法必崩、performance_monitor.dart:47 FPS 统计无意义、cloud_page.dart:160 死语句
- 空实现：login_page 服务条款/隐私政策按钮、audio_player_sheet tooltip 未包 Tooltip
- 细节：m3e_context_menu 无滚动无 Esc、Hero tag 冲突边缘场景、welcome 桌面端步骤点跳格、双击手势 300ms 延迟、菜单定位错、'Confirm'.tr() key 大小写、navigation_element id 用 DateTime.now 导致 == 永不相等、重连 toast 连弹 5 次、NetworkImage 无缓存无 errorBuilder（profile 多处）、download_utils 重命名后校验旧路径、通知 id 用 hashCode、device_info 'mi' 子串误判
