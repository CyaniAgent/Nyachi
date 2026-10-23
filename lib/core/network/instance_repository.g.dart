// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instance_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(instanceInfo)
final instanceInfoProvider = InstanceInfoProvider._();

final class InstanceInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<InstanceInfo?>,
          InstanceInfo?,
          FutureOr<InstanceInfo?>
        >
    with $FutureModifier<InstanceInfo?>, $FutureProvider<InstanceInfo?> {
  InstanceInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'instanceInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$instanceInfoHash();

  @$internal
  @override
  $FutureProviderElement<InstanceInfo?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InstanceInfo?> create(Ref ref) {
    return instanceInfo(ref);
  }
}

String _$instanceInfoHash() => r'221198c48a106641038003318e8f278da9cf4ba1';
