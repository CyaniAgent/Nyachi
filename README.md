# Nyachi

[**中文**](README_CN.md) | [**English**](README.md)

---

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Misskey](https://img.shields.io/badge/Misskey-97c41a?style=for-the-badge&logo=misskey&logoColor=white)
![Flarum](https://img.shields.io/badge/Flarum-E7742E?style=for-the-badge&logo=flarum&logoColor=white)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow?style=for-the-badge)

**Nyachi** is a diversified, cross-platform social client built with Flutter. It bridges the gap between **Misskey** (decentralized micro-blogging) and **Flarum** (structured community forums), offering a unified experience for both casual social interaction and deep technical discussions.

Designed with a **Responsive Shell**, Nyachi adapts seamlessly between mobile (iOS/Android) and desktop (Windows/macOS/Linux) environments, providing native-tier features like real-time streaming and advanced administrative tools.

---

## 🌟 Key Features

### 🎨 Adaptive UI/UX
Nyachi decouples the navigation logic from the content to provide an ergonomic experience on any device:
*   **Mobile:** Classic **Bottom Navigation Bar** for one-handed use.
*   **Desktop:** Vertical **Navigation Rail** for wide screens, utilizing a Master-Detail view for efficient browsing.
*   **Unified Sections:** Access Misskey, Forum, Drive, Messages, and Profile seamlessly.

### 🪐 Misskey Integration (The "Dynamic" Layer)
*   **Real-time Streaming:** Connects to the Misskey WebSocket (`streaming`) to deliver notes, notifications, and messaging instantly.
*   **MFM Renderer:** Full Markup Language For Misskey rendering support including emoji, search, links, and more syntax elements.
*   **Misskey Drive:** A dedicated visual interface for managing cloud files and images.
*   **AiScript & API:** Support for running basic AiScript interactions and an embedded API Console.

### 💬 Flarum Integration (The "Static" Layer)
*   **Structured Discussions:** Browse tags, discussions, and posts with a clean reading experience.
*   **Community interaction:** Create discussions, reply to posts, and manage your forum identity.
*   **Authentication:** Seamless JSON:API based login and token management.

### 🔍 Unified Services
*   **Global Search:** Unified search across Misskey and Flarum platforms.
*   **Notification System:** Unified management system supporting multiple notification types.
*   **Cache Management:** Integrated note and image cache management for improved performance.
*   **Audio Engine:** Audio playback powered by `audioplayers`.

### 🛡️ Admin & Power Tools (Admin Only)
*   **Unified Dashboard:** Detects admin privileges to reveal hidden control panels.
*   **Misskey Control Panel:** View instance health, stats, and moderate users.
*   **Flarum Management:** Basic moderation tools and backend management.
*   **API Console:** A built-in developer tool to test endpoints and inspect JSON responses directly within the app.

---

## 🛠 Tech Stack

*   **Framework:** [Flutter](https://flutter.dev/) (Dart)
*   **State Management:** [Riverpod](https://riverpod.dev/) (with `@riverpod` annotations for type-safety).
*   **Networking:**
    *   `dio` (REST API calls).
    *   `web_socket_channel` (Misskey Streaming).
*   **Routing:** `go_router` with support for Master-Detail views on Desktop.
*   **Audio:** `audioplayers` for high-quality audio playback.
*   **UI Components:** `flutter_adaptive_scaffold`, custom Material Design 3 theme system.
*   **Data Models:** `freezed` & `json_serializable`.
*   **Storage:** `flutter_secure_storage` for credentials, `shared_preferences` for settings.

---

## 🗺️ Development Roadmap

### Phase 1: The Responsive Foundation 🚧
- [x] Initialize Flutter project.
- [x] Implement the **Responsive Shell** (Bottom Nav vs. Nav Rail).
- [x] Create skeleton pages for the 5 main tabs.

### Phase 2: Authentication & Core Connectivity
- [x] Implement **MiAuth** flow for Misskey.
- [x] Implement Token retrieval for Flarum.
- [x] Create the Unified Login Manager.

### Phase 3: The Real-time Engine ✅
- [x] Establish WebSocket connections for Misskey.
- [x] Implement global event distribution (Notifications/New Notes).
- [x] Build the "Messages" tab aggregation.

### Phase 4: Content & Creation 🚧
- [x] **Misskey:** Timeline rendering and Posting interface.
- [x] **MFM Renderer:** Full syntax support.
- [x] **Flarum:** Discussion list and Thread view.
- [x] **Drive:** File grid view and upload functionality.
- [ ] Advanced drafting and rich media uploads.

### Phase 5: Admin Tools & Polish 🚧
- [x] Build the API Console.
- [x] Implement Global Search Service.
- [x] Audio Engine integration.
- [ ] Implement Admin-only route protection.
- [ ] Desktop-specific optimizations (keyboard shortcuts, window management).

---

## 🚀 Getting Started

*Prerequisites: Flutter SDK installed.*

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/CyaniAgent/Nyachi.git
    cd Nyachi
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Code Generation:**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the app:**
    ```bash
    # For Mobile
    flutter run

    # For Desktop (macOS/Windows/Linux)
    flutter run -d windows # or macos/linux
    ```
Note: After changing dependencies, you need to run "dart run dart_pubspec_licenses:generate" to update the open-source license file.

---

## 🤝 Contributing

This project is moving towards its first stable release. Contributions, especially regarding UI refinement and Flarum JSON:API edge cases, are welcome!

## 📄 License

[AGPL-3.0 License](LICENSE)
