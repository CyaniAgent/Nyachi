// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/network/error_mapper.dart';
import 'package:nyachi/features/notes/application/note_list_controller.dart';
import 'package:nyachi/features/notes/data/note_feed_repository.dart';
import 'package:nyachi/features/notes/domain/note_feed_source.dart';

import '../../support/fixtures.dart';

class _FakeRepository implements NoteFeedRepository {
  _FakeRepository({required this.cached});

  final List<Note> cached;
  Future<NotePage> Function(String? untilId)? fetch;
  var writes = 0;

  @override
  Future<NotePage> fetchPage(NoteFeedSource source, {String? untilId}) {
    return fetch!(untilId);
  }

  @override
  Future<List<Note>> readCache(NoteFeedSource source) async => cached;

  @override
  Future<void> writeCache(NoteFeedSource source, List<Note> notes) async {
    writes++;
  }
}

void main() {
  final source = NoteFeedSource.home(HomeFeedKind.home);

  test(
    'hydrates cache, refreshes, falls back offline, paginates, and dedupes',
    () async {
      final cached = [makeNote('cached-1'), makeNote('cached-2')];
      final repository = _FakeRepository(cached: cached);
      final firstPage = Completer<NotePage>();
      repository.fetch = (_) => firstPage.future;
      final container = ProviderContainer(
        overrides: [
          noteFeedRepositoryProvider.overrideWith((ref, arg) => repository),
        ],
      );
      addTearDown(container.dispose);

      final provider = noteListControllerProvider(source);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      container.read(provider);
      await pumpEventQueue();
      var state = container.read(provider);
      expect(state.items.map((n) => n.id), ['cached-1', 'cached-2']);
      expect(state.usingCache, isTrue);

      final page = [for (var i = 0; i < 20; i++) makeNote('fresh-$i')];
      firstPage.complete(NotePage(items: page, hasMore: true));
      await pumpEventQueue();
      state = container.read(provider);
      expect(state.items, hasLength(20));
      expect(state.usingCache, isFalse);

      repository.fetch = (_) async => throw Exception('offline');
      await container.read(provider.notifier).refresh();
      state = container.read(provider);
      expect(state.items, hasLength(20));
      expect(state.usingCache, isTrue);
      expect(state.error?.kind, AppFailureKind.unknown);

      var requestedCursor = '';
      repository.fetch = (untilId) async {
        requestedCursor = untilId ?? '';
        return NotePage(
          items: [makeNote('fresh-19'), makeNote('older-1')],
          hasMore: false,
        );
      };
      await container.read(provider.notifier).loadMore();
      state = container.read(provider);
      expect(requestedCursor, 'fresh-19');
      expect(state.items.map((n) => n.id), contains('older-1'));
      expect(state.items.where((n) => n.id == 'fresh-19'), hasLength(1));

      final before = state.items.length;
      container.read(provider.notifier).insertLiveNote(makeNote('fresh-0'));
      expect(container.read(provider).items, hasLength(before));
    },
  );
}
