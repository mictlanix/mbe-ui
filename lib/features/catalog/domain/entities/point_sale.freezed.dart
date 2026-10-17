// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'point_sale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PointSale {

 int get pointSaleId; int get facilityId; String get facilityName; String get code; String get name; int get warehouseId; String get warehouseName; String? get comment; EntityStatus get status;
/// Create a copy of PointSale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PointSaleCopyWith<PointSale> get copyWith => _$PointSaleCopyWithImpl<PointSale>(this as PointSale, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PointSale;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PointSale&&(identical(other.pointSaleId, _this.pointSaleId) || other.pointSaleId == _this.pointSaleId)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.facilityName, _this.facilityName) || other.facilityName == _this.facilityName)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.warehouseName, _this.warehouseName) || other.warehouseName == _this.warehouseName)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as PointSale;
  return Object.hash(runtimeType,_this.pointSaleId,_this.facilityId,_this.facilityName,_this.code,_this.name,_this.warehouseId,_this.warehouseName,_this.comment,_this.status);
}

@override
String toString() {
  final _this = this as PointSale;
  return 'PointSale(pointSaleId: ${_this.pointSaleId}, facilityId: ${_this.facilityId}, facilityName: ${_this.facilityName}, code: ${_this.code}, name: ${_this.name}, warehouseId: ${_this.warehouseId}, warehouseName: ${_this.warehouseName}, comment: ${_this.comment}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $PointSaleCopyWith<$Res>  {
  factory $PointSaleCopyWith(PointSale value, $Res Function(PointSale) _then) = _$PointSaleCopyWithImpl;
@useResult
$Res call({
 int pointSaleId, int facilityId, String facilityName, String code, String name, int warehouseId, String warehouseName, String? comment, EntityStatus status
});




}
/// @nodoc
class _$PointSaleCopyWithImpl<$Res>
    implements $PointSaleCopyWith<$Res> {
  _$PointSaleCopyWithImpl(this._self, this._then);

  final PointSale _self;
  final $Res Function(PointSale) _then;

/// Create a copy of PointSale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pointSaleId = null,Object? facilityId = null,Object? facilityName = null,Object? code = null,Object? name = null,Object? warehouseId = null,Object? warehouseName = null,Object? comment = freezed,Object? status = null,}) {
  return _then(PointSale(
pointSaleId: null == pointSaleId ? _self.pointSaleId : pointSaleId // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,facilityName: null == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,warehouseName: null == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [PointSale].
extension PointSalePatterns on PointSale {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PointSale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PointSale() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PointSale value)  $default,){
final _that = this;
switch (_that) {
case _PointSale():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PointSale value)?  $default,){
final _that = this;
switch (_that) {
case _PointSale() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pointSaleId,  int facilityId,  String facilityName,  String code,  String name,  int warehouseId,  String warehouseName,  String? comment,  EntityStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PointSale() when $default != null:
return $default(_that.pointSaleId,_that.facilityId,_that.facilityName,_that.code,_that.name,_that.warehouseId,_that.warehouseName,_that.comment,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pointSaleId,  int facilityId,  String facilityName,  String code,  String name,  int warehouseId,  String warehouseName,  String? comment,  EntityStatus status)  $default,) {final _that = this;
switch (_that) {
case _PointSale():
return $default(_that.pointSaleId,_that.facilityId,_that.facilityName,_that.code,_that.name,_that.warehouseId,_that.warehouseName,_that.comment,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pointSaleId,  int facilityId,  String facilityName,  String code,  String name,  int warehouseId,  String warehouseName,  String? comment,  EntityStatus status)?  $default,) {final _that = this;
switch (_that) {
case _PointSale() when $default != null:
return $default(_that.pointSaleId,_that.facilityId,_that.facilityName,_that.code,_that.name,_that.warehouseId,_that.warehouseName,_that.comment,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _PointSale implements PointSale {
  const _PointSale({required this.pointSaleId, required this.facilityId, required this.facilityName, required this.code, required this.name, required this.warehouseId, required this.warehouseName, this.comment, required this.status});
  

@override final  int pointSaleId;
@override final  int facilityId;
@override final  String facilityName;
@override final  String code;
@override final  String name;
@override final  int warehouseId;
@override final  String warehouseName;
@override final  String? comment;
@override final  EntityStatus status;

/// Create a copy of PointSale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PointSaleCopyWith<_PointSale> get copyWith => __$PointSaleCopyWithImpl<_PointSale>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PointSale&&(identical(other.pointSaleId, pointSaleId) || other.pointSaleId == pointSaleId)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,pointSaleId,facilityId,facilityName,code,name,warehouseId,warehouseName,comment,status);
}

@override
String toString() {
    return 'PointSale(pointSaleId: $pointSaleId, facilityId: $facilityId, facilityName: $facilityName, code: $code, name: $name, warehouseId: $warehouseId, warehouseName: $warehouseName, comment: $comment, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PointSaleCopyWith<$Res> implements $PointSaleCopyWith<$Res> {
  factory _$PointSaleCopyWith(_PointSale value, $Res Function(_PointSale) _then) = __$PointSaleCopyWithImpl;
@override @useResult
$Res call({
 int pointSaleId, int facilityId, String facilityName, String code, String name, int warehouseId, String warehouseName, String? comment, EntityStatus status
});




}
/// @nodoc
class __$PointSaleCopyWithImpl<$Res>
    implements _$PointSaleCopyWith<$Res> {
  __$PointSaleCopyWithImpl(this._self, this._then);

  final _PointSale _self;
  final $Res Function(_PointSale) _then;

/// Create a copy of PointSale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pointSaleId = null,Object? facilityId = null,Object? facilityName = null,Object? code = null,Object? name = null,Object? warehouseId = null,Object? warehouseName = null,Object? comment = freezed,Object? status = null,}) {
  return _then(_PointSale(
pointSaleId: null == pointSaleId ? _self.pointSaleId : pointSaleId // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,facilityName: null == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,warehouseName: null == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}


}

// dart format on
