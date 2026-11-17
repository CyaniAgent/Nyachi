// SPDX-License-Identifier: AGPL-3.0-or-later
//
// ImageSaverPlugin — bridges image saving to HarmonyOS file system.
// Downloads image bytes and saves to the app's sandbox or user's
// Pictures directory using HarmonyOS PhotoAccessHelper.

import { FlutterPlugin, MethodChannel, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo as fs } from '@kit.CoreFileKit';

const CHANNEL_NAME = 'com.nyachi/image_saver';

export class ImageSaverPlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;

  getName(): string {
    return 'ImageSaverPlugin';
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
        case 'saveImage':
          result.success(await this.saveImage(
            call.argument('bytes') as Uint8Array,
            call.argument('fileName') as string
          ));
          break;
        default:
          result.notImplemented();
      }
    } catch (error) {
      result.error('IMAGE_SAVER_ERROR', error?.toString() ?? 'Unknown error', null);
    }
  }

  private async saveImage(bytes: Uint8Array, fileName: string): Promise<string> {
    // TODO: Implement image saving using HarmonyOS PhotoAccessHelper
    // 1. Create a photo asset via photoAccessHelper
    // 2. Write bytes to the asset's file descriptor
    // 3. Return the asset URI
    //
    // Alternative: save to app sandbox if photo library access is not available
    // const context = getContext(this);
    // const filePath = `${context.filesDir}/${fileName}`;
    // const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
    // fs.writeSync(file.fd, bytes.buffer);
    // fs.closeSync(file);
    // return filePath;
    return '';
  }
}