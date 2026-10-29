// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anonymous_meta.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Public instance metadata fetched without credentials. Serves the login
/// page and the OOBE wizard before any account exists, so compliance
/// surfaces (rules, ToS links) can render before sign-in.
///
/// [host] should already be normalized via [normalizeHost] (that value also
/// keys the provider family cache); the provider normalizes defensively
/// before building the client.

@ProviderFor(anonymousMeta)
final anonymousMetaProvider = AnonymousMetaFamily._();

/// Public instance metadata fetched without credentials. Serves the login
/// page and the OOBE wizard before any account exists, so compliance
/// surfaces (rules, ToS links) can render before sign-in.
///
/// [host] should already be normalized via [normalizeHost] (that value also
/// keys the provider family cache); the provider normalizes defensively
/// before building the client.

final class AnonymousMetaProvider
    extends
        $FunctionalProvider<AsyncValue<MetaLite>, MetaLite, FutureOr<MetaLite>>
    with $FutureModifier<MetaLite>, $FutureProvider<MetaLite> {
  /// Public instance metadata fetched without credentials. Serves the login
  /// page and the OOBE wizard before any account exists, so compliance
  /// surfaces (rules, ToS links) can render before sign-in.
  ///
  /// [host] should already be normalized via [normalizeHost] (that value also
  /// keys the provider family cache); the provider normalizes defensively
  /// before building the client.
  AnonymousMetaProvider._({
    required AnonymousMetaFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'anonymousMetaProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$anonymousMetaHash();

  @override
  String toString() {
    return r'anonymousMetaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MetaLite> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<MetaLite> create(Ref ref) {
    final argument = this.argument as String;
    return anonymousMeta(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnonymousMetaProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$anonymousMetaHash() => r'3cf66485eca3d223584b005d7491a77e1ac6dd28';

/// Public instance metadata fetched without credentials. Serves the login
/// page and the OOBE wizard before any account exists, so compliance
/// surfaces (rules, ToS links) can render before sign-in.
///
/// [host] should already be normalized via [normalizeHost] (that value also
/// keys the provider family cache); the provider normalizes defensively
/// before building the client.

final class AnonymousMetaFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MetaLite>, String> {
  AnonymousMetaFamily._()
    : super(
        retry: null,
        name: r'anonymousMetaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Public instance metadata fetched without credentials. Serves the login
  /// page and the OOBE wizard before any account exists, so compliance
  /// surfaces (rules, ToS links) can render before sign-in.
  ///
  /// [host] should already be normalized via [normalizeHost] (that value also
  /// keys the provider family cache); the provider normalizes defensively
  /// before building the client.

  AnonymousMetaProvider call(String host) =>
      AnonymousMetaProvider._(argument: host, from: this);

  @override
  String toString() => r'anonymousMetaProvider';
}
