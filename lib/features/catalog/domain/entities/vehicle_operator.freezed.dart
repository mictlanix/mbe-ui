// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_operator.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VehicleOperator {

 int get vehicleOperatorId; int get driverId; String get driverName; String get licenseType; String get driverLicenseNumber; DateTime get issueDate; DateTime get expirationDate; String get issuingLocation; EntityStatus get status; int? get daysUntilExpiry; bool get hasLicensePhoto;
/// Create a copy of VehicleOperator
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleOperatorCopyWith<VehicleOperator> get copyWith => _$VehicleOperatorCopyWithImpl<VehicleOperator>(this as VehicleOperator, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VehicleOperator;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleOperator&&(identical(other.vehicleOperatorId, _this.vehicleOperatorId) || other.vehicleOperatorId == _this.vehicleOperatorId)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId)&&(identical(other.driverName, _this.driverName) || other.driverName == _this.driverName)&&(identical(other.licenseType, _this.licenseType) || other.licenseType == _this.licenseType)&&(identical(other.driverLicenseNumber, _this.driverLicenseNumber) || other.driverLicenseNumber == _this.driverLicenseNumber)&&(identical(other.issueDate, _this.issueDate) || other.issueDate == _this.issueDate)&&(identical(other.expirationDate, _this.expirationDate) || other.expirationDate == _this.expirationDate)&&(identical(other.issuingLocation, _this.issuingLocation) || other.issuingLocation == _this.issuingLocation)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.daysUntilExpiry, _this.daysUntilExpiry) || other.daysUntilExpiry == _this.daysUntilExpiry)&&(identical(other.hasLicensePhoto, _this.hasLicensePhoto) || other.hasLicensePhoto == _this.hasLicensePhoto));
}


@override
int get hashCode {
  final _this = this as VehicleOperator;
  return Object.hash(runtimeType,_this.vehicleOperatorId,_this.driverId,_this.driverName,_this.licenseType,_this.driverLicenseNumber,_this.issueDate,_this.expirationDate,_this.issuingLocation,_this.status,_this.daysUntilExpiry,_this.hasLicensePhoto);
}

@override
String toString() {
  final _this = this as VehicleOperator;
  return 'VehicleOperator(vehicleOperatorId: ${_this.vehicleOperatorId}, driverId: ${_this.driverId}, driverName: ${_this.driverName}, licenseType: ${_this.licenseType}, driverLicenseNumber: ${_this.driverLicenseNumber}, issueDate: ${_this.issueDate}, expirationDate: ${_this.expirationDate}, issuingLocation: ${_this.issuingLocation}, status: ${_this.status}, daysUntilExpiry: ${_this.daysUntilExpiry}, hasLicensePhoto: ${_this.hasLicensePhoto})';
}


}

/// @nodoc
abstract mixin class $VehicleOperatorCopyWith<$Res>  {
  factory $VehicleOperatorCopyWith(VehicleOperator value, $Res Function(VehicleOperator) _then) = _$VehicleOperatorCopyWithImpl;
@useResult
$Res call({
 int vehicleOperatorId, int driverId, String driverName, String licenseType, String driverLicenseNumber, DateTime issueDate, DateTime expirationDate, String issuingLocation, EntityStatus status, int? daysUntilExpiry, bool hasLicensePhoto
});




}
/// @nodoc
class _$VehicleOperatorCopyWithImpl<$Res>
    implements $VehicleOperatorCopyWith<$Res> {
  _$VehicleOperatorCopyWithImpl(this._self, this._then);

  final VehicleOperator _self;
  final $Res Function(VehicleOperator) _then;

/// Create a copy of VehicleOperator
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vehicleOperatorId = null,Object? driverId = null,Object? driverName = null,Object? licenseType = null,Object? driverLicenseNumber = null,Object? issueDate = null,Object? expirationDate = null,Object? issuingLocation = null,Object? status = null,Object? daysUntilExpiry = freezed,Object? hasLicensePhoto = null,}) {
  return _then(VehicleOperator(
vehicleOperatorId: null == vehicleOperatorId ? _self.vehicleOperatorId : vehicleOperatorId // ignore: cast_nullable_to_non_nullable
as int,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as int,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,licenseType: null == licenseType ? _self.licenseType : licenseType // ignore: cast_nullable_to_non_nullable
as String,driverLicenseNumber: null == driverLicenseNumber ? _self.driverLicenseNumber : driverLicenseNumber // ignore: cast_nullable_to_non_nullable
as String,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,expirationDate: null == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime,issuingLocation: null == issuingLocation ? _self.issuingLocation : issuingLocation // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,daysUntilExpiry: freezed == daysUntilExpiry ? _self.daysUntilExpiry : daysUntilExpiry // ignore: cast_nullable_to_non_nullable
as int?,hasLicensePhoto: null == hasLicensePhoto ? _self.hasLicensePhoto : hasLicensePhoto // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleOperator].
extension VehicleOperatorPatterns on VehicleOperator {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleOperator value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleOperator() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleOperator value)  $default,){
final _that = this;
switch (_that) {
case _VehicleOperator():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleOperator value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleOperator() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int vehicleOperatorId,  int driverId,  String driverName,  String licenseType,  String driverLicenseNumber,  DateTime issueDate,  DateTime expirationDate,  String issuingLocation,  EntityStatus status,  int? daysUntilExpiry,  bool hasLicensePhoto)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleOperator() when $default != null:
return $default(_that.vehicleOperatorId,_that.driverId,_that.driverName,_that.licenseType,_that.driverLicenseNumber,_that.issueDate,_that.expirationDate,_that.issuingLocation,_that.status,_that.daysUntilExpiry,_that.hasLicensePhoto);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int vehicleOperatorId,  int driverId,  String driverName,  String licenseType,  String driverLicenseNumber,  DateTime issueDate,  DateTime expirationDate,  String issuingLocation,  EntityStatus status,  int? daysUntilExpiry,  bool hasLicensePhoto)  $default,) {final _that = this;
switch (_that) {
case _VehicleOperator():
return $default(_that.vehicleOperatorId,_that.driverId,_that.driverName,_that.licenseType,_that.driverLicenseNumber,_that.issueDate,_that.expirationDate,_that.issuingLocation,_that.status,_that.daysUntilExpiry,_that.hasLicensePhoto);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int vehicleOperatorId,  int driverId,  String driverName,  String licenseType,  String driverLicenseNumber,  DateTime issueDate,  DateTime expirationDate,  String issuingLocation,  EntityStatus status,  int? daysUntilExpiry,  bool hasLicensePhoto)?  $default,) {final _that = this;
switch (_that) {
case _VehicleOperator() when $default != null:
return $default(_that.vehicleOperatorId,_that.driverId,_that.driverName,_that.licenseType,_that.driverLicenseNumber,_that.issueDate,_that.expirationDate,_that.issuingLocation,_that.status,_that.daysUntilExpiry,_that.hasLicensePhoto);case _:
  return null;

}
}

}

/// @nodoc


class _VehicleOperator implements VehicleOperator {
  const _VehicleOperator({required this.vehicleOperatorId, required this.driverId, required this.driverName, required this.licenseType, required this.driverLicenseNumber, required this.issueDate, required this.expirationDate, required this.issuingLocation, required this.status, this.daysUntilExpiry, this.hasLicensePhoto = false});
  

@override final  int vehicleOperatorId;
@override final  int driverId;
@override final  String driverName;
@override final  String licenseType;
@override final  String driverLicenseNumber;
@override final  DateTime issueDate;
@override final  DateTime expirationDate;
@override final  String issuingLocation;
@override final  EntityStatus status;
@override final  int? daysUntilExpiry;
@override@JsonKey() final  bool hasLicensePhoto;

/// Create a copy of VehicleOperator
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleOperatorCopyWith<_VehicleOperator> get copyWith => __$VehicleOperatorCopyWithImpl<_VehicleOperator>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleOperator&&(identical(other.vehicleOperatorId, vehicleOperatorId) || other.vehicleOperatorId == vehicleOperatorId)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.licenseType, licenseType) || other.licenseType == licenseType)&&(identical(other.driverLicenseNumber, driverLicenseNumber) || other.driverLicenseNumber == driverLicenseNumber)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.issuingLocation, issuingLocation) || other.issuingLocation == issuingLocation)&&(identical(other.status, status) || other.status == status)&&(identical(other.daysUntilExpiry, daysUntilExpiry) || other.daysUntilExpiry == daysUntilExpiry)&&(identical(other.hasLicensePhoto, hasLicensePhoto) || other.hasLicensePhoto == hasLicensePhoto));
}


@override
int get hashCode {
    return Object.hash(runtimeType,vehicleOperatorId,driverId,driverName,licenseType,driverLicenseNumber,issueDate,expirationDate,issuingLocation,status,daysUntilExpiry,hasLicensePhoto);
}

@override
String toString() {
    return 'VehicleOperator(vehicleOperatorId: $vehicleOperatorId, driverId: $driverId, driverName: $driverName, licenseType: $licenseType, driverLicenseNumber: $driverLicenseNumber, issueDate: $issueDate, expirationDate: $expirationDate, issuingLocation: $issuingLocation, status: $status, daysUntilExpiry: $daysUntilExpiry, hasLicensePhoto: $hasLicensePhoto)';
}


}

/// @nodoc
abstract mixin class _$VehicleOperatorCopyWith<$Res> implements $VehicleOperatorCopyWith<$Res> {
  factory _$VehicleOperatorCopyWith(_VehicleOperator value, $Res Function(_VehicleOperator) _then) = __$VehicleOperatorCopyWithImpl;
@override @useResult
$Res call({
 int vehicleOperatorId, int driverId, String driverName, String licenseType, String driverLicenseNumber, DateTime issueDate, DateTime expirationDate, String issuingLocation, EntityStatus status, int? daysUntilExpiry, bool hasLicensePhoto
});




}
/// @nodoc
class __$VehicleOperatorCopyWithImpl<$Res>
    implements _$VehicleOperatorCopyWith<$Res> {
  __$VehicleOperatorCopyWithImpl(this._self, this._then);

  final _VehicleOperator _self;
  final $Res Function(_VehicleOperator) _then;

/// Create a copy of VehicleOperator
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vehicleOperatorId = null,Object? driverId = null,Object? driverName = null,Object? licenseType = null,Object? driverLicenseNumber = null,Object? issueDate = null,Object? expirationDate = null,Object? issuingLocation = null,Object? status = null,Object? daysUntilExpiry = freezed,Object? hasLicensePhoto = null,}) {
  return _then(_VehicleOperator(
vehicleOperatorId: null == vehicleOperatorId ? _self.vehicleOperatorId : vehicleOperatorId // ignore: cast_nullable_to_non_nullable
as int,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as int,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,licenseType: null == licenseType ? _self.licenseType : licenseType // ignore: cast_nullable_to_non_nullable
as String,driverLicenseNumber: null == driverLicenseNumber ? _self.driverLicenseNumber : driverLicenseNumber // ignore: cast_nullable_to_non_nullable
as String,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,expirationDate: null == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime,issuingLocation: null == issuingLocation ? _self.issuingLocation : issuingLocation // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,daysUntilExpiry: freezed == daysUntilExpiry ? _self.daysUntilExpiry : daysUntilExpiry // ignore: cast_nullable_to_non_nullable
as int?,hasLicensePhoto: null == hasLicensePhoto ? _self.hasLicensePhoto : hasLicensePhoto // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
