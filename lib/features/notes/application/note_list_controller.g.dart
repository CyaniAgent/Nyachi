// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NoteListController)
final noteListControllerProvider = NoteListControllerFamily._();

final class NoteListControllerProvider
    extends $NotifierProvider<NoteListController, NoteListState> {
  NoteListControllerProvider._({
    required NoteListControllerFamily super.from,
    required NoteFeedSource super.argument,
  }) : super(
         retry: null,
         name: r'noteListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$noteListControllerHash();

  @override
  String toString() {
    return r'noteListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  NoteListController create() => NoteListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteListState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NoteListControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$noteListControllerHash() =>
    r'43243d1b53e41824c9a51fbaeafbd996c71ebd01';

final class NoteListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          NoteListController,
          NoteListState,
          NoteListState,
          NoteListState,
          NoteFeedSource
        > {
  NoteListControllerFamily._()
    : super(
        retry: null,
        name: r'noteListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NoteListControllerProvider call(NoteFeedSource source) =>
      NoteListControllerProvider._(argument: source, from: this);

  @override
  String toString() => r'noteListControllerProvider';
}

abstract class _$NoteListController extends $Notifier<NoteListState> {
  late final _$args = ref.$arg as NoteFeedSource;
  NoteFeedSource get source => _$args;

  NoteListState build(NoteFeedSource source);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NoteListState, NoteListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NoteListState, NoteListState>,
              NoteListState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
