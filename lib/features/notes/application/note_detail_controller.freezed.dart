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

 Note? get note; bool get loading; bool get mutating; AppFailure? get error; bool get usingCache; List<Note> get replies; bool get repliesLoading; bool get repliesLoadingMore; bool get repliesHasMore; String? get repliesCursor; AppFailure? get repliesError;
/// Create a copy of NoteDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteDetailStateCopyWith<NoteDetailState> get copyWith => _$NoteDetailStateCopyWithImpl<NoteDetailState>(this as NoteDetailState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NoteDetailState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteDetailState&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.mutating, _this.mutating) || other.mutating == _this.mutating)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.usingCache, _this.usingCache) || other.usingCache == _this.usingCache)&&const DeepCollectionEquality().equals(other.replies, _this.replies)&&(identical(other.repliesLoading, _this.repliesLoading) || other.repliesLoading == _this.repliesLoading)&&(identical(other.repliesLoadingMore, _this.repliesLoadingMore) || other.repliesLoadingMore == _this.repliesLoadingMore)&&(identical(other.repliesHasMore, _this.repliesHasMore) || other.repliesHasMore == _this.repliesHasMore)&&(identical(other.repliesCursor, _this.repliesCursor) || other.repliesCursor == _this.repliesCursor)&&(identical(other.repliesError, _this.repliesError) || other.repliesError == _this.repliesError));
}


@override
int get hashCode {
  final _this = this as NoteDetailState;
  return Object.hash(runtimeType,_this.note,_this.loading,_this.mutating,_this.error,_this.usingCache,const DeepCollectionEquality().hash(_this.replies),_this.repliesLoading,_this.repliesLoadingMore,_this.repliesHasMore,_this.repliesCursor,_this.repliesError);
}

@override
String toString() {
  final _this = this as NoteDetailState;
  return 'NoteDetailState(note: ${_this.note}, loading: ${_this.loading}, mutating: ${_this.mutating}, error: ${_this.error}, usingCache: ${_this.usingCache}, replies: ${_this.replies}, repliesLoading: ${_this.repliesLoading}, repliesLoadingMore: ${_this.repliesLoadingMore}, repliesHasMore: ${_this.repliesHasMore}, repliesCursor: ${_this.repliesCursor}, repliesError: ${_this.repliesError})';
}


}

/// @nodoc
abstract mixin class $NoteDetailStateCopyWith<$Res>  {
  factory $NoteDetailStateCopyWith(NoteDetailState value, $Res Function(NoteDetailState) _then) = _$NoteDetailStateCopyWithImpl;
@useResult
$Res call({
 Note? note, bool loading, bool mutating, AppFailure? error, bool usingCache, List<Note> replies, bool repliesLoading, bool repliesLoadingMore, bool repliesHasMore, String? repliesCursor, AppFailure? repliesError
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
@pragma('vm:prefer-inline') @override $Res call({Object? note = freezed,Object? loading = null,Object? mutating = null,Object? error = freezed,Object? usingCache = null,Object? replies = null,Object? repliesLoading = null,Object? repliesLoadingMore = null,Object? repliesHasMore = null,Object? repliesCursor = freezed,Object? repliesError = freezed,}) {
  return _then(NoteDetailState(
note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as Note?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,mutating: null == mutating ? _self.mutating : mutating // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,usingCache: null == usingCache ? _self.usingCache : usingCache // ignore: cast_nullable_to_non_nullable
as bool,replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as List<Note>,repliesLoading: null == repliesLoading ? _self.repliesLoading : repliesLoading // ignore: cast_nullable_to_non_nullable
as bool,repliesLoadingMore: null == repliesLoadingMore ? _self.repliesLoadingMore : repliesLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,repliesHasMore: null == repliesHasMore ? _self.repliesHasMore : repliesHasMore // ignore: cast_nullable_to_non_nullable
as bool,repliesCursor: freezed == repliesCursor ? _self.repliesCursor : repliesCursor // ignore: cast_nullable_to_non_nullable
as String?,repliesError: freezed == repliesError ? _self.repliesError : repliesError // ignore: cast_nullable_to_non_nullable
as AppFailure?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Note? note,  bool loading,  bool mutating,  AppFailure? error,  bool usingCache,  List<Note> replies,  bool repliesLoading,  bool repliesLoadingMore,  bool repliesHasMore,  String? repliesCursor,  AppFailure? repliesError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteDetailState() when $default != null:
return $default(_that.note,_that.loading,_that.mutating,_that.error,_that.usingCache,_that.replies,_that.repliesLoading,_that.repliesLoadingMore,_that.repliesHasMore,_that.repliesCursor,_that.repliesError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Note? note,  bool loading,  bool mutating,  AppFailure? error,  bool usingCache,  List<Note> replies,  bool repliesLoading,  bool repliesLoadingMore,  bool repliesHasMore,  String? repliesCursor,  AppFailure? repliesError)  $default,) {final _that = this;
switch (_that) {
case _NoteDetailState():
return $default(_that.note,_that.loading,_that.mutating,_that.error,_that.usingCache,_that.replies,_that.repliesLoading,_that.repliesLoadingMore,_that.repliesHasMore,_that.repliesCursor,_that.repliesError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Note? note,  bool loading,  bool mutating,  AppFailure? error,  bool usingCache,  List<Note> replies,  bool repliesLoading,  bool repliesLoadingMore,  bool repliesHasMore,  String? repliesCursor,  AppFailure? repliesError)?  $default,) {final _that = this;
switch (_that) {
case _NoteDetailState() when $default != null:
return $default(_that.note,_that.loading,_that.mutating,_that.error,_that.usingCache,_that.replies,_that.repliesLoading,_that.repliesLoadingMore,_that.repliesHasMore,_that.repliesCursor,_that.repliesError);case _:
  return null;

}
}

}

/// @nodoc


class _NoteDetailState implements NoteDetailState {
  const _NoteDetailState({this.note, this.loading = true, this.mutating = false, this.error, this.usingCache = false,  List<Note> replies = const <Note>[], this.repliesLoading = true, this.repliesLoadingMore = false, this.repliesHasMore = false, this.repliesCursor, this.repliesError}): _replies = replies;
  

@override final  Note? note;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool mutating;
@override final  AppFailure? error;
@override@JsonKey() final  bool usingCache;
 final  List<Note> _replies;
@override@JsonKey() List<Note> get replies {
  if (_replies is EqualUnmodifiableListView) return _replies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_replies);
}

@override@JsonKey() final  bool repliesLoading;
@override@JsonKey() final  bool repliesLoadingMore;
@override@JsonKey() final  bool repliesHasMore;
@override final  String? repliesCursor;
@override final  AppFailure? repliesError;

/// Create a copy of NoteDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteDetailStateCopyWith<_NoteDetailState> get copyWith => __$NoteDetailStateCopyWithImpl<_NoteDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteDetailState&&(identical(other.note, note) || other.note == note)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.mutating, mutating) || other.mutating == mutating)&&(identical(other.error, error) || other.error == error)&&(identical(other.usingCache, usingCache) || other.usingCache == usingCache)&&const DeepCollectionEquality().equals(other.replies, _replies)&&(identical(other.repliesLoading, repliesLoading) || other.repliesLoading == repliesLoading)&&(identical(other.repliesLoadingMore, repliesLoadingMore) || other.repliesLoadingMore == repliesLoadingMore)&&(identical(other.repliesHasMore, repliesHasMore) || other.repliesHasMore == repliesHasMore)&&(identical(other.repliesCursor, repliesCursor) || other.repliesCursor == repliesCursor)&&(identical(other.repliesError, repliesError) || other.repliesError == repliesError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,note,loading,mutating,error,usingCache,const DeepCollectionEquality().hash(_replies),repliesLoading,repliesLoadingMore,repliesHasMore,repliesCursor,repliesError);
}

@override
String toString() {
    return 'NoteDetailState(note: $note, loading: $loading, mutating: $mutating, error: $error, usingCache: $usingCache, replies: $replies, repliesLoading: $repliesLoading, repliesLoadingMore: $repliesLoadingMore, repliesHasMore: $repliesHasMore, repliesCursor: $repliesCursor, repliesError: $repliesError)';
}


}

/// @nodoc
abstract mixin class _$NoteDetailStateCopyWith<$Res> implements $NoteDetailStateCopyWith<$Res> {
  factory _$NoteDetailStateCopyWith(_NoteDetailState value, $Res Function(_NoteDetailState) _then) = __$NoteDetailStateCopyWithImpl;
@override @useResult
$Res call({
 Note? note, bool loading, bool mutating, AppFailure? error, bool usingCache, List<Note> replies, bool repliesLoading, bool repliesLoadingMore, bool repliesHasMore, String? repliesCursor, AppFailure? repliesError
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
@override @pragma('vm:prefer-inline') $Res call({Object? note = freezed,Object? loading = null,Object? mutating = null,Object? error = freezed,Object? usingCache = null,Object? replies = null,Object? repliesLoading = null,Object? repliesLoadingMore = null,Object? repliesHasMore = null,Object? repliesCursor = freezed,Object? repliesError = freezed,}) {
  return _then(_NoteDetailState(
note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as Note?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,mutating: null == mutating ? _self.mutating : mutating // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,usingCache: null == usingCache ? _self.usingCache : usingCache // ignore: cast_nullable_to_non_nullable
as bool,replies: null == replies ? _self._replies : replies // ignore: cast_nullable_to_non_nullable
as List<Note>,repliesLoading: null == repliesLoading ? _self.repliesLoading : repliesLoading // ignore: cast_nullable_to_non_nullable
as bool,repliesLoadingMore: null == repliesLoadingMore ? _self.repliesLoadingMore : repliesLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,repliesHasMore: null == repliesHasMore ? _self.repliesHasMore : repliesHasMore // ignore: cast_nullable_to_non_nullable
as bool,repliesCursor: freezed == repliesCursor ? _self.repliesCursor : repliesCursor // ignore: cast_nullable_to_non_nullable
as String?,repliesError: freezed == repliesError ? _self.repliesError : repliesError // ignore: cast_nullable_to_non_nullable
as AppFailure?,
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
