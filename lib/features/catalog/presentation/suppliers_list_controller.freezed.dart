// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suppliers_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SupplierFilter {

 String get search; int get pageIndex;
/// Create a copy of SupplierFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplierFilterCopyWith<SupplierFilter> get copyWith => _$SupplierFilterCopyWithImpl<SupplierFilter>(this as SupplierFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SupplierFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupplierFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as SupplierFilter;
  return Object.hash(runtimeType,_this.search,_this.pageIndex);
}

@override
String toString() {
  final _this = this as SupplierFilter;
  return 'SupplierFilter(search: ${_this.search}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $SupplierFilterCopyWith<$Res>  {
  factory $SupplierFilterCopyWith(SupplierFilter value, $Res Function(SupplierFilter) _then) = _$SupplierFilterCopyWithImpl;
@useResult
$Res call({
 String search, int pageIndex
});




}
/// @nodoc
class _$SupplierFilterCopyWithImpl<$Res>
    implements $SupplierFilterCopyWith<$Res> {
  _$SupplierFilterCopyWithImpl(this._self, this._then);

  final SupplierFilter _self;
  final $Res Function(SupplierFilter) _then;

/// Create a copy of SupplierFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? pageIndex = null,}) {
  return _then(SupplierFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SupplierFilter].
extension SupplierFilterPatterns on SupplierFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupplierFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupplierFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupplierFilter value)  $default,){
final _that = this;
switch (_that) {
case _SupplierFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupplierFilter value)?  $default,){
final _that = this;
switch (_that) {
case _SupplierFilter() when $default != null:
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
case _SupplierFilter() when $default != null:
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
case _SupplierFilter():
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
case _SupplierFilter() when $default != null:
return $default(_that.search,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _SupplierFilter implements SupplierFilter {
  const _SupplierFilter({this.search = '', this.pageIndex = 0});
  

@override@JsonKey() final  String search;
@override@JsonKey() final  int pageIndex;

/// Create a copy of SupplierFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupplierFilterCopyWith<_SupplierFilter> get copyWith => __$SupplierFilterCopyWithImpl<_SupplierFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupplierFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,pageIndex);
}

@override
String toString() {
    return 'SupplierFilter(search: $search, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$SupplierFilterCopyWith<$Res> implements $SupplierFilterCopyWith<$Res> {
  factory _$SupplierFilterCopyWith(_SupplierFilter value, $Res Function(_SupplierFilter) _then) = __$SupplierFilterCopyWithImpl;
@override @useResult
$Res call({
 String search, int pageIndex
});




}
/// @nodoc
class __$SupplierFilterCopyWithImpl<$Res>
    implements _$SupplierFilterCopyWith<$Res> {
  __$SupplierFilterCopyWithImpl(this._self, this._then);

  final _SupplierFilter _self;
  final $Res Function(_SupplierFilter) _then;

/// Create a copy of SupplierFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? pageIndex = null,}) {
  return _then(_SupplierFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
