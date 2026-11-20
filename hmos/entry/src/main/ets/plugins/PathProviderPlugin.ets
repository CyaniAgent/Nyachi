// SPDX-License-Identifier: AGPL-3.0-or-later
//
// PathProviderPlugin — bridges path_provider to HarmonyOS file system.
// Maps Flutter's path_provider API to HarmonyOS sandbox directories.

import { FlutterPlugin, FlutterPluginBinding, MethodChannel, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { Context } from '@kit.AbilityKit';

const CHANNEL_NAME = 'plugins.flutter.io/path_provider';

export class PathProviderPlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;
  private context: Context | null = null;

  getUniqueClassName(): string {
    return 'PathProviderPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.context = binding.getApplicationContext() as Context;
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this.handleMethodCall.bind(this));
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
    this.context = null;
  }

  private async handleMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      switch (call.method) {
        case 'getApplicationDocumentsDirectory':
          result.success(this.getApplicationDocumentsPath());
          break;
        case 'getApplicationSupportDirectory':
          result.success(this.getApplicationSupportPath());
          break;
        case 'getTemporaryDirectory':
          result.success(this.getTemporaryPath());
          break;
        case 'getDownloadsDirectory':
          result.success(this.getDownloadsPath());
          break;
        default:
          result.notImplemented();
      }
    } catch (error) {
      result.error('PATH_PROVIDER_ERROR', error?.toString() ?? 'Unknown error', null);
    }
  }

  // HarmonyOS sandbox directory mappings:
  // - ApplicationDocuments → context.filesDir
  // - ApplicationSupport → context.filesDir + '/support'
  // - Temporary → context.cacheDir
  // - Downloads → context.filesDir + '/downloads' (HarmonyOS has no public Downloads)

  private getApplicationDocumentsPath(): string {
    if (!this.context) throw new Error('Context not available');
    return this.context.filesDir;
  }

  private getApplicationSupportPath(): string {
    if (!this.context) throw new Error('Context not available');
    return `${this.context.filesDir}/support`;
  }

  private getTemporaryPath(): string {
    if (!this.context) throw new Error('Context not available');
    return this.context.cacheDir;
  }

  private getDownloadsPath(): string {
    if (!this.context) throw new Error('Context not available');
    // HarmonyOS does not expose a public Downloads directory to apps.
    // Use app sandbox as fallback, consistent with image_saver_io.dart behavior.
    return `${this.context.filesDir}/downloads`;
  }
}