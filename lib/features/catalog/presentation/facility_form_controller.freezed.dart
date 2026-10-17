// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facility_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FacilityFormState {

 int? get facilityId; String get code; String get name; FacilityType get type; String? get locationId; String get locationDisplayText; int? get addressId; String get addressDisplayText;/// The stored issuer RFC (FR-034). Empty until a taxpayer is picked (or
/// typed, in the read-denied fallback).
 String get taxpayerRfc;/// The issuer display name resolved on load (FR-034b); the taxpayer field
/// shows `taxpayerDisplayText`, which the detail screen prefers over the
/// bare [taxpayerRfc].
 String get taxpayerDisplayText; String get logo; String get receiptMessage; String get defaultBatch; EntityStatus get status; bool get loading; bool get submitting; bool get saved; bool get deleted; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of FacilityFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilityFormStateCopyWith<FacilityFormState> get copyWith => _$FacilityFormStateCopyWithImpl<FacilityFormState>(this as FacilityFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FacilityFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FacilityFormState&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.locationDisplayText, _this.locationDisplayText) || other.locationDisplayText == _this.locationDisplayText)&&(identical(other.addressId, _this.addressId) || other.addressId == _this.addressId)&&(identical(other.addressDisplayText, _this.addressDisplayText) || other.addressDisplayText == _this.addressDisplayText)&&(identical(other.taxpayerRfc, _this.taxpayerRfc) || other.taxpayerRfc == _this.taxpayerRfc)&&(identical(other.taxpayerDisplayText, _this.taxpayerDisplayText) || other.taxpayerDisplayText == _this.taxpayerDisplayText)&&(identical(other.logo, _this.logo) || other.logo == _this.logo)&&(identical(other.receiptMessage, _this.receiptMessage) || other.receiptMessage == _this.receiptMessage)&&(identical(other.defaultBatch, _this.defaultBatch) || other.defaultBatch == _this.defaultBatch)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as FacilityFormState;
  return Object.hashAll([runtimeType,_this.facilityId,_this.code,_this.name,_this.type,_this.locationId,_this.locationDisplayText,_this.addressId,_this.addressDisplayText,_this.taxpayerRfc,_this.taxpayerDisplayText,_this.logo,_this.receiptMessage,_this.defaultBatch,_this.status,_this.loading,_this.submitting,_this.saved,_this.deleted,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors)]);
}

@override
String toString() {
  final _this = this as FacilityFormState;
  return 'FacilityFormState(facilityId: ${_this.facilityId}, code: ${_this.code}, name: ${_this.name}, type: ${_this.type}, locationId: ${_this.locationId}, locationDisplayText: ${_this.locationDisplayText}, addressId: ${_this.addressId}, addressDisplayText: ${_this.addressDisplayText}, taxpayerRfc: ${_this.taxpayerRfc}, taxpayerDisplayText: ${_this.taxpayerDisplayText}, logo: ${_this.logo}, receiptMessage: ${_this.receiptMessage}, defaultBatch: ${_this.defaultBatch}, status: ${_this.status}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, deleted: ${_this.deleted}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $FacilityFormStateCopyWith<$Res>  {
  factory $FacilityFormStateCopyWith(FacilityFormState value, $Res Function(FacilityFormState) _then) = _$FacilityFormStateCopyWithImpl;
@useResult
$Res call({
 int? facilityId, String code, String name, FacilityType type, String? locationId, String locationDisplayText, int? addressId, String addressDisplayText, String taxpayerRfc, String taxpayerDisplayText, String logo, String receiptMessage, String defaultBatch, EntityStatus status, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$FacilityFormStateCopyWithImpl<$Res>
    implements $FacilityFormStateCopyWith<$Res> {
  _$FacilityFormStateCopyWithImpl(this._self, this._then);

  final FacilityFormState _self;
  final $Res Function(FacilityFormState) _then;

/// Create a copy of FacilityFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? facilityId = freezed,Object? code = null,Object? name = null,Object? type = null,Object? locationId = freezed,Object? locationDisplayText = null,Object? addressId = freezed,Object? addressDisplayText = null,Object? taxpayerRfc = null,Object? taxpayerDisplayText = null,Object? logo = null,Object? receiptMessage = null,Object? defaultBatch = null,Object? status = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(FacilityFormState(
facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FacilityType,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,locationDisplayText: null == locationDisplayText ? _self.locationDisplayText : locationDisplayText // ignore: cast_nullable_to_non_nullable
as String,addressId: freezed == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as int?,addressDisplayText: null == addressDisplayText ? _self.addressDisplayText : addressDisplayText // ignore: cast_nullable_to_non_nullable
as String,taxpayerRfc: null == taxpayerRfc ? _self.taxpayerRfc : taxpayerRfc // ignore: cast_nullable_to_non_nullable
as String,taxpayerDisplayText: null == taxpayerDisplayText ? _self.taxpayerDisplayText : taxpayerDisplayText // ignore: cast_nullable_to_non_nullable
as String,logo: null == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String,receiptMessage: null == receiptMessage ? _self.receiptMessage : receiptMessage // ignore: cast_nullable_to_non_nullable
as String,defaultBatch: null == defaultBatch ? _self.defaultBatch : defaultBatch // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [FacilityFormState].
extension FacilityFormStatePatterns on FacilityFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FacilityFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FacilityFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FacilityFormState value)  $default,){
final _that = this;
switch (_that) {
case _FacilityFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FacilityFormState value)?  $default,){
final _that = this;
switch (_that) {
case _FacilityFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? facilityId,  String code,  String name,  FacilityType type,  String? locationId,  String locationDisplayText,  int? addressId,  String addressDisplayText,  String taxpayerRfc,  String taxpayerDisplayText,  String logo,  String receiptMessage,  String defaultBatch,  EntityStatus status,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FacilityFormState() when $default != null:
return $default(_that.facilityId,_that.code,_that.name,_that.type,_that.locationId,_that.locationDisplayText,_that.addressId,_that.addressDisplayText,_that.taxpayerRfc,_that.taxpayerDisplayText,_that.logo,_that.receiptMessage,_that.defaultBatch,_that.status,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? facilityId,  String code,  String name,  FacilityType type,  String? locationId,  String locationDisplayText,  int? addressId,  String addressDisplayText,  String taxpayerRfc,  String taxpayerDisplayText,  String logo,  String receiptMessage,  String defaultBatch,  EntityStatus status,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _FacilityFormState():
return $default(_that.facilityId,_that.code,_that.name,_that.type,_that.locationId,_that.locationDisplayText,_that.addressId,_that.addressDisplayText,_that.taxpayerRfc,_that.taxpayerDisplayText,_that.logo,_that.receiptMessage,_that.defaultBatch,_that.status,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? facilityId,  String code,  String name,  FacilityType type,  String? locationId,  String locationDisplayText,  int? addressId,  String addressDisplayText,  String taxpayerRfc,  String taxpayerDisplayText,  String logo,  String receiptMessage,  String defaultBatch,  EntityStatus status,  bool loading,  bool submitting,  bool saved,  bool deleted,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _FacilityFormState() when $default != null:
return $default(_that.facilityId,_that.code,_that.name,_that.type,_that.locationId,_that.locationDisplayText,_that.addressId,_that.addressDisplayText,_that.taxpayerRfc,_that.taxpayerDisplayText,_that.logo,_that.receiptMessage,_that.defaultBatch,_that.status,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _FacilityFormState implements FacilityFormState {
  const _FacilityFormState({this.facilityId, this.code = '', this.name = '', this.type = FacilityType.store, this.locationId, this.locationDisplayText = '', this.addressId, this.addressDisplayText = '', this.taxpayerRfc = '', this.taxpayerDisplayText = '', this.logo = '', this.receiptMessage = '', this.defaultBatch = '', this.status = EntityStatus.active, this.loading = false, this.submitting = false, this.saved = false, this.deleted = false, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override final  int? facilityId;
@override@JsonKey() final  String code;
@override@JsonKey() final  String name;
@override@JsonKey() final  FacilityType type;
@override final  String? locationId;
@override@JsonKey() final  String locationDisplayText;
@override final  int? addressId;
@override@JsonKey() final  String addressDisplayText;
/// The stored issuer RFC (FR-034). Empty until a taxpayer is picked (or
/// typed, in the read-denied fallback).
@override@JsonKey() final  String taxpayerRfc;
/// The issuer display name resolved on load (FR-034b); the taxpayer field
/// shows `taxpayerDisplayText`, which the detail screen prefers over the
/// bare [taxpayerRfc].
@override@JsonKey() final  String taxpayerDisplayText;
@override@JsonKey() final  String logo;
@override@JsonKey() final  String receiptMessage;
@override@JsonKey() final  String defaultBatch;
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


/// Create a copy of FacilityFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilityFormStateCopyWith<_FacilityFormState> get copyWith => __$FacilityFormStateCopyWithImpl<_FacilityFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FacilityFormState&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.locationDisplayText, locationDisplayText) || other.locationDisplayText == locationDisplayText)&&(identical(other.addressId, addressId) || other.addressId == addressId)&&(identical(other.addressDisplayText, addressDisplayText) || other.addressDisplayText == addressDisplayText)&&(identical(other.taxpayerRfc, taxpayerRfc) || other.taxpayerRfc == taxpayerRfc)&&(identical(other.taxpayerDisplayText, taxpayerDisplayText) || other.taxpayerDisplayText == taxpayerDisplayText)&&(identical(other.logo, logo) || other.logo == logo)&&(identical(other.receiptMessage, receiptMessage) || other.receiptMessage == receiptMessage)&&(identical(other.defaultBatch, defaultBatch) || other.defaultBatch == defaultBatch)&&(identical(other.status, status) || other.status == status)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,facilityId,code,name,type,locationId,locationDisplayText,addressId,addressDisplayText,taxpayerRfc,taxpayerDisplayText,logo,receiptMessage,defaultBatch,status,loading,submitting,saved,deleted,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors)]);
}

@override
String toString() {
    return 'FacilityFormState(facilityId: $facilityId, code: $code, name: $name, type: $type, locationId: $locationId, locationDisplayText: $locationDisplayText, addressId: $addressId, addressDisplayText: $addressDisplayText, taxpayerRfc: $taxpayerRfc, taxpayerDisplayText: $taxpayerDisplayText, logo: $logo, receiptMessage: $receiptMessage, defaultBatch: $defaultBatch, status: $status, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$FacilityFormStateCopyWith<$Res> implements $FacilityFormStateCopyWith<$Res> {
  factory _$FacilityFormStateCopyWith(_FacilityFormState value, $Res Function(_FacilityFormState) _then) = __$FacilityFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? facilityId, String code, String name, FacilityType type, String? locationId, String locationDisplayText, int? addressId, String addressDisplayText, String taxpayerRfc, String taxpayerDisplayText, String logo, String receiptMessage, String defaultBatch, EntityStatus status, bool loading, bool submitting, bool saved, bool deleted, String? error, String? errorDetail, Map<String, String> fieldErrors
});




}
/// @nodoc
class __$FacilityFormStateCopyWithImpl<$Res>
    implements _$FacilityFormStateCopyWith<$Res> {
  __$FacilityFormStateCopyWithImpl(this._self, this._then);

  final _FacilityFormState _self;
  final $Res Function(_FacilityFormState) _then;

/// Create a copy of FacilityFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? facilityId = freezed,Object? code = null,Object? name = null,Object? type = null,Object? locationId = freezed,Object? locationDisplayText = null,Object? addressId = freezed,Object? addressDisplayText = null,Object? taxpayerRfc = null,Object? taxpayerDisplayText = null,Object? logo = null,Object? receiptMessage = null,Object? defaultBatch = null,Object? status = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_FacilityFormState(
facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FacilityType,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String?,locationDisplayText: null == locationDisplayText ? _self.locationDisplayText : locationDisplayText // ignore: cast_nullable_to_non_nullable
as String,addressId: freezed == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as int?,addressDisplayText: null == addressDisplayText ? _self.addressDisplayText : addressDisplayText // ignore: cast_nullable_to_non_nullable
as String,taxpayerRfc: null == taxpayerRfc ? _self.taxpayerRfc : taxpayerRfc // ignore: cast_nullable_to_non_nullable
as String,taxpayerDisplayText: null == taxpayerDisplayText ? _self.taxpayerDisplayText : taxpayerDisplayText // ignore: cast_nullable_to_non_nullable
as String,logo: null == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String,receiptMessage: null == receiptMessage ? _self.receiptMessage : receiptMessage // ignore: cast_nullable_to_non_nullable
as String,defaultBatch: null == defaultBatch ? _self.defaultBatch : defaultBatch // ignore: cast_nullable_to_non_nullable
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
