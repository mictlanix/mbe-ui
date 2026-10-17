// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_method_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentMethodOption {

 int get paymentMethodOptionId; int get facilityId; String get facilityName; int? get warehouseId; String? get warehouseName; String get name; int get numberOfPayments; bool get displayOnTicket; int get paymentMethod; String? get commission; EntityStatus get status; bool get requiresReference;
/// Create a copy of PaymentMethodOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentMethodOptionCopyWith<PaymentMethodOption> get copyWith => _$PaymentMethodOptionCopyWithImpl<PaymentMethodOption>(this as PaymentMethodOption, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentMethodOption;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentMethodOption&&(identical(other.paymentMethodOptionId, _this.paymentMethodOptionId) || other.paymentMethodOptionId == _this.paymentMethodOptionId)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.facilityName, _this.facilityName) || other.facilityName == _this.facilityName)&&(identical(other.warehouseId, _this.warehouseId) || other.warehouseId == _this.warehouseId)&&(identical(other.warehouseName, _this.warehouseName) || other.warehouseName == _this.warehouseName)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.numberOfPayments, _this.numberOfPayments) || other.numberOfPayments == _this.numberOfPayments)&&(identical(other.displayOnTicket, _this.displayOnTicket) || other.displayOnTicket == _this.displayOnTicket)&&(identical(other.paymentMethod, _this.paymentMethod) || other.paymentMethod == _this.paymentMethod)&&(identical(other.commission, _this.commission) || other.commission == _this.commission)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.requiresReference, _this.requiresReference) || other.requiresReference == _this.requiresReference));
}


@override
int get hashCode {
  final _this = this as PaymentMethodOption;
  return Object.hash(runtimeType,_this.paymentMethodOptionId,_this.facilityId,_this.facilityName,_this.warehouseId,_this.warehouseName,_this.name,_this.numberOfPayments,_this.displayOnTicket,_this.paymentMethod,_this.commission,_this.status,_this.requiresReference);
}

@override
String toString() {
  final _this = this as PaymentMethodOption;
  return 'PaymentMethodOption(paymentMethodOptionId: ${_this.paymentMethodOptionId}, facilityId: ${_this.facilityId}, facilityName: ${_this.facilityName}, warehouseId: ${_this.warehouseId}, warehouseName: ${_this.warehouseName}, name: ${_this.name}, numberOfPayments: ${_this.numberOfPayments}, displayOnTicket: ${_this.displayOnTicket}, paymentMethod: ${_this.paymentMethod}, commission: ${_this.commission}, status: ${_this.status}, requiresReference: ${_this.requiresReference})';
}


}

/// @nodoc
abstract mixin class $PaymentMethodOptionCopyWith<$Res>  {
  factory $PaymentMethodOptionCopyWith(PaymentMethodOption value, $Res Function(PaymentMethodOption) _then) = _$PaymentMethodOptionCopyWithImpl;
@useResult
$Res call({
 int paymentMethodOptionId, int facilityId, String facilityName, int? warehouseId, String? warehouseName, String name, int numberOfPayments, bool displayOnTicket, int paymentMethod, String? commission, EntityStatus status, bool requiresReference
});




}
/// @nodoc
class _$PaymentMethodOptionCopyWithImpl<$Res>
    implements $PaymentMethodOptionCopyWith<$Res> {
  _$PaymentMethodOptionCopyWithImpl(this._self, this._then);

  final PaymentMethodOption _self;
  final $Res Function(PaymentMethodOption) _then;

/// Create a copy of PaymentMethodOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentMethodOptionId = null,Object? facilityId = null,Object? facilityName = null,Object? warehouseId = freezed,Object? warehouseName = freezed,Object? name = null,Object? numberOfPayments = null,Object? displayOnTicket = null,Object? paymentMethod = null,Object? commission = freezed,Object? status = null,Object? requiresReference = null,}) {
  return _then(PaymentMethodOption(
paymentMethodOptionId: null == paymentMethodOptionId ? _self.paymentMethodOptionId : paymentMethodOptionId // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,facilityName: null == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,numberOfPayments: null == numberOfPayments ? _self.numberOfPayments : numberOfPayments // ignore: cast_nullable_to_non_nullable
as int,displayOnTicket: null == displayOnTicket ? _self.displayOnTicket : displayOnTicket // ignore: cast_nullable_to_non_nullable
as bool,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as int,commission: freezed == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,requiresReference: null == requiresReference ? _self.requiresReference : requiresReference // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentMethodOption].
extension PaymentMethodOptionPatterns on PaymentMethodOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentMethodOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentMethodOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentMethodOption value)  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentMethodOption value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int paymentMethodOptionId,  int facilityId,  String facilityName,  int? warehouseId,  String? warehouseName,  String name,  int numberOfPayments,  bool displayOnTicket,  int paymentMethod,  String? commission,  EntityStatus status,  bool requiresReference)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentMethodOption() when $default != null:
return $default(_that.paymentMethodOptionId,_that.facilityId,_that.facilityName,_that.warehouseId,_that.warehouseName,_that.name,_that.numberOfPayments,_that.displayOnTicket,_that.paymentMethod,_that.commission,_that.status,_that.requiresReference);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int paymentMethodOptionId,  int facilityId,  String facilityName,  int? warehouseId,  String? warehouseName,  String name,  int numberOfPayments,  bool displayOnTicket,  int paymentMethod,  String? commission,  EntityStatus status,  bool requiresReference)  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodOption():
return $default(_that.paymentMethodOptionId,_that.facilityId,_that.facilityName,_that.warehouseId,_that.warehouseName,_that.name,_that.numberOfPayments,_that.displayOnTicket,_that.paymentMethod,_that.commission,_that.status,_that.requiresReference);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int paymentMethodOptionId,  int facilityId,  String facilityName,  int? warehouseId,  String? warehouseName,  String name,  int numberOfPayments,  bool displayOnTicket,  int paymentMethod,  String? commission,  EntityStatus status,  bool requiresReference)?  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodOption() when $default != null:
return $default(_that.paymentMethodOptionId,_that.facilityId,_that.facilityName,_that.warehouseId,_that.warehouseName,_that.name,_that.numberOfPayments,_that.displayOnTicket,_that.paymentMethod,_that.commission,_that.status,_that.requiresReference);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentMethodOption implements PaymentMethodOption {
  const _PaymentMethodOption({required this.paymentMethodOptionId, required this.facilityId, required this.facilityName, this.warehouseId, this.warehouseName, required this.name, required this.numberOfPayments, required this.displayOnTicket, required this.paymentMethod, this.commission, required this.status, this.requiresReference = false});
  

@override final  int paymentMethodOptionId;
@override final  int facilityId;
@override final  String facilityName;
@override final  int? warehouseId;
@override final  String? warehouseName;
@override final  String name;
@override final  int numberOfPayments;
@override final  bool displayOnTicket;
@override final  int paymentMethod;
@override final  String? commission;
@override final  EntityStatus status;
@override@JsonKey() final  bool requiresReference;

/// Create a copy of PaymentMethodOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentMethodOptionCopyWith<_PaymentMethodOption> get copyWith => __$PaymentMethodOptionCopyWithImpl<_PaymentMethodOption>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentMethodOption&&(identical(other.paymentMethodOptionId, paymentMethodOptionId) || other.paymentMethodOptionId == paymentMethodOptionId)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.name, name) || other.name == name)&&(identical(other.numberOfPayments, numberOfPayments) || other.numberOfPayments == numberOfPayments)&&(identical(other.displayOnTicket, displayOnTicket) || other.displayOnTicket == displayOnTicket)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.status, status) || other.status == status)&&(identical(other.requiresReference, requiresReference) || other.requiresReference == requiresReference));
}


@override
int get hashCode {
    return Object.hash(runtimeType,paymentMethodOptionId,facilityId,facilityName,warehouseId,warehouseName,name,numberOfPayments,displayOnTicket,paymentMethod,commission,status,requiresReference);
}

@override
String toString() {
    return 'PaymentMethodOption(paymentMethodOptionId: $paymentMethodOptionId, facilityId: $facilityId, facilityName: $facilityName, warehouseId: $warehouseId, warehouseName: $warehouseName, name: $name, numberOfPayments: $numberOfPayments, displayOnTicket: $displayOnTicket, paymentMethod: $paymentMethod, commission: $commission, status: $status, requiresReference: $requiresReference)';
}


}

/// @nodoc
abstract mixin class _$PaymentMethodOptionCopyWith<$Res> implements $PaymentMethodOptionCopyWith<$Res> {
  factory _$PaymentMethodOptionCopyWith(_PaymentMethodOption value, $Res Function(_PaymentMethodOption) _then) = __$PaymentMethodOptionCopyWithImpl;
@override @useResult
$Res call({
 int paymentMethodOptionId, int facilityId, String facilityName, int? warehouseId, String? warehouseName, String name, int numberOfPayments, bool displayOnTicket, int paymentMethod, String? commission, EntityStatus status, bool requiresReference
});




}
/// @nodoc
class __$PaymentMethodOptionCopyWithImpl<$Res>
    implements _$PaymentMethodOptionCopyWith<$Res> {
  __$PaymentMethodOptionCopyWithImpl(this._self, this._then);

  final _PaymentMethodOption _self;
  final $Res Function(_PaymentMethodOption) _then;

/// Create a copy of PaymentMethodOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentMethodOptionId = null,Object? facilityId = null,Object? facilityName = null,Object? warehouseId = freezed,Object? warehouseName = freezed,Object? name = null,Object? numberOfPayments = null,Object? displayOnTicket = null,Object? paymentMethod = null,Object? commission = freezed,Object? status = null,Object? requiresReference = null,}) {
  return _then(_PaymentMethodOption(
paymentMethodOptionId: null == paymentMethodOptionId ? _self.paymentMethodOptionId : paymentMethodOptionId // ignore: cast_nullable_to_non_nullable
as int,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,facilityName: null == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String,warehouseId: freezed == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as int?,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,numberOfPayments: null == numberOfPayments ? _self.numberOfPayments : numberOfPayments // ignore: cast_nullable_to_non_nullable
as int,displayOnTicket: null == displayOnTicket ? _self.displayOnTicket : displayOnTicket // ignore: cast_nullable_to_non_nullable
as bool,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as int,commission: freezed == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,requiresReference: null == requiresReference ? _self.requiresReference : requiresReference // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
