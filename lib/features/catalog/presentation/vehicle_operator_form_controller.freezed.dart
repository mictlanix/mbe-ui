// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_operator_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VehicleOperatorFormState {

 int? get vehicleOperatorId; int? get driverId; String get driverDisplayText; String get licenseType; String get driverLicenseNumber; DateTime? get issueDate; DateTime? get expirationDate; String get issuingLocation; EntityStatus get status; bool get loading; bool get submitting; bool get saved; bool get deleted; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of VehicleOperatorFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleOperatorFormStateCopyWith<VehicleOperatorFormState> get copyWith => _$VehicleOperatorFormStateCopyWithImpl<VehicleOperatorFormState>(this as VehicleOperatorFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as VehicleOperatorFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleOperatorFormState&&(identical(other.vehicleOperatorId, _this.vehicleOperatorId) || other.vehicleOperatorId == _this.vehicleOperatorId)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId)&&(identical(other.driverDisplayText, _this.driverDisplayText) || other.driverDisplayText == _this.driverDisplayText)&&(identical(other.licenseType, _this.licenseType) || other.licenseType == _this.licenseType)&&(identical(other.driverLicenseNumber, _this.driverLicenseNumber) || other.driverLicenseNumber == _this.driverLicenseNumber)&&(identical(other.issueDate, _this.issueDate) || other.issueDate == _this.issueDate)&&(identical(other.expirationDate, _this.expirationDate) || other.expirationDate == _this.expirationDate)&&(identical(other.issuingLocation, _this.issuingLocation) || other.issuingLocation == _this.issuingLocation)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as VehicleOperatorFormState;
  return Object.hash(runtimeType,_this.vehicleOperatorId,_this.driverId,_this.driverDisplayText,_this.licenseType,_this.driverLicenseNumber,_this.issueDate,_this.expirationDate,_this.issuingLocation,_this.status,_this.loading,_this.submitting,_this.saved,_this.deleted,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as VehicleOperatorFormState;
  return 'VehicleOperatorFormState(vehicleOperatorId: ${_this.vehicleOperatorId}, driverId: ${_this.driverId}, driverDisplayText: ${_this.driverDisplayText}, licenseType: ${_this.licenseType}, driverLicenseNumber: ${_this.driverLicenseNumber}, issueDate: ${_this.issueDate}, expirationDate: ${_this.expirationDate}, issuingLocation: ${_this.issuingLocation}, status: ${_this.status}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, deleted: ${_this.deleted}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $VehicleOperatorFormStateCopyWith<$Res>  {
  factory $VehicleOperatorFormStateCopyWith(VehicleOperatorFormState value, $Res Function(VehicleOperatorFormState) _then) = _$VehicleOperatorFormStateCopyWithImpl;
@useResult
$Res call({
 int? vehicleOperatorId, int? driverId, String driverDisplayText, String licenseType, String driverLicenseNumber, DateTime? issueDate, DateTime? expirationDate, String issuingLocation, EntityStatus status, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$VehicleOperatorFormStateCopyWithImpl<$Res>
    implements $VehicleOperatorFormStateCopyWith<$Res> {
  _$VehicleOperatorFormStateCopyWithImpl(this._self, this._then);

  final VehicleOperatorFormState _self;
  final $Res Function(VehicleOperatorFormState) _then;

/// Create a copy of VehicleOperatorFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vehicleOperatorId = freezed,Object? driverId = freezed,Object? driverDisplayText = null,Object? licenseType = null,Object? driverLicenseNumber = null,Object? issueDate = freezed,Object? expirationDate = freezed,Object? issuingLocation = null,Object? status = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(VehicleOperatorFormState(
vehicleOperatorId: freezed == vehicleOperatorId ? _self.vehicleOperatorId : vehicleOperatorId // ignore: cast_nullable_to_non_nullable
as int?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as int?,driverDisplayText: null == driverDisplayText ? _self.driverDisplayText : driverDisplayText // ignore: cast_nullable_to_non_nullable
as String,licenseType: null == licenseType ? _self.licenseType : licenseType // ignore: cast_nullable_to_non_nullable
as String,driverLicenseNumber: null == driverLicenseNumber ? _self.driverLicenseNumber : driverLicenseNumber // ignore: cast_nullable_to_non_nullable
as String,issueDate: freezed == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,issuingLocation: null == issuingLocation ? _self.issuingLocation : issuingLocation // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleOperatorFormState].
extension VehicleOperatorFormStatePatterns on VehicleOperatorFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleOperatorFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleOperatorFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleOperatorFormState value)  $default,){
final _that = this;
switch (_that) {
case _VehicleOperatorFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleOperatorFormState value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleOperatorFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? vehicleOperatorId,  int? driverId,  String driverDisplayText,  String licenseType,  String driverLicenseNumber,  DateTime? issueDate,  DateTime? expirationDate,  String issuingLocation,  EntityStatus status,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleOperatorFormState() when $default != null:
return $default(_that.vehicleOperatorId,_that.driverId,_that.driverDisplayText,_that.licenseType,_that.driverLicenseNumber,_that.issueDate,_that.expirationDate,_that.issuingLocation,_that.status,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? vehicleOperatorId,  int? driverId,  String driverDisplayText,  String licenseType,  String driverLicenseNumber,  DateTime? issueDate,  DateTime? expirationDate,  String issuingLocation,  EntityStatus status,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _VehicleOperatorFormState():
return $default(_that.vehicleOperatorId,_that.driverId,_that.driverDisplayText,_that.licenseType,_that.driverLicenseNumber,_that.issueDate,_that.expirationDate,_that.issuingLocation,_that.status,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? vehicleOperatorId,  int? driverId,  String driverDisplayText,  String licenseType,  String driverLicenseNumber,  DateTime? issueDate,  DateTime? expirationDate,  String issuingLocation,  EntityStatus status,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _VehicleOperatorFormState() when $default != null:
return $default(_that.vehicleOperatorId,_that.driverId,_that.driverDisplayText,_that.licenseType,_that.driverLicenseNumber,_that.issueDate,_that.expirationDate,_that.issuingLocation,_that.status,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _VehicleOperatorFormState implements VehicleOperatorFormState {
  const _VehicleOperatorFormState({this.vehicleOperatorId, this.driverId, this.driverDisplayText = '', this.licenseType = '', this.driverLicenseNumber = '', this.issueDate, this.expirationDate, this.issuingLocation = '', this.status = EntityStatus.active, this.loading = false, this.submitting = false, this.saved = false, this.deleted = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override final  int? vehicleOperatorId;
@override final  int? driverId;
@override@JsonKey() final  String driverDisplayText;
@override@JsonKey() final  String licenseType;
@override@JsonKey() final  String driverLicenseNumber;
@override final  DateTime? issueDate;
@override final  DateTime? expirationDate;
@override@JsonKey() final  String issuingLocation;
@override@JsonKey() final  EntityStatus status;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool saved;
@override@JsonKey() final  bool deleted;
@override final  String? error;
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of VehicleOperatorFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleOperatorFormStateCopyWith<_VehicleOperatorFormState> get copyWith => __$VehicleOperatorFormStateCopyWithImpl<_VehicleOperatorFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleOperatorFormState&&(identical(other.vehicleOperatorId, vehicleOperatorId) || other.vehicleOperatorId == vehicleOperatorId)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverDisplayText, driverDisplayText) || other.driverDisplayText == driverDisplayText)&&(identical(other.licenseType, licenseType) || other.licenseType == licenseType)&&(identical(other.driverLicenseNumber, driverLicenseNumber) || other.driverLicenseNumber == driverLicenseNumber)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.issuingLocation, issuingLocation) || other.issuingLocation == issuingLocation)&&(identical(other.status, status) || other.status == status)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,vehicleOperatorId,driverId,driverDisplayText,licenseType,driverLicenseNumber,issueDate,expirationDate,issuingLocation,status,loading,submitting,saved,deleted,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'VehicleOperatorFormState(vehicleOperatorId: $vehicleOperatorId, driverId: $driverId, driverDisplayText: $driverDisplayText, licenseType: $licenseType, driverLicenseNumber: $driverLicenseNumber, issueDate: $issueDate, expirationDate: $expirationDate, issuingLocation: $issuingLocation, status: $status, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$VehicleOperatorFormStateCopyWith<$Res> implements $VehicleOperatorFormStateCopyWith<$Res> {
  factory _$VehicleOperatorFormStateCopyWith(_VehicleOperatorFormState value, $Res Function(_VehicleOperatorFormState) _then) = __$VehicleOperatorFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? vehicleOperatorId, int? driverId, String driverDisplayText, String licenseType, String driverLicenseNumber, DateTime? issueDate, DateTime? expirationDate, String issuingLocation, EntityStatus status, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$VehicleOperatorFormStateCopyWithImpl<$Res>
    implements _$VehicleOperatorFormStateCopyWith<$Res> {
  __$VehicleOperatorFormStateCopyWithImpl(this._self, this._then);

  final _VehicleOperatorFormState _self;
  final $Res Function(_VehicleOperatorFormState) _then;

/// Create a copy of VehicleOperatorFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vehicleOperatorId = freezed,Object? driverId = freezed,Object? driverDisplayText = null,Object? licenseType = null,Object? driverLicenseNumber = null,Object? issueDate = freezed,Object? expirationDate = freezed,Object? issuingLocation = null,Object? status = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_VehicleOperatorFormState(
vehicleOperatorId: freezed == vehicleOperatorId ? _self.vehicleOperatorId : vehicleOperatorId // ignore: cast_nullable_to_non_nullable
as int?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as int?,driverDisplayText: null == driverDisplayText ? _self.driverDisplayText : driverDisplayText // ignore: cast_nullable_to_non_nullable
as String,licenseType: null == licenseType ? _self.licenseType : licenseType // ignore: cast_nullable_to_non_nullable
as String,driverLicenseNumber: null == driverLicenseNumber ? _self.driverLicenseNumber : driverLicenseNumber // ignore: cast_nullable_to_non_nullable
as String,issueDate: freezed == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,issuingLocation: null == issuingLocation ? _self.issuingLocation : issuingLocation // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
