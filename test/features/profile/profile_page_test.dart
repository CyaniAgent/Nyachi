// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:nyachi/core/auth/session_controller.dart';
import 'package:nyachi/core/l10n/app_localizations.dart';
import 'package:nyachi/core/storage/storage_models.dart';
import 'package:nyachi/core/storage/storage_providers.dart';
import 'package:nyachi/core/ui/avatar.dart';
import 'package:nyachi/features/notes/data/note_feed_repository.dart';
import 'package:nyachi/features/notes/domain/note_feed_repository.dart';
import 'package:nyachi/features/notes/domain/note_feed_source.dart';
import 'package:nyachi/features/profile/application/profile_providers.dart';
import 'package:nyachi/features/profile/presentation/profile_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSessionController extends SessionController {
  _FakeSessionController(this.account);

  final LocalAccount account;

  @override
  SessionState build() =>
      SessionState(accounts: [account], active: account, initialized: true);
}

class _FakeFeedRepository implements NoteFeedRepository {
  @override
  Future<NotePage> fetchPage(NoteFeedSource source, {String? untilId}) async =>
      const NotePage(items: [], hasMore: false);

  @override
  Future<List<Note>> readCache(NoteFeedSource source) async => const [];

  @override
  Future<void> writeCache(NoteFeedSource source, List<Note> notes) async {}
}

UserDetailedNotMe _user({
  String? bannerUrl,
  String avatarUrl = 'https://example.test/avatar.png',
}) {
  return UserDetailedNotMe.fromJson({
    'id': 'u-target',
    'name': 'Alice',
    'username': 'alice',
    'host': null,
    'avatarUrl': avatarUrl,
    'avatarBlurhash': null,
    'avatarDecorations': const [],
    'emojis': const <String, String>{},
    'onlineStatus': 'unknown',
    'url': null,
    'uri': null,
    'movedTo': null,
    'alsoKnownAs': null,
    'createdAt': '2026-01-01T00:00:00.000Z',
    'updatedAt': null,
    'lastFetchedAt': null,
    'bannerUrl': bannerUrl,
    'bannerBlurhash': null,
    'isLocked': false,
    'isSilenced': false,
    'isSuspended': false,
    'description': null,
    'location': null,
    'birthday': null,
    'lang': null,
    'fields': const [],
    'verifiedLinks': const [],
    'followersCount': 0,
    'followingCount': 0,
    'notesCount': 0,
    'pinnedNoteIds': const [],
    'pinnedNotes': const [],
    'pinnedPageId': null,
    'pinnedPage': null,
    'publicReactions': true,
    'followingVisibility': 'public',
    'followersVisibility': 'public',
    'chatScope': 'none',
    'canChat': false,
    'roles': const [],
    'memo': null,
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required UserDetailedNotMe user,
}) async {
  final account = LocalAccount(
    id: 'account',
    host: 'example.test',
    userId: 'me',
    username: 'me',
    addedAt: DateTime(2026),
    lastUsedAt: DateTime(2026),
  );
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      sessionControllerProvider.overrideWith(
        () => _FakeSessionController(account),
      ),
      userProfileProvider('u-target')
          .overrideWith((ref) => Future<UserDetailed?>.value(user)),
      noteFeedRepositoryProvider.overrideWith(
        (ref, source) => _FakeFeedRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UserProfilePage(userId: 'u-target'),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'renders banner and fixed-size overlapping avatar when bannerUrl is set',
    (tester) async {
      const bannerUrl = 'https://example.test/banner.png';
      await _pumpPage(tester, user: _user(bannerUrl: bannerUrl));

      // Banner renders through NyachiImage (a CachedNetworkImage underneath).
      expect(
        find.byWidgetPredicate(
          (w) => w is CachedNetworkImage && w.imageUrl == bannerUrl,
        ),
        findsOneWidget,
      );
      // Full-bleed 3:1 banner.
      final aspect = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspect.aspectRatio, 3);
      final bannerBox = tester.getSize(find.byType(AspectRatio));
      expect(bannerBox.width / bannerBox.height, closeTo(3, 0.01));

      // Avatar is the fixed profile size, both in widget args and on screen.
      final avatar = tester.widget<NyachiAvatar>(find.byType(NyachiAvatar));
      expect(avatar.size, kProfileAvatarSize);
      expect(
        tester.getSize(find.byType(NyachiAvatar)),
        Size(kProfileAvatarSize, kProfileAvatarSize),
      );

      // Name and handle are present in the overlap row.
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('@alice'), findsOneWidget);
    },
  );

  testWidgets(
    'renders the neutral placeholder background when bannerUrl is null',
    (tester) async {
      await _pumpPage(tester, user: _user(bannerUrl: null));

      final context = tester.element(find.byType(UserProfilePage));
      final placeholder = Theme.of(context).colorScheme.surfaceContainerHighest;

      // No banner image request, only the avatar's own.
      expect(
        find.byWidgetPredicate(
          (w) => w is CachedNetworkImage && w.imageUrl.contains('banner'),
        ),
        findsNothing,
      );
      // Placeholder background fills the banner slot (3:1 full-bleed).
      final aspect = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspect.aspectRatio, 3);
      expect(
        find.byWidgetPredicate(
          (w) => w is ColoredBox && w.color == placeholder,
        ),
        findsAtLeastNWidgets(1),
      );
      // Avatar still renders at the fixed size.
      final avatar = tester.widget<NyachiAvatar>(find.byType(NyachiAvatar));
      expect(avatar.size, kProfileAvatarSize);
    },
  );
}
