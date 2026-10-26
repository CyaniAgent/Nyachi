// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/error_mapper.dart';
import '../data/note_feed_repository.dart';
import '../domain/note_feed_repository.dart';
import '../domain/note_feed_source.dart';

part 'note_list_controller.freezed.dart';
part 'note_list_controller.g.dart';

@freezed
abstract class NoteListState with _$NoteListState {
  const factory NoteListState({
    @Default([]) List<Note> items,
    @Default(true) bool initialLoading,
    @Default(false) bool refreshing,
    @Default(false) bool loadingMore,
    @Default(true) bool hasMore,
    AppFailure? error,
    @Default(false) bool usingCache,
  }) = _NoteListState;
}

@riverpod
class NoteListController extends _$NoteListController {
  late NoteFeedSource _source;
  late NoteFeedRepository _repository;
  var _disposed = false;
  var _epoch = 0;

  static const _networkTimeout = Duration(seconds: 15);

  Future<NotePage> _fetchPage(NoteFeedSource source, {String? untilId}) async {
    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await _repository
            .fetchPage(source, untilId: untilId)
            .timeout(_networkTimeout);
      } catch (error) {
        lastError = error;
        if (attempt == 0) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      }
    }
    throw lastError!;
  }

  @override
  NoteListState build(NoteFeedSource source) {
    _source = source;
    _disposed = false;
    _epoch++;
    ref.onDispose(() => _disposed = true);
    _repository = ref.watch(noteFeedRepositoryProvider(source));
    final epoch = _epoch;
    unawaited(Future<void>.microtask(() => _hydrate(epoch)));
    return const NoteListState();
  }

  Future<void> _hydrate(int epoch) async {
    final cached = await _repository.readCache(_source);
    if (_disposed || epoch != _epoch) return;
    if (cached.isNotEmpty) {
      state = state.copyWith(
        items: cached,
        initialLoading: false,
        usingCache: true,
      );
    }
    await _refresh(epoch);
  }

  Future<void> refresh() => _refresh(_epoch);

  Future<void> _refresh(int epoch) async {
    if (_disposed || epoch != _epoch) return;
    final hadItems = state.items.isNotEmpty;
    state = state.copyWith(
      refreshing: true,
      initialLoading: state.initialLoading && !hadItems,
      error: null,
    );
    try {
      final page = await _fetchPage(_source);
      if (_disposed || epoch != _epoch) return;
      final deduped = _dedupe(page.items);
      state = state.copyWith(
        items: deduped,
        initialLoading: false,
        refreshing: false,
        hasMore: page.hasMore,
        usingCache: false,
        error: null,
      );
      await _repository.writeCache(_source, deduped);
    } catch (error) {
      if (_disposed || epoch != _epoch) return;
      state = state.copyWith(
        initialLoading: false,
        refreshing: false,
        usingCache: hadItems || state.usingCache,
        error: mapFailure(error),
      );
    }
  }

  Future<void> loadMore() async {
    if (_disposed ||
        state.loadingMore ||
        state.refreshing ||
        !state.hasMore ||
        state.items.isEmpty) {
      return;
    }
    final epoch = _epoch;
    state = state.copyWith(loadingMore: true, error: null);
    try {
      final page = await _fetchPage(_source, untilId: state.items.last.id);
      if (_disposed || epoch != _epoch) return;
      final merged = _dedupe([...state.items, ...page.items]);
      state = state.copyWith(
        items: merged,
        loadingMore: false,
        hasMore: page.hasMore,
        error: null,
      );
      await _repository.writeCache(_source, merged);
    } catch (error) {
      if (_disposed || epoch != _epoch) return;
      state = state.copyWith(loadingMore: false, error: mapFailure(error));
    }
  }

  void insertLiveNote(Note note) {
    if (_disposed || state.items.any((item) => item.id == note.id)) return;
    final items = [...state.items, note]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = state.copyWith(items: items, usingCache: false);
    unawaited(_repository.writeCache(_source, items));
  }

  List<Note> _dedupe(List<Note> notes) {
    final seen = <String>{};
    return notes.where((note) => seen.add(note.id)).toList(growable: false);
  }
}
