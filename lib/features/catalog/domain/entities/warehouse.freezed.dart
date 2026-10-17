// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'warehouse.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Warehouse {

 int get warehouseId; int get facilityId; String get facilityName; String get code; String get name; String? get comment; EntityStatus get status;
/// Create a copy of Warehouse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarehouseCopyWith<Warehouse> get copyWith => _$WarehouseCopyWithImpl<Warehouse>(this as Warehouse, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Warehouse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Warehouse&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.facilityName, _this.facilityName) || other.facilityName == _this.facilityName)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as Warehouse;
  return Object.hash(runtimeType,_this.warehouseId,_this.facilityId,_this.facilityName,_this.code,_this.name,_this.comment,_this.status);
}

@override
String toString() {
  final _this = this as Warehouse;
  return 'Warehouse(warehouseId: ${_this.warehouseId}, facilityId: ${_this.facilityId}, facilityName: ${_this.facilityName}, code: ${_this.code}, name: ${_this.name}, comment: ${_this.comment}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $WarehouseCopyWith<$Res>  {
  factory $WarehouseCopyWith(Warehouse value, $Res Function(Warehouse) _then) = _$WarehouseCopyWithImpl;
@useResult
$Res call({
 int warehouseId, int facilityId, String facilityName, String code, String name, String? comment, EntityStatus status
});




}
/// @nodoc
class _$WarehouseCopyWithImpl<$Res>
    implements $WarehouseCopyWith<$Res> {
  _$WarehouseCopyWithImpl(this._self, this._then);

  final Warehouse _self;
  final $Res Function(Warehouse) _then;

/// Create a copy of Warehouse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? warehouseId = null,Object? facilityId = null,Object? facilityName = null,Object? code = null,Object? name = null,Object? comment = freezed,Object? status = null,}) {
  return _then(Warehouse(
warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,facilityName: null == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Warehouse].
extension WarehousePatterns on Warehouse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Warehouse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Warehouse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Warehouse value)  $default,){
final _that = this;
switch (_that) {
case _Warehouse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Warehouse value)?  $default,){
final _that = this;
switch (_that) {
case _Warehouse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int warehouseId,  int facilityId,  String facilityName,  String code,  String name,  String? comment,  EntityStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Warehouse() when $default != null:
return $default(_that.warehouseId,_that.facilityId,_that.facilityName,_that.code,_that.name,_that.comment,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int warehouseId,  int facilityId,  String facilityName,  String code,  String name,  String? comment,  EntityStatus status)  $default,) {final _that = this;
switch (_that) {
case _Warehouse():
return $default(_that.warehouseId,_that.facilityId,_that.facilityName,_that.code,_that.name,_that.comment,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int warehouseId,  int facilityId,  String facilityName,  String code,  String name,  String? comment,  EntityStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Warehouse() when $default != null:
return $default(_that.warehouseId,_that.facilityId,_that.facilityName,_that.code,_that.name,_that.comment,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _Warehouse implements Warehouse {
  const _Warehouse({required this.warehouseId, required this.facilityId, required this.facilityName, required this.code, required this.name, this.comment, required this.status});
  

@override final  int warehouseId;
@override final  int facilityId;
@override final  String facilityName;
@override final  String code;
@override final  String name;
@override final  String? comment;
@override final  EntityStatus status;

/// Create a copy of Warehouse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WarehouseCopyWith<_Warehouse> get copyWith => __$WarehouseCopyWithImpl<_Warehouse>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Warehouse&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,warehouseId,facilityId,facilityName,code,name,comment,status);
}

@override
String toString() {
    return 'Warehouse(warehouseId: $warehouseId, facilityId: $facilityId, facilityName: $facilityName, code: $code, name: $name, comment: $comment, status: $status)';
}


}

/// @nodoc
abstract mixin class _$WarehouseCopyWith<$Res> implements $WarehouseCopyWith<$Res> {
  factory _$WarehouseCopyWith(_Warehouse value, $Res Function(_Warehouse) _then) = __$WarehouseCopyWithImpl;
@override @useResult
$Res call({
 int warehouseId, int facilityId, String facilityName, String code, String name, String? comment, EntityStatus status
});




}
/// @nodoc
class __$WarehouseCopyWithImpl<$Res>
    implements _$WarehouseCopyWith<$Res> {
  __$WarehouseCopyWithImpl(this._self, this._then);

  final _Warehouse _self;
  final $Res Function(_Warehouse) _then;

/// Create a copy of Warehouse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? warehouseId = null,Object? facilityId = null,Object? facilityName = null,Object? code = null,Object? name = null,Object? comment = freezed,Object? status = null,}) {
  return _then(_Warehouse(
warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,facilityName: null == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}


}

// dart format on
