// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStore {
  Future<String?> read(String accountId);

  Future<void> write(String accountId, String token);

  Future<void> delete(String accountId);
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  String _key(String accountId) => 'nyachi.token.$accountId';

  @override
  Future<String?> read(String accountId) => _storage.read(key: _key(accountId));

  @override
  Future<void> write(String accountId, String token) {
    return _storage.write(key: _key(accountId), value: token);
  }

  @override
  Future<void> delete(String accountId) =>
      _storage.delete(key: _key(accountId));
}
