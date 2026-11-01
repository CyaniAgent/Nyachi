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

/// The stored drafts, newest first, for the composer's avatar panel.

@ProviderFor(composerDrafts)
final composerDraftsProvider = ComposerDraftsProvider._();

/// The stored drafts, newest first, for the composer's avatar panel.

final class ComposerDraftsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ComposerDraft>>,
          List<ComposerDraft>,
          FutureOr<List<ComposerDraft>>
        >
    with
        $FutureModifier<List<ComposerDraft>>,
        $FutureProvider<List<ComposerDraft>> {
  /// The stored drafts, newest first, for the composer's avatar panel.
  ComposerDraftsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'composerDraftsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$composerDraftsHash();

  @$internal
  @override
  $FutureProviderElement<List<ComposerDraft>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ComposerDraft>> create(Ref ref) {
    return composerDrafts(ref);
  }
}

String _$composerDraftsHash() => r'ba77a12d8842ac4a52621cefcafbe1d6f0dcf3cc';

/// The account's server-side scheduled posts for the avatar panel.

@ProviderFor(composerScheduledDrafts)
final composerScheduledDraftsProvider = ComposerScheduledDraftsProvider._();

/// The account's server-side scheduled posts for the avatar panel.

final class ComposerScheduledDraftsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ComposerDraft>>,
          List<ComposerDraft>,
          FutureOr<List<ComposerDraft>>
        >
    with
        $FutureModifier<List<ComposerDraft>>,
        $FutureProvider<List<ComposerDraft>> {
  /// The account's server-side scheduled posts for the avatar panel.
  ComposerScheduledDraftsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'composerScheduledDraftsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$composerScheduledDraftsHash();

  @$internal
  @override
  $FutureProviderElement<List<ComposerDraft>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ComposerDraft>> create(Ref ref) {
    return composerScheduledDrafts(ref);
  }
}

String _$composerScheduledDraftsHash() =>
    r'08ac83b284bd18393737a6e46b80e2e13fadce2d';
