// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_operators_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VehicleOperatorFilter {

 String get search; int? get driverId; EntityStatus? get status; int get pageIndex;
/// Create a copy of VehicleOperatorFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleOperatorFilterCopyWith<VehicleOperatorFilter> get copyWith => _$VehicleOperatorFilterCopyWithImpl<VehicleOperatorFilter>(this as VehicleOperatorFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VehicleOperatorFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleOperatorFilter&&(identical(other.search, _this.search) || other.search == _this.search)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.pageIndex, _this.pageIndex) || other.pageIndex == _this.pageIndex));
}


@override
int get hashCode {
  final _this = this as VehicleOperatorFilter;
  return Object.hash(runtimeType,_this.search,_this.driverId,_this.status,_this.pageIndex);
}

@override
String toString() {
  final _this = this as VehicleOperatorFilter;
  return 'VehicleOperatorFilter(search: ${_this.search}, driverId: ${_this.driverId}, status: ${_this.status}, pageIndex: ${_this.pageIndex})';
}


}

/// @nodoc
abstract mixin class $VehicleOperatorFilterCopyWith<$Res>  {
  factory $VehicleOperatorFilterCopyWith(VehicleOperatorFilter value, $Res Function(VehicleOperatorFilter) _then) = _$VehicleOperatorFilterCopyWithImpl;
@useResult
$Res call({
 String search, int? driverId, EntityStatus? status, int pageIndex
});




}
/// @nodoc
class _$VehicleOperatorFilterCopyWithImpl<$Res>
    implements $VehicleOperatorFilterCopyWith<$Res> {
  _$VehicleOperatorFilterCopyWithImpl(this._self, this._then);

  final VehicleOperatorFilter _self;
  final $Res Function(VehicleOperatorFilter) _then;

/// Create a copy of VehicleOperatorFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? driverId = freezed,Object? status = freezed,Object? pageIndex = null,}) {
  return _then(VehicleOperatorFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleOperatorFilter].
extension VehicleOperatorFilterPatterns on VehicleOperatorFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleOperatorFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleOperatorFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleOperatorFilter value)  $default,){
final _that = this;
switch (_that) {
case _VehicleOperatorFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleOperatorFilter value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleOperatorFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  int? driverId,  EntityStatus? status,  int pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleOperatorFilter() when $default != null:
return $default(_that.search,_that.driverId,_that.status,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  int? driverId,  EntityStatus? status,  int pageIndex)  $default,) {final _that = this;
switch (_that) {
case _VehicleOperatorFilter():
return $default(_that.search,_that.driverId,_that.status,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  int? driverId,  EntityStatus? status,  int pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _VehicleOperatorFilter() when $default != null:
return $default(_that.search,_that.driverId,_that.status,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _VehicleOperatorFilter implements VehicleOperatorFilter {
  const _VehicleOperatorFilter({this.search = '', this.driverId, this.status, this.pageIndex = 0});
  

@override@JsonKey() final  String search;
@override final  int? driverId;
@override final  EntityStatus? status;
@override@JsonKey() final  int pageIndex;

/// Create a copy of VehicleOperatorFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleOperatorFilterCopyWith<_VehicleOperatorFilter> get copyWith => __$VehicleOperatorFilterCopyWithImpl<_VehicleOperatorFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleOperatorFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.status, status) || other.status == status)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,search,driverId,status,pageIndex);
}

@override
String toString() {
    return 'VehicleOperatorFilter(search: $search, driverId: $driverId, status: $status, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$VehicleOperatorFilterCopyWith<$Res> implements $VehicleOperatorFilterCopyWith<$Res> {
  factory _$VehicleOperatorFilterCopyWith(_VehicleOperatorFilter value, $Res Function(_VehicleOperatorFilter) _then) = __$VehicleOperatorFilterCopyWithImpl;
@override @useResult
$Res call({
 String search, int? driverId, EntityStatus? status, int pageIndex
});




}
/// @nodoc
class __$VehicleOperatorFilterCopyWithImpl<$Res>
    implements _$VehicleOperatorFilterCopyWith<$Res> {
  __$VehicleOperatorFilterCopyWithImpl(this._self, this._then);

  final _VehicleOperatorFilter _self;
  final $Res Function(_VehicleOperatorFilter) _then;

/// Create a copy of VehicleOperatorFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? driverId = freezed,Object? status = freezed,Object? pageIndex = null,}) {
  return _then(_VehicleOperatorFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus?,pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
