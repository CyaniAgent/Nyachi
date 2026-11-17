// SPDX-License-Identifier: AGPL-3.0-or-later
//
// MediaKitPlugin — bridges media_kit to HarmonyOS media playback.
// Uses HarmonyOS AVPlayer (audio/video) and AVCodec for media decoding.

import { FlutterPlugin, MethodChannel, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { media } from '@kit.MediaKit';

const CHANNEL_NAME = 'plugins.flutter.io/media_kit';

export class MediaKitPlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;
  private players: Map<number, media.AVPlayer> = new Map();

  getName(): string {
    return 'MediaKitPlugin';
  }

  onAttachedToEngine(channel: MethodChannel): void {
    this.channel = channel;
    this.channel.setMethodCallHandler(this.handleMethodCall.bind(this));
  }

  onDetachedFromEngine(): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
    // Release all players
    for (const player of this.players.values()) {
      player.release();
    }
    this.players.clear();
  }

  private async handleMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      switch (call.method) {
        case 'createPlayer':
          result.success(await this.createPlayer());
          break;
        case 'setSource':
          await this.setSource(call.argument('playerId') as number, call.argument('url') as string);
          result.success(null);
          break;
        case 'play':
          await this.play(call.argument('playerId') as number);
          result.success(null);
          break;
        case 'pause':
          await this.pause(call.argument('playerId') as number);
          result.success(null);
          break;
        case 'release':
          await this.releasePlayer(call.argument('playerId') as number);
          result.success(null);
          break;
        default:
          result.notImplemented();
      }
    } catch (error) {
      result.error('MEDIA_KIT_ERROR', error?.toString() ?? 'Unknown error', null);
    }
  }

  private async createPlayer(): Promise<number> {
    // TODO: Create HarmonyOS AVPlayer instance
    // const player = await media.createAVPlayer();
    // const playerId = this.nextPlayerId++;
    // this.players.set(playerId, player);
    // return playerId;
    return -1;
  }

  private async setSource(playerId: number, url: string): Promise<void> {
    // TODO: Set media source on AVPlayer
    // const player = this.players.get(playerId);
    // if (player) { player.url = url; }
  }

  private async play(playerId: number): Promise<void> {
    // TODO: Call AVPlayer.play()
  }

  private async pause(playerId: number): Promise<void> {
    // TODO: Call AVPlayer.pause()
  }

  private async releasePlayer(playerId: number): Promise<void> {
    // TODO: Call AVPlayer.release() and remove from map
  }
}