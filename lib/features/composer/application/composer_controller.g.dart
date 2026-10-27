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
    r'5bccdac65bd6f8cb28c8f23a1e42afa2a105e590';

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

/// Loads the note being replied to, for the composer's reply-target preview.

@ProviderFor(composerReplyNote)
final composerReplyNoteProvider = ComposerReplyNoteFamily._();

/// Loads the note being replied to, for the composer's reply-target preview.

final class ComposerReplyNoteProvider
    extends $FunctionalProvider<AsyncValue<Note?>, Note?, FutureOr<Note?>>
    with $FutureModifier<Note?>, $FutureProvider<Note?> {
  /// Loads the note being replied to, for the composer's reply-target preview.
  ComposerReplyNoteProvider._({
    required ComposerReplyNoteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'composerReplyNoteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$composerReplyNoteHash();

  @override
  String toString() {
    return r'composerReplyNoteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Note?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Note?> create(Ref ref) {
    final argument = this.argument as String;
    return composerReplyNote(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ComposerReplyNoteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$composerReplyNoteHash() => r'afc3f3cd1ebcce4c744e50774c7e342896bdf3c2';

/// Loads the note being replied to, for the composer's reply-target preview.

final class ComposerReplyNoteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Note?>, String> {
  ComposerReplyNoteFamily._()
    : super(
        retry: null,
        name: r'composerReplyNoteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads the note being replied to, for the composer's reply-target preview.

  ComposerReplyNoteProvider call(String noteId) =>
      ComposerReplyNoteProvider._(argument: noteId, from: this);

  @override
  String toString() => r'composerReplyNoteProvider';
}
