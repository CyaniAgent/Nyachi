// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_stream_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeStream)
final homeStreamProvider = HomeStreamProvider._();

final class HomeStreamProvider
    extends
        $FunctionalProvider<
          HomeStreamService,
          HomeStreamService,
          HomeStreamService
        >
    with $Provider<HomeStreamService> {
  HomeStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeStreamHash();

  @$internal
  @override
  $ProviderElement<HomeStreamService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomeStreamService create(Ref ref) {
    return homeStream(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeStreamService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeStreamService>(value),
    );
  }
}

String _$homeStreamHash() => r'59f0733862a886f931465cd139193db89e1975b0';
