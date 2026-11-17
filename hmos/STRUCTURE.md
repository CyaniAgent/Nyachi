# SPDX-License-Identifier: AGPL-3.0-or-later
#
# HarmonyOS Flutter Embedder — Project Structure
#
# This directory contains the HarmonyOS (OpenHarmony) platform project
# for the Nyachi Misskey client. It is a standard DevEco Studio project
# that embeds the Flutter Engine via the @ohos/flutter_ohos package.
#
# Directory layout:
#
# hmos/
#   ├── AppScope/              # Application-level configuration
#   │   ├── app.json5          # Bundle name, version, icon, label
#   │   └── resources/         # App-level resources (strings, icons)
#   ├── entry/                 # Main entry module (HAP)
#   │   ├── build-profile.json5
#   │   ├── oh-package.json5   # Module dependencies (flutter_ohos)
#   │   ├── hvigorfile.ts      # Build script
#   │   ├── libs/
#   │   │   └── flutter_ohos/  # Flutter Engine embedder (HAR package)
#   │   └── src/main/
#   │       ├── module.json5   # Module manifest (abilities, pages)
#   │       ├── ets/
#   │       │   ├── entryability/
#   │       │   │   └── EntryAbility.ets   # Flutter entry point
#   │       │   ├── pages/
#   │       │   │   └── Index.ets          # FlutterView host page
#   │       │   └── plugins/
#   │       │       ├── PluginRegistry.ets # Plugin registration
#   │       │       ├── SecureStoragePlugin.ets  # HUKS-backed token storage
#   │       │       ├── PathProviderPlugin.ets   # FS directory mapping
#   │       │       ├── UrlLauncherPlugin.ets    # Browser URL opening
#   │       │       ├── FilePickerPlugin.ets     # File selection
#   │       │       ├── MediaKitPlugin.ets       # Video/audio playback
#   │       │       └── ImageSaverPlugin.ets     # Image saving
#   │       ├── cpp/
#   │       │   ├── CMakeLists.txt          # Native build config
#   │       │   └── native_plugin.cpp       # Native plugin bridge
#   │       └── resources/                  # Module resources
#   ├── build-profile.json5   # Project-level build config
#   ├── oh-package.json5      # Project-level package config
#   ├── hvigorfile.ts         # Project-level build script
#   └── .npmrc                # NPM registry config for ohpm
#
# Plugin adaptation mapping:
#
# | Flutter Plugin            | HarmonyOS API                    | Status |
# |---------------------------|----------------------------------|--------|
# | flutter_secure_storage    | HUKS (Universal Keystore Kit)    | Stub   |
# | path_provider             | Context.filesDir / cacheDir      | Stub   |
# | url_launcher              | WebviewController / Want         | Stub   |
# | file_picker               | PhotoViewPicker / DocumentPicker | Stub   |
# | media_kit                 | AVPlayer (Media Kit)             | Stub   |
# | image_saver (custom)      | PhotoAccessHelper                | Stub   |
# | drift (SQLite)            | relational_store / native SQLite | TODO   |
#
# Build prerequisites:
# - DevEco Studio 26.0+ with HarmonyOS SDK (API 26)
# - @ohos/flutter_ohos package (from flutter_flutter project)
# - Flutter SDK for Dart code compilation