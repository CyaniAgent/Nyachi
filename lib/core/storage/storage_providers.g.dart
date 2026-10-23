// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'16306660de1833c37600809292546077d41a8f0b';

@ProviderFor(accountDao)
final accountDaoProvider = AccountDaoProvider._();

final class AccountDaoProvider
    extends $FunctionalProvider<AccountDao, AccountDao, AccountDao>
    with $Provider<AccountDao> {
  AccountDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountDaoHash();

  @$internal
  @override
  $ProviderElement<AccountDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountDao create(Ref ref) {
    return accountDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountDao>(value),
    );
  }
}

String _$accountDaoHash() => r'9b5cce9b178be215d87d9d92a41e6494c5b966ec';

@ProviderFor(cacheDao)
final cacheDaoProvider = CacheDaoProvider._();

final class CacheDaoProvider
    extends $FunctionalProvider<CacheDao, CacheDao, CacheDao>
    with $Provider<CacheDao> {
  CacheDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheDaoHash();

  @$internal
  @override
  $ProviderElement<CacheDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CacheDao create(Ref ref) {
    return cacheDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CacheDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CacheDao>(value),
    );
  }
}

String _$cacheDaoHash() => r'cb76662c58085408c1f9bf2e1a283380999fa6a2';

@ProviderFor(draftDao)
final draftDaoProvider = DraftDaoProvider._();

final class DraftDaoProvider
    extends $FunctionalProvider<DraftDao, DraftDao, DraftDao>
    with $Provider<DraftDao> {
  DraftDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftDaoHash();

  @$internal
  @override
  $ProviderElement<DraftDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DraftDao create(Ref ref) {
    return draftDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DraftDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DraftDao>(value),
    );
  }
}

String _$draftDaoHash() => r'a83b6b7596e67a7ec61cdb53fb168cfa366e74cb';

@ProviderFor(tokenStore)
final tokenStoreProvider = TokenStoreProvider._();

final class TokenStoreProvider
    extends $FunctionalProvider<TokenStore, TokenStore, TokenStore>
    with $Provider<TokenStore> {
  TokenStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStoreHash();

  @$internal
  @override
  $ProviderElement<TokenStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenStore create(Ref ref) {
    return tokenStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenStore>(value),
    );
  }
}

String _$tokenStoreHash() => r'e1af499041ec8e3fd653ab4576cba8185f657d98';
