// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facility.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Facility {

 int get facilityId; String get code; String get name; FacilityType get type; String get locationId; String get locationLabel; int get addressId; String get addressLabel; String get taxpayerRfc;/// Resolved issuer name — `null` from [fromResponse] (the facility
/// response carries only the RFC, not the expanded issuer); populated by
/// the form controller's `loadForEdit` via a single
/// `TaxpayerIssuersApi.get(rfc)` call (FR-034b, data-model.md).
 String? get taxpayerName; String? get logo; String? get receiptMessage; String? get defaultBatch; EntityStatus get status;
/// Create a copy of Facility
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilityCopyWith<Facility> get copyWith => _$FacilityCopyWithImpl<Facility>(this as Facility, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Facility;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Facility&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.locationId, _this.locationId) || other.locationId == _this.locationId)&&(identical(other.locationLabel, _this.locationLabel) || other.locationLabel == _this.locationLabel)&&(identical(other.addressId, _this.addressId) || other.addressId == _this.addressId)&&(identical(other.addressLabel, _this.addressLabel) || other.addressLabel == _this.addressLabel)&&(identical(other.taxpayerRfc, _this.taxpayerRfc) || other.taxpayerRfc == _this.taxpayerRfc)&&(identical(other.taxpayerName, _this.taxpayerName) || other.taxpayerName == _this.taxpayerName)&&(identical(other.logo, _this.logo) || other.logo == _this.logo)&&(identical(other.receiptMessage, _this.receiptMessage) || other.receiptMessage == _this.receiptMessage)&&(identical(other.defaultBatch, _this.defaultBatch) || other.defaultBatch == _this.defaultBatch)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as Facility;
  return Object.hash(runtimeType,_this.facilityId,_this.code,_this.name,_this.type,_this.locationId,_this.locationLabel,_this.addressId,_this.addressLabel,_this.taxpayerRfc,_this.taxpayerName,_this.logo,_this.receiptMessage,_this.defaultBatch,_this.status);
}

@override
String toString() {
  final _this = this as Facility;
  return 'Facility(facilityId: ${_this.facilityId}, code: ${_this.code}, name: ${_this.name}, type: ${_this.type}, locationId: ${_this.locationId}, locationLabel: ${_this.locationLabel}, addressId: ${_this.addressId}, addressLabel: ${_this.addressLabel}, taxpayerRfc: ${_this.taxpayerRfc}, taxpayerName: ${_this.taxpayerName}, logo: ${_this.logo}, receiptMessage: ${_this.receiptMessage}, defaultBatch: ${_this.defaultBatch}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $FacilityCopyWith<$Res>  {
  factory $FacilityCopyWith(Facility value, $Res Function(Facility) _then) = _$FacilityCopyWithImpl;
@useResult
$Res call({
 int facilityId, String code, String name, FacilityType type, String locationId, String locationLabel, int addressId, String addressLabel, String taxpayerRfc, String? taxpayerName, String? logo, String? receiptMessage, String? defaultBatch, EntityStatus status
});




}
/// @nodoc
class _$FacilityCopyWithImpl<$Res>
    implements $FacilityCopyWith<$Res> {
  _$FacilityCopyWithImpl(this._self, this._then);

  final Facility _self;
  final $Res Function(Facility) _then;

/// Create a copy of Facility
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? facilityId = null,Object? code = null,Object? name = null,Object? type = null,Object? locationId = null,Object? locationLabel = null,Object? addressId = null,Object? addressLabel = null,Object? taxpayerRfc = null,Object? taxpayerName = freezed,Object? logo = freezed,Object? receiptMessage = freezed,Object? defaultBatch = freezed,Object? status = null,}) {
  return _then(Facility(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FacilityType,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,locationLabel: null == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String,addressId: null == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as int,addressLabel: null == addressLabel ? _self.addressLabel : addressLabel // ignore: cast_nullable_to_non_nullable
as String,taxpayerRfc: null == taxpayerRfc ? _self.taxpayerRfc : taxpayerRfc // ignore: cast_nullable_to_non_nullable
as String,taxpayerName: freezed == taxpayerName ? _self.taxpayerName : taxpayerName // ignore: cast_nullable_to_non_nullable
as String?,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,receiptMessage: freezed == receiptMessage ? _self.receiptMessage : receiptMessage // ignore: cast_nullable_to_non_nullable
as String?,defaultBatch: freezed == defaultBatch ? _self.defaultBatch : defaultBatch // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Facility].
extension FacilityPatterns on Facility {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Facility value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Facility() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Facility value)  $default,){
final _that = this;
switch (_that) {
case _Facility():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Facility value)?  $default,){
final _that = this;
switch (_that) {
case _Facility() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int facilityId,  String code,  String name,  FacilityType type,  String locationId,  String locationLabel,  int addressId,  String addressLabel,  String taxpayerRfc,  String? taxpayerName,  String? logo,  String? receiptMessage,  String? defaultBatch,  EntityStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Facility() when $default != null:
return $default(_that.facilityId,_that.code,_that.name,_that.type,_that.locationId,_that.locationLabel,_that.addressId,_that.addressLabel,_that.taxpayerRfc,_that.taxpayerName,_that.logo,_that.receiptMessage,_that.defaultBatch,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int facilityId,  String code,  String name,  FacilityType type,  String locationId,  String locationLabel,  int addressId,  String addressLabel,  String taxpayerRfc,  String? taxpayerName,  String? logo,  String? receiptMessage,  String? defaultBatch,  EntityStatus status)  $default,) {final _that = this;
switch (_that) {
case _Facility():
return $default(_that.facilityId,_that.code,_that.name,_that.type,_that.locationId,_that.locationLabel,_that.addressId,_that.addressLabel,_that.taxpayerRfc,_that.taxpayerName,_that.logo,_that.receiptMessage,_that.defaultBatch,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int facilityId,  String code,  String name,  FacilityType type,  String locationId,  String locationLabel,  int addressId,  String addressLabel,  String taxpayerRfc,  String? taxpayerName,  String? logo,  String? receiptMessage,  String? defaultBatch,  EntityStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Facility() when $default != null:
return $default(_that.facilityId,_that.code,_that.name,_that.type,_that.locationId,_that.locationLabel,_that.addressId,_that.addressLabel,_that.taxpayerRfc,_that.taxpayerName,_that.logo,_that.receiptMessage,_that.defaultBatch,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _Facility implements Facility {
  const _Facility({required this.facilityId, required this.code, required this.name, required this.type, required this.locationId, required this.locationLabel, required this.addressId, required this.addressLabel, required this.taxpayerRfc, this.taxpayerName, this.logo, this.receiptMessage, this.defaultBatch, required this.status});
  

@override final  int facilityId;
@override final  String code;
@override final  String name;
@override final  FacilityType type;
@override final  String locationId;
@override final  String locationLabel;
@override final  int addressId;
@override final  String addressLabel;
@override final  String taxpayerRfc;
/// Resolved issuer name — `null` from [fromResponse] (the facility
/// response carries only the RFC, not the expanded issuer); populated by
/// the form controller's `loadForEdit` via a single
/// `TaxpayerIssuersApi.get(rfc)` call (FR-034b, data-model.md).
@override final  String? taxpayerName;
@override final  String? logo;
@override final  String? receiptMessage;
@override final  String? defaultBatch;
@override final  EntityStatus status;

/// Create a copy of Facility
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilityCopyWith<_Facility> get copyWith => __$FacilityCopyWithImpl<_Facility>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Facility&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.locationLabel, locationLabel) || other.locationLabel == locationLabel)&&(identical(other.addressId, addressId) || other.addressId == addressId)&&(identical(other.addressLabel, addressLabel) || other.addressLabel == addressLabel)&&(identical(other.taxpayerRfc, taxpayerRfc) || other.taxpayerRfc == taxpayerRfc)&&(identical(other.taxpayerName, taxpayerName) || other.taxpayerName == taxpayerName)&&(identical(other.logo, logo) || other.logo == logo)&&(identical(other.receiptMessage, receiptMessage) || other.receiptMessage == receiptMessage)&&(identical(other.defaultBatch, defaultBatch) || other.defaultBatch == defaultBatch)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,facilityId,code,name,type,locationId,locationLabel,addressId,addressLabel,taxpayerRfc,taxpayerName,logo,receiptMessage,defaultBatch,status);
}

@override
String toString() {
    return 'Facility(facilityId: $facilityId, code: $code, name: $name, type: $type, locationId: $locationId, locationLabel: $locationLabel, addressId: $addressId, addressLabel: $addressLabel, taxpayerRfc: $taxpayerRfc, taxpayerName: $taxpayerName, logo: $logo, receiptMessage: $receiptMessage, defaultBatch: $defaultBatch, status: $status)';
}


}

/// @nodoc
abstract mixin class _$FacilityCopyWith<$Res> implements $FacilityCopyWith<$Res> {
  factory _$FacilityCopyWith(_Facility value, $Res Function(_Facility) _then) = __$FacilityCopyWithImpl;
@override @useResult
$Res call({
 int facilityId, String code, String name, FacilityType type, String locationId, String locationLabel, int addressId, String addressLabel, String taxpayerRfc, String? taxpayerName, String? logo, String? receiptMessage, String? defaultBatch, EntityStatus status
});




}
/// @nodoc
class __$FacilityCopyWithImpl<$Res>
    implements _$FacilityCopyWith<$Res> {
  __$FacilityCopyWithImpl(this._self, this._then);

  final _Facility _self;
  final $Res Function(_Facility) _then;

/// Create a copy of Facility
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? facilityId = null,Object? code = null,Object? name = null,Object? type = null,Object? locationId = null,Object? locationLabel = null,Object? addressId = null,Object? addressLabel = null,Object? taxpayerRfc = null,Object? taxpayerName = freezed,Object? logo = freezed,Object? receiptMessage = freezed,Object? defaultBatch = freezed,Object? status = null,}) {
  return _then(_Facility(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FacilityType,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,locationLabel: null == locationLabel ? _self.locationLabel : locationLabel // ignore: cast_nullable_to_non_nullable
as String,addressId: null == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as int,addressLabel: null == addressLabel ? _self.addressLabel : addressLabel // ignore: cast_nullable_to_non_nullable
as String,taxpayerRfc: null == taxpayerRfc ? _self.taxpayerRfc : taxpayerRfc // ignore: cast_nullable_to_non_nullable
as String,taxpayerName: freezed == taxpayerName ? _self.taxpayerName : taxpayerName // ignore: cast_nullable_to_non_nullable
as String?,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,receiptMessage: freezed == receiptMessage ? _self.receiptMessage : receiptMessage // ignore: cast_nullable_to_non_nullable
as String?,defaultBatch: freezed == defaultBatch ? _self.defaultBatch : defaultBatch // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}


}

// dart format on
