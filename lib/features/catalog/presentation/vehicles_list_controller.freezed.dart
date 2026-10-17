// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicles_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VehicleFilter {

 String get search; EntityStatus? get status; int get pageIndex;
/// Create a copy of VehicleFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleFilterCopyWith<VehicleFilter> get copyWith => _$VehicleFilterCopyWithImpl<VehicleFilter>(this as VehicleFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VehicleFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as VehicleFilter;
  return Object.hash(runtimeType,_this.search,_this.status,_this.pageIndex);
}

@override
String toString() {
  final _this = this as VehicleFilter;
  return 'VehicleFilter(search: ${_this.search}, status: ${_this.status}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $VehicleFilterCopyWith<$Res>  {
  factory $VehicleFilterCopyWith(VehicleFilter value, $Res Function(VehicleFilter) _then) = _$VehicleFilterCopyWithImpl;
@useResult
$Res call({
 String search, EntityStatus? status, int pageIndex
});




}
/// @nodoc
class _$VehicleFilterCopyWithImpl<$Res>
    implements $VehicleFilterCopyWith<$Res> {
  _$VehicleFilterCopyWithImpl(this._self, this._then);

  final VehicleFilter _self;
  final $Res Function(VehicleFilter) _then;

/// Create a copy of VehicleFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? status = freezed,Object? pageIndex = null,}) {
  return _then(VehicleFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleFilter].
extension VehicleFilterPatterns on VehicleFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleFilter value)  $default,){
final _that = this;
switch (_that) {
case _VehicleFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleFilter value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  EntityStatus? status,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleFilter() when $default != null:
return $default(_that.search,_that.status,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  EntityStatus? status,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _VehicleFilter():
return $default(_that.search,_that.status,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  EntityStatus? status,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _VehicleFilter() when $default != null:
return $default(_that.search,_that.status,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _VehicleFilter implements VehicleFilter {
  const _VehicleFilter({this.search = '', this.status, this.pageIndex = 0});
  

@override@JsonKey() final  String search;
@override final  EntityStatus? status;
@override@JsonKey() final  int pageIndex;

/// Create a copy of VehicleFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleFilterCopyWith<_VehicleFilter> get copyWith => __$VehicleFilterCopyWithImpl<_VehicleFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.status, status) || other.status == status)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,status,pageIndex);
}

@override
String toString() {
    return 'VehicleFilter(search: $search, status: $status, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$VehicleFilterCopyWith<$Res> implements $VehicleFilterCopyWith<$Res> {
  factory _$VehicleFilterCopyWith(_VehicleFilter value, $Res Function(_VehicleFilter) _then) = __$VehicleFilterCopyWithImpl;
@override @useResult
$Res call({
 String search, EntityStatus? status, int pageIndex
});




}
/// @nodoc
class __$VehicleFilterCopyWithImpl<$Res>
    implements _$VehicleFilterCopyWith<$Res> {
  __$VehicleFilterCopyWithImpl(this._self, this._then);

  final _VehicleFilter _self;
  final $Res Function(_VehicleFilter) _then;

/// Create a copy of VehicleFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? status = freezed,Object? pageIndex = null,}) {
  return _then(_VehicleFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
