// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NoteOverrides)
final noteOverridesProvider = NoteOverridesProvider._();

final class NoteOverridesProvider
    extends $NotifierProvider<NoteOverrides, Map<String, Note>> {
  NoteOverridesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteOverridesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteOverridesHash();

  @$internal
  @override
  NoteOverrides create() => NoteOverrides();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Note> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Note>>(value),
    );
  }
}

String _$noteOverridesHash() => r'fa48e921bfd61a50cbdca7c6f74d1522f672c12a';

abstract class _$NoteOverrides extends $Notifier<Map<String, Note>> {
  Map<String, Note> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<String, Note>, Map<String, Note>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, Note>, Map<String, Note>>,
              Map<String, Note>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(NoteDetailController)
final noteDetailControllerProvider = NoteDetailControllerFamily._();

final class NoteDetailControllerProvider
    extends $NotifierProvider<NoteDetailController, NoteDetailState> {
  NoteDetailControllerProvider._({
    required NoteDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'noteDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$noteDetailControllerHash();

  @override
  String toString() {
    return r'noteDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  NoteDetailController create() => NoteDetailController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NoteDetailControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$noteDetailControllerHash() =>
    r'2174987a169724da1ebb92dfe5bba84ab02223ab';

final class NoteDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          NoteDetailController,
          NoteDetailState,
          NoteDetailState,
          NoteDetailState,
          String
        > {
  NoteDetailControllerFamily._()
    : super(
        retry: null,
        name: r'noteDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NoteDetailControllerProvider call(String noteId) =>
      NoteDetailControllerProvider._(argument: noteId, from: this);

  @override
  String toString() => r'noteDetailControllerProvider';
}

abstract class _$NoteDetailController extends $Notifier<NoteDetailState> {
  late final _$args = ref.$arg as String;
  String get noteId => _$args;

  NoteDetailState build(String noteId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NoteDetailState, NoteDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NoteDetailState, NoteDetailState>,
              NoteDetailState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
