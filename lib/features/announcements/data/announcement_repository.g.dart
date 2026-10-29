// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Announcements for the active account, cached across restarts.

@ProviderFor(announcementRepository)
final announcementRepositoryProvider = AnnouncementRepositoryProvider._();

/// Announcements for the active account, cached across restarts.

final class AnnouncementRepositoryProvider
    extends
        $FunctionalProvider<
          AnnouncementRepository,
          AnnouncementRepository,
          AnnouncementRepository
        >
    with $Provider<AnnouncementRepository> {
  /// Announcements for the active account, cached across restarts.
  AnnouncementRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnnouncementRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnnouncementRepository create(Ref ref) {
    return announcementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnnouncementRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnnouncementRepository>(value),
    );
  }
}

String _$announcementRepositoryHash() =>
    r'7b120fd5215aabb48f9a9a546371eb85edaebf60';

@ProviderFor(announcements)
final announcementsProvider = AnnouncementsProvider._();

final class AnnouncementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Announcement>>,
          List<Announcement>,
          FutureOr<List<Announcement>>
        >
    with
        $FutureModifier<List<Announcement>>,
        $FutureProvider<List<Announcement>> {
  AnnouncementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementsHash();

  @$internal
  @override
  $FutureProviderElement<List<Announcement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Announcement>> create(Ref ref) {
    return announcements(ref);
  }
}

String _$announcementsHash() => r'c163c6d255bab839d143416945f5aa860efc5219';

/// Announcement ids marked read during this session. The server's `isRead`
/// flag only updates on the next refresh, so this set hides them in between.

@ProviderFor(ReadAnnouncements)
final readAnnouncementsProvider = ReadAnnouncementsProvider._();

/// Announcement ids marked read during this session. The server's `isRead`
/// flag only updates on the next refresh, so this set hides them in between.
final class ReadAnnouncementsProvider
    extends $NotifierProvider<ReadAnnouncements, Set<String>> {
  /// Announcement ids marked read during this session. The server's `isRead`
  /// flag only updates on the next refresh, so this set hides them in between.
  ReadAnnouncementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readAnnouncementsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readAnnouncementsHash();

  @$internal
  @override
  ReadAnnouncements create() => ReadAnnouncements();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$readAnnouncementsHash() => r'a91be584862e765a6ab1052b4155c8aa855e851b';

/// Announcement ids marked read during this session. The server's `isRead`
/// flag only updates on the next refresh, so this set hides them in between.

abstract class _$ReadAnnouncements extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Unread announcements that should render as a persistent banner
/// (`display: banner`) at the top of the timeline.

@ProviderFor(bannerAnnouncements)
final bannerAnnouncementsProvider = BannerAnnouncementsProvider._();

/// Unread announcements that should render as a persistent banner
/// (`display: banner`) at the top of the timeline.

final class BannerAnnouncementsProvider
    extends
        $FunctionalProvider<
          List<Announcement>,
          List<Announcement>,
          List<Announcement>
        >
    with $Provider<List<Announcement>> {
  /// Unread announcements that should render as a persistent banner
  /// (`display: banner`) at the top of the timeline.
  BannerAnnouncementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bannerAnnouncementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bannerAnnouncementsHash();

  @$internal
  @override
  $ProviderElement<List<Announcement>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Announcement> create(Ref ref) {
    return bannerAnnouncements(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Announcement> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Announcement>>(value),
    );
  }
}

String _$bannerAnnouncementsHash() =>
    r'6a37e22513f1b6a28901c22d1d857bc1a17d2a42';

/// Unread announcements that should interrupt the user (`display: dialog`).

@ProviderFor(pendingDialogAnnouncements)
final pendingDialogAnnouncementsProvider =
    PendingDialogAnnouncementsProvider._();

/// Unread announcements that should interrupt the user (`display: dialog`).

final class PendingDialogAnnouncementsProvider
    extends
        $FunctionalProvider<
          List<Announcement>,
          List<Announcement>,
          List<Announcement>
        >
    with $Provider<List<Announcement>> {
  /// Unread announcements that should interrupt the user (`display: dialog`).
  PendingDialogAnnouncementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingDialogAnnouncementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingDialogAnnouncementsHash();

  @$internal
  @override
  $ProviderElement<List<Announcement>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<Announcement> create(Ref ref) {
    return pendingDialogAnnouncements(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Announcement> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Announcement>>(value),
    );
  }
}

String _$pendingDialogAnnouncementsHash() =>
    r'29bec64d0cddbd4cb13a6d763ec8f602e431926e';
