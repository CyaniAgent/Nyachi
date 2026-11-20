// SPDX-License-Identifier: AGPL-3.0-or-later

import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { SecureStoragePlugin } from '../plugins/SecureStoragePlugin';
import { PathProviderPlugin } from '../plugins/PathProviderPlugin';
import { UrlLauncherPlugin } from '../plugins/UrlLauncherPlugin';
import { FilePickerPlugin } from '../plugins/FilePickerPlugin';
import { MediaKitPlugin } from '../plugins/MediaKitPlugin';
import { ImageSaverPlugin } from '../plugins/ImageSaverPlugin';

export default class EntryAbility extends FlutterAbility {
  // FlutterAbility handles:
  // - FlutterEngine initialization and lifecycle
  // - Platform channel registration
  // - Window stage creation and FlutterView setup
  // - Loading pages/Index with viewId in LocalStorage

  configureFlutterEngine(flutterEngine: FlutterEngine): void {
    // Register Nyachi platform channel plugins
    const plugins = flutterEngine.getPlugins();
    if (plugins) {
      plugins.add(new SecureStoragePlugin());
      plugins.add(new PathProviderPlugin());
      plugins.add(new UrlLauncherPlugin());
      plugins.add(new FilePickerPlugin());
      plugins.add(new MediaKitPlugin());
      plugins.add(new ImageSaverPlugin());
    }
  }
}