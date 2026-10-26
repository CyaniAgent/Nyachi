// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/network/client_provider.dart';
import '../../../core/storage/storage_providers.dart';
import '../data/note_repository.dart';
import '../domain/note_repository.dart';

part 'note_providers.g.dart';

@Riverpod(keepAlive: true)
NoteRepository noteRepository(Ref ref) {
  final active = ref.watch(sessionControllerProvider).active;
  if (active == null) throw StateError('No active account.');
  return MisskeyNoteRepository(
    client: ref.watch(misskeyClientProvider),
    cache: ref.watch(cacheDaoProvider),
    accountId: active.id,
  );
}
