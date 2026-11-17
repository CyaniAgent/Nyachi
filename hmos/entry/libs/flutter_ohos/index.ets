// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Placeholder Flutter Engine embedder for HarmonyOS.
// This file will be replaced by the actual @ohos/flutter_ohos package
// built from the flutter_flutter project:
//   https://gitcode.com/openharmony-sig/flutter_flutter
//
// The real package provides:
// - FlutterAbility: base class for Flutter entry abilities
// - FlutterView: component that hosts the Flutter rendering surface
// - FlutterEngine: manages the Dart isolate and rendering pipeline
// - FlutterPlugin / MethodChannel: platform channel infrastructure
// - FlutterPluginRegistry: plugin registration manager

export class FlutterAbility {
  // Placeholder — real implementation extends UIAbility and manages
  // FlutterEngine lifecycle (create, resume, pause, destroy).
}

@Component
export struct FlutterView {
  @Prop entryName: string = 'main';

  // Placeholder — real implementation provides a rendering surface
  // for the Flutter engine via XComponent or custom rendering.
  build() {
    Column() {
      Text('Flutter Engine (placeholder)')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}

export class FlutterEngine {
  // Placeholder — real implementation manages Dart VM, isolate,
  // and rendering pipeline.
}

export class MethodChannel {
  // Placeholder — real implementation provides platform channel
  // messaging between Dart and native code.
  setMethodCallHandler(_handler?: (call: MethodCall, result: MethodResult) => void): void {}
}

export class MethodCall {
  method: string = '';
  argument(_key: string): Object | null { return null; }
}

export class MethodResult {
  success(_result: Object | null): void {}
  error(_code: string, _message: string, _details: Object | null): void {}
  notImplemented(): void {}
}

export interface FlutterPlugin {
  getName(): string;
  onAttachedToEngine(channel: MethodChannel): void;
  onDetachedFromEngine(): void;
}

export class FlutterPluginRegistry {
  private plugins: FlutterPlugin[] = [];

  registerPlugin(plugin: FlutterPlugin): void {
    this.plugins.push(plugin);
  }
}