// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    host,
    userId,
    username,
    displayName,
    avatarUrl,
    addedAt,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {host, userId},
  ];
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String host;
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final DateTime addedAt;
  final DateTime lastUsedAt;
  const Account({
    required this.id,
    required this.host,
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.addedAt,
    required this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['host'] = Variable<String>(host);
    map['user_id'] = Variable<String>(userId);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      host: Value(host),
      userId: Value(userId),
      username: Value(username),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      addedAt: Value(addedAt),
      lastUsedAt: Value(lastUsedAt),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      host: serializer.fromJson<String>(json['host']),
      userId: serializer.fromJson<String>(json['userId']),
      username: serializer.fromJson<String>(json['username']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'host': serializer.toJson<String>(host),
      'userId': serializer.toJson<String>(userId),
      'username': serializer.toJson<String>(username),
      'displayName': serializer.toJson<String?>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
    };
  }

  Account copyWith({
    String? id,
    String? host,
    String? userId,
    String? username,
    Value<String?> displayName = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    DateTime? addedAt,
    DateTime? lastUsedAt,
  }) => Account(
    id: id ?? this.id,
    host: host ?? this.host,
    userId: userId ?? this.userId,
    username: username ?? this.username,
    displayName: displayName.present ? displayName.value : this.displayName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    addedAt: addedAt ?? this.addedAt,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      host: data.host.present ? data.host.value : this.host,
      userId: data.userId.present ? data.userId.value : this.userId,
      username: data.username.present ? data.username.value : this.username,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    host,
    userId,
    username,
    displayName,
    avatarUrl,
    addedAt,
    lastUsedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.host == this.host &&
          other.userId == this.userId &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.addedAt == this.addedAt &&
          other.lastUsedAt == this.lastUsedAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> host;
  final Value<String> userId;
  final Value<String> username;
  final Value<String?> displayName;
  final Value<String?> avatarUrl;
  final Value<DateTime> addedAt;
  final Value<DateTime> lastUsedAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.host = const Value.absent(),
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String host,
    required String userId,
    required String username,
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    required DateTime addedAt,
    required DateTime lastUsedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       host = Value(host),
       userId = Value(userId),
       username = Value(username),
       addedAt = Value(addedAt),
       lastUsedAt = Value(lastUsedAt);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? host,
    Expression<String>? userId,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (host != null) 'host': host,
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (addedAt != null) 'added_at': addedAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? host,
    Value<String>? userId,
    Value<String>? username,
    Value<String?>? displayName,
    Value<String?>? avatarUrl,
    Value<DateTime>? addedAt,
    Value<DateTime>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      host: host ?? this.host,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      addedAt: addedAt ?? this.addedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheEntriesTable extends CacheEntries
    with TableInfo<$CacheEntriesTable, CacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    cacheKey,
    payload,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, cacheKey};
  @override
  CacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheEntry(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CacheEntriesTable createAlias(String alias) {
    return $CacheEntriesTable(attachedDatabase, alias);
  }
}

class CacheEntry extends DataClass implements Insertable<CacheEntry> {
  final String accountId;
  final String cacheKey;
  final String payload;
  final DateTime updatedAt;
  const CacheEntry({
    required this.accountId,
    required this.cacheKey,
    required this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['cache_key'] = Variable<String>(cacheKey);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return CacheEntriesCompanion(
      accountId: Value(accountId),
      cacheKey: Value(cacheKey),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory CacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheEntry(
      accountId: serializer.fromJson<String>(json['accountId']),
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'cacheKey': serializer.toJson<String>(cacheKey),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CacheEntry copyWith({
    String? accountId,
    String? cacheKey,
    String? payload,
    DateTime? updatedAt,
  }) => CacheEntry(
    accountId: accountId ?? this.accountId,
    cacheKey: cacheKey ?? this.cacheKey,
    payload: payload ?? this.payload,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CacheEntry copyWithCompanion(CacheEntriesCompanion data) {
    return CacheEntry(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheEntry(')
          ..write('accountId: $accountId, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountId, cacheKey, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheEntry &&
          other.accountId == this.accountId &&
          other.cacheKey == this.cacheKey &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class CacheEntriesCompanion extends UpdateCompanion<CacheEntry> {
  final Value<String> accountId;
  final Value<String> cacheKey;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CacheEntriesCompanion({
    this.accountId = const Value.absent(),
    this.cacheKey = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheEntriesCompanion.insert({
    required String accountId,
    required String cacheKey,
    required String payload,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       cacheKey = Value(cacheKey),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<CacheEntry> custom({
    Expression<String>? accountId,
    Expression<String>? cacheKey,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (cacheKey != null) 'cache_key': cacheKey,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheEntriesCompanion copyWith({
    Value<String>? accountId,
    Value<String>? cacheKey,
    Value<String>? payload,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheEntriesCompanion(
      accountId: accountId ?? this.accountId,
      cacheKey: cacheKey ?? this.cacheKey,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheEntriesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalDraftsTable extends LocalDrafts
    with TableInfo<$LocalDraftsTable, LocalDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _replyIdMeta = const VerificationMeta(
    'replyId',
  );
  @override
  late final GeneratedColumn<String> replyId = GeneratedColumn<String>(
    'reply_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cwMeta = const VerificationMeta('cw');
  @override
  late final GeneratedColumn<String> cw = GeneratedColumn<String>(
    'cw',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localOnlyMeta = const VerificationMeta(
    'localOnly',
  );
  @override
  late final GeneratedColumn<bool> localOnly = GeneratedColumn<bool>(
    'local_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("local_only" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reactionAcceptanceMeta =
      const VerificationMeta('reactionAcceptance');
  @override
  late final GeneratedColumn<String> reactionAcceptance =
      GeneratedColumn<String>(
        'reaction_acceptance',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileIdsMeta = const VerificationMeta(
    'fileIds',
  );
  @override
  late final GeneratedColumn<String> fileIds = GeneratedColumn<String>(
    'file_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pollChoicesMeta = const VerificationMeta(
    'pollChoices',
  );
  @override
  late final GeneratedColumn<String> pollChoices = GeneratedColumn<String>(
    'poll_choices',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pollMultipleMeta = const VerificationMeta(
    'pollMultiple',
  );
  @override
  late final GeneratedColumn<bool> pollMultiple = GeneratedColumn<bool>(
    'poll_multiple',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("poll_multiple" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pollExpiresAtMeta = const VerificationMeta(
    'pollExpiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> pollExpiresAt =
      GeneratedColumn<DateTime>(
        'poll_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _visibleUserIdsMeta = const VerificationMeta(
    'visibleUserIds',
  );
  @override
  late final GeneratedColumn<String> visibleUserIds = GeneratedColumn<String>(
    'visible_user_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    replyId,
    body,
    cw,
    visibility,
    localOnly,
    reactionAcceptance,
    scheduledAt,
    fileIds,
    pollChoices,
    pollMultiple,
    pollExpiresAt,
    visibleUserIds,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('reply_id')) {
      context.handle(
        _replyIdMeta,
        replyId.isAcceptableOrUnknown(data['reply_id']!, _replyIdMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('cw')) {
      context.handle(_cwMeta, cw.isAcceptableOrUnknown(data['cw']!, _cwMeta));
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    } else if (isInserting) {
      context.missing(_visibilityMeta);
    }
    if (data.containsKey('local_only')) {
      context.handle(
        _localOnlyMeta,
        localOnly.isAcceptableOrUnknown(data['local_only']!, _localOnlyMeta),
      );
    }
    if (data.containsKey('reaction_acceptance')) {
      context.handle(
        _reactionAcceptanceMeta,
        reactionAcceptance.isAcceptableOrUnknown(
          data['reaction_acceptance']!,
          _reactionAcceptanceMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('file_ids')) {
      context.handle(
        _fileIdsMeta,
        fileIds.isAcceptableOrUnknown(data['file_ids']!, _fileIdsMeta),
      );
    }
    if (data.containsKey('poll_choices')) {
      context.handle(
        _pollChoicesMeta,
        pollChoices.isAcceptableOrUnknown(
          data['poll_choices']!,
          _pollChoicesMeta,
        ),
      );
    }
    if (data.containsKey('poll_multiple')) {
      context.handle(
        _pollMultipleMeta,
        pollMultiple.isAcceptableOrUnknown(
          data['poll_multiple']!,
          _pollMultipleMeta,
        ),
      );
    }
    if (data.containsKey('poll_expires_at')) {
      context.handle(
        _pollExpiresAtMeta,
        pollExpiresAt.isAcceptableOrUnknown(
          data['poll_expires_at']!,
          _pollExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('visible_user_ids')) {
      context.handle(
        _visibleUserIdsMeta,
        visibleUserIds.isAcceptableOrUnknown(
          data['visible_user_ids']!,
          _visibleUserIdsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      replyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_id'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      cw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cw'],
      ),
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility'],
      )!,
      localOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}local_only'],
      )!,
      reactionAcceptance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reaction_acceptance'],
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      ),
      fileIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_ids'],
      ),
      pollChoices: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poll_choices'],
      ),
      pollMultiple: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}poll_multiple'],
      )!,
      pollExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}poll_expires_at'],
      ),
      visibleUserIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visible_user_ids'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalDraftsTable createAlias(String alias) {
    return $LocalDraftsTable(attachedDatabase, alias);
  }
}

class LocalDraft extends DataClass implements Insertable<LocalDraft> {
  final String id;
  final String accountId;
  final String? replyId;
  final String body;
  final String? cw;
  final String visibility;
  final bool localOnly;
  final String? reactionAcceptance;
  final DateTime? scheduledAt;

  /// JSON list of drive file ids; null when the draft has no attachments.
  final String? fileIds;

  /// JSON list of poll choices; null when the draft has no poll.
  final String? pollChoices;
  final bool pollMultiple;
  final DateTime? pollExpiresAt;

  /// JSON list of user ids for the `specified` (direct message) visibility.
  final String? visibleUserIds;
  final DateTime updatedAt;
  const LocalDraft({
    required this.id,
    required this.accountId,
    this.replyId,
    required this.body,
    this.cw,
    required this.visibility,
    required this.localOnly,
    this.reactionAcceptance,
    this.scheduledAt,
    this.fileIds,
    this.pollChoices,
    required this.pollMultiple,
    this.pollExpiresAt,
    this.visibleUserIds,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || replyId != null) {
      map['reply_id'] = Variable<String>(replyId);
    }
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || cw != null) {
      map['cw'] = Variable<String>(cw);
    }
    map['visibility'] = Variable<String>(visibility);
    map['local_only'] = Variable<bool>(localOnly);
    if (!nullToAbsent || reactionAcceptance != null) {
      map['reaction_acceptance'] = Variable<String>(reactionAcceptance);
    }
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    if (!nullToAbsent || fileIds != null) {
      map['file_ids'] = Variable<String>(fileIds);
    }
    if (!nullToAbsent || pollChoices != null) {
      map['poll_choices'] = Variable<String>(pollChoices);
    }
    map['poll_multiple'] = Variable<bool>(pollMultiple);
    if (!nullToAbsent || pollExpiresAt != null) {
      map['poll_expires_at'] = Variable<DateTime>(pollExpiresAt);
    }
    if (!nullToAbsent || visibleUserIds != null) {
      map['visible_user_ids'] = Variable<String>(visibleUserIds);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalDraftsCompanion toCompanion(bool nullToAbsent) {
    return LocalDraftsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      replyId: replyId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyId),
      body: Value(body),
      cw: cw == null && nullToAbsent ? const Value.absent() : Value(cw),
      visibility: Value(visibility),
      localOnly: Value(localOnly),
      reactionAcceptance: reactionAcceptance == null && nullToAbsent
          ? const Value.absent()
          : Value(reactionAcceptance),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      fileIds: fileIds == null && nullToAbsent
          ? const Value.absent()
          : Value(fileIds),
      pollChoices: pollChoices == null && nullToAbsent
          ? const Value.absent()
          : Value(pollChoices),
      pollMultiple: Value(pollMultiple),
      pollExpiresAt: pollExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pollExpiresAt),
      visibleUserIds: visibleUserIds == null && nullToAbsent
          ? const Value.absent()
          : Value(visibleUserIds),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDraft(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      replyId: serializer.fromJson<String?>(json['replyId']),
      body: serializer.fromJson<String>(json['body']),
      cw: serializer.fromJson<String?>(json['cw']),
      visibility: serializer.fromJson<String>(json['visibility']),
      localOnly: serializer.fromJson<bool>(json['localOnly']),
      reactionAcceptance: serializer.fromJson<String?>(
        json['reactionAcceptance'],
      ),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      fileIds: serializer.fromJson<String?>(json['fileIds']),
      pollChoices: serializer.fromJson<String?>(json['pollChoices']),
      pollMultiple: serializer.fromJson<bool>(json['pollMultiple']),
      pollExpiresAt: serializer.fromJson<DateTime?>(json['pollExpiresAt']),
      visibleUserIds: serializer.fromJson<String?>(json['visibleUserIds']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'replyId': serializer.toJson<String?>(replyId),
      'body': serializer.toJson<String>(body),
      'cw': serializer.toJson<String?>(cw),
      'visibility': serializer.toJson<String>(visibility),
      'localOnly': serializer.toJson<bool>(localOnly),
      'reactionAcceptance': serializer.toJson<String?>(reactionAcceptance),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'fileIds': serializer.toJson<String?>(fileIds),
      'pollChoices': serializer.toJson<String?>(pollChoices),
      'pollMultiple': serializer.toJson<bool>(pollMultiple),
      'pollExpiresAt': serializer.toJson<DateTime?>(pollExpiresAt),
      'visibleUserIds': serializer.toJson<String?>(visibleUserIds),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalDraft copyWith({
    String? id,
    String? accountId,
    Value<String?> replyId = const Value.absent(),
    String? body,
    Value<String?> cw = const Value.absent(),
    String? visibility,
    bool? localOnly,
    Value<String?> reactionAcceptance = const Value.absent(),
    Value<DateTime?> scheduledAt = const Value.absent(),
    Value<String?> fileIds = const Value.absent(),
    Value<String?> pollChoices = const Value.absent(),
    bool? pollMultiple,
    Value<DateTime?> pollExpiresAt = const Value.absent(),
    Value<String?> visibleUserIds = const Value.absent(),
    DateTime? updatedAt,
  }) => LocalDraft(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    replyId: replyId.present ? replyId.value : this.replyId,
    body: body ?? this.body,
    cw: cw.present ? cw.value : this.cw,
    visibility: visibility ?? this.visibility,
    localOnly: localOnly ?? this.localOnly,
    reactionAcceptance: reactionAcceptance.present
        ? reactionAcceptance.value
        : this.reactionAcceptance,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    fileIds: fileIds.present ? fileIds.value : this.fileIds,
    pollChoices: pollChoices.present ? pollChoices.value : this.pollChoices,
    pollMultiple: pollMultiple ?? this.pollMultiple,
    pollExpiresAt: pollExpiresAt.present
        ? pollExpiresAt.value
        : this.pollExpiresAt,
    visibleUserIds: visibleUserIds.present
        ? visibleUserIds.value
        : this.visibleUserIds,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalDraft copyWithCompanion(LocalDraftsCompanion data) {
    return LocalDraft(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      replyId: data.replyId.present ? data.replyId.value : this.replyId,
      body: data.body.present ? data.body.value : this.body,
      cw: data.cw.present ? data.cw.value : this.cw,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      localOnly: data.localOnly.present ? data.localOnly.value : this.localOnly,
      reactionAcceptance: data.reactionAcceptance.present
          ? data.reactionAcceptance.value
          : this.reactionAcceptance,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      fileIds: data.fileIds.present ? data.fileIds.value : this.fileIds,
      pollChoices: data.pollChoices.present
          ? data.pollChoices.value
          : this.pollChoices,
      pollMultiple: data.pollMultiple.present
          ? data.pollMultiple.value
          : this.pollMultiple,
      pollExpiresAt: data.pollExpiresAt.present
          ? data.pollExpiresAt.value
          : this.pollExpiresAt,
      visibleUserIds: data.visibleUserIds.present
          ? data.visibleUserIds.value
          : this.visibleUserIds,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDraft(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('replyId: $replyId, ')
          ..write('body: $body, ')
          ..write('cw: $cw, ')
          ..write('visibility: $visibility, ')
          ..write('localOnly: $localOnly, ')
          ..write('reactionAcceptance: $reactionAcceptance, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('fileIds: $fileIds, ')
          ..write('pollChoices: $pollChoices, ')
          ..write('pollMultiple: $pollMultiple, ')
          ..write('pollExpiresAt: $pollExpiresAt, ')
          ..write('visibleUserIds: $visibleUserIds, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    replyId,
    body,
    cw,
    visibility,
    localOnly,
    reactionAcceptance,
    scheduledAt,
    fileIds,
    pollChoices,
    pollMultiple,
    pollExpiresAt,
    visibleUserIds,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDraft &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.replyId == this.replyId &&
          other.body == this.body &&
          other.cw == this.cw &&
          other.visibility == this.visibility &&
          other.localOnly == this.localOnly &&
          other.reactionAcceptance == this.reactionAcceptance &&
          other.scheduledAt == this.scheduledAt &&
          other.fileIds == this.fileIds &&
          other.pollChoices == this.pollChoices &&
          other.pollMultiple == this.pollMultiple &&
          other.pollExpiresAt == this.pollExpiresAt &&
          other.visibleUserIds == this.visibleUserIds &&
          other.updatedAt == this.updatedAt);
}

class LocalDraftsCompanion extends UpdateCompanion<LocalDraft> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String?> replyId;
  final Value<String> body;
  final Value<String?> cw;
  final Value<String> visibility;
  final Value<bool> localOnly;
  final Value<String?> reactionAcceptance;
  final Value<DateTime?> scheduledAt;
  final Value<String?> fileIds;
  final Value<String?> pollChoices;
  final Value<bool> pollMultiple;
  final Value<DateTime?> pollExpiresAt;
  final Value<String?> visibleUserIds;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalDraftsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.replyId = const Value.absent(),
    this.body = const Value.absent(),
    this.cw = const Value.absent(),
    this.visibility = const Value.absent(),
    this.localOnly = const Value.absent(),
    this.reactionAcceptance = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.fileIds = const Value.absent(),
    this.pollChoices = const Value.absent(),
    this.pollMultiple = const Value.absent(),
    this.pollExpiresAt = const Value.absent(),
    this.visibleUserIds = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDraftsCompanion.insert({
    required String id,
    required String accountId,
    this.replyId = const Value.absent(),
    this.body = const Value.absent(),
    this.cw = const Value.absent(),
    required String visibility,
    this.localOnly = const Value.absent(),
    this.reactionAcceptance = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.fileIds = const Value.absent(),
    this.pollChoices = const Value.absent(),
    this.pollMultiple = const Value.absent(),
    this.pollExpiresAt = const Value.absent(),
    this.visibleUserIds = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       visibility = Value(visibility),
       updatedAt = Value(updatedAt);
  static Insertable<LocalDraft> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? replyId,
    Expression<String>? body,
    Expression<String>? cw,
    Expression<String>? visibility,
    Expression<bool>? localOnly,
    Expression<String>? reactionAcceptance,
    Expression<DateTime>? scheduledAt,
    Expression<String>? fileIds,
    Expression<String>? pollChoices,
    Expression<bool>? pollMultiple,
    Expression<DateTime>? pollExpiresAt,
    Expression<String>? visibleUserIds,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (replyId != null) 'reply_id': replyId,
      if (body != null) 'body': body,
      if (cw != null) 'cw': cw,
      if (visibility != null) 'visibility': visibility,
      if (localOnly != null) 'local_only': localOnly,
      if (reactionAcceptance != null) 'reaction_acceptance': reactionAcceptance,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (fileIds != null) 'file_ids': fileIds,
      if (pollChoices != null) 'poll_choices': pollChoices,
      if (pollMultiple != null) 'poll_multiple': pollMultiple,
      if (pollExpiresAt != null) 'poll_expires_at': pollExpiresAt,
      if (visibleUserIds != null) 'visible_user_ids': visibleUserIds,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDraftsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<String?>? replyId,
    Value<String>? body,
    Value<String?>? cw,
    Value<String>? visibility,
    Value<bool>? localOnly,
    Value<String?>? reactionAcceptance,
    Value<DateTime?>? scheduledAt,
    Value<String?>? fileIds,
    Value<String?>? pollChoices,
    Value<bool>? pollMultiple,
    Value<DateTime?>? pollExpiresAt,
    Value<String?>? visibleUserIds,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalDraftsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      replyId: replyId ?? this.replyId,
      body: body ?? this.body,
      cw: cw ?? this.cw,
      visibility: visibility ?? this.visibility,
      localOnly: localOnly ?? this.localOnly,
      reactionAcceptance: reactionAcceptance ?? this.reactionAcceptance,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      fileIds: fileIds ?? this.fileIds,
      pollChoices: pollChoices ?? this.pollChoices,
      pollMultiple: pollMultiple ?? this.pollMultiple,
      pollExpiresAt: pollExpiresAt ?? this.pollExpiresAt,
      visibleUserIds: visibleUserIds ?? this.visibleUserIds,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (replyId.present) {
      map['reply_id'] = Variable<String>(replyId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (cw.present) {
      map['cw'] = Variable<String>(cw.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (localOnly.present) {
      map['local_only'] = Variable<bool>(localOnly.value);
    }
    if (reactionAcceptance.present) {
      map['reaction_acceptance'] = Variable<String>(reactionAcceptance.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (fileIds.present) {
      map['file_ids'] = Variable<String>(fileIds.value);
    }
    if (pollChoices.present) {
      map['poll_choices'] = Variable<String>(pollChoices.value);
    }
    if (pollMultiple.present) {
      map['poll_multiple'] = Variable<bool>(pollMultiple.value);
    }
    if (pollExpiresAt.present) {
      map['poll_expires_at'] = Variable<DateTime>(pollExpiresAt.value);
    }
    if (visibleUserIds.present) {
      map['visible_user_ids'] = Variable<String>(visibleUserIds.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDraftsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('replyId: $replyId, ')
          ..write('body: $body, ')
          ..write('cw: $cw, ')
          ..write('visibility: $visibility, ')
          ..write('localOnly: $localOnly, ')
          ..write('reactionAcceptance: $reactionAcceptance, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('fileIds: $fileIds, ')
          ..write('pollChoices: $pollChoices, ')
          ..write('pollMultiple: $pollMultiple, ')
          ..write('pollExpiresAt: $pollExpiresAt, ')
          ..write('visibleUserIds: $visibleUserIds, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CacheEntriesTable cacheEntries = $CacheEntriesTable(this);
  late final $LocalDraftsTable localDrafts = $LocalDraftsTable(this);
  late final AccountDao accountDao = AccountDao(this as AppDatabase);
  late final CacheDao cacheDao = CacheDao(this as AppDatabase);
  late final LocalDraftsDao localDraftsDao = LocalDraftsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    cacheEntries,
    localDrafts,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String host,
  required String userId,
  required String username,
  Value<String?> displayName,
  Value<String?> avatarUrl,
  required DateTime addedAt,
  required DateTime lastUsedAt,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> host,
  Value<String> userId,
  Value<String> username,
  Value<String?> displayName,
  Value<String?> avatarUrl,
  Value<DateTime> addedAt,
  Value<DateTime> lastUsedAt,
  Value<int> rowid,
});

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
          Account,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                host: host,
                userId: userId,
                username: username,
                displayName: displayName,
                avatarUrl: avatarUrl,
                addedAt: addedAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String host,
                required String userId,
                required String username,
                Value<String?> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                required DateTime addedAt,
                required DateTime lastUsedAt,
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                host: host,
                userId: userId,
                username: username,
                displayName: displayName,
                avatarUrl: avatarUrl,
                addedAt: addedAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, Account>(table),
                  BaseReferences<_$AppDatabase, $AccountsTable, Account>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
      Account,
      PrefetchHooks Function()
    >;
typedef $$CacheEntriesTableCreateCompanionBuilder =
    CacheEntriesCompanion Function({
      required String accountId,
      required String cacheKey,
      required String payload,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CacheEntriesTableUpdateCompanionBuilder =
    CacheEntriesCompanion Function({
      Value<String> accountId,
      Value<String> cacheKey,
      Value<String> payload,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheEntriesTable,
          CacheEntry,
          $$CacheEntriesTableFilterComposer,
          $$CacheEntriesTableOrderingComposer,
          $$CacheEntriesTableAnnotationComposer,
          $$CacheEntriesTableCreateCompanionBuilder,
          $$CacheEntriesTableUpdateCompanionBuilder,
          (
            CacheEntry,
            BaseReferences<_$AppDatabase, $CacheEntriesTable, CacheEntry>,
          ),
          CacheEntry,
          PrefetchHooks Function()
        > {
  $$CacheEntriesTableTableManager(_$AppDatabase db, $CacheEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountId = const Value.absent(),
                Value<String> cacheKey = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheEntriesCompanion(
                accountId: accountId,
                cacheKey: cacheKey,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String accountId,
                required String cacheKey,
                required String payload,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CacheEntriesCompanion.insert(
                accountId: accountId,
                cacheKey: cacheKey,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CacheEntriesTable, CacheEntry>(table),
                  BaseReferences<_$AppDatabase, $CacheEntriesTable, CacheEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheEntriesTable,
      CacheEntry,
      $$CacheEntriesTableFilterComposer,
      $$CacheEntriesTableOrderingComposer,
      $$CacheEntriesTableAnnotationComposer,
      $$CacheEntriesTableCreateCompanionBuilder,
      $$CacheEntriesTableUpdateCompanionBuilder,
      (
        CacheEntry,
        BaseReferences<_$AppDatabase, $CacheEntriesTable, CacheEntry>,
      ),
      CacheEntry,
      PrefetchHooks Function()
    >;
typedef $$LocalDraftsTableCreateCompanionBuilder =
    LocalDraftsCompanion Function({
      required String id,
      required String accountId,
      Value<String?> replyId,
      Value<String> body,
      Value<String?> cw,
      required String visibility,
      Value<bool> localOnly,
      Value<String?> reactionAcceptance,
      Value<DateTime?> scheduledAt,
      Value<String?> fileIds,
      Value<String?> pollChoices,
      Value<bool> pollMultiple,
      Value<DateTime?> pollExpiresAt,
      Value<String?> visibleUserIds,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalDraftsTableUpdateCompanionBuilder =
    LocalDraftsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<String?> replyId,
      Value<String> body,
      Value<String?> cw,
      Value<String> visibility,
      Value<bool> localOnly,
      Value<String?> reactionAcceptance,
      Value<DateTime?> scheduledAt,
      Value<String?> fileIds,
      Value<String?> pollChoices,
      Value<bool> pollMultiple,
      Value<DateTime?> pollExpiresAt,
      Value<String?> visibleUserIds,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDraftsTable> {
  $$LocalDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyId => $composableBuilder(
    column: $table.replyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cw => $composableBuilder(
    column: $table.cw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get localOnly => $composableBuilder(
    column: $table.localOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reactionAcceptance => $composableBuilder(
    column: $table.reactionAcceptance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileIds => $composableBuilder(
    column: $table.fileIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pollChoices => $composableBuilder(
    column: $table.pollChoices,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pollMultiple => $composableBuilder(
    column: $table.pollMultiple,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pollExpiresAt => $composableBuilder(
    column: $table.pollExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibleUserIds => $composableBuilder(
    column: $table.visibleUserIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDraftsTable> {
  $$LocalDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyId => $composableBuilder(
    column: $table.replyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cw => $composableBuilder(
    column: $table.cw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get localOnly => $composableBuilder(
    column: $table.localOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reactionAcceptance => $composableBuilder(
    column: $table.reactionAcceptance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileIds => $composableBuilder(
    column: $table.fileIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pollChoices => $composableBuilder(
    column: $table.pollChoices,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pollMultiple => $composableBuilder(
    column: $table.pollMultiple,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pollExpiresAt => $composableBuilder(
    column: $table.pollExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibleUserIds => $composableBuilder(
    column: $table.visibleUserIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDraftsTable> {
  $$LocalDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get replyId =>
      $composableBuilder(column: $table.replyId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get cw =>
      $composableBuilder(column: $table.cw, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get localOnly =>
      $composableBuilder(column: $table.localOnly, builder: (column) => column);

  GeneratedColumn<String> get reactionAcceptance => $composableBuilder(
    column: $table.reactionAcceptance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileIds =>
      $composableBuilder(column: $table.fileIds, builder: (column) => column);

  GeneratedColumn<String> get pollChoices => $composableBuilder(
    column: $table.pollChoices,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pollMultiple => $composableBuilder(
    column: $table.pollMultiple,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pollExpiresAt => $composableBuilder(
    column: $table.pollExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visibleUserIds => $composableBuilder(
    column: $table.visibleUserIds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalDraftsTable,
          LocalDraft,
          $$LocalDraftsTableFilterComposer,
          $$LocalDraftsTableOrderingComposer,
          $$LocalDraftsTableAnnotationComposer,
          $$LocalDraftsTableCreateCompanionBuilder,
          $$LocalDraftsTableUpdateCompanionBuilder,
          (
            LocalDraft,
            BaseReferences<_$AppDatabase, $LocalDraftsTable, LocalDraft>,
          ),
          LocalDraft,
          PrefetchHooks Function()
        > {
  $$LocalDraftsTableTableManager(_$AppDatabase db, $LocalDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> replyId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> cw = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<bool> localOnly = const Value.absent(),
                Value<String?> reactionAcceptance = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<String?> fileIds = const Value.absent(),
                Value<String?> pollChoices = const Value.absent(),
                Value<bool> pollMultiple = const Value.absent(),
                Value<DateTime?> pollExpiresAt = const Value.absent(),
                Value<String?> visibleUserIds = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDraftsCompanion(
                id: id,
                accountId: accountId,
                replyId: replyId,
                body: body,
                cw: cw,
                visibility: visibility,
                localOnly: localOnly,
                reactionAcceptance: reactionAcceptance,
                scheduledAt: scheduledAt,
                fileIds: fileIds,
                pollChoices: pollChoices,
                pollMultiple: pollMultiple,
                pollExpiresAt: pollExpiresAt,
                visibleUserIds: visibleUserIds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                Value<String?> replyId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> cw = const Value.absent(),
                required String visibility,
                Value<bool> localOnly = const Value.absent(),
                Value<String?> reactionAcceptance = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<String?> fileIds = const Value.absent(),
                Value<String?> pollChoices = const Value.absent(),
                Value<bool> pollMultiple = const Value.absent(),
                Value<DateTime?> pollExpiresAt = const Value.absent(),
                Value<String?> visibleUserIds = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalDraftsCompanion.insert(
                id: id,
                accountId: accountId,
                replyId: replyId,
                body: body,
                cw: cw,
                visibility: visibility,
                localOnly: localOnly,
                reactionAcceptance: reactionAcceptance,
                scheduledAt: scheduledAt,
                fileIds: fileIds,
                pollChoices: pollChoices,
                pollMultiple: pollMultiple,
                pollExpiresAt: pollExpiresAt,
                visibleUserIds: visibleUserIds,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalDraftsTable, LocalDraft>(table),
                  BaseReferences<_$AppDatabase, $LocalDraftsTable, LocalDraft>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalDraftsTable,
      LocalDraft,
      $$LocalDraftsTableFilterComposer,
      $$LocalDraftsTableOrderingComposer,
      $$LocalDraftsTableAnnotationComposer,
      $$LocalDraftsTableCreateCompanionBuilder,
      $$LocalDraftsTableUpdateCompanionBuilder,
      (
        LocalDraft,
        BaseReferences<_$AppDatabase, $LocalDraftsTable, LocalDraft>,
      ),
      LocalDraft,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CacheEntriesTableTableManager get cacheEntries =>
      $$CacheEntriesTableTableManager(_db, _db.cacheEntries);
  $$LocalDraftsTableTableManager get localDrafts =>
      $$LocalDraftsTableTableManager(_db, _db.localDrafts);
}

mixin _$AccountDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccountsTable get accounts => attachedDatabase.accounts;
  AccountDaoManager get managers => AccountDaoManager(this);
}

class AccountDaoManager {
  final _$AccountDaoMixin _db;
  AccountDaoManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
}

mixin _$CacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $CacheEntriesTable get cacheEntries => attachedDatabase.cacheEntries;
  CacheDaoManager get managers => CacheDaoManager(this);
}

class CacheDaoManager {
  final _$CacheDaoMixin _db;
  CacheDaoManager(this._db);
  $$CacheEntriesTableTableManager get cacheEntries =>
      $$CacheEntriesTableTableManager(_db.attachedDatabase, _db.cacheEntries);
}

mixin _$LocalDraftsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalDraftsTable get localDrafts => attachedDatabase.localDrafts;
  LocalDraftsDaoManager get managers => LocalDraftsDaoManager(this);
}

class LocalDraftsDaoManager {
  final _$LocalDraftsDaoMixin _db;
  LocalDraftsDaoManager(this._db);
  $$LocalDraftsTableTableManager get localDrafts =>
      $$LocalDraftsTableTableManager(_db.attachedDatabase, _db.localDrafts);
}
