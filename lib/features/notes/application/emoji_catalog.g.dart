// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_catalog.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(emojiCatalog)
final emojiCatalogProvider = EmojiCatalogProvider._();

final class EmojiCatalogProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EmojiSimple>>,
          List<EmojiSimple>,
          FutureOr<List<EmojiSimple>>
        >
    with
        $FutureModifier<List<EmojiSimple>>,
        $FutureProvider<List<EmojiSimple>> {
  EmojiCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emojiCatalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emojiCatalogHash();

  @$internal
  @override
  $FutureProviderElement<List<EmojiSimple>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EmojiSimple>> create(Ref ref) {
    return emojiCatalog(ref);
  }
}

String _$emojiCatalogHash() => r'7b917ef063152aad2350a352043dd775a9e47527';
