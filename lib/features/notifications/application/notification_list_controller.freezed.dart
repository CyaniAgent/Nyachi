// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationListState {

 List<Notification> get items; bool get initialLoading; bool get refreshing; bool get loadingMore; bool get hasMore; bool get usingCache; bool get markingRead; AppFailure? get error;
/// Create a copy of NotificationListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationListStateCopyWith<NotificationListState> get copyWith => _$NotificationListStateCopyWithImpl<NotificationListState>(this as NotificationListState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NotificationListState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationListState&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.initialLoading, _this.initialLoading) || other.initialLoading == _this.initialLoading)&&(identical(other.refreshing, _this.refreshing) || other.refreshing == _this.refreshing)&&(identical(other.loadingMore, _this.loadingMore) || other.loadingMore == _this.loadingMore)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.usingCache, _this.usingCache) || other.usingCache == _this.usingCache)&&(identical(other.markingRead, _this.markingRead) || other.markingRead == _this.markingRead)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as NotificationListState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.initialLoading,_this.refreshing,_this.loadingMore,_this.hasMore,_this.usingCache,_this.markingRead,_this.error);
}

@override
String toString() {
  final _this = this as NotificationListState;
  return 'NotificationListState(items: ${_this.items}, initialLoading: ${_this.initialLoading}, refreshing: ${_this.refreshing}, loadingMore: ${_this.loadingMore}, hasMore: ${_this.hasMore}, usingCache: ${_this.usingCache}, markingRead: ${_this.markingRead}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $NotificationListStateCopyWith<$Res>  {
  factory $NotificationListStateCopyWith(NotificationListState value, $Res Function(NotificationListState) _then) = _$NotificationListStateCopyWithImpl;
@useResult
$Res call({
 List<Notification> items, bool initialLoading, bool refreshing, bool loadingMore, bool hasMore, bool usingCache, bool markingRead, AppFailure? error
});




}
/// @nodoc
class _$NotificationListStateCopyWithImpl<$Res>
    implements $NotificationListStateCopyWith<$Res> {
  _$NotificationListStateCopyWithImpl(this._self, this._then);

  final NotificationListState _self;
  final $Res Function(NotificationListState) _then;

/// Create a copy of NotificationListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? initialLoading = null,Object? refreshing = null,Object? loadingMore = null,Object? hasMore = null,Object? usingCache = null,Object? markingRead = null,Object? error = freezed,}) {
  return _then(NotificationListState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Notification>,initialLoading: null == initialLoading ? _self.initialLoading : initialLoading // ignore: cast_nullable_to_non_nullable
as bool,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,usingCache: null == usingCache ? _self.usingCache : usingCache // ignore: cast_nullable_to_non_nullable
as bool,markingRead: null == markingRead ? _self.markingRead : markingRead // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationListState].
extension NotificationListStatePatterns on NotificationListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationListState value)  $default,){
final _that = this;
switch (_that) {
case _NotificationListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationListState value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Notification> items,  bool initialLoading,  bool refreshing,  bool loadingMore,  bool hasMore,  bool usingCache,  bool markingRead,  AppFailure? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationListState() when $default != null:
return $default(_that.items,_that.initialLoading,_that.refreshing,_that.loadingMore,_that.hasMore,_that.usingCache,_that.markingRead,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Notification> items,  bool initialLoading,  bool refreshing,  bool loadingMore,  bool hasMore,  bool usingCache,  bool markingRead,  AppFailure? error)  $default,) {final _that = this;
switch (_that) {
case _NotificationListState():
return $default(_that.items,_that.initialLoading,_that.refreshing,_that.loadingMore,_that.hasMore,_that.usingCache,_that.markingRead,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Notification> items,  bool initialLoading,  bool refreshing,  bool loadingMore,  bool hasMore,  bool usingCache,  bool markingRead,  AppFailure? error)?  $default,) {final _that = this;
switch (_that) {
case _NotificationListState() when $default != null:
return $default(_that.items,_that.initialLoading,_that.refreshing,_that.loadingMore,_that.hasMore,_that.usingCache,_that.markingRead,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationListState implements NotificationListState {
  const _NotificationListState({ List<Notification> items = const [], this.initialLoading = true, this.refreshing = false, this.loadingMore = false, this.hasMore = true, this.usingCache = false, this.markingRead = false, this.error}): _items = items;
  

 final  List<Notification> _items;
@override@JsonKey() List<Notification> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool initialLoading;
@override@JsonKey() final  bool refreshing;
@override@JsonKey() final  bool loadingMore;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  bool usingCache;
@override@JsonKey() final  bool markingRead;
@override final  AppFailure? error;

/// Create a copy of NotificationListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationListStateCopyWith<_NotificationListState> get copyWith => __$NotificationListStateCopyWithImpl<_NotificationListState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationListState&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.initialLoading, initialLoading) || other.initialLoading == initialLoading)&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.usingCache, usingCache) || other.usingCache == usingCache)&&(identical(other.markingRead, markingRead) || other.markingRead == markingRead)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),initialLoading,refreshing,loadingMore,hasMore,usingCache,markingRead,error);
}

@override
String toString() {
    return 'NotificationListState(items: $items, initialLoading: $initialLoading, refreshing: $refreshing, loadingMore: $loadingMore, hasMore: $hasMore, usingCache: $usingCache, markingRead: $markingRead, error: $error)';
}


}

/// @nodoc
abstract mixin class _$NotificationListStateCopyWith<$Res> implements $NotificationListStateCopyWith<$Res> {
  factory _$NotificationListStateCopyWith(_NotificationListState value, $Res Function(_NotificationListState) _then) = __$NotificationListStateCopyWithImpl;
@override @useResult
$Res call({
 List<Notification> items, bool initialLoading, bool refreshing, bool loadingMore, bool hasMore, bool usingCache, bool markingRead, AppFailure? error
});




}
/// @nodoc
class __$NotificationListStateCopyWithImpl<$Res>
    implements _$NotificationListStateCopyWith<$Res> {
  __$NotificationListStateCopyWithImpl(this._self, this._then);

  final _NotificationListState _self;
  final $Res Function(_NotificationListState) _then;

/// Create a copy of NotificationListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? initialLoading = null,Object? refreshing = null,Object? loadingMore = null,Object? hasMore = null,Object? usingCache = null,Object? markingRead = null,Object? error = freezed,}) {
  return _then(_NotificationListState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Notification>,initialLoading: null == initialLoading ? _self.initialLoading : initialLoading // ignore: cast_nullable_to_non_nullable
as bool,refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,usingCache: null == usingCache ? _self.usingCache : usingCache // ignore: cast_nullable_to_non_nullable
as bool,markingRead: null == markingRead ? _self.markingRead : markingRead // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
