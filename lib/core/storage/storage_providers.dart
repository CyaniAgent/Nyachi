// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/token_store.dart';
import 'app_database.dart';

part 'storage_providers.g.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase.open();
  ref.onDispose(() {
    unawaited(database.close());
  });
  return database;
}

@Riverpod(keepAlive: true)
AccountDao accountDao(Ref ref) => ref.watch(appDatabaseProvider).accountDao;

@Riverpod(keepAlive: true)
CacheDao cacheDao(Ref ref) => ref.watch(appDatabaseProvider).cacheDao;

@Riverpod(keepAlive: true)
DraftDao draftDao(Ref ref) => ref.watch(appDatabaseProvider).draftDao;

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => SecureTokenStore();
