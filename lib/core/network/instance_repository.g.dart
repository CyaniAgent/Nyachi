// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instance_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Serves the cached instance metadata immediately and refreshes it in the
/// background, so the theme colour and text limit are available on the very
/// first frame and follow the server when it changes.

@ProviderFor(instanceInfo)
final instanceInfoProvider = InstanceInfoProvider._();

/// Serves the cached instance metadata immediately and refreshes it in the
/// background, so the theme colour and text limit are available on the very
/// first frame and follow the server when it changes.

final class InstanceInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<InstanceInfo?>,
          InstanceInfo?,
          FutureOr<InstanceInfo?>
        >
    with $FutureModifier<InstanceInfo?>, $FutureProvider<InstanceInfo?> {
  /// Serves the cached instance metadata immediately and refreshes it in the
  /// background, so the theme colour and text limit are available on the very
  /// first frame and follow the server when it changes.
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

String _$instanceInfoHash() => r'32658fcaee2008f8df7cc93ed91c6f164fa52e65';
