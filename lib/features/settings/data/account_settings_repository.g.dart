// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_settings_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountSettingsRepository)
final accountSettingsRepositoryProvider = AccountSettingsRepositoryProvider._();

final class AccountSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AccountSettingsRepository,
          AccountSettingsRepository,
          AccountSettingsRepository
        >
    with $Provider<AccountSettingsRepository> {
  AccountSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountSettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccountSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountSettingsRepository create(Ref ref) {
    return accountSettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountSettingsRepository>(value),
    );
  }
}

String _$accountSettingsRepositoryHash() =>
    r'e512544498e9d64917aea3e0290ae50cdb2d7bd3';
