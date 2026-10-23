// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NoteListState {

 List<Note> get items; bool get initialLoading; bool get refreshing; bool get loadingMore; bool get hasMore; AppFailure? get error; bool get usingCache;
/// Create a copy of NoteListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteListStateCopyWith<NoteListState> get copyWith => _$NoteListStateCopyWithImpl<NoteListState>(this as NoteListState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NoteListState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteListState&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.initialLoading, _this.initialLoading) || other.initialLoading == _this.initialLoading)&&(identical(other.refreshing, _this.refreshing) || other.refreshing == _this.refreshing)&&(identical(other.loadingMore, _this.loadingMore) || other.loadingMore == _this.loadingMore)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.usingCache, _this.usingCache) || other.usingCache == _this.usingCache));
}


@override
int get hashCode {
  final _this = this as NoteListState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.initialLoading,_this.refreshing,_this.loadingMore,_this.hasMore,_this.error,_this.usingCache);
}

@override
String toString() {
  final _this = this as NoteListState;
  return 'NoteListState(items: ${_this.items}, initialLoading: ${_this.initialLoading}, refreshing: ${_this.refreshing}, loadingMore: ${_this.loadingMore}, hasMore: ${_this.hasMore}, error: ${_this.error}, usingCache: ${_this.usingCache})';
}


}

/// @nodoc
abstract mixin class $NoteListStateCopyWith<$Res>  {
  factory $NoteListStateCopyWith(NoteListState value, $Res Function(NoteListState) _then) = _$NoteListStateCopyWithImpl;
@useResult
$Res call({
 List<Note> items, bool initialLoading, bool refreshing, bool loadingMore, bool hasMore, AppFailure? error, bool usingCache
});




}
/// @nodoc
class _$NoteListStateCopyWithImpl<$Res>
    implements $NoteListStateCopyWith<$Res> {
  _$NoteListStateCopyWithImpl(this._self, this._then);

  final NoteListState _self;
  final $Res Function(NoteListState) _then;

/// Create a copy of NoteListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? initialLoading = null,Object? refreshing = null,Object? loadingMore = null,Object? hasMore = null,Object? error = freezed,Object? usingCache = null,}) {
  return _then(NoteListState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Note>,initialLoading: null == initialLoading ? _self.initialLoading : initialLoading // ignore: cast_nullable_to_non_nullable
as bool,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,usingCache: null == usingCache ? _self.usingCache : usingCache // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NoteListState].
extension NoteListStatePatterns on NoteListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteListState value)  $default,){
final _that = this;
switch (_that) {
case _NoteListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteListState value)?  $default,){
final _that = this;
switch (_that) {
case _NoteListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Note> items,  bool initialLoading,  bool refreshing,  bool loadingMore,  bool hasMore,  AppFailure? error,  bool usingCache)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteListState() when $default != null:
return $default(_that.items,_that.initialLoading,_that.refreshing,_that.loadingMore,_that.hasMore,_that.error,_that.usingCache);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Note> items,  bool initialLoading,  bool refreshing,  bool loadingMore,  bool hasMore,  AppFailure? error,  bool usingCache)  $default,) {final _that = this;
switch (_that) {
case _NoteListState():
return $default(_that.items,_that.initialLoading,_that.refreshing,_that.loadingMore,_that.hasMore,_that.error,_that.usingCache);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Note> items,  bool initialLoading,  bool refreshing,  bool loadingMore,  bool hasMore,  AppFailure? error,  bool usingCache)?  $default,) {final _that = this;
switch (_that) {
case _NoteListState() when $default != null:
return $default(_that.items,_that.initialLoading,_that.refreshing,_that.loadingMore,_that.hasMore,_that.error,_that.usingCache);case _:
  return null;

}
}

}

/// @nodoc


class _NoteListState implements NoteListState {
  const _NoteListState({ List<Note> items = const [], this.initialLoading = true, this.refreshing = false, this.loadingMore = false, this.hasMore = true, this.error, this.usingCache = false}): _items = items;
  

 final  List<Note> _items;
@override@JsonKey() List<Note> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool initialLoading;
@override@JsonKey() final  bool refreshing;
@override@JsonKey() final  bool loadingMore;
@override@JsonKey() final  bool hasMore;
@override final  AppFailure? error;
@override@JsonKey() final  bool usingCache;

/// Create a copy of NoteListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteListStateCopyWith<_NoteListState> get copyWith => __$NoteListStateCopyWithImpl<_NoteListState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteListState&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.initialLoading, initialLoading) || other.initialLoading == initialLoading)&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.error, error) || other.error == error)&&(identical(other.usingCache, usingCache) || other.usingCache == usingCache));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),initialLoading,refreshing,loadingMore,hasMore,error,usingCache);
}

@override
String toString() {
    return 'NoteListState(items: $items, initialLoading: $initialLoading, refreshing: $refreshing, loadingMore: $loadingMore, hasMore: $hasMore, error: $error, usingCache: $usingCache)';
}


}

/// @nodoc
abstract mixin class _$NoteListStateCopyWith<$Res> implements $NoteListStateCopyWith<$Res> {
  factory _$NoteListStateCopyWith(_NoteListState value, $Res Function(_NoteListState) _then) = __$NoteListStateCopyWithImpl;
@override @useResult
$Res call({
 List<Note> items, bool initialLoading, bool refreshing, bool loadingMore, bool hasMore, AppFailure? error, bool usingCache
});




}
/// @nodoc
class __$NoteListStateCopyWithImpl<$Res>
    implements _$NoteListStateCopyWith<$Res> {
  __$NoteListStateCopyWithImpl(this._self, this._then);

  final _NoteListState _self;
  final $Res Function(_NoteListState) _then;

/// Create a copy of NoteListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? initialLoading = null,Object? refreshing = null,Object? loadingMore = null,Object? hasMore = null,Object? error = freezed,Object? usingCache = null,}) {
  return _then(_NoteListState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Note>,initialLoading: null == initialLoading ? _self.initialLoading : initialLoading // ignore: cast_nullable_to_non_nullable
as bool,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,usingCache: null == usingCache ? _self.usingCache : usingCache // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
