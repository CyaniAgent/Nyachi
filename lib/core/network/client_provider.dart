// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/session_controller.dart';
import '../storage/storage_providers.dart';

part 'client_provider.g.dart';

@Riverpod(keepAlive: true)
MisskeyClient misskeyClient(Ref ref) {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) {
    throw StateError('No active account.');
  }
  final tokens = ref.watch(tokenStoreProvider);
  final client = MisskeyClient.fromHost(
    active.host,
    tokenProvider: () => tokens.read(active.id),
  );
  ref.onDispose(client.close);
  return client;
}
