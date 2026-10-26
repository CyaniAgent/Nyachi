// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'composer_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ComposerState {

 String get text; String? get cw; NotesCreateRequestVisibility get visibility; bool get localOnly; bool get restored; bool get posting; List<String> get fileIds; AppFailure? get error;
/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComposerStateCopyWith<ComposerState> get copyWith => _$ComposerStateCopyWithImpl<ComposerState>(this as ComposerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ComposerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComposerState&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.cw, _this.cw) || other.cw == _this.cw)&&(identical(other.visibility, _this.visibility) || other.visibility == _this.visibility)&&(identical(other.localOnly, _this.localOnly) || other.localOnly == _this.localOnly)&&(identical(other.restored, _this.restored) || other.restored == _this.restored)&&(identical(other.posting, _this.posting) || other.posting == _this.posting)&&const DeepCollectionEquality().equals(other.fileIds, _this.fileIds)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as ComposerState;
  return Object.hash(runtimeType,_this.text,_this.cw,_this.visibility,_this.localOnly,_this.restored,_this.posting,const DeepCollectionEquality().hash(_this.fileIds),_this.error);
}

@override
String toString() {
  final _this = this as ComposerState;
  return 'ComposerState(text: ${_this.text}, cw: ${_this.cw}, visibility: ${_this.visibility}, localOnly: ${_this.localOnly}, restored: ${_this.restored}, posting: ${_this.posting}, fileIds: ${_this.fileIds}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $ComposerStateCopyWith<$Res>  {
  factory $ComposerStateCopyWith(ComposerState value, $Res Function(ComposerState) _then) = _$ComposerStateCopyWithImpl;
@useResult
$Res call({
 String text, String? cw, NotesCreateRequestVisibility visibility, bool localOnly, bool restored, bool posting, List<String> fileIds, AppFailure? error
});




}
/// @nodoc
class _$ComposerStateCopyWithImpl<$Res>
    implements $ComposerStateCopyWith<$Res> {
  _$ComposerStateCopyWithImpl(this._self, this._then);

  final ComposerState _self;
  final $Res Function(ComposerState) _then;

/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? cw = freezed,Object? visibility = null,Object? localOnly = null,Object? restored = null,Object? posting = null,Object? fileIds = null,Object? error = freezed,}) {
  return _then(ComposerState(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,cw: freezed == cw ? _self.cw : cw // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as NotesCreateRequestVisibility,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,restored: null == restored ? _self.restored : restored // ignore: cast_nullable_to_non_nullable
as bool,posting: null == posting ? _self.posting : posting // ignore: cast_nullable_to_non_nullable
as bool,fileIds: null == fileIds ? _self.fileIds : fileIds // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [ComposerState].
extension ComposerStatePatterns on ComposerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComposerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComposerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComposerState value)  $default,){
final _that = this;
switch (_that) {
case _ComposerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComposerState value)?  $default,){
final _that = this;
switch (_that) {
case _ComposerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  String? cw,  NotesCreateRequestVisibility visibility,  bool localOnly,  bool restored,  bool posting,  List<String> fileIds,  AppFailure? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComposerState() when $default != null:
return $default(_that.text,_that.cw,_that.visibility,_that.localOnly,_that.restored,_that.posting,_that.fileIds,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  String? cw,  NotesCreateRequestVisibility visibility,  bool localOnly,  bool restored,  bool posting,  List<String> fileIds,  AppFailure? error)  $default,) {final _that = this;
switch (_that) {
case _ComposerState():
return $default(_that.text,_that.cw,_that.visibility,_that.localOnly,_that.restored,_that.posting,_that.fileIds,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  String? cw,  NotesCreateRequestVisibility visibility,  bool localOnly,  bool restored,  bool posting,  List<String> fileIds,  AppFailure? error)?  $default,) {final _that = this;
switch (_that) {
case _ComposerState() when $default != null:
return $default(_that.text,_that.cw,_that.visibility,_that.localOnly,_that.restored,_that.posting,_that.fileIds,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ComposerState implements ComposerState {
  const _ComposerState({this.text = '', this.cw, this.visibility = NotesCreateRequestVisibility.public, this.localOnly = false, this.restored = false, this.posting = false,  List<String> fileIds = const <String>[], this.error}): _fileIds = fileIds;
  

@override@JsonKey() final  String text;
@override final  String? cw;
@override@JsonKey() final  NotesCreateRequestVisibility visibility;
@override@JsonKey() final  bool localOnly;
@override@JsonKey() final  bool restored;
@override@JsonKey() final  bool posting;
 final  List<String> _fileIds;
@override@JsonKey() List<String> get fileIds {
  if (_fileIds is EqualUnmodifiableListView) return _fileIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fileIds);
}

@override final  AppFailure? error;

/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComposerStateCopyWith<_ComposerState> get copyWith => __$ComposerStateCopyWithImpl<_ComposerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComposerState&&(identical(other.text, text) || other.text == text)&&(identical(other.cw, cw) || other.cw == cw)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.localOnly, localOnly) || other.localOnly == localOnly)&&(identical(other.restored, restored) || other.restored == restored)&&(identical(other.posting, posting) || other.posting == posting)&&const DeepCollectionEquality().equals(other.fileIds, _fileIds)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text,cw,visibility,localOnly,restored,posting,const DeepCollectionEquality().hash(_fileIds),error);
}

@override
String toString() {
    return 'ComposerState(text: $text, cw: $cw, visibility: $visibility, localOnly: $localOnly, restored: $restored, posting: $posting, fileIds: $fileIds, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ComposerStateCopyWith<$Res> implements $ComposerStateCopyWith<$Res> {
  factory _$ComposerStateCopyWith(_ComposerState value, $Res Function(_ComposerState) _then) = __$ComposerStateCopyWithImpl;
@override @useResult
$Res call({
 String text, String? cw, NotesCreateRequestVisibility visibility, bool localOnly, bool restored, bool posting, List<String> fileIds, AppFailure? error
});




}
/// @nodoc
class __$ComposerStateCopyWithImpl<$Res>
    implements _$ComposerStateCopyWith<$Res> {
  __$ComposerStateCopyWithImpl(this._self, this._then);

  final _ComposerState _self;
  final $Res Function(_ComposerState) _then;

/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? cw = freezed,Object? visibility = null,Object? localOnly = null,Object? restored = null,Object? posting = null,Object? fileIds = null,Object? error = freezed,}) {
  return _then(_ComposerState(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,cw: freezed == cw ? _self.cw : cw // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as NotesCreateRequestVisibility,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,restored: null == restored ? _self.restored : restored // ignore: cast_nullable_to_non_nullable
as bool,posting: null == posting ? _self.posting : posting // ignore: cast_nullable_to_non_nullable
as bool,fileIds: null == fileIds ? _self._fileIds : fileIds // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
