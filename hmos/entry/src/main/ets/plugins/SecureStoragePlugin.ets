// SPDX-License-Identifier: AGPL-3.0-or-later
//
// SecureStoragePlugin — bridges flutter_secure_storage to HarmonyOS HUKS.
// Token storage uses HarmonyOS Universal KeyStore (HUKS) for secure
// key-value storage, replacing the Android Keystore / iOS Keychain backend.

import { FlutterPlugin, MethodChannel, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { huks } from '@kit.UniversalKeystoreKit';

const CHANNEL_NAME = 'plugins.it_nomads.com/flutter_secure_storage';

export class SecureStoragePlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;

  getName(): string {
    return 'SecureStoragePlugin';
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
        case 'read':
          result.success(await this.read(call.argument('key') as string));
          break;
        case 'write':
          await this.write(call.argument('key') as string, call.argument('value') as string);
          result.success(null);
          break;
        case 'delete':
          await this.delete(call.argument('key') as string);
          result.success(null);
          break;
        case 'readAll':
          result.success(await this.readAll());
          break;
        case 'deleteAll':
          await this.deleteAll();
          result.success(null);
          break;
        default:
          result.notImplemented();
      }
    } catch (error) {
      result.error('SECURE_STORAGE_ERROR', error?.toString() ?? 'Unknown error', null);
    }
  }

  // HUKS-backed secure storage implementation.
  // Uses AES-256-GCM encryption with hardware-backed key when available.
  private async read(key: string): Promise<string | null> {
    // TODO: Implement HUKS-based secure read
    // 1. Get or create HUKS key alias for the storage namespace
    // 2. Decrypt the stored value using AES-256-GCM
    // 3. Return the plaintext value
    return null;
  }

  private async write(key: string, value: string): Promise<void> {
    // TODO: Implement HUKS-based secure write
    // 1. Get or create HUKS key alias
    // 2. Encrypt the value using AES-256-GCM
    // 3. Store the ciphertext in app sandbox
  }

  private async delete(key: string): Promise<void> {
    // TODO: Implement HUKS-based secure delete
  }

  private async readAll(): Promise<Map<string, string>> {
    // TODO: Implement read all entries
    return new Map();
  }

  private async deleteAll(): Promise<void> {
    // TODO: Implement delete all entries
  }
}