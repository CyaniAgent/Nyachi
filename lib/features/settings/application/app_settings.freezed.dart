// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NavConfig implements DiagnosticableTreeMixin {

 List<AppTab> get order; Set<AppTab> get visible;
/// Create a copy of NavConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavConfigCopyWith<NavConfig> get copyWith => _$NavConfigCopyWithImpl<NavConfig>(this as NavConfig, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as NavConfig;
  properties
    ..add(DiagnosticsProperty('type', 'NavConfig'))
    ..add(DiagnosticsProperty('order', _this.order))..add(DiagnosticsProperty('visible', _this.visible));
}

@override
bool operator ==(Object other) {
  final _this = this as NavConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavConfig&&const DeepCollectionEquality().equals(other.order, _this.order)&&const DeepCollectionEquality().equals(other.visible, _this.visible));
}


@override
int get hashCode {
  final _this = this as NavConfig;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.order),const DeepCollectionEquality().hash(_this.visible));
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as NavConfig;
  return 'NavConfig(order: ${_this.order}, visible: ${_this.visible})';
}


}

/// @nodoc
abstract mixin class $NavConfigCopyWith<$Res>  {
  factory $NavConfigCopyWith(NavConfig value, $Res Function(NavConfig) _then) = _$NavConfigCopyWithImpl;
@useResult
$Res call({
 List<AppTab> order, Set<AppTab> visible
});




}
/// @nodoc
class _$NavConfigCopyWithImpl<$Res>
    implements $NavConfigCopyWith<$Res> {
  _$NavConfigCopyWithImpl(this._self, this._then);

  final NavConfig _self;
  final $Res Function(NavConfig) _then;

/// Create a copy of NavConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? order = null,Object? visible = null,}) {
  return _then(NavConfig(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as List<AppTab>,visible: null == visible ? _self.visible : visible // ignore: cast_nullable_to_non_nullable
as Set<AppTab>,
  ));
}

}


/// Adds pattern-matching-related methods to [NavConfig].
extension NavConfigPatterns on NavConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavConfig value)  $default,){
final _that = this;
switch (_that) {
case _NavConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavConfig value)?  $default,){
final _that = this;
switch (_that) {
case _NavConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AppTab> order,  Set<AppTab> visible)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavConfig() when $default != null:
return $default(_that.order,_that.visible);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AppTab> order,  Set<AppTab> visible)  $default,) {final _that = this;
switch (_that) {
case _NavConfig():
return $default(_that.order,_that.visible);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AppTab> order,  Set<AppTab> visible)?  $default,) {final _that = this;
switch (_that) {
case _NavConfig() when $default != null:
return $default(_that.order,_that.visible);case _:
  return null;

}
}

}

/// @nodoc


class _NavConfig with DiagnosticableTreeMixin implements NavConfig {
  const _NavConfig({required  List<AppTab> order, required  Set<AppTab> visible}): _order = order,_visible = visible;
  

 final  List<AppTab> _order;
@override List<AppTab> get order {
  if (_order is EqualUnmodifiableListView) return _order;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_order);
}

 final  Set<AppTab> _visible;
@override Set<AppTab> get visible {
  if (_visible is EqualUnmodifiableSetView) return _visible;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_visible);
}


/// Create a copy of NavConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavConfigCopyWith<_NavConfig> get copyWith => __$NavConfigCopyWithImpl<_NavConfig>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'NavConfig'))
    ..add(DiagnosticsProperty('order', order))..add(DiagnosticsProperty('visible', visible));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavConfig&&const DeepCollectionEquality().equals(other.order, _order)&&const DeepCollectionEquality().equals(other.visible, _visible));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_order),const DeepCollectionEquality().hash(_visible));
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'NavConfig(order: $order, visible: $visible)';
}


}

/// @nodoc
abstract mixin class _$NavConfigCopyWith<$Res> implements $NavConfigCopyWith<$Res> {
  factory _$NavConfigCopyWith(_NavConfig value, $Res Function(_NavConfig) _then) = __$NavConfigCopyWithImpl;
@override @useResult
$Res call({
 List<AppTab> order, Set<AppTab> visible
});




}
/// @nodoc
class __$NavConfigCopyWithImpl<$Res>
    implements _$NavConfigCopyWith<$Res> {
  __$NavConfigCopyWithImpl(this._self, this._then);

  final _NavConfig _self;
  final $Res Function(_NavConfig) _then;

/// Create a copy of NavConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? order = null,Object? visible = null,}) {
  return _then(_NavConfig(
order: null == order ? _self._order : order // ignore: cast_nullable_to_non_nullable
as List<AppTab>,visible: null == visible ? _self._visible : visible // ignore: cast_nullable_to_non_nullable
as Set<AppTab>,
  ));
}


}

// dart format on
