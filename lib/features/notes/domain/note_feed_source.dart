// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_feed_source.freezed.dart';

enum HomeFeedKind { home, local, hybrid, global }

@freezed
sealed class NoteFeedSource with _$NoteFeedSource {
  const factory NoteFeedSource.home(HomeFeedKind kind) = HomeTimelineSource;
  const factory NoteFeedSource.tag(String tag) = TagFeedSource;
  const factory NoteFeedSource.user(String userId) = UserNotesSource;
  const factory NoteFeedSource.search(String query) = SearchNotesSource;
}

extension NoteFeedSourceKey on NoteFeedSource {
  String get cacheKey => switch (this) {
    HomeTimelineSource(:final kind) => switch (kind) {
      HomeFeedKind.home => 'timeline:home',
      HomeFeedKind.local => 'timeline:local',
      HomeFeedKind.hybrid => 'timeline:hybrid',
      HomeFeedKind.global => 'timeline:global',
    },
    TagFeedSource(:final tag) => 'tag:$tag',
    UserNotesSource(:final userId) => 'user-notes:$userId',
    SearchNotesSource(:final query) => 'search-notes:$query',
  };
}
