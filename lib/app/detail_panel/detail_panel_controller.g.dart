// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_panel_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DetailPanelController)
final detailPanelControllerProvider = DetailPanelControllerProvider._();

final class DetailPanelControllerProvider
    extends $NotifierProvider<DetailPanelController, DetailPanelState> {
  DetailPanelControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'detailPanelControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$detailPanelControllerHash();

  @$internal
  @override
  DetailPanelController create() => DetailPanelController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DetailPanelState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DetailPanelState>(value),
    );
  }
}

String _$detailPanelControllerHash() =>
    r'046375dbd7ca7550a3027041e063aab835e58aba';

abstract class _$DetailPanelController extends $Notifier<DetailPanelState> {
  DetailPanelState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DetailPanelState, DetailPanelState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DetailPanelState, DetailPanelState>,
              DetailPanelState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
