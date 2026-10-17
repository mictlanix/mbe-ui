// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ListQuery {

 String get search; int get pageIndex; Map<String, List<String>> get facets;
/// Create a copy of ListQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListQueryCopyWith<ListQuery> get copyWith => _$ListQueryCopyWithImpl<ListQuery>(this as ListQuery, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ListQuery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListQuery&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex)&&const DeepCollectionEquality().equals(other.facets, _this.facets));
}


@override
int get hashCode {
  final _this = this as ListQuery;
  return Object.hash(runtimeType,_this.search,_this.pageIndex,const DeepCollectionEquality().hash(_this.facets));
}

@override
String toString() {
  final _this = this as ListQuery;
  return 'ListQuery(search: ${_this.search}, pageIndex: ${_this.pageIndex}, facets: ${_this.facets})';
}


}

/// @nodoc
abstract mixin class $ListQueryCopyWith<$Res>  {
  factory $ListQueryCopyWith(ListQuery value, $Res Function(ListQuery) _then) = _$ListQueryCopyWithImpl;
@useResult
$Res call({
 String search, int pageIndex, Map<String, List<String>> facets
});




}
/// @nodoc
class _$ListQueryCopyWithImpl<$Res>
    implements $ListQueryCopyWith<$Res> {
  _$ListQueryCopyWithImpl(this._self, this._then);

  final ListQuery _self;
  final $Res Function(ListQuery) _then;

/// Create a copy of ListQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? pageIndex = null,Object? facets = null,}) {
  return _then(ListQuery(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,facets: null == facets ? _self.facets : facets // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}

}


/// Adds pattern-matching-related methods to [ListQuery].
extension ListQueryPatterns on ListQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListQuery value)  $default,){
final _that = this;
switch (_that) {
case _ListQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListQuery value)?  $default,){
final _that = this;
switch (_that) {
case _ListQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  int pageIndex,  Map<String, List<String>> facets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListQuery() when $default != null:
return $default(_that.search,_that.pageIndex,_that.facets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  int pageIndex,  Map<String, List<String>> facets)  $default,) {final _that = this;
switch (_that) {
case _ListQuery():
return $default(_that.search,_that.pageIndex,_that.facets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  int pageIndex,  Map<String, List<String>> facets)?  $default,) {final _that = this;
switch (_that) {
case _ListQuery() when $default != null:
return $default(_that.search,_that.pageIndex,_that.facets);case _:
  return null;

}
}

}

/// @nodoc


class _ListQuery implements ListQuery {
  const _ListQuery({this.search = '', this.pageIndex = 0,  Map<String, List<String>> facets = const <String, List<String>>{}}): _facets = facets;
  

@override@JsonKey() final  String search;
@override@JsonKey() final  int pageIndex;
 final  Map<String, List<String>> _facets;
@override@JsonKey() Map<String, List<String>> get facets {
  if (_facets is EqualUnmodifiableMapView) return _facets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_facets);
}


/// Create a copy of ListQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListQueryCopyWith<_ListQuery> get copyWith => __$ListQueryCopyWithImpl<_ListQuery>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListQuery&&(identical(other.search, search) || other.search == search)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&const DeepCollectionEquality().equals(other.facets, _facets));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,pageIndex,const DeepCollectionEquality().hash(_facets));
}

@override
String toString() {
    return 'ListQuery(search: $search, pageIndex: $pageIndex, facets: $facets)';
}


}

/// @nodoc
abstract mixin class _$ListQueryCopyWith<$Res> implements $ListQueryCopyWith<$Res> {
  factory _$ListQueryCopyWith(_ListQuery value, $Res Function(_ListQuery) _then) = __$ListQueryCopyWithImpl;
@override @useResult
$Res call({
 String search, int pageIndex, Map<String, List<String>> facets
});




}
/// @nodoc
class __$ListQueryCopyWithImpl<$Res>
    implements _$ListQueryCopyWith<$Res> {
  __$ListQueryCopyWithImpl(this._self, this._then);

  final _ListQuery _self;
  final $Res Function(_ListQuery) _then;

/// Create a copy of ListQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? pageIndex = null,Object? facets = null,}) {
  return _then(_ListQuery(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,facets: null == facets ? _self._facets : facets // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,
  ));
}


}

// dart format on
