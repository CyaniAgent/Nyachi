// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(draftStore)
final draftStoreProvider = DraftStoreProvider._();

final class DraftStoreProvider
    extends $FunctionalProvider<DraftStore, DraftStore, DraftStore>
    with $Provider<DraftStore> {
  DraftStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftStoreHash();

  @$internal
  @override
  $ProviderElement<DraftStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DraftStore create(Ref ref) {
    return draftStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DraftStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DraftStore>(value),
    );
  }
}

String _$draftStoreHash() => r'd1397b6e7cab8a13c10064451f9c4f822085d13e';
