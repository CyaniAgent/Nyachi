// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ComposerController)
final composerControllerProvider = ComposerControllerFamily._();

final class ComposerControllerProvider
    extends $NotifierProvider<ComposerController, ComposerState> {
  ComposerControllerProvider._({
    required ComposerControllerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'composerControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$composerControllerHash();

  @override
  String toString() {
    return r'composerControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ComposerController create() => ComposerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ComposerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ComposerState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ComposerControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$composerControllerHash() =>
    r'd0cc6c5e8af8a3776efe57e22ac65386c4b1a045';

final class ComposerControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ComposerController,
          ComposerState,
          ComposerState,
          ComposerState,
          String?
        > {
  ComposerControllerFamily._()
    : super(
        retry: null,
        name: r'composerControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ComposerControllerProvider call(String? replyId) =>
      ComposerControllerProvider._(argument: replyId, from: this);

  @override
  String toString() => r'composerControllerProvider';
}

abstract class _$ComposerController extends $Notifier<ComposerState> {
  late final _$args = ref.$arg as String?;
  String? get replyId => _$args;

  ComposerState build(String? replyId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ComposerState, ComposerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ComposerState, ComposerState>,
              ComposerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
