# 当前项目即将归档绝版，请查看继承的项目 [Asagity-Connect](https://github.com/CyaniAgent/Asagity-Connect)。



# CyaniTalk

[**中文**](README_CN.md) | [**English**](README.md)

---

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Misskey](https://img.shields.io/badge/Misskey-97c41a?style=for-the-badge&logo=misskey&logoColor=white)
![Flarum](https://img.shields.io/badge/Flarum-E7742E?style=for-the-badge&logo=flarum&logoColor=white)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow?style=for-the-badge)

**CyaniTalk** 是一个基于 Flutter 开发的多元化跨平台社交客户端。它连接了 **Misskey**（去中心化的动态社交平台）与 **Flarum**（结构化的轻论坛），旨在为用户提供从“广场喧嚣”到“深度讨论”的统一社区体验。

CyaniTalk 采用**响应式外壳 (Responsive Shell)** 设计，能够完美适配移动端（iOS/Android）和桌面端（Windows/macOS/Linux），并提供原生级的实时流体验与高级管理工具。

---

## 🌟 核心功能

### 🎨 自适应 UI/UX
CyaniTalk 将导航逻辑与内容展示分离，在不同设备上提供符合直觉的操作体验：
*   **移动端：** 经典的 **底部导航栏 (Bottom Navigation)**，便于单手操作。
*   **桌面端：** 垂直的 **侧边导航轨 (Navigation Rail)**，利用宽屏优势，支持 Master-Detail（列表-详情）分栏浏览。
*   **统一分类：** 无缝切换 Misskey 动态、论坛讨论、网盘资源、消息通知与个人中心。

### 🪐 Misskey 集成（"动" 态层）
*   **实时流 (Real-time Streaming)：** 连接 Misskey WebSocket (`streaming`)，实现动态、通知与私信的毫秒级推送。
*   **MFM 渲染器：** 完整支持 Misskey 特色的 MFM (Misskey Flavored Markdown) 语法，包括表情、搜索、链接等元素。
*   **Misskey 网盘：** 专用的可视化界面，用于管理云端图片与文件。
*   **AiScript & API：** 支持运行基础 AiScript 交互，并内置 API 控制台。

### 💬 Flarum 集成（"静" 态层）
*   **深度讨论：** 浏览标签、讨论列表与帖子详情，提供沉浸式阅读体验。
*   **社区互动：** 支持发布新帖、回复讨论以及管理论坛身份。
*   **认证体系：** 基于 JSON:API 的无缝登录与 Token 管理。

### 🔍 统一服务
*   **全局搜索：** 实现跨 Misskey 和 Flarum 平台的统一搜索功能。
*   **通知系统：** 实现统一的通知管理系统，支持多种通知类型和多端推送。
*   **缓存管理：** 内置笔记与图片缓存管理器，提升加载速度并节省流量。
*   **音频引擎：** 集成 `audioplayers` 实现高质量的音频播放体验。

### 🛡️ 管理员与高级工具 (仅限管理员)
*   **统一控制台：** 自动检测管理员权限，解锁隐藏的管理入口。
*   **Misskey 控制面板：** 查看实例运行指标、统计数据及审核用户。
*   **Flarum 后台管理：** 基础的内容管理与板块维护。
*   **API Console：** 内置开发者调试工具，支持在 App 内直接测试 API 端点并查看高亮 JSON 响应。

---

## 🛠 技术栈

*   **框架：** [Flutter](https://flutter.dev/) (Dart)
*   **状态管理：** [Riverpod](https://riverpod.dev/) (使用 `@riverpod` 注解确保类型安全与代码生成)。
*   **网络层：**
    *   `dio` (REST API 请求)。
    *   `web_socket_channel` (Misskey 实时流)。
*   **路由管理：** `go_router` (支持桌面端的分栏路由)。
*   **音频引擎：** `audioplayers` (用于高质量音效与音频播放)。
*   **UI 组件：** `flutter_adaptive_scaffold`、基于 Material Design 3 的自定义主题系统。
*   **数据模型：** `freezed` & `json_serializable` (不可变模型与自动化序列化)。
*   **本地存储：** `flutter_secure_storage` (加密存储 Token) 与 `shared_preferences` (设置项)。

---

## 🗺️ 开发路线图

### 第一阶段：响应式骨架 ✅
- [x] 初始化 Flutter 项目。
- [x] 实现 **响应式外壳** (移动端底栏 vs 桌面端侧栏)。

### 第二阶段：认证与核心连接
- [x] 实现 **JuheAuth** (Rust 驱动)。
- [x] 实现 Misskey 的 **MiAuth** 认证流程。
- [x] 实现 Flarum 的 Token 获取与登录。
- [x] 创建统一登录管理器 (Unified Login Manager)。

### 第三阶段：实时流引擎 ✅
- [x] 建立 Misskey WebSocket 长连接。
- [x] 实现全局事件分发 (通知/新动态)。
- [x] 构建聚合的“消息” Tab。

### 第四阶段：内容与创作 🚧
- [x] **Misskey:** 时间流渲染与发帖界面。
- [x] **MFM 渲染器:** 完整语法支持。
- [x] **Flarum:** 讨论列表与帖子详情页。
- [x] **网盘:** 图片网格视图与上传功能。
- [ ] 增强型草稿箱与多媒体上传优化。

### 第五阶段：管理工具与打磨 🚧
- [x] 构建 API Console 调试器。
- [x] 实现全局搜索服务。
- [x] 集成音频引擎。
- [ ] 实现管理员路由权限保护。
- [ ] 桌面端专属优化 (快捷键、窗口管理)。

---

## 🚀 快速开始

*前提条件：已安装 Flutter SDK。*

1.  **克隆仓库：**
    ```bash
    git clone https://github.com/CyaniAgent/CyaniTalk.git
    cd CyaniTalk
    ```

2.  **安装依赖：**
    ```bash
    flutter pub get
    ```

3.  **代码生成：**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **运行应用：**
    ```bash
    # 移动端
    flutter run

    # 桌面端 (macOS/Windows/Linux)
    flutter run -d windows # 或 macos/linux
    ```
注：更改依赖后需要运行“dart run dart_pubspec_licenses:generate”以更新开源许可证文件。

---

## 🤝 贡献指南

本项目正朝着首个稳定版本迈进。非常欢迎社区贡献代码，特别是关于 UI 精致化、多语言支持以及 Flarum JSON:API 边界情况处理方面的改进！

## 📄 许可证

[AGPL-3.0 License](LICENSE)
