// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'residency.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(residency)
final residencyProvider = ResidencyProvider._();

final class ResidencyProvider
    extends
        $FunctionalProvider<
          ResidencyService,
          ResidencyService,
          ResidencyService
        >
    with $Provider<ResidencyService> {
  ResidencyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'residencyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$residencyHash();

  @$internal
  @override
  $ProviderElement<ResidencyService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ResidencyService create(Ref ref) {
    return residency(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResidencyService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResidencyService>(value),
    );
  }
}

String _$residencyHash() => r'9fa6599f1de7bce594252c9a5f699be2b5beaa83';
