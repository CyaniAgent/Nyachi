// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatTarget {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatTarget);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChatTarget()';
}


}

/// @nodoc
class $ChatTargetCopyWith<$Res>  {
$ChatTargetCopyWith(ChatTarget _, $Res Function(ChatTarget) __);
}


/// Adds pattern-matching-related methods to [ChatTarget].
extension ChatTargetPatterns on ChatTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChatUserTarget value)?  user,TResult Function( ChatRoomTarget value)?  room,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChatUserTarget() when user != null:
return user(_that);case ChatRoomTarget() when room != null:
return room(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChatUserTarget value)  user,required TResult Function( ChatRoomTarget value)  room,}){
final _that = this;
switch (_that) {
case ChatUserTarget():
return user(_that);case ChatRoomTarget():
return room(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChatUserTarget value)?  user,TResult? Function( ChatRoomTarget value)?  room,}){
final _that = this;
switch (_that) {
case ChatUserTarget() when user != null:
return user(_that);case ChatRoomTarget() when room != null:
return room(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String userId)?  user,TResult Function( String roomId)?  room,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChatUserTarget() when user != null:
return user(_that.userId);case ChatRoomTarget() when room != null:
return room(_that.roomId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String userId)  user,required TResult Function( String roomId)  room,}) {final _that = this;
switch (_that) {
case ChatUserTarget():
return user(_that.userId);case ChatRoomTarget():
return room(_that.roomId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String userId)?  user,TResult? Function( String roomId)?  room,}) {final _that = this;
switch (_that) {
case ChatUserTarget() when user != null:
return user(_that.userId);case ChatRoomTarget() when room != null:
return room(_that.roomId);case _:
  return null;

}
}

}

/// @nodoc


class ChatUserTarget implements ChatTarget {
  const ChatUserTarget(this.userId);
  

 final  String userId;

/// Create a copy of ChatTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatUserTargetCopyWith<ChatUserTarget> get copyWith => _$ChatUserTargetCopyWithImpl<ChatUserTarget>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatUserTarget&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId);
}

@override
String toString() {
    return 'ChatTarget.user(userId: $userId)';
}


}

/// @nodoc
abstract mixin class $ChatUserTargetCopyWith<$Res> implements $ChatTargetCopyWith<$Res> {
  factory $ChatUserTargetCopyWith(ChatUserTarget value, $Res Function(ChatUserTarget) _then) = _$ChatUserTargetCopyWithImpl;
@useResult
$Res call({
 String userId
});




}
/// @nodoc
class _$ChatUserTargetCopyWithImpl<$Res>
    implements $ChatUserTargetCopyWith<$Res> {
  _$ChatUserTargetCopyWithImpl(this._self, this._then);

  final ChatUserTarget _self;
  final $Res Function(ChatUserTarget) _then;

/// Create a copy of ChatTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,}) {
  return _then(ChatUserTarget(
null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ChatRoomTarget implements ChatTarget {
  const ChatRoomTarget(this.roomId);
  

 final  String roomId;

/// Create a copy of ChatTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatRoomTargetCopyWith<ChatRoomTarget> get copyWith => _$ChatRoomTargetCopyWithImpl<ChatRoomTarget>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatRoomTarget&&(identical(other.roomId, roomId) || other.roomId == roomId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,roomId);
}

@override
String toString() {
    return 'ChatTarget.room(roomId: $roomId)';
}


}

/// @nodoc
abstract mixin class $ChatRoomTargetCopyWith<$Res> implements $ChatTargetCopyWith<$Res> {
  factory $ChatRoomTargetCopyWith(ChatRoomTarget value, $Res Function(ChatRoomTarget) _then) = _$ChatRoomTargetCopyWithImpl;
@useResult
$Res call({
 String roomId
});




}
/// @nodoc
class _$ChatRoomTargetCopyWithImpl<$Res>
    implements $ChatRoomTargetCopyWith<$Res> {
  _$ChatRoomTargetCopyWithImpl(this._self, this._then);

  final ChatRoomTarget _self;
  final $Res Function(ChatRoomTarget) _then;

/// Create a copy of ChatTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? roomId = null,}) {
  return _then(ChatRoomTarget(
null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
