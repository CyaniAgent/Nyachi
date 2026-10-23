// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_feed_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NoteFeedSource {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteFeedSource);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'NoteFeedSource()';
}


}

/// @nodoc
class $NoteFeedSourceCopyWith<$Res>  {
$NoteFeedSourceCopyWith(NoteFeedSource _, $Res Function(NoteFeedSource) __);
}


/// Adds pattern-matching-related methods to [NoteFeedSource].
extension NoteFeedSourcePatterns on NoteFeedSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HomeTimelineSource value)?  home,TResult Function( TagFeedSource value)?  tag,TResult Function( UserNotesSource value)?  user,TResult Function( SearchNotesSource value)?  search,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HomeTimelineSource() when home != null:
return home(_that);case TagFeedSource() when tag != null:
return tag(_that);case UserNotesSource() when user != null:
return user(_that);case SearchNotesSource() when search != null:
return search(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HomeTimelineSource value)  home,required TResult Function( TagFeedSource value)  tag,required TResult Function( UserNotesSource value)  user,required TResult Function( SearchNotesSource value)  search,}){
final _that = this;
switch (_that) {
case HomeTimelineSource():
return home(_that);case TagFeedSource():
return tag(_that);case UserNotesSource():
return user(_that);case SearchNotesSource():
return search(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HomeTimelineSource value)?  home,TResult? Function( TagFeedSource value)?  tag,TResult? Function( UserNotesSource value)?  user,TResult? Function( SearchNotesSource value)?  search,}){
final _that = this;
switch (_that) {
case HomeTimelineSource() when home != null:
return home(_that);case TagFeedSource() when tag != null:
return tag(_that);case UserNotesSource() when user != null:
return user(_that);case SearchNotesSource() when search != null:
return search(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( HomeFeedKind kind)?  home,TResult Function( String tag)?  tag,TResult Function( String userId)?  user,TResult Function( String query)?  search,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HomeTimelineSource() when home != null:
return home(_that.kind);case TagFeedSource() when tag != null:
return tag(_that.tag);case UserNotesSource() when user != null:
return user(_that.userId);case SearchNotesSource() when search != null:
return search(_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( HomeFeedKind kind)  home,required TResult Function( String tag)  tag,required TResult Function( String userId)  user,required TResult Function( String query)  search,}) {final _that = this;
switch (_that) {
case HomeTimelineSource():
return home(_that.kind);case TagFeedSource():
return tag(_that.tag);case UserNotesSource():
return user(_that.userId);case SearchNotesSource():
return search(_that.query);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( HomeFeedKind kind)?  home,TResult? Function( String tag)?  tag,TResult? Function( String userId)?  user,TResult? Function( String query)?  search,}) {final _that = this;
switch (_that) {
case HomeTimelineSource() when home != null:
return home(_that.kind);case TagFeedSource() when tag != null:
return tag(_that.tag);case UserNotesSource() when user != null:
return user(_that.userId);case SearchNotesSource() when search != null:
return search(_that.query);case _:
  return null;

}
}

}

/// @nodoc


class HomeTimelineSource implements NoteFeedSource {
  const HomeTimelineSource(this.kind);
  

 final  HomeFeedKind kind;

/// Create a copy of NoteFeedSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeTimelineSourceCopyWith<HomeTimelineSource> get copyWith => _$HomeTimelineSourceCopyWithImpl<HomeTimelineSource>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeTimelineSource&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind);
}

@override
String toString() {
    return 'NoteFeedSource.home(kind: $kind)';
}


}

/// @nodoc
abstract mixin class $HomeTimelineSourceCopyWith<$Res> implements $NoteFeedSourceCopyWith<$Res> {
  factory $HomeTimelineSourceCopyWith(HomeTimelineSource value, $Res Function(HomeTimelineSource) _then) = _$HomeTimelineSourceCopyWithImpl;
@useResult
$Res call({
 HomeFeedKind kind
});




}
/// @nodoc
class _$HomeTimelineSourceCopyWithImpl<$Res>
    implements $HomeTimelineSourceCopyWith<$Res> {
  _$HomeTimelineSourceCopyWithImpl(this._self, this._then);

  final HomeTimelineSource _self;
  final $Res Function(HomeTimelineSource) _then;

/// Create a copy of NoteFeedSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? kind = null,}) {
  return _then(HomeTimelineSource(
null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HomeFeedKind,
  ));
}


}

/// @nodoc


class TagFeedSource implements NoteFeedSource {
  const TagFeedSource(this.tag);
  

 final  String tag;

/// Create a copy of NoteFeedSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagFeedSourceCopyWith<TagFeedSource> get copyWith => _$TagFeedSourceCopyWithImpl<TagFeedSource>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TagFeedSource&&(identical(other.tag, tag) || other.tag == tag));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tag);
}

@override
String toString() {
    return 'NoteFeedSource.tag(tag: $tag)';
}


}

/// @nodoc
abstract mixin class $TagFeedSourceCopyWith<$Res> implements $NoteFeedSourceCopyWith<$Res> {
  factory $TagFeedSourceCopyWith(TagFeedSource value, $Res Function(TagFeedSource) _then) = _$TagFeedSourceCopyWithImpl;
@useResult
$Res call({
 String tag
});




}
/// @nodoc
class _$TagFeedSourceCopyWithImpl<$Res>
    implements $TagFeedSourceCopyWith<$Res> {
  _$TagFeedSourceCopyWithImpl(this._self, this._then);

  final TagFeedSource _self;
  final $Res Function(TagFeedSource) _then;

/// Create a copy of NoteFeedSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tag = null,}) {
  return _then(TagFeedSource(
null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UserNotesSource implements NoteFeedSource {
  const UserNotesSource(this.userId);
  

 final  String userId;

/// Create a copy of NoteFeedSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserNotesSourceCopyWith<UserNotesSource> get copyWith => _$UserNotesSourceCopyWithImpl<UserNotesSource>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UserNotesSource&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId);
}

@override
String toString() {
    return 'NoteFeedSource.user(userId: $userId)';
}


}

/// @nodoc
abstract mixin class $UserNotesSourceCopyWith<$Res> implements $NoteFeedSourceCopyWith<$Res> {
  factory $UserNotesSourceCopyWith(UserNotesSource value, $Res Function(UserNotesSource) _then) = _$UserNotesSourceCopyWithImpl;
@useResult
$Res call({
 String userId
});




}
/// @nodoc
class _$UserNotesSourceCopyWithImpl<$Res>
    implements $UserNotesSourceCopyWith<$Res> {
  _$UserNotesSourceCopyWithImpl(this._self, this._then);

  final UserNotesSource _self;
  final $Res Function(UserNotesSource) _then;

/// Create a copy of NoteFeedSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,}) {
  return _then(UserNotesSource(
null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SearchNotesSource implements NoteFeedSource {
  const SearchNotesSource(this.query);
  

 final  String query;

/// Create a copy of NoteFeedSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchNotesSourceCopyWith<SearchNotesSource> get copyWith => _$SearchNotesSourceCopyWithImpl<SearchNotesSource>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchNotesSource&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode {
    return Object.hash(runtimeType,query);
}

@override
String toString() {
    return 'NoteFeedSource.search(query: $query)';
}


}

/// @nodoc
abstract mixin class $SearchNotesSourceCopyWith<$Res> implements $NoteFeedSourceCopyWith<$Res> {
  factory $SearchNotesSourceCopyWith(SearchNotesSource value, $Res Function(SearchNotesSource) _then) = _$SearchNotesSourceCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$SearchNotesSourceCopyWithImpl<$Res>
    implements $SearchNotesSourceCopyWith<$Res> {
  _$SearchNotesSourceCopyWithImpl(this._self, this._then);

  final SearchNotesSource _self;
  final $Res Function(SearchNotesSource) _then;

/// Create a copy of NoteFeedSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(SearchNotesSource(
null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
