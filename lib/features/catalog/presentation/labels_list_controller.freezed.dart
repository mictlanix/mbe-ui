// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'labels_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LabelFilter {

 String get search; int get pageIndex;
/// Create a copy of LabelFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabelFilterCopyWith<LabelFilter> get copyWith => _$LabelFilterCopyWithImpl<LabelFilter>(this as LabelFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LabelFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabelFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as LabelFilter;
  return Object.hash(runtimeType,_this.search,_this.pageIndex);
}

@override
String toString() {
  final _this = this as LabelFilter;
  return 'LabelFilter(search: ${_this.search}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $LabelFilterCopyWith<$Res>  {
  factory $LabelFilterCopyWith(LabelFilter value, $Res Function(LabelFilter) _then) = _$LabelFilterCopyWithImpl;
@useResult
$Res call({
 String search, int pageIndex
});




}
/// @nodoc
class _$LabelFilterCopyWithImpl<$Res>
    implements $LabelFilterCopyWith<$Res> {
  _$LabelFilterCopyWithImpl(this._self, this._then);

  final LabelFilter _self;
  final $Res Function(LabelFilter) _then;

/// Create a copy of LabelFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? pageIndex = null,}) {
  return _then(LabelFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LabelFilter].
extension LabelFilterPatterns on LabelFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabelFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabelFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabelFilter value)  $default,){
final _that = this;
switch (_that) {
case _LabelFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabelFilter value)?  $default,){
final _that = this;
switch (_that) {
case _LabelFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabelFilter() when $default != null:
return $default(_that.search,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _LabelFilter():
return $default(_that.search,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _LabelFilter() when $default != null:
return $default(_that.search,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _LabelFilter implements LabelFilter {
  const _LabelFilter({this.search = '', this.pageIndex = 0});
  

@override@JsonKey() final  String search;
@override@JsonKey() final  int pageIndex;

/// Create a copy of LabelFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabelFilterCopyWith<_LabelFilter> get copyWith => __$LabelFilterCopyWithImpl<_LabelFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabelFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,pageIndex);
}

@override
String toString() {
    return 'LabelFilter(search: $search, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$LabelFilterCopyWith<$Res> implements $LabelFilterCopyWith<$Res> {
  factory _$LabelFilterCopyWith(_LabelFilter value, $Res Function(_LabelFilter) _then) = __$LabelFilterCopyWithImpl;
@override @useResult
$Res call({
 String search, int pageIndex
});




}
/// @nodoc
class __$LabelFilterCopyWithImpl<$Res>
    implements _$LabelFilterCopyWith<$Res> {
  __$LabelFilterCopyWithImpl(this._self, this._then);

  final _LabelFilter _self;
  final $Res Function(_LabelFilter) _then;

/// Create a copy of LabelFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? pageIndex = null,}) {
  return _then(_LabelFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
