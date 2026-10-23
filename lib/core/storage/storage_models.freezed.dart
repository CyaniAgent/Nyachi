// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'storage_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocalAccount {

 String get id; String get host; String get userId; String get username; String? get displayName; String? get avatarUrl; DateTime get addedAt; DateTime get lastUsedAt;
/// Create a copy of LocalAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalAccountCopyWith<LocalAccount> get copyWith => _$LocalAccountCopyWithImpl<LocalAccount>(this as LocalAccount, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LocalAccount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalAccount&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.addedAt, _this.addedAt) || other.addedAt == _this.addedAt)&&(identical(other.lastUsedAt, _this.lastUsedAt) || other.lastUsedAt == _this.lastUsedAt));
}


@override
int get hashCode {
  final _this = this as LocalAccount;
  return Object.hash(runtimeType,_this.id,_this.host,_this.userId,_this.username,_this.displayName,_this.avatarUrl,_this.addedAt,_this.lastUsedAt);
}

@override
String toString() {
  final _this = this as LocalAccount;
  return 'LocalAccount(id: ${_this.id}, host: ${_this.host}, userId: ${_this.userId}, username: ${_this.username}, displayName: ${_this.displayName}, avatarUrl: ${_this.avatarUrl}, addedAt: ${_this.addedAt}, lastUsedAt: ${_this.lastUsedAt})';
}


}

/// @nodoc
abstract mixin class $LocalAccountCopyWith<$Res>  {
  factory $LocalAccountCopyWith(LocalAccount value, $Res Function(LocalAccount) _then) = _$LocalAccountCopyWithImpl;
@useResult
$Res call({
 String id, String host, String userId, String username, String? displayName, String? avatarUrl, DateTime addedAt, DateTime lastUsedAt
});




}
/// @nodoc
class _$LocalAccountCopyWithImpl<$Res>
    implements $LocalAccountCopyWith<$Res> {
  _$LocalAccountCopyWithImpl(this._self, this._then);

  final LocalAccount _self;
  final $Res Function(LocalAccount) _then;

/// Create a copy of LocalAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? host = null,Object? userId = null,Object? username = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? addedAt = null,Object? lastUsedAt = null,}) {
  return _then(LocalAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: null == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalAccount].
extension LocalAccountPatterns on LocalAccount {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalAccount() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalAccount value)  $default,){
final _that = this;
switch (_that) {
case _LocalAccount():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalAccount value)?  $default,){
final _that = this;
switch (_that) {
case _LocalAccount() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String host,  String userId,  String username,  String? displayName,  String? avatarUrl,  DateTime addedAt,  DateTime lastUsedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalAccount() when $default != null:
return $default(_that.id,_that.host,_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.addedAt,_that.lastUsedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String host,  String userId,  String username,  String? displayName,  String? avatarUrl,  DateTime addedAt,  DateTime lastUsedAt)  $default,) {final _that = this;
switch (_that) {
case _LocalAccount():
return $default(_that.id,_that.host,_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.addedAt,_that.lastUsedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String host,  String userId,  String username,  String? displayName,  String? avatarUrl,  DateTime addedAt,  DateTime lastUsedAt)?  $default,) {final _that = this;
switch (_that) {
case _LocalAccount() when $default != null:
return $default(_that.id,_that.host,_that.userId,_that.username,_that.displayName,_that.avatarUrl,_that.addedAt,_that.lastUsedAt);case _:
  return null;

}
}

}

/// @nodoc


class _LocalAccount implements LocalAccount {
  const _LocalAccount({required this.id, required this.host, required this.userId, required this.username, this.displayName, this.avatarUrl, required this.addedAt, required this.lastUsedAt});
  

@override final  String id;
@override final  String host;
@override final  String userId;
@override final  String username;
@override final  String? displayName;
@override final  String? avatarUrl;
@override final  DateTime addedAt;
@override final  DateTime lastUsedAt;

/// Create a copy of LocalAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalAccountCopyWith<_LocalAccount> get copyWith => __$LocalAccountCopyWithImpl<_LocalAccount>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.host, host) || other.host == host)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,host,userId,username,displayName,avatarUrl,addedAt,lastUsedAt);
}

@override
String toString() {
    return 'LocalAccount(id: $id, host: $host, userId: $userId, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, addedAt: $addedAt, lastUsedAt: $lastUsedAt)';
}


}

/// @nodoc
abstract mixin class _$LocalAccountCopyWith<$Res> implements $LocalAccountCopyWith<$Res> {
  factory _$LocalAccountCopyWith(_LocalAccount value, $Res Function(_LocalAccount) _then) = __$LocalAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String host, String userId, String username, String? displayName, String? avatarUrl, DateTime addedAt, DateTime lastUsedAt
});




}
/// @nodoc
class __$LocalAccountCopyWithImpl<$Res>
    implements _$LocalAccountCopyWith<$Res> {
  __$LocalAccountCopyWithImpl(this._self, this._then);

  final _LocalAccount _self;
  final $Res Function(_LocalAccount) _then;

/// Create a copy of LocalAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? host = null,Object? userId = null,Object? username = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? addedAt = null,Object? lastUsedAt = null,}) {
  return _then(_LocalAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastUsedAt: null == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$ComposerDraft {

 String get accountId; String get text; String? get cw; String get visibility; bool get localOnly; String? get replyId; DateTime get updatedAt;
/// Create a copy of ComposerDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComposerDraftCopyWith<ComposerDraft> get copyWith => _$ComposerDraftCopyWithImpl<ComposerDraft>(this as ComposerDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ComposerDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComposerDraft&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.cw, _this.cw) || other.cw == _this.cw)&&(identical(other.visibility, _this.visibility) || other.visibility == _this.visibility)&&(identical(other.localOnly, _this.localOnly) || other.localOnly == _this.localOnly)&&(identical(other.replyId, _this.replyId) || other.replyId == _this.replyId)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}


@override
int get hashCode {
  final _this = this as ComposerDraft;
  return Object.hash(runtimeType,_this.accountId,_this.text,_this.cw,_this.visibility,_this.localOnly,_this.replyId,_this.updatedAt);
}

@override
String toString() {
  final _this = this as ComposerDraft;
  return 'ComposerDraft(accountId: ${_this.accountId}, text: ${_this.text}, cw: ${_this.cw}, visibility: ${_this.visibility}, localOnly: ${_this.localOnly}, replyId: ${_this.replyId}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ComposerDraftCopyWith<$Res>  {
  factory $ComposerDraftCopyWith(ComposerDraft value, $Res Function(ComposerDraft) _then) = _$ComposerDraftCopyWithImpl;
@useResult
$Res call({
 String accountId, String text, String? cw, String visibility, bool localOnly, String? replyId, DateTime updatedAt
});




}
/// @nodoc
class _$ComposerDraftCopyWithImpl<$Res>
    implements $ComposerDraftCopyWith<$Res> {
  _$ComposerDraftCopyWithImpl(this._self, this._then);

  final ComposerDraft _self;
  final $Res Function(ComposerDraft) _then;

/// Create a copy of ComposerDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? text = null,Object? cw = freezed,Object? visibility = null,Object? localOnly = null,Object? replyId = freezed,Object? updatedAt = null,}) {
  return _then(ComposerDraft(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,cw: freezed == cw ? _self.cw : cw // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,replyId: freezed == replyId ? _self.replyId : replyId // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ComposerDraft].
extension ComposerDraftPatterns on ComposerDraft {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComposerDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComposerDraft() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComposerDraft value)  $default,){
final _that = this;
switch (_that) {
case _ComposerDraft():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComposerDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ComposerDraft() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accountId,  String text,  String? cw,  String visibility,  bool localOnly,  String? replyId,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComposerDraft() when $default != null:
return $default(_that.accountId,_that.text,_that.cw,_that.visibility,_that.localOnly,_that.replyId,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accountId,  String text,  String? cw,  String visibility,  bool localOnly,  String? replyId,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ComposerDraft():
return $default(_that.accountId,_that.text,_that.cw,_that.visibility,_that.localOnly,_that.replyId,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accountId,  String text,  String? cw,  String visibility,  bool localOnly,  String? replyId,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ComposerDraft() when $default != null:
return $default(_that.accountId,_that.text,_that.cw,_that.visibility,_that.localOnly,_that.replyId,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ComposerDraft implements ComposerDraft {
  const _ComposerDraft({required this.accountId, required this.text, this.cw, required this.visibility, this.localOnly = false, this.replyId, required this.updatedAt});
  

@override final  String accountId;
@override final  String text;
@override final  String? cw;
@override final  String visibility;
@override@JsonKey() final  bool localOnly;
@override final  String? replyId;
@override final  DateTime updatedAt;

/// Create a copy of ComposerDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComposerDraftCopyWith<_ComposerDraft> get copyWith => __$ComposerDraftCopyWithImpl<_ComposerDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComposerDraft&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.text, text) || other.text == text)&&(identical(other.cw, cw) || other.cw == cw)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.localOnly, localOnly) || other.localOnly == localOnly)&&(identical(other.replyId, replyId) || other.replyId == replyId)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,accountId,text,cw,visibility,localOnly,replyId,updatedAt);
}

@override
String toString() {
    return 'ComposerDraft(accountId: $accountId, text: $text, cw: $cw, visibility: $visibility, localOnly: $localOnly, replyId: $replyId, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ComposerDraftCopyWith<$Res> implements $ComposerDraftCopyWith<$Res> {
  factory _$ComposerDraftCopyWith(_ComposerDraft value, $Res Function(_ComposerDraft) _then) = __$ComposerDraftCopyWithImpl;
@override @useResult
$Res call({
 String accountId, String text, String? cw, String visibility, bool localOnly, String? replyId, DateTime updatedAt
});




}
/// @nodoc
class __$ComposerDraftCopyWithImpl<$Res>
    implements _$ComposerDraftCopyWith<$Res> {
  __$ComposerDraftCopyWithImpl(this._self, this._then);

  final _ComposerDraft _self;
  final $Res Function(_ComposerDraft) _then;

/// Create a copy of ComposerDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? text = null,Object? cw = freezed,Object? visibility = null,Object? localOnly = null,Object? replyId = freezed,Object? updatedAt = null,}) {
  return _then(_ComposerDraft(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,cw: freezed == cw ? _self.cw : cw // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,replyId: freezed == replyId ? _self.replyId : replyId // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$CachedPayload {

 String get payload; DateTime get updatedAt;
/// Create a copy of CachedPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CachedPayloadCopyWith<CachedPayload> get copyWith => _$CachedPayloadCopyWithImpl<CachedPayload>(this as CachedPayload, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CachedPayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CachedPayload&&(identical(other.payload, _this.payload) || other.payload == _this.payload)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}


@override
int get hashCode {
  final _this = this as CachedPayload;
  return Object.hash(runtimeType,_this.payload,_this.updatedAt);
}

@override
String toString() {
  final _this = this as CachedPayload;
  return 'CachedPayload(payload: ${_this.payload}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $CachedPayloadCopyWith<$Res>  {
  factory $CachedPayloadCopyWith(CachedPayload value, $Res Function(CachedPayload) _then) = _$CachedPayloadCopyWithImpl;
@useResult
$Res call({
 String payload, DateTime updatedAt
});




}
/// @nodoc
class _$CachedPayloadCopyWithImpl<$Res>
    implements $CachedPayloadCopyWith<$Res> {
  _$CachedPayloadCopyWithImpl(this._self, this._then);

  final CachedPayload _self;
  final $Res Function(CachedPayload) _then;

/// Create a copy of CachedPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? payload = null,Object? updatedAt = null,}) {
  return _then(CachedPayload(
payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CachedPayload].
extension CachedPayloadPatterns on CachedPayload {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CachedPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CachedPayload() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CachedPayload value)  $default,){
final _that = this;
switch (_that) {
case _CachedPayload():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CachedPayload value)?  $default,){
final _that = this;
switch (_that) {
case _CachedPayload() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String payload,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CachedPayload() when $default != null:
return $default(_that.payload,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String payload,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CachedPayload():
return $default(_that.payload,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String payload,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CachedPayload() when $default != null:
return $default(_that.payload,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CachedPayload implements CachedPayload {
  const _CachedPayload({required this.payload, required this.updatedAt});
  

@override final  String payload;
@override final  DateTime updatedAt;

/// Create a copy of CachedPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CachedPayloadCopyWith<_CachedPayload> get copyWith => __$CachedPayloadCopyWithImpl<_CachedPayload>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CachedPayload&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,payload,updatedAt);
}

@override
String toString() {
    return 'CachedPayload(payload: $payload, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CachedPayloadCopyWith<$Res> implements $CachedPayloadCopyWith<$Res> {
  factory _$CachedPayloadCopyWith(_CachedPayload value, $Res Function(_CachedPayload) _then) = __$CachedPayloadCopyWithImpl;
@override @useResult
$Res call({
 String payload, DateTime updatedAt
});




}
/// @nodoc
class __$CachedPayloadCopyWithImpl<$Res>
    implements _$CachedPayloadCopyWith<$Res> {
  __$CachedPayloadCopyWithImpl(this._self, this._then);

  final _CachedPayload _self;
  final $Res Function(_CachedPayload) _then;

/// Create a copy of CachedPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? payload = null,Object? updatedAt = null,}) {
  return _then(_CachedPayload(
payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
