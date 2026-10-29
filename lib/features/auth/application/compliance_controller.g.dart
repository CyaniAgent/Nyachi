// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compliance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks the two consent granularities: one application-level acceptance
/// (app terms + privacy policy) and one acceptance per instance host.

@ProviderFor(ComplianceController)
final complianceControllerProvider = ComplianceControllerProvider._();

/// Tracks the two consent granularities: one application-level acceptance
/// (app terms + privacy policy) and one acceptance per instance host.
final class ComplianceControllerProvider
    extends $NotifierProvider<ComplianceController, ComplianceState> {
  /// Tracks the two consent granularities: one application-level acceptance
  /// (app terms + privacy policy) and one acceptance per instance host.
  ComplianceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'complianceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$complianceControllerHash();

  @$internal
  @override
  ComplianceController create() => ComplianceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ComplianceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ComplianceState>(value),
    );
  }
}

String _$complianceControllerHash() =>
    r'3fcfa3756d8edcfd5c9a3aec0e53ff889a00b892';

/// Tracks the two consent granularities: one application-level acceptance
/// (app terms + privacy policy) and one acceptance per instance host.

abstract class _$ComplianceController extends $Notifier<ComplianceState> {
  ComplianceState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ComplianceState, ComplianceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ComplianceState, ComplianceState>,
              ComplianceState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
