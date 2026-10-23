// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_controllers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatListState {

 List<ChatConversation> get direct; List<ChatRoom> get rooms; bool get loading; AppFailure? get error;
/// Create a copy of ChatListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatListStateCopyWith<ChatListState> get copyWith => _$ChatListStateCopyWithImpl<ChatListState>(this as ChatListState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatListState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatListState&&const DeepCollectionEquality().equals(other.direct, _this.direct)&&const DeepCollectionEquality().equals(other.rooms, _this.rooms)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as ChatListState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.direct),const DeepCollectionEquality().hash(_this.rooms),_this.loading,_this.error);
}

@override
String toString() {
  final _this = this as ChatListState;
  return 'ChatListState(direct: ${_this.direct}, rooms: ${_this.rooms}, loading: ${_this.loading}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $ChatListStateCopyWith<$Res>  {
  factory $ChatListStateCopyWith(ChatListState value, $Res Function(ChatListState) _then) = _$ChatListStateCopyWithImpl;
@useResult
$Res call({
 List<ChatConversation> direct, List<ChatRoom> rooms, bool loading, AppFailure? error
});




}
/// @nodoc
class _$ChatListStateCopyWithImpl<$Res>
    implements $ChatListStateCopyWith<$Res> {
  _$ChatListStateCopyWithImpl(this._self, this._then);

  final ChatListState _self;
  final $Res Function(ChatListState) _then;

/// Create a copy of ChatListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? direct = null,Object? rooms = null,Object? loading = null,Object? error = freezed,}) {
  return _then(ChatListState(
direct: null == direct ? _self.direct : direct // ignore: cast_nullable_to_non_nullable
as List<ChatConversation>,rooms: null == rooms ? _self.rooms : rooms // ignore: cast_nullable_to_non_nullable
as List<ChatRoom>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatListState].
extension ChatListStatePatterns on ChatListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatListState value)  $default,){
final _that = this;
switch (_that) {
case _ChatListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatListState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ChatConversation> direct,  List<ChatRoom> rooms,  bool loading,  AppFailure? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatListState() when $default != null:
return $default(_that.direct,_that.rooms,_that.loading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ChatConversation> direct,  List<ChatRoom> rooms,  bool loading,  AppFailure? error)  $default,) {final _that = this;
switch (_that) {
case _ChatListState():
return $default(_that.direct,_that.rooms,_that.loading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ChatConversation> direct,  List<ChatRoom> rooms,  bool loading,  AppFailure? error)?  $default,) {final _that = this;
switch (_that) {
case _ChatListState() when $default != null:
return $default(_that.direct,_that.rooms,_that.loading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ChatListState implements ChatListState {
  const _ChatListState({ List<ChatConversation> direct = const [],  List<ChatRoom> rooms = const [], this.loading = true, this.error}): _direct = direct,_rooms = rooms;
  

 final  List<ChatConversation> _direct;
@override@JsonKey() List<ChatConversation> get direct {
  if (_direct is EqualUnmodifiableListView) return _direct;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_direct);
}

 final  List<ChatRoom> _rooms;
@override@JsonKey() List<ChatRoom> get rooms {
  if (_rooms is EqualUnmodifiableListView) return _rooms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rooms);
}

@override@JsonKey() final  bool loading;
@override final  AppFailure? error;

/// Create a copy of ChatListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatListStateCopyWith<_ChatListState> get copyWith => __$ChatListStateCopyWithImpl<_ChatListState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatListState&&const DeepCollectionEquality().equals(other.direct, _direct)&&const DeepCollectionEquality().equals(other.rooms, _rooms)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_direct),const DeepCollectionEquality().hash(_rooms),loading,error);
}

@override
String toString() {
    return 'ChatListState(direct: $direct, rooms: $rooms, loading: $loading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ChatListStateCopyWith<$Res> implements $ChatListStateCopyWith<$Res> {
  factory _$ChatListStateCopyWith(_ChatListState value, $Res Function(_ChatListState) _then) = __$ChatListStateCopyWithImpl;
@override @useResult
$Res call({
 List<ChatConversation> direct, List<ChatRoom> rooms, bool loading, AppFailure? error
});




}
/// @nodoc
class __$ChatListStateCopyWithImpl<$Res>
    implements _$ChatListStateCopyWith<$Res> {
  __$ChatListStateCopyWithImpl(this._self, this._then);

  final _ChatListState _self;
  final $Res Function(_ChatListState) _then;

/// Create a copy of ChatListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? direct = null,Object? rooms = null,Object? loading = null,Object? error = freezed,}) {
  return _then(_ChatListState(
direct: null == direct ? _self._direct : direct // ignore: cast_nullable_to_non_nullable
as List<ChatConversation>,rooms: null == rooms ? _self._rooms : rooms // ignore: cast_nullable_to_non_nullable
as List<ChatRoom>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc
mixin _$ChatThreadState {

 List<ChatMessageItem> get items; UserDetailed? get user; ChatRoom? get room; bool get loading; bool get loadingOlder; bool get hasMore; bool get sending; bool get usingCache; AppFailure? get error;
/// Create a copy of ChatThreadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatThreadStateCopyWith<ChatThreadState> get copyWith => _$ChatThreadStateCopyWithImpl<ChatThreadState>(this as ChatThreadState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatThreadState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatThreadState&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.room, _this.room) || other.room == _this.room)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.loadingOlder, _this.loadingOlder) || other.loadingOlder == _this.loadingOlder)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.sending, _this.sending) || other.sending == _this.sending)&&(identical(other.usingCache, _this.usingCache) || other.usingCache == _this.usingCache)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as ChatThreadState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.user,_this.room,_this.loading,_this.loadingOlder,_this.hasMore,_this.sending,_this.usingCache,_this.error);
}

@override
String toString() {
  final _this = this as ChatThreadState;
  return 'ChatThreadState(items: ${_this.items}, user: ${_this.user}, room: ${_this.room}, loading: ${_this.loading}, loadingOlder: ${_this.loadingOlder}, hasMore: ${_this.hasMore}, sending: ${_this.sending}, usingCache: ${_this.usingCache}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $ChatThreadStateCopyWith<$Res>  {
  factory $ChatThreadStateCopyWith(ChatThreadState value, $Res Function(ChatThreadState) _then) = _$ChatThreadStateCopyWithImpl;
@useResult
$Res call({
 List<ChatMessageItem> items, UserDetailed? user, ChatRoom? room, bool loading, bool loadingOlder, bool hasMore, bool sending, bool usingCache, AppFailure? error
});


$ChatRoomCopyWith<$Res>? get room;

}
/// @nodoc
class _$ChatThreadStateCopyWithImpl<$Res>
    implements $ChatThreadStateCopyWith<$Res> {
  _$ChatThreadStateCopyWithImpl(this._self, this._then);

  final ChatThreadState _self;
  final $Res Function(ChatThreadState) _then;

/// Create a copy of ChatThreadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? user = freezed,Object? room = freezed,Object? loading = null,Object? loadingOlder = null,Object? hasMore = null,Object? sending = null,Object? usingCache = null,Object? error = freezed,}) {
  return _then(ChatThreadState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ChatMessageItem>,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserDetailed?,room: freezed == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as ChatRoom?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,loadingOlder: null == loadingOlder ? _self.loadingOlder : loadingOlder // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,usingCache: null == usingCache ? _self.usingCache : usingCache // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}
/// Create a copy of ChatThreadState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatRoomCopyWith<$Res>? get room {
    if (_self.room == null) {
    return null;
  }

  return $ChatRoomCopyWith<$Res>(_self.room!, (value) {
    return _then(_self.copyWith(room: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatThreadState].
extension ChatThreadStatePatterns on ChatThreadState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatThreadState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatThreadState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatThreadState value)  $default,){
final _that = this;
switch (_that) {
case _ChatThreadState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatThreadState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatThreadState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ChatMessageItem> items,  UserDetailed? user,  ChatRoom? room,  bool loading,  bool loadingOlder,  bool hasMore,  bool sending,  bool usingCache,  AppFailure? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatThreadState() when $default != null:
return $default(_that.items,_that.user,_that.room,_that.loading,_that.loadingOlder,_that.hasMore,_that.sending,_that.usingCache,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ChatMessageItem> items,  UserDetailed? user,  ChatRoom? room,  bool loading,  bool loadingOlder,  bool hasMore,  bool sending,  bool usingCache,  AppFailure? error)  $default,) {final _that = this;
switch (_that) {
case _ChatThreadState():
return $default(_that.items,_that.user,_that.room,_that.loading,_that.loadingOlder,_that.hasMore,_that.sending,_that.usingCache,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ChatMessageItem> items,  UserDetailed? user,  ChatRoom? room,  bool loading,  bool loadingOlder,  bool hasMore,  bool sending,  bool usingCache,  AppFailure? error)?  $default,) {final _that = this;
switch (_that) {
case _ChatThreadState() when $default != null:
return $default(_that.items,_that.user,_that.room,_that.loading,_that.loadingOlder,_that.hasMore,_that.sending,_that.usingCache,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ChatThreadState implements ChatThreadState {
  const _ChatThreadState({ List<ChatMessageItem> items = const [], this.user, this.room, this.loading = true, this.loadingOlder = false, this.hasMore = true, this.sending = false, this.usingCache = false, this.error}): _items = items;
  

 final  List<ChatMessageItem> _items;
@override@JsonKey() List<ChatMessageItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  UserDetailed? user;
@override final  ChatRoom? room;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool loadingOlder;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  bool sending;
@override@JsonKey() final  bool usingCache;
@override final  AppFailure? error;

/// Create a copy of ChatThreadState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadStateCopyWith<_ChatThreadState> get copyWith => __$ChatThreadStateCopyWithImpl<_ChatThreadState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThreadState&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.user, user) || other.user == user)&&(identical(other.room, room) || other.room == room)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.loadingOlder, loadingOlder) || other.loadingOlder == loadingOlder)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.usingCache, usingCache) || other.usingCache == usingCache)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),user,room,loading,loadingOlder,hasMore,sending,usingCache,error);
}

@override
String toString() {
    return 'ChatThreadState(items: $items, user: $user, room: $room, loading: $loading, loadingOlder: $loadingOlder, hasMore: $hasMore, sending: $sending, usingCache: $usingCache, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadStateCopyWith<$Res> implements $ChatThreadStateCopyWith<$Res> {
  factory _$ChatThreadStateCopyWith(_ChatThreadState value, $Res Function(_ChatThreadState) _then) = __$ChatThreadStateCopyWithImpl;
@override @useResult
$Res call({
 List<ChatMessageItem> items, UserDetailed? user, ChatRoom? room, bool loading, bool loadingOlder, bool hasMore, bool sending, bool usingCache, AppFailure? error
});


@override $ChatRoomCopyWith<$Res>? get room;

}
/// @nodoc
class __$ChatThreadStateCopyWithImpl<$Res>
    implements _$ChatThreadStateCopyWith<$Res> {
  __$ChatThreadStateCopyWithImpl(this._self, this._then);

  final _ChatThreadState _self;
  final $Res Function(_ChatThreadState) _then;

/// Create a copy of ChatThreadState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? user = freezed,Object? room = freezed,Object? loading = null,Object? loadingOlder = null,Object? hasMore = null,Object? sending = null,Object? usingCache = null,Object? error = freezed,}) {
  return _then(_ChatThreadState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ChatMessageItem>,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserDetailed?,room: freezed == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as ChatRoom?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,loadingOlder: null == loadingOlder ? _self.loadingOlder : loadingOlder // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,usingCache: null == usingCache ? _self.usingCache : usingCache // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

/// Create a copy of ChatThreadState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatRoomCopyWith<$Res>? get room {
    if (_self.room == null) {
    return null;
  }

  return $ChatRoomCopyWith<$Res>(_self.room!, (value) {
    return _then(_self.copyWith(room: value));
  });
}
}

// dart format on
