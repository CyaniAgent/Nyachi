// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(driveRepository)
final driveRepositoryProvider = DriveRepositoryProvider._();

final class DriveRepositoryProvider
    extends
        $FunctionalProvider<DriveRepository, DriveRepository, DriveRepository>
    with $Provider<DriveRepository> {
  DriveRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveRepositoryHash();

  @$internal
  @override
  $ProviderElement<DriveRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DriveRepository create(Ref ref) {
    return driveRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriveRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriveRepository>(value),
    );
  }
}

String _$driveRepositoryHash() => r'6b7c8ebd8c5fcff788225428892e710474f7de8e';

@ProviderFor(driveListing)
final driveListingProvider = DriveListingFamily._();

final class DriveListingProvider
    extends
        $FunctionalProvider<
          AsyncValue<DriveListing>,
          DriveListing,
          FutureOr<DriveListing>
        >
    with $FutureModifier<DriveListing>, $FutureProvider<DriveListing> {
  DriveListingProvider._({
    required DriveListingFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'driveListingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driveListingHash();

  @override
  String toString() {
    return r'driveListingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DriveListing> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DriveListing> create(Ref ref) {
    final argument = this.argument as String?;
    return driveListing(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DriveListingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driveListingHash() => r'4f6fe1a8d5cb0c13b4d6230fe98f94fe8511f7e4';

final class DriveListingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DriveListing>, String?> {
  DriveListingFamily._()
    : super(
        retry: null,
        name: r'driveListingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DriveListingProvider call(String? folderId) =>
      DriveListingProvider._(argument: folderId, from: this);

  @override
  String toString() => r'driveListingProvider';
}
