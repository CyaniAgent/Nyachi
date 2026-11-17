// SPDX-License-Identifier: AGPL-3.0-or-later
//
// UrlLauncherPlugin — bridges url_launcher to HarmonyOS Web browser.
// Opens URLs in the system browser using HarmonyOS WebviewController.

import { FlutterPlugin, MethodChannel, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { webview } from '@kit.ArkWeb';

const CHANNEL_NAME = 'plugins.flutter.io/url_launcher';

export class UrlLauncherPlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;

  getName(): string {
    return 'UrlLauncherPlugin';
  }

  onAttachedToEngine(channel: MethodChannel): void {
    this.channel = channel;
    this.channel.setMethodCallHandler(this.handleMethodCall.bind(this));
  }

  onDetachedFromEngine(): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }

  private async handleMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      switch (call.method) {
        case 'canLaunch':
          result.success(this.canLaunch(call.argument('url') as string));
          break;
        case 'launch':
          result.success(await this.launch(call.argument('url') as string));
          break;
        case 'closeWebView':
          result.success(true);
          break;
        default:
          result.notImplemented();
      }
    } catch (error) {
      result.error('URL_LAUNCHER_ERROR', error?.toString() ?? 'Unknown error', null);
    }
  }

  private canLaunch(url: string): boolean {
    // HarmonyOS can launch http/https URLs via WebviewController
    return url.startsWith('http://') || url.startsWith('https://');
  }

  private async launch(url: string): Promise<boolean> {
    // TODO: Implement URL launch using HarmonyOS WebviewController
    // or want-based approach to open system browser
    // For now, use the webview controller approach:
    // const controller = new webview.WebviewController();
    // controller.loadUrl(url);
    return true;
  }
}