// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oobe_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// OOBE step index. Steps: 0 language + welcome, 1 compliance + sign-in,
/// 2 appearance, 3 done. The wizard cannot be skipped: completion persists
/// `oobe.completed` and the router guard releases the app only afterwards.

@ProviderFor(OobeController)
final oobeControllerProvider = OobeControllerProvider._();

/// OOBE step index. Steps: 0 language + welcome, 1 compliance + sign-in,
/// 2 appearance, 3 done. The wizard cannot be skipped: completion persists
/// `oobe.completed` and the router guard releases the app only afterwards.
final class OobeControllerProvider
    extends $NotifierProvider<OobeController, int> {
  /// OOBE step index. Steps: 0 language + welcome, 1 compliance + sign-in,
  /// 2 appearance, 3 done. The wizard cannot be skipped: completion persists
  /// `oobe.completed` and the router guard releases the app only afterwards.
  OobeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oobeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oobeControllerHash();

  @$internal
  @override
  OobeController create() => OobeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$oobeControllerHash() => r'34a618c3aa65c3b3e1097613a1c3acc34c4b5f69';

/// OOBE step index. Steps: 0 language + welcome, 1 compliance + sign-in,
/// 2 appearance, 3 done. The wizard cannot be skipped: completion persists
/// `oobe.completed` and the router guard releases the app only afterwards.

abstract class _$OobeController extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
