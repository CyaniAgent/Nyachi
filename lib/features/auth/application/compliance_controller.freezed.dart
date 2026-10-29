// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compliance_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ComplianceState {

 bool get appAccepted; Set<String> get instanceAcceptedHosts;
/// Create a copy of ComplianceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplianceStateCopyWith<ComplianceState> get copyWith => _$ComplianceStateCopyWithImpl<ComplianceState>(this as ComplianceState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ComplianceState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplianceState&&(identical(other.appAccepted, _this.appAccepted) || other.appAccepted == _this.appAccepted)&&const DeepCollectionEquality().equals(other.instanceAcceptedHosts, _this.instanceAcceptedHosts));
}


@override
int get hashCode {
  final _this = this as ComplianceState;
  return Object.hash(runtimeType,_this.appAccepted,const DeepCollectionEquality().hash(_this.instanceAcceptedHosts));
}

@override
String toString() {
  final _this = this as ComplianceState;
  return 'ComplianceState(appAccepted: ${_this.appAccepted}, instanceAcceptedHosts: ${_this.instanceAcceptedHosts})';
}


}

/// @nodoc
abstract mixin class $ComplianceStateCopyWith<$Res>  {
  factory $ComplianceStateCopyWith(ComplianceState value, $Res Function(ComplianceState) _then) = _$ComplianceStateCopyWithImpl;
@useResult
$Res call({
 bool appAccepted, Set<String> instanceAcceptedHosts
});




}
/// @nodoc
class _$ComplianceStateCopyWithImpl<$Res>
    implements $ComplianceStateCopyWith<$Res> {
  _$ComplianceStateCopyWithImpl(this._self, this._then);

  final ComplianceState _self;
  final $Res Function(ComplianceState) _then;

/// Create a copy of ComplianceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appAccepted = null,Object? instanceAcceptedHosts = null,}) {
  return _then(ComplianceState(
appAccepted: null == appAccepted ? _self.appAccepted : appAccepted // ignore: cast_nullable_to_non_nullable
as bool,instanceAcceptedHosts: null == instanceAcceptedHosts ? _self.instanceAcceptedHosts : instanceAcceptedHosts // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ComplianceState].
extension ComplianceStatePatterns on ComplianceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComplianceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComplianceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComplianceState value)  $default,){
final _that = this;
switch (_that) {
case _ComplianceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComplianceState value)?  $default,){
final _that = this;
switch (_that) {
case _ComplianceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool appAccepted,  Set<String> instanceAcceptedHosts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComplianceState() when $default != null:
return $default(_that.appAccepted,_that.instanceAcceptedHosts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool appAccepted,  Set<String> instanceAcceptedHosts)  $default,) {final _that = this;
switch (_that) {
case _ComplianceState():
return $default(_that.appAccepted,_that.instanceAcceptedHosts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool appAccepted,  Set<String> instanceAcceptedHosts)?  $default,) {final _that = this;
switch (_that) {
case _ComplianceState() when $default != null:
return $default(_that.appAccepted,_that.instanceAcceptedHosts);case _:
  return null;

}
}

}

/// @nodoc


class _ComplianceState implements ComplianceState {
  const _ComplianceState({this.appAccepted = false,  Set<String> instanceAcceptedHosts = const {}}): _instanceAcceptedHosts = instanceAcceptedHosts;
  

@override@JsonKey() final  bool appAccepted;
 final  Set<String> _instanceAcceptedHosts;
@override@JsonKey() Set<String> get instanceAcceptedHosts {
  if (_instanceAcceptedHosts is EqualUnmodifiableSetView) return _instanceAcceptedHosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_instanceAcceptedHosts);
}


/// Create a copy of ComplianceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplianceStateCopyWith<_ComplianceState> get copyWith => __$ComplianceStateCopyWithImpl<_ComplianceState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplianceState&&(identical(other.appAccepted, appAccepted) || other.appAccepted == appAccepted)&&const DeepCollectionEquality().equals(other.instanceAcceptedHosts, _instanceAcceptedHosts));
}


@override
int get hashCode {
    return Object.hash(runtimeType,appAccepted,const DeepCollectionEquality().hash(_instanceAcceptedHosts));
}

@override
String toString() {
    return 'ComplianceState(appAccepted: $appAccepted, instanceAcceptedHosts: $instanceAcceptedHosts)';
}


}

/// @nodoc
abstract mixin class _$ComplianceStateCopyWith<$Res> implements $ComplianceStateCopyWith<$Res> {
  factory _$ComplianceStateCopyWith(_ComplianceState value, $Res Function(_ComplianceState) _then) = __$ComplianceStateCopyWithImpl;
@override @useResult
$Res call({
 bool appAccepted, Set<String> instanceAcceptedHosts
});




}
/// @nodoc
class __$ComplianceStateCopyWithImpl<$Res>
    implements _$ComplianceStateCopyWith<$Res> {
  __$ComplianceStateCopyWithImpl(this._self, this._then);

  final _ComplianceState _self;
  final $Res Function(_ComplianceState) _then;

/// Create a copy of ComplianceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appAccepted = null,Object? instanceAcceptedHosts = null,}) {
  return _then(_ComplianceState(
appAccepted: null == appAccepted ? _self.appAccepted : appAccepted // ignore: cast_nullable_to_non_nullable
as bool,instanceAcceptedHosts: null == instanceAcceptedHosts ? _self._instanceAcceptedHosts : instanceAcceptedHosts // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
