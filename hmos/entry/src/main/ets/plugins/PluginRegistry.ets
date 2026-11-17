// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Flutter Plugin Registry for HarmonyOS
// Registers all platform channel plugins that bridge Flutter Dart code
// to HarmonyOS native APIs.

import { FlutterPluginRegistry } from '@ohos/flutter_ohos';
import { SecureStoragePlugin } from '../plugins/SecureStoragePlugin';
import { PathProviderPlugin } from '../plugins/PathProviderPlugin';
import { UrlLauncherPlugin } from '../plugins/UrlLauncherPlugin';
import { FilePickerPlugin } from '../plugins/FilePickerPlugin';
import { MediaKitPlugin } from '../plugins/MediaKitPlugin';
import { ImageSaverPlugin } from '../plugins/ImageSaverPlugin';

export class NyachiPluginRegistry {
  static register(registry: FlutterPluginRegistry): void {
    // Core platform plugins adapted for HarmonyOS
    registry.registerPlugin(new SecureStoragePlugin());
    registry.registerPlugin(new PathProviderPlugin());
    registry.registerPlugin(new UrlLauncherPlugin());
    registry.registerPlugin(new FilePickerPlugin());
    registry.registerPlugin(new MediaKitPlugin());
    registry.registerPlugin(new ImageSaverPlugin());
  }
}