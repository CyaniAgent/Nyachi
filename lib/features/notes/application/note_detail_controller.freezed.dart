// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_detail_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NoteDetailState {

 Note? get note; bool get loading; bool get mutating; AppFailure? get error; bool get usingCache;
/// Create a copy of NoteDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteDetailStateCopyWith<NoteDetailState> get copyWith => _$NoteDetailStateCopyWithImpl<NoteDetailState>(this as NoteDetailState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NoteDetailState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteDetailState&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.mutating, _this.mutating) || other.mutating == _this.mutating)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.usingCache, _this.usingCache) || other.usingCache == _this.usingCache));
}


@override
int get hashCode {
  final _this = this as NoteDetailState;
  return Object.hash(runtimeType,_this.note,_this.loading,_this.mutating,_this.error,_this.usingCache);
}

@override
String toString() {
  final _this = this as NoteDetailState;
  return 'NoteDetailState(note: ${_this.note}, loading: ${_this.loading}, mutating: ${_this.mutating}, error: ${_this.error}, usingCache: ${_this.usingCache})';
}


}

/// @nodoc
abstract mixin class $NoteDetailStateCopyWith<$Res>  {
  factory $NoteDetailStateCopyWith(NoteDetailState value, $Res Function(NoteDetailState) _then) = _$NoteDetailStateCopyWithImpl;
@useResult
$Res call({
 Note? note, bool loading, bool mutating, AppFailure? error, bool usingCache
});


$NoteCopyWith<$Res>? get note;

}
/// @nodoc
class _$NoteDetailStateCopyWithImpl<$Res>
    implements $NoteDetailStateCopyWith<$Res> {
  _$NoteDetailStateCopyWithImpl(this._self, this._then);

  final NoteDetailState _self;
  final $Res Function(NoteDetailState) _then;

/// Create a copy of NoteDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? note = freezed,Object? loading = null,Object? mutating = null,Object? error = freezed,Object? usingCache = null,}) {
  return _then(NoteDetailState(
note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as Note?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,mutating: null == mutating ? _self.mutating : mutating // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,usingCache: null == usingCache ? _self.usingCache : usingCache // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of NoteDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteCopyWith<$Res>? get note {
    if (_self.note == null) {
    return null;
  }

  return $NoteCopyWith<$Res>(_self.note!, (value) {
    return _then(_self.copyWith(note: value));
  });
}
}


/// Adds pattern-matching-related methods to [NoteDetailState].
extension NoteDetailStatePatterns on NoteDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteDetailState value)  $default,){
final _that = this;
switch (_that) {
case _NoteDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _NoteDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Note? note,  bool loading,  bool mutating,  AppFailure? error,  bool usingCache)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteDetailState() when $default != null:
return $default(_that.note,_that.loading,_that.mutating,_that.error,_that.usingCache);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Note? note,  bool loading,  bool mutating,  AppFailure? error,  bool usingCache)  $default,) {final _that = this;
switch (_that) {
case _NoteDetailState():
return $default(_that.note,_that.loading,_that.mutating,_that.error,_that.usingCache);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Note? note,  bool loading,  bool mutating,  AppFailure? error,  bool usingCache)?  $default,) {final _that = this;
switch (_that) {
case _NoteDetailState() when $default != null:
return $default(_that.note,_that.loading,_that.mutating,_that.error,_that.usingCache);case _:
  return null;

}
}

}

/// @nodoc


class _NoteDetailState implements NoteDetailState {
  const _NoteDetailState({this.note, this.loading = true, this.mutating = false, this.error, this.usingCache = false});
  

@override final  Note? note;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool mutating;
@override final  AppFailure? error;
@override@JsonKey() final  bool usingCache;

/// Create a copy of NoteDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteDetailStateCopyWith<_NoteDetailState> get copyWith => __$NoteDetailStateCopyWithImpl<_NoteDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteDetailState&&(identical(other.note, note) || other.note == note)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.mutating, mutating) || other.mutating == mutating)&&(identical(other.error, error) || other.error == error)&&(identical(other.usingCache, usingCache) || other.usingCache == usingCache));
}


@override
int get hashCode {
    return Object.hash(runtimeType,note,loading,mutating,error,usingCache);
}

@override
String toString() {
    return 'NoteDetailState(note: $note, loading: $loading, mutating: $mutating, error: $error, usingCache: $usingCache)';
}


}

/// @nodoc
abstract mixin class _$NoteDetailStateCopyWith<$Res> implements $NoteDetailStateCopyWith<$Res> {
  factory _$NoteDetailStateCopyWith(_NoteDetailState value, $Res Function(_NoteDetailState) _then) = __$NoteDetailStateCopyWithImpl;
@override @useResult
$Res call({
 Note? note, bool loading, bool mutating, AppFailure? error, bool usingCache
});


@override $NoteCopyWith<$Res>? get note;

}
/// @nodoc
class __$NoteDetailStateCopyWithImpl<$Res>
    implements _$NoteDetailStateCopyWith<$Res> {
  __$NoteDetailStateCopyWithImpl(this._self, this._then);

  final _NoteDetailState _self;
  final $Res Function(_NoteDetailState) _then;

/// Create a copy of NoteDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? note = freezed,Object? loading = null,Object? mutating = null,Object? error = freezed,Object? usingCache = null,}) {
  return _then(_NoteDetailState(
note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as Note?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,mutating: null == mutating ? _self.mutating : mutating // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,usingCache: null == usingCache ? _self.usingCache : usingCache // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of NoteDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteCopyWith<$Res>? get note {
    if (_self.note == null) {
    return null;
  }

  return $NoteCopyWith<$Res>(_self.note!, (value) {
    return _then(_self.copyWith(note: value));
  });
}
}

// dart format on
