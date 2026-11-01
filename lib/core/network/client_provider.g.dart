// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(misskeyClient)
final misskeyClientProvider = MisskeyClientProvider._();

final class MisskeyClientProvider
    extends $FunctionalProvider<MisskeyClient, MisskeyClient, MisskeyClient>
    with $Provider<MisskeyClient> {
  MisskeyClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'misskeyClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$misskeyClientHash();

  @$internal
  @override
  $ProviderElement<MisskeyClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MisskeyClient create(Ref ref) {
    return misskeyClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MisskeyClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MisskeyClient>(value),
    );
  }
}

String _$misskeyClientHash() => r'6a1176796b19b3d07d5744bf4695247058ac3dfd';
