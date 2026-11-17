// SPDX-License-Identifier: AGPL-3.0-or-later
//
// FilePickerPlugin — bridges file_picker to HarmonyOS file selection.
// Uses HarmonyOS FilePicker (photoView, documentView) for file selection.

import { FlutterPlugin, MethodChannel, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { picker } from '@kit.CoreFileKit';

const CHANNEL_NAME = 'plugins.miguelruivo.com/file_picker';

export class FilePickerPlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;

  getName(): string {
    return 'FilePickerPlugin';
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
        case 'pickFiles':
          result.success(await this.pickFiles(call.argument('type') as string));
          break;
        default:
          result.notImplemented();
      }
    } catch (error) {
      result.error('FILE_PICKER_ERROR', error?.toString() ?? 'Unknown error', null);
    }
  }

  private async pickFiles(type: string): Promise<string[]> {
    // TODO: Implement using HarmonyOS picker.PhotoViewPicker or picker.DocumentViewPicker
    // For image picking:
    //   const photoViewPicker = new picker.PhotoViewPicker();
    //   const selectOptions = new picker.PhotoSelectOptions();
    //   const result = await photoViewPicker.select(selectOptions);
    // For document picking:
    //   const documentViewPicker = new picker.DocumentViewPicker();
    //   const selectOptions = new picker.DocumentSelectOptions();
    //   const result = await documentViewPicker.select(selectOptions);
    return [];
  }
}