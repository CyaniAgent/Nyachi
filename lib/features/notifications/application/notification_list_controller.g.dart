// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kept alive: the realtime service pushes notifications into this list even
/// when no screen is listening, so it must not be disposed between visits.

@ProviderFor(NotificationListController)
final notificationListControllerProvider =
    NotificationListControllerProvider._();

/// Kept alive: the realtime service pushes notifications into this list even
/// when no screen is listening, so it must not be disposed between visits.
final class NotificationListControllerProvider
    extends
        $NotifierProvider<NotificationListController, NotificationListState> {
  /// Kept alive: the realtime service pushes notifications into this list even
  /// when no screen is listening, so it must not be disposed between visits.
  NotificationListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationListControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationListControllerHash();

  @$internal
  @override
  NotificationListController create() => NotificationListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationListState>(value),
    );
  }
}

String _$notificationListControllerHash() =>
    r'db2e4cb31e2eac1d13a28ab5aac180acac014195';

/// Kept alive: the realtime service pushes notifications into this list even
/// when no screen is listening, so it must not be disposed between visits.

abstract class _$NotificationListController
    extends $Notifier<NotificationListState> {
  NotificationListState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NotificationListState, NotificationListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationListState, NotificationListState>,
              NotificationListState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
