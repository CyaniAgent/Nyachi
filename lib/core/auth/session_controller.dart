// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:misskey_dart_api/misskey_dart_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../storage/app_database.dart';
import '../storage/storage_models.dart';
import '../storage/storage_providers.dart';
import 'token_store.dart';

part 'session_controller.g.dart';

final activeAccountProvider = Provider<LocalAccount?>(
  (ref) => ref.watch(sessionControllerProvider).active,
);

const activeAccountKey = 'session.activeAccountId';

@immutable
class SessionState {
  const SessionState({
    required this.accounts,
    required this.active,
    required this.initialized,
  });

  const SessionState.initial()
    : accounts = const [],
      active = null,
      initialized = false;

  final List<LocalAccount> accounts;
  final LocalAccount? active;
  final bool initialized;

  bool get isAuthenticated => active != null;

  SessionState copyWith({
    List<LocalAccount>? accounts,
    LocalAccount? active,
    bool clearActive = false,
    bool? initialized,
  }) {
    return SessionState(
      accounts: accounts ?? this.accounts,
      active: clearActive ? null : (active ?? this.active),
      initialized: initialized ?? this.initialized,
    );
  }
}

class SessionExpiredException implements Exception {
  const SessionExpiredException();

  @override
  String toString() => 'The stored session has expired.';
}

/// A single process-wide session with one active account.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  bool _initializing = false;

  @override
  SessionState build() => const SessionState.initial();

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  AccountDao get _accounts => ref.read(accountDaoProvider);

  CacheDao get _cache => ref.read(cacheDaoProvider);

  DraftDao get _drafts => ref.read(draftDaoProvider);

  TokenStore get _tokens => ref.read(tokenStoreProvider);

  Future<void> initialize() async {
    if (state.initialized || _initializing) return;
    _initializing = true;
    try {
      final id = _prefs.getString(activeAccountKey);
      LocalAccount? active;
      if (id != null) {
        final account = await _accounts.byId(id);
        final token = account == null ? null : await _tokens.read(id);
        if (account != null && token != null && token.isNotEmpty) {
          active = account;
        } else {
          await _prefs.remove(activeAccountKey);
        }
      }
      final accounts = await _accounts.all();
      state = SessionState(
        accounts: accounts,
        active: active,
        initialized: true,
      );
    } finally {
      _initializing = false;
    }
  }

  Future<LocalAccount> addAccount(
    String host,
    String token,
    MeDetailed me,
  ) async {
    final normalized = normalizeHost(host);
    final existing = await _accounts.byHostAndUser(normalized, me.id);
    final id = existing?.id ?? const Uuid().v4();
    final now = DateTime.now();
    final account = LocalAccount(
      id: id,
      host: normalized,
      userId: me.id,
      username: me.username,
      displayName: me.name,
      avatarUrl: me.avatarUrl,
      addedAt: existing?.addedAt ?? now,
      lastUsedAt: now,
    );
    await _tokens.write(id, token.trim());
    try {
      await _accounts.upsert(account);
    } catch (_) {
      if (existing == null) await _tokens.delete(id);
      rethrow;
    }
    await _prefs.setString(activeAccountKey, id);
    state = SessionState(
      accounts: await _accounts.all(),
      active: account,
      initialized: true,
    );
    return account;
  }

  Future<void> switchAccount(String id) async {
    if (state.active?.id == id) return;
    final account = await _accounts.byId(id);
    if (account == null) {
      throw const SessionExpiredException();
    }
    final token = await _tokens.read(id);
    if (token == null || token.isEmpty) {
      throw const SessionExpiredException();
    }
    final now = DateTime.now();
    final updated = account.copyWith(lastUsedAt: now);
    await _accounts.touch(id, now);
    await _prefs.setString(activeAccountKey, id);
    final accounts = await _accounts.all();
    state = SessionState(
      accounts: accounts,
      active: updated,
      initialized: true,
    );
  }

  Future<void> removeAccount(String id) async {
    final wasActive = state.active?.id == id;
    await _tokens.delete(id);
    await _cache.deleteAccount(id);
    await _drafts.deleteDraft(id);
    await _accounts.deleteAccount(id);
    final remaining = await _accounts.all();
    if (!wasActive) {
      state = SessionState(
        accounts: remaining,
        active: state.active,
        initialized: true,
      );
      return;
    }
    String? next;
    for (final account in remaining) {
      final token = await _tokens.read(account.id);
      if (token != null && token.isNotEmpty) {
        next = account.id;
        break;
      }
    }
    if (next == null) {
      await _prefs.remove(activeAccountKey);
      state = SessionState(
        accounts: remaining,
        active: null,
        initialized: true,
      );
      return;
    }
    final active = remaining.firstWhere((a) => a.id == next);
    await _prefs.setString(activeAccountKey, next);
    state = SessionState(
      accounts: remaining,
      active: active,
      initialized: true,
    );
  }

  Future<void> expireActiveAccount() async {
    final active = state.active;
    if (active == null) return;
    await _tokens.delete(active.id);
    await _prefs.remove(activeAccountKey);
    state = SessionState(
      accounts: await _accounts.all(),
      active: null,
      initialized: true,
    );
  }
}

String normalizeHost(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    throw const FormatException('Instance host is empty.');
  }
  final withScheme = trimmed.contains('://') ? trimmed : 'https://$trimmed';
  final uri = Uri.parse(withScheme);
  if (uri.host.isEmpty) {
    throw FormatException('Invalid instance host: $input');
  }
  return uri.authority.toLowerCase();
}
