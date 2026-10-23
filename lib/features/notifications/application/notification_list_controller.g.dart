// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationListController)
final notificationListControllerProvider =
    NotificationListControllerProvider._();

final class NotificationListControllerProvider
    extends
        $NotifierProvider<NotificationListController, NotificationListState> {
  NotificationListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationListControllerProvider',
        isAutoDispose: true,
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
    r'8a2e51d3c997363c9fa5e796a2498e9d2916ef10';

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
