// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CustomerPayment {

 int get customerPaymentId; int get customerId; String get amount; Currency get currency; int get methodCode; int? get paymentOptionId; String? get reference; DateTime get date; int get facilityId; int? get cashSessionId; PaymentType get type; int? get verifierId;/// The server's derived figure: the amount less its non-reversed
/// applications. Never recomputed client-side.
 String get unapplied;
/// Create a copy of CustomerPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerPaymentCopyWith<CustomerPayment> get copyWith => _$CustomerPaymentCopyWithImpl<CustomerPayment>(this as CustomerPayment, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomerPayment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerPayment&&(identical(other.customerPaymentId, _this.customerPaymentId) || other.customerPaymentId == _this.customerPaymentId)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.methodCode, _this.methodCode) || other.methodCode == _this.methodCode)&&(identical(other.paymentOptionId, _this.paymentOptionId) || other.paymentOptionId == _this.paymentOptionId)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.cashSessionId, _this.cashSessionId) || other.cashSessionId == _this.cashSessionId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.verifierId, _this.verifierId) || other.verifierId == _this.verifierId)&&(identical(other.unapplied, _this.unapplied) || other.unapplied == _this.unapplied));
}


@override
int get hashCode {
  final _this = this as CustomerPayment;
  return Object.hash(runtimeType,_this.customerPaymentId,_this.customerId,_this.amount,_this.currency,_this.methodCode,_this.paymentOptionId,_this.reference,_this.date,_this.facilityId,_this.cashSessionId,_this.type,_this.verifierId,_this.unapplied);
}

@override
String toString() {
  final _this = this as CustomerPayment;
  return 'CustomerPayment(customerPaymentId: ${_this.customerPaymentId}, customerId: ${_this.customerId}, amount: ${_this.amount}, currency: ${_this.currency}, methodCode: ${_this.methodCode}, paymentOptionId: ${_this.paymentOptionId}, reference: ${_this.reference}, date: ${_this.date}, facilityId: ${_this.facilityId}, cashSessionId: ${_this.cashSessionId}, type: ${_this.type}, verifierId: ${_this.verifierId}, unapplied: ${_this.unapplied})';
}


}

/// @nodoc
abstract mixin class $CustomerPaymentCopyWith<$Res>  {
  factory $CustomerPaymentCopyWith(CustomerPayment value, $Res Function(CustomerPayment) _then) = _$CustomerPaymentCopyWithImpl;
@useResult
$Res call({
 int customerPaymentId, int customerId, String amount, Currency currency, int methodCode, int? paymentOptionId, String? reference, DateTime date, int facilityId, int? cashSessionId, PaymentType type, int? verifierId, String unapplied
});




}
/// @nodoc
class _$CustomerPaymentCopyWithImpl<$Res>
    implements $CustomerPaymentCopyWith<$Res> {
  _$CustomerPaymentCopyWithImpl(this._self, this._then);

  final CustomerPayment _self;
  final $Res Function(CustomerPayment) _then;

/// Create a copy of CustomerPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerPaymentId = null,Object? customerId = null,Object? amount = null,Object? currency = null,Object? methodCode = null,Object? paymentOptionId = freezed,Object? reference = freezed,Object? date = null,Object? facilityId = null,Object? cashSessionId = freezed,Object? type = null,Object? verifierId = freezed,Object? unapplied = null,}) {
  return _then(CustomerPayment(
customerPaymentId: null == customerPaymentId ? _self.customerPaymentId : customerPaymentId // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,methodCode: null == methodCode ? _self.methodCode : methodCode // ignore: cast_nullable_to_non_nullable
as int,paymentOptionId: freezed == paymentOptionId ? _self.paymentOptionId : paymentOptionId // ignore: cast_nullable_to_non_nullable
as int?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,cashSessionId: freezed == cashSessionId ? _self.cashSessionId : cashSessionId // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PaymentType,verifierId: freezed == verifierId ? _self.verifierId : verifierId // ignore: cast_nullable_to_non_nullable
as int?,unapplied: null == unapplied ? _self.unapplied : unapplied // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerPayment].
extension CustomerPaymentPatterns on CustomerPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerPayment value)  $default,){
final _that = this;
switch (_that) {
case _CustomerPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerPayment value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int customerPaymentId,  int customerId,  String amount,  Currency currency,  int methodCode,  int? paymentOptionId,  String? reference,  DateTime date,  int facilityId,  int? cashSessionId,  PaymentType type,  int? verifierId,  String unapplied)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerPayment() when $default != null:
return $default(_that.customerPaymentId,_that.customerId,_that.amount,_that.currency,_that.methodCode,_that.paymentOptionId,_that.reference,_that.date,_that.facilityId,_that.cashSessionId,_that.type,_that.verifierId,_that.unapplied);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int customerPaymentId,  int customerId,  String amount,  Currency currency,  int methodCode,  int? paymentOptionId,  String? reference,  DateTime date,  int facilityId,  int? cashSessionId,  PaymentType type,  int? verifierId,  String unapplied)  $default,) {final _that = this;
switch (_that) {
case _CustomerPayment():
return $default(_that.customerPaymentId,_that.customerId,_that.amount,_that.currency,_that.methodCode,_that.paymentOptionId,_that.reference,_that.date,_that.facilityId,_that.cashSessionId,_that.type,_that.verifierId,_that.unapplied);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int customerPaymentId,  int customerId,  String amount,  Currency currency,  int methodCode,  int? paymentOptionId,  String? reference,  DateTime date,  int facilityId,  int? cashSessionId,  PaymentType type,  int? verifierId,  String unapplied)?  $default,) {final _that = this;
switch (_that) {
case _CustomerPayment() when $default != null:
return $default(_that.customerPaymentId,_that.customerId,_that.amount,_that.currency,_that.methodCode,_that.paymentOptionId,_that.reference,_that.date,_that.facilityId,_that.cashSessionId,_that.type,_that.verifierId,_that.unapplied);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerPayment extends CustomerPayment {
  const _CustomerPayment({required this.customerPaymentId, required this.customerId, required this.amount, required this.currency, required this.methodCode, this.paymentOptionId, this.reference, required this.date, required this.facilityId, this.cashSessionId, required this.type, this.verifierId, required this.unapplied}): super._();
  

@override final  int customerPaymentId;
@override final  int customerId;
@override final  String amount;
@override final  Currency currency;
@override final  int methodCode;
@override final  int? paymentOptionId;
@override final  String? reference;
@override final  DateTime date;
@override final  int facilityId;
@override final  int? cashSessionId;
@override final  PaymentType type;
@override final  int? verifierId;
/// The server's derived figure: the amount less its non-reversed
/// applications. Never recomputed client-side.
@override final  String unapplied;

/// Create a copy of CustomerPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerPaymentCopyWith<_CustomerPayment> get copyWith => __$CustomerPaymentCopyWithImpl<_CustomerPayment>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerPayment&&(identical(other.customerPaymentId, customerPaymentId) || other.customerPaymentId == customerPaymentId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.methodCode, methodCode) || other.methodCode == methodCode)&&(identical(other.paymentOptionId, paymentOptionId) || other.paymentOptionId == paymentOptionId)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.date, date) || other.date == date)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.cashSessionId, cashSessionId) || other.cashSessionId == cashSessionId)&&(identical(other.type, type) || other.type == type)&&(identical(other.verifierId, verifierId) || other.verifierId == verifierId)&&(identical(other.unapplied, unapplied) || other.unapplied == unapplied));
}


@override
int get hashCode {
    return Object.hash(runtimeType,customerPaymentId,customerId,amount,currency,methodCode,paymentOptionId,reference,date,facilityId,cashSessionId,type,verifierId,unapplied);
}

@override
String toString() {
    return 'CustomerPayment(customerPaymentId: $customerPaymentId, customerId: $customerId, amount: $amount, currency: $currency, methodCode: $methodCode, paymentOptionId: $paymentOptionId, reference: $reference, date: $date, facilityId: $facilityId, cashSessionId: $cashSessionId, type: $type, verifierId: $verifierId, unapplied: $unapplied)';
}


}

/// @nodoc
abstract mixin class _$CustomerPaymentCopyWith<$Res> implements $CustomerPaymentCopyWith<$Res> {
  factory _$CustomerPaymentCopyWith(_CustomerPayment value, $Res Function(_CustomerPayment) _then) = __$CustomerPaymentCopyWithImpl;
@override @useResult
$Res call({
 int customerPaymentId, int customerId, String amount, Currency currency, int methodCode, int? paymentOptionId, String? reference, DateTime date, int facilityId, int? cashSessionId, PaymentType type, int? verifierId, String unapplied
});




}
/// @nodoc
class __$CustomerPaymentCopyWithImpl<$Res>
    implements _$CustomerPaymentCopyWith<$Res> {
  __$CustomerPaymentCopyWithImpl(this._self, this._then);

  final _CustomerPayment _self;
  final $Res Function(_CustomerPayment) _then;

/// Create a copy of CustomerPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerPaymentId = null,Object? customerId = null,Object? amount = null,Object? currency = null,Object? methodCode = null,Object? paymentOptionId = freezed,Object? reference = freezed,Object? date = null,Object? facilityId = null,Object? cashSessionId = freezed,Object? type = null,Object? verifierId = freezed,Object? unapplied = null,}) {
  return _then(_CustomerPayment(
customerPaymentId: null == customerPaymentId ? _self.customerPaymentId : customerPaymentId // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,methodCode: null == methodCode ? _self.methodCode : methodCode // ignore: cast_nullable_to_non_nullable
as int,paymentOptionId: freezed == paymentOptionId ? _self.paymentOptionId : paymentOptionId // ignore: cast_nullable_to_non_nullable
as int?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,cashSessionId: freezed == cashSessionId ? _self.cashSessionId : cashSessionId // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PaymentType,verifierId: freezed == verifierId ? _self.verifierId : verifierId // ignore: cast_nullable_to_non_nullable
as int?,unapplied: null == unapplied ? _self.unapplied : unapplied // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$PaymentApplication {

 int get id; int get saleId; String get amount; String get change; int? get applierId; DateTime? get date; bool get reversed;
/// Create a copy of PaymentApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentApplicationCopyWith<PaymentApplication> get copyWith => _$PaymentApplicationCopyWithImpl<PaymentApplication>(this as PaymentApplication, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentApplication;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentApplication&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.saleId, _this.saleId) || other.saleId == _this.saleId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.change, _this.change) || other.change == _this.change)&&(identical(other.applierId, _this.applierId) || other.applierId == _this.applierId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.reversed, _this.reversed) || other.reversed == _this.reversed));
}


@override
int get hashCode {
  final _this = this as PaymentApplication;
  return Object.hash(runtimeType,_this.id,_this.saleId,_this.amount,_this.change,_this.applierId,_this.date,_this.reversed);
}

@override
String toString() {
  final _this = this as PaymentApplication;
  return 'PaymentApplication(id: ${_this.id}, saleId: ${_this.saleId}, amount: ${_this.amount}, change: ${_this.change}, applierId: ${_this.applierId}, date: ${_this.date}, reversed: ${_this.reversed})';
}


}

/// @nodoc
abstract mixin class $PaymentApplicationCopyWith<$Res>  {
  factory $PaymentApplicationCopyWith(PaymentApplication value, $Res Function(PaymentApplication) _then) = _$PaymentApplicationCopyWithImpl;
@useResult
$Res call({
 int id, int saleId, String amount, String change, int? applierId, DateTime? date, bool reversed
});




}
/// @nodoc
class _$PaymentApplicationCopyWithImpl<$Res>
    implements $PaymentApplicationCopyWith<$Res> {
  _$PaymentApplicationCopyWithImpl(this._self, this._then);

  final PaymentApplication _self;
  final $Res Function(PaymentApplication) _then;

/// Create a copy of PaymentApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? saleId = null,Object? amount = null,Object? change = null,Object? applierId = freezed,Object? date = freezed,Object? reversed = null,}) {
  return _then(PaymentApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as String,applierId: freezed == applierId ? _self.applierId : applierId // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,reversed: null == reversed ? _self.reversed : reversed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentApplication].
extension PaymentApplicationPatterns on PaymentApplication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentApplication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentApplication value)  $default,){
final _that = this;
switch (_that) {
case _PaymentApplication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentApplication value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentApplication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int saleId,  String amount,  String change,  int? applierId,  DateTime? date,  bool reversed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentApplication() when $default != null:
return $default(_that.id,_that.saleId,_that.amount,_that.change,_that.applierId,_that.date,_that.reversed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int saleId,  String amount,  String change,  int? applierId,  DateTime? date,  bool reversed)  $default,) {final _that = this;
switch (_that) {
case _PaymentApplication():
return $default(_that.id,_that.saleId,_that.amount,_that.change,_that.applierId,_that.date,_that.reversed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int saleId,  String amount,  String change,  int? applierId,  DateTime? date,  bool reversed)?  $default,) {final _that = this;
switch (_that) {
case _PaymentApplication() when $default != null:
return $default(_that.id,_that.saleId,_that.amount,_that.change,_that.applierId,_that.date,_that.reversed);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentApplication implements PaymentApplication {
  const _PaymentApplication({required this.id, required this.saleId, required this.amount, required this.change, this.applierId, this.date, required this.reversed});
  

@override final  int id;
@override final  int saleId;
@override final  String amount;
@override final  String change;
@override final  int? applierId;
@override final  DateTime? date;
@override final  bool reversed;

/// Create a copy of PaymentApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentApplicationCopyWith<_PaymentApplication> get copyWith => __$PaymentApplicationCopyWithImpl<_PaymentApplication>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.change, change) || other.change == change)&&(identical(other.applierId, applierId) || other.applierId == applierId)&&(identical(other.date, date) || other.date == date)&&(identical(other.reversed, reversed) || other.reversed == reversed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,saleId,amount,change,applierId,date,reversed);
}

@override
String toString() {
    return 'PaymentApplication(id: $id, saleId: $saleId, amount: $amount, change: $change, applierId: $applierId, date: $date, reversed: $reversed)';
}


}

/// @nodoc
abstract mixin class _$PaymentApplicationCopyWith<$Res> implements $PaymentApplicationCopyWith<$Res> {
  factory _$PaymentApplicationCopyWith(_PaymentApplication value, $Res Function(_PaymentApplication) _then) = __$PaymentApplicationCopyWithImpl;
@override @useResult
$Res call({
 int id, int saleId, String amount, String change, int? applierId, DateTime? date, bool reversed
});




}
/// @nodoc
class __$PaymentApplicationCopyWithImpl<$Res>
    implements _$PaymentApplicationCopyWith<$Res> {
  __$PaymentApplicationCopyWithImpl(this._self, this._then);

  final _PaymentApplication _self;
  final $Res Function(_PaymentApplication) _then;

/// Create a copy of PaymentApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? saleId = null,Object? amount = null,Object? change = null,Object? applierId = freezed,Object? date = freezed,Object? reversed = null,}) {
  return _then(_PaymentApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,saleId: null == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,change: null == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as String,applierId: freezed == applierId ? _self.applierId : applierId // ignore: cast_nullable_to_non_nullable
as int?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,reversed: null == reversed ? _self.reversed : reversed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
