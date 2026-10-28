// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Announcements for the active account, cached across restarts.

@ProviderFor(announcements)
final announcementsProvider = AnnouncementsProvider._();

/// Announcements for the active account, cached across restarts.

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
  /// Announcements for the active account, cached across restarts.
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

String _$announcementsHash() => r'fdda54fc4c48f26624dce8c68038a20d73baa5ba';

/// Unread announcements that should interrupt the user (`display: dialog`).

@ProviderFor(pendingDialogAnnouncements)
final pendingDialogAnnouncementsProvider =
    PendingDialogAnnouncementsProvider._();

/// Unread announcements that should interrupt the user (`display: dialog`).

final class PendingDialogAnnouncementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Announcement>>,
          List<Announcement>,
          FutureOr<List<Announcement>>
        >
    with
        $FutureModifier<List<Announcement>>,
        $FutureProvider<List<Announcement>> {
  /// Unread announcements that should interrupt the user (`display: dialog`).
  PendingDialogAnnouncementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingDialogAnnouncementsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingDialogAnnouncementsHash();

  @$internal
  @override
  $FutureProviderElement<List<Announcement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Announcement>> create(Ref ref) {
    return pendingDialogAnnouncements(ref);
  }
}

String _$pendingDialogAnnouncementsHash() =>
    r'1b00322c14d485f9672877cb47eb437941836079';
