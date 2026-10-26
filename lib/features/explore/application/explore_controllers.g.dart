// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trends)
final trendsProvider = TrendsProvider._();

final class TrendsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HashtagsTrendResponseItem>>,
          List<HashtagsTrendResponseItem>,
          FutureOr<List<HashtagsTrendResponseItem>>
        >
    with
        $FutureModifier<List<HashtagsTrendResponseItem>>,
        $FutureProvider<List<HashtagsTrendResponseItem>> {
  TrendsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendsHash();

  @$internal
  @override
  $FutureProviderElement<List<HashtagsTrendResponseItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HashtagsTrendResponseItem>> create(Ref ref) {
    return trends(ref);
  }
}

String _$trendsHash() => r'859dfa2ef1404b45b385e3ad7a6ec3aa6d05f94f';

@ProviderFor(UserSearchController)
final userSearchControllerProvider = UserSearchControllerFamily._();

final class UserSearchControllerProvider
    extends $NotifierProvider<UserSearchController, UserSearchState> {
  UserSearchControllerProvider._({
    required UserSearchControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userSearchControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userSearchControllerHash();

  @override
  String toString() {
    return r'userSearchControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserSearchController create() => UserSearchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserSearchState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserSearchControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userSearchControllerHash() =>
    r'ee390c7a0cfed1d984db03fe3d0bedeab5bed213';

final class UserSearchControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          UserSearchController,
          UserSearchState,
          UserSearchState,
          UserSearchState,
          String
        > {
  UserSearchControllerFamily._()
    : super(
        retry: null,
        name: r'userSearchControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserSearchControllerProvider call(String query) =>
      UserSearchControllerProvider._(argument: query, from: this);

  @override
  String toString() => r'userSearchControllerProvider';
}

abstract class _$UserSearchController extends $Notifier<UserSearchState> {
  late final _$args = ref.$arg as String;
  String get query => _$args;

  UserSearchState build(String query);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UserSearchState, UserSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserSearchState, UserSearchState>,
              UserSearchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
