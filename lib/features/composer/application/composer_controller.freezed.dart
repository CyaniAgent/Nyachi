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

 String get text; String? get cw; NotesCreateRequestVisibility get visibility; bool get localOnly; bool get restored; bool get posting; List<String> get fileIds; bool get showPoll; List<String> get pollChoices; bool get pollMultiple; DateTime? get pollExpiresAt; String? get reactionAcceptance; List<String> get visibleUserIds; DateTime? get scheduledAt; bool get showPreview; AppFailure? get error;
/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComposerStateCopyWith<ComposerState> get copyWith => _$ComposerStateCopyWithImpl<ComposerState>(this as ComposerState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ComposerState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComposerState&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.cw, _this.cw) || other.cw == _this.cw)&&(identical(other.visibility, _this.visibility) || other.visibility == _this.visibility)&&(identical(other.localOnly, _this.localOnly) || other.localOnly == _this.localOnly)&&(identical(other.restored, _this.restored) || other.restored == _this.restored)&&(identical(other.posting, _this.posting) || other.posting == _this.posting)&&const DeepCollectionEquality().equals(other.fileIds, _this.fileIds)&&(identical(other.showPoll, _this.showPoll) || other.showPoll == _this.showPoll)&&const DeepCollectionEquality().equals(other.pollChoices, _this.pollChoices)&&(identical(other.pollMultiple, _this.pollMultiple) || other.pollMultiple == _this.pollMultiple)&&(identical(other.pollExpiresAt, _this.pollExpiresAt) || other.pollExpiresAt == _this.pollExpiresAt)&&(identical(other.reactionAcceptance, _this.reactionAcceptance) || other.reactionAcceptance == _this.reactionAcceptance)&&const DeepCollectionEquality().equals(other.visibleUserIds, _this.visibleUserIds)&&(identical(other.scheduledAt, _this.scheduledAt) || other.scheduledAt == _this.scheduledAt)&&(identical(other.showPreview, _this.showPreview) || other.showPreview == _this.showPreview)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as ComposerState;
  return Object.hash(runtimeType,_this.text,_this.cw,_this.visibility,_this.localOnly,_this.restored,_this.posting,const DeepCollectionEquality().hash(_this.fileIds),_this.showPoll,const DeepCollectionEquality().hash(_this.pollChoices),_this.pollMultiple,_this.pollExpiresAt,_this.reactionAcceptance,const DeepCollectionEquality().hash(_this.visibleUserIds),_this.scheduledAt,_this.showPreview,_this.error);
}

@override
String toString() {
  final _this = this as ComposerState;
  return 'ComposerState(text: ${_this.text}, cw: ${_this.cw}, visibility: ${_this.visibility}, localOnly: ${_this.localOnly}, restored: ${_this.restored}, posting: ${_this.posting}, fileIds: ${_this.fileIds}, showPoll: ${_this.showPoll}, pollChoices: ${_this.pollChoices}, pollMultiple: ${_this.pollMultiple}, pollExpiresAt: ${_this.pollExpiresAt}, reactionAcceptance: ${_this.reactionAcceptance}, visibleUserIds: ${_this.visibleUserIds}, scheduledAt: ${_this.scheduledAt}, showPreview: ${_this.showPreview}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $ComposerStateCopyWith<$Res>  {
  factory $ComposerStateCopyWith(ComposerState value, $Res Function(ComposerState) _then) = _$ComposerStateCopyWithImpl;
@useResult
$Res call({
 String text, String? cw, NotesCreateRequestVisibility visibility, bool localOnly, bool restored, bool posting, List<String> fileIds, bool showPoll, List<String> pollChoices, bool pollMultiple, DateTime? pollExpiresAt, String? reactionAcceptance, List<String> visibleUserIds, DateTime? scheduledAt, bool showPreview, AppFailure? error
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
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? cw = freezed,Object? visibility = null,Object? localOnly = null,Object? restored = null,Object? posting = null,Object? fileIds = null,Object? showPoll = null,Object? pollChoices = null,Object? pollMultiple = null,Object? pollExpiresAt = freezed,Object? reactionAcceptance = freezed,Object? visibleUserIds = null,Object? scheduledAt = freezed,Object? showPreview = null,Object? error = freezed,}) {
  return _then(ComposerState(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,cw: freezed == cw ? _self.cw : cw // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as NotesCreateRequestVisibility,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,restored: null == restored ? _self.restored : restored // ignore: cast_nullable_to_non_nullable
as bool,posting: null == posting ? _self.posting : posting // ignore: cast_nullable_to_non_nullable
as bool,fileIds: null == fileIds ? _self.fileIds : fileIds // ignore: cast_nullable_to_non_nullable
as List<String>,showPoll: null == showPoll ? _self.showPoll : showPoll // ignore: cast_nullable_to_non_nullable
as bool,pollChoices: null == pollChoices ? _self.pollChoices : pollChoices // ignore: cast_nullable_to_non_nullable
as List<String>,pollMultiple: null == pollMultiple ? _self.pollMultiple : pollMultiple // ignore: cast_nullable_to_non_nullable
as bool,pollExpiresAt: freezed == pollExpiresAt ? _self.pollExpiresAt : pollExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reactionAcceptance: freezed == reactionAcceptance ? _self.reactionAcceptance : reactionAcceptance // ignore: cast_nullable_to_non_nullable
as String?,visibleUserIds: null == visibleUserIds ? _self.visibleUserIds : visibleUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,showPreview: null == showPreview ? _self.showPreview : showPreview // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  String? cw,  NotesCreateRequestVisibility visibility,  bool localOnly,  bool restored,  bool posting,  List<String> fileIds,  bool showPoll,  List<String> pollChoices,  bool pollMultiple,  DateTime? pollExpiresAt,  String? reactionAcceptance,  List<String> visibleUserIds,  DateTime? scheduledAt,  bool showPreview,  AppFailure? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComposerState() when $default != null:
return $default(_that.text,_that.cw,_that.visibility,_that.localOnly,_that.restored,_that.posting,_that.fileIds,_that.showPoll,_that.pollChoices,_that.pollMultiple,_that.pollExpiresAt,_that.reactionAcceptance,_that.visibleUserIds,_that.scheduledAt,_that.showPreview,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  String? cw,  NotesCreateRequestVisibility visibility,  bool localOnly,  bool restored,  bool posting,  List<String> fileIds,  bool showPoll,  List<String> pollChoices,  bool pollMultiple,  DateTime? pollExpiresAt,  String? reactionAcceptance,  List<String> visibleUserIds,  DateTime? scheduledAt,  bool showPreview,  AppFailure? error)  $default,) {final _that = this;
switch (_that) {
case _ComposerState():
return $default(_that.text,_that.cw,_that.visibility,_that.localOnly,_that.restored,_that.posting,_that.fileIds,_that.showPoll,_that.pollChoices,_that.pollMultiple,_that.pollExpiresAt,_that.reactionAcceptance,_that.visibleUserIds,_that.scheduledAt,_that.showPreview,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  String? cw,  NotesCreateRequestVisibility visibility,  bool localOnly,  bool restored,  bool posting,  List<String> fileIds,  bool showPoll,  List<String> pollChoices,  bool pollMultiple,  DateTime? pollExpiresAt,  String? reactionAcceptance,  List<String> visibleUserIds,  DateTime? scheduledAt,  bool showPreview,  AppFailure? error)?  $default,) {final _that = this;
switch (_that) {
case _ComposerState() when $default != null:
return $default(_that.text,_that.cw,_that.visibility,_that.localOnly,_that.restored,_that.posting,_that.fileIds,_that.showPoll,_that.pollChoices,_that.pollMultiple,_that.pollExpiresAt,_that.reactionAcceptance,_that.visibleUserIds,_that.scheduledAt,_that.showPreview,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ComposerState implements ComposerState {
  const _ComposerState({this.text = '', this.cw, this.visibility = NotesCreateRequestVisibility.public, this.localOnly = false, this.restored = false, this.posting = false,  List<String> fileIds = const <String>[], this.showPoll = false,  List<String> pollChoices = const <String>['', ''], this.pollMultiple = false, this.pollExpiresAt, this.reactionAcceptance,  List<String> visibleUserIds = const <String>[], this.scheduledAt, this.showPreview = false, this.error}): _fileIds = fileIds,_pollChoices = pollChoices,_visibleUserIds = visibleUserIds;
  

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

@override@JsonKey() final  bool showPoll;
 final  List<String> _pollChoices;
@override@JsonKey() List<String> get pollChoices {
  if (_pollChoices is EqualUnmodifiableListView) return _pollChoices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pollChoices);
}

@override@JsonKey() final  bool pollMultiple;
@override final  DateTime? pollExpiresAt;
@override final  String? reactionAcceptance;
 final  List<String> _visibleUserIds;
@override@JsonKey() List<String> get visibleUserIds {
  if (_visibleUserIds is EqualUnmodifiableListView) return _visibleUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_visibleUserIds);
}

@override final  DateTime? scheduledAt;
@override@JsonKey() final  bool showPreview;
@override final  AppFailure? error;

/// Create a copy of ComposerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComposerStateCopyWith<_ComposerState> get copyWith => __$ComposerStateCopyWithImpl<_ComposerState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComposerState&&(identical(other.text, text) || other.text == text)&&(identical(other.cw, cw) || other.cw == cw)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.localOnly, localOnly) || other.localOnly == localOnly)&&(identical(other.restored, restored) || other.restored == restored)&&(identical(other.posting, posting) || other.posting == posting)&&const DeepCollectionEquality().equals(other.fileIds, _fileIds)&&(identical(other.showPoll, showPoll) || other.showPoll == showPoll)&&const DeepCollectionEquality().equals(other.pollChoices, _pollChoices)&&(identical(other.pollMultiple, pollMultiple) || other.pollMultiple == pollMultiple)&&(identical(other.pollExpiresAt, pollExpiresAt) || other.pollExpiresAt == pollExpiresAt)&&(identical(other.reactionAcceptance, reactionAcceptance) || other.reactionAcceptance == reactionAcceptance)&&const DeepCollectionEquality().equals(other.visibleUserIds, _visibleUserIds)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.showPreview, showPreview) || other.showPreview == showPreview)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text,cw,visibility,localOnly,restored,posting,const DeepCollectionEquality().hash(_fileIds),showPoll,const DeepCollectionEquality().hash(_pollChoices),pollMultiple,pollExpiresAt,reactionAcceptance,const DeepCollectionEquality().hash(_visibleUserIds),scheduledAt,showPreview,error);
}

@override
String toString() {
    return 'ComposerState(text: $text, cw: $cw, visibility: $visibility, localOnly: $localOnly, restored: $restored, posting: $posting, fileIds: $fileIds, showPoll: $showPoll, pollChoices: $pollChoices, pollMultiple: $pollMultiple, pollExpiresAt: $pollExpiresAt, reactionAcceptance: $reactionAcceptance, visibleUserIds: $visibleUserIds, scheduledAt: $scheduledAt, showPreview: $showPreview, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ComposerStateCopyWith<$Res> implements $ComposerStateCopyWith<$Res> {
  factory _$ComposerStateCopyWith(_ComposerState value, $Res Function(_ComposerState) _then) = __$ComposerStateCopyWithImpl;
@override @useResult
$Res call({
 String text, String? cw, NotesCreateRequestVisibility visibility, bool localOnly, bool restored, bool posting, List<String> fileIds, bool showPoll, List<String> pollChoices, bool pollMultiple, DateTime? pollExpiresAt, String? reactionAcceptance, List<String> visibleUserIds, DateTime? scheduledAt, bool showPreview, AppFailure? error
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
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? cw = freezed,Object? visibility = null,Object? localOnly = null,Object? restored = null,Object? posting = null,Object? fileIds = null,Object? showPoll = null,Object? pollChoices = null,Object? pollMultiple = null,Object? pollExpiresAt = freezed,Object? reactionAcceptance = freezed,Object? visibleUserIds = null,Object? scheduledAt = freezed,Object? showPreview = null,Object? error = freezed,}) {
  return _then(_ComposerState(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,cw: freezed == cw ? _self.cw : cw // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as NotesCreateRequestVisibility,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,restored: null == restored ? _self.restored : restored // ignore: cast_nullable_to_non_nullable
as bool,posting: null == posting ? _self.posting : posting // ignore: cast_nullable_to_non_nullable
as bool,fileIds: null == fileIds ? _self._fileIds : fileIds // ignore: cast_nullable_to_non_nullable
as List<String>,showPoll: null == showPoll ? _self.showPoll : showPoll // ignore: cast_nullable_to_non_nullable
as bool,pollChoices: null == pollChoices ? _self._pollChoices : pollChoices // ignore: cast_nullable_to_non_nullable
as List<String>,pollMultiple: null == pollMultiple ? _self.pollMultiple : pollMultiple // ignore: cast_nullable_to_non_nullable
as bool,pollExpiresAt: freezed == pollExpiresAt ? _self.pollExpiresAt : pollExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reactionAcceptance: freezed == reactionAcceptance ? _self.reactionAcceptance : reactionAcceptance // ignore: cast_nullable_to_non_nullable
as String?,visibleUserIds: null == visibleUserIds ? _self._visibleUserIds : visibleUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,showPreview: null == showPreview ? _self.showPreview : showPreview // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
