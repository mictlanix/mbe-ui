// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SalePayment {

 int get id; int get customerPayment; String get amount; PaymentMethod? get method; int get methodCode; Currency get currency; String? get reference; int? get verifier; String get changeAmount; bool get cancelled;/// The payment's type. A credit-note redemption is an application of a
/// payment of type `creditNote`, and the applied-payments panel labels it
/// as such (spec 056 FR-009) because its method reads "N/A".
 PaymentType get type; DateTime get paymentDate; DateTime? get date;
/// Create a copy of SalePayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalePaymentCopyWith<SalePayment> get copyWith => _$SalePaymentCopyWithImpl<SalePayment>(this as SalePayment, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SalePayment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalePayment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.customerPayment, _this.customerPayment) || other.customerPayment == _this.customerPayment)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.methodCode, _this.methodCode) || other.methodCode == _this.methodCode)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.verifier, _this.verifier) || other.verifier == _this.verifier)&&(identical(other.changeAmount, _this.changeAmount) || other.changeAmount == _this.changeAmount)&&(identical(other.cancelled, _this.cancelled) || other.cancelled == _this.cancelled)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.paymentDate, _this.paymentDate) || other.paymentDate == _this.paymentDate)&&(identical(other.date, _this.date) || other.date == _this.date));
}


@override
int get hashCode {
  final _this = this as SalePayment;
  return Object.hash(runtimeType,_this.id,_this.customerPayment,_this.amount,_this.method,_this.methodCode,_this.currency,_this.reference,_this.verifier,_this.changeAmount,_this.cancelled,_this.type,_this.paymentDate,_this.date);
}

@override
String toString() {
  final _this = this as SalePayment;
  return 'SalePayment(id: ${_this.id}, customerPayment: ${_this.customerPayment}, amount: ${_this.amount}, method: ${_this.method}, methodCode: ${_this.methodCode}, currency: ${_this.currency}, reference: ${_this.reference}, verifier: ${_this.verifier}, changeAmount: ${_this.changeAmount}, cancelled: ${_this.cancelled}, type: ${_this.type}, paymentDate: ${_this.paymentDate}, date: ${_this.date})';
}


}

/// @nodoc
abstract mixin class $SalePaymentCopyWith<$Res>  {
  factory $SalePaymentCopyWith(SalePayment value, $Res Function(SalePayment) _then) = _$SalePaymentCopyWithImpl;
@useResult
$Res call({
 int id, int customerPayment, String amount, PaymentMethod? method, int methodCode, Currency currency, String? reference, int? verifier, String changeAmount, bool cancelled, PaymentType type, DateTime paymentDate, DateTime? date
});




}
/// @nodoc
class _$SalePaymentCopyWithImpl<$Res>
    implements $SalePaymentCopyWith<$Res> {
  _$SalePaymentCopyWithImpl(this._self, this._then);

  final SalePayment _self;
  final $Res Function(SalePayment) _then;

/// Create a copy of SalePayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerPayment = null,Object? amount = null,Object? method = freezed,Object? methodCode = null,Object? currency = null,Object? reference = freezed,Object? verifier = freezed,Object? changeAmount = null,Object? cancelled = null,Object? type = null,Object? paymentDate = null,Object? date = freezed,}) {
  return _then(SalePayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,customerPayment: null == customerPayment ? _self.customerPayment : customerPayment // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,methodCode: null == methodCode ? _self.methodCode : methodCode // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,verifier: freezed == verifier ? _self.verifier : verifier // ignore: cast_nullable_to_non_nullable
as int?,changeAmount: null == changeAmount ? _self.changeAmount : changeAmount // ignore: cast_nullable_to_non_nullable
as String,cancelled: null == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PaymentType,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SalePayment].
extension SalePaymentPatterns on SalePayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalePayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalePayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalePayment value)  $default,){
final _that = this;
switch (_that) {
case _SalePayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalePayment value)?  $default,){
final _that = this;
switch (_that) {
case _SalePayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int customerPayment,  String amount,  PaymentMethod? method,  int methodCode,  Currency currency,  String? reference,  int? verifier,  String changeAmount,  bool cancelled,  PaymentType type,  DateTime paymentDate,  DateTime? date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalePayment() when $default != null:
return $default(_that.id,_that.customerPayment,_that.amount,_that.method,_that.methodCode,_that.currency,_that.reference,_that.verifier,_that.changeAmount,_that.cancelled,_that.type,_that.paymentDate,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int customerPayment,  String amount,  PaymentMethod? method,  int methodCode,  Currency currency,  String? reference,  int? verifier,  String changeAmount,  bool cancelled,  PaymentType type,  DateTime paymentDate,  DateTime? date)  $default,) {final _that = this;
switch (_that) {
case _SalePayment():
return $default(_that.id,_that.customerPayment,_that.amount,_that.method,_that.methodCode,_that.currency,_that.reference,_that.verifier,_that.changeAmount,_that.cancelled,_that.type,_that.paymentDate,_that.date);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int customerPayment,  String amount,  PaymentMethod? method,  int methodCode,  Currency currency,  String? reference,  int? verifier,  String changeAmount,  bool cancelled,  PaymentType type,  DateTime paymentDate,  DateTime? date)?  $default,) {final _that = this;
switch (_that) {
case _SalePayment() when $default != null:
return $default(_that.id,_that.customerPayment,_that.amount,_that.method,_that.methodCode,_that.currency,_that.reference,_that.verifier,_that.changeAmount,_that.cancelled,_that.type,_that.paymentDate,_that.date);case _:
  return null;

}
}

}

/// @nodoc


class _SalePayment extends SalePayment {
  const _SalePayment({required this.id, required this.customerPayment, required this.amount, this.method, required this.methodCode, required this.currency, this.reference, this.verifier, required this.changeAmount, required this.cancelled, required this.type, required this.paymentDate, this.date}): super._();
  

@override final  int id;
@override final  int customerPayment;
@override final  String amount;
@override final  PaymentMethod? method;
@override final  int methodCode;
@override final  Currency currency;
@override final  String? reference;
@override final  int? verifier;
@override final  String changeAmount;
@override final  bool cancelled;
/// The payment's type. A credit-note redemption is an application of a
/// payment of type `creditNote`, and the applied-payments panel labels it
/// as such (spec 056 FR-009) because its method reads "N/A".
@override final  PaymentType type;
@override final  DateTime paymentDate;
@override final  DateTime? date;

/// Create a copy of SalePayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalePaymentCopyWith<_SalePayment> get copyWith => __$SalePaymentCopyWithImpl<_SalePayment>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalePayment&&(identical(other.id, id) || other.id == id)&&(identical(other.customerPayment, customerPayment) || other.customerPayment == customerPayment)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.methodCode, methodCode) || other.methodCode == methodCode)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.verifier, verifier) || other.verifier == verifier)&&(identical(other.changeAmount, changeAmount) || other.changeAmount == changeAmount)&&(identical(other.cancelled, cancelled) || other.cancelled == cancelled)&&(identical(other.type, type) || other.type == type)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,customerPayment,amount,method,methodCode,currency,reference,verifier,changeAmount,cancelled,type,paymentDate,date);
}

@override
String toString() {
    return 'SalePayment(id: $id, customerPayment: $customerPayment, amount: $amount, method: $method, methodCode: $methodCode, currency: $currency, reference: $reference, verifier: $verifier, changeAmount: $changeAmount, cancelled: $cancelled, type: $type, paymentDate: $paymentDate, date: $date)';
}


}

/// @nodoc
abstract mixin class _$SalePaymentCopyWith<$Res> implements $SalePaymentCopyWith<$Res> {
  factory _$SalePaymentCopyWith(_SalePayment value, $Res Function(_SalePayment) _then) = __$SalePaymentCopyWithImpl;
@override @useResult
$Res call({
 int id, int customerPayment, String amount, PaymentMethod? method, int methodCode, Currency currency, String? reference, int? verifier, String changeAmount, bool cancelled, PaymentType type, DateTime paymentDate, DateTime? date
});




}
/// @nodoc
class __$SalePaymentCopyWithImpl<$Res>
    implements _$SalePaymentCopyWith<$Res> {
  __$SalePaymentCopyWithImpl(this._self, this._then);

  final _SalePayment _self;
  final $Res Function(_SalePayment) _then;

/// Create a copy of SalePayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerPayment = null,Object? amount = null,Object? method = freezed,Object? methodCode = null,Object? currency = null,Object? reference = freezed,Object? verifier = freezed,Object? changeAmount = null,Object? cancelled = null,Object? type = null,Object? paymentDate = null,Object? date = freezed,}) {
  return _then(_SalePayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,customerPayment: null == customerPayment ? _self.customerPayment : customerPayment // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod?,methodCode: null == methodCode ? _self.methodCode : methodCode // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,verifier: freezed == verifier ? _self.verifier : verifier // ignore: cast_nullable_to_non_nullable
as int?,changeAmount: null == changeAmount ? _self.changeAmount : changeAmount // ignore: cast_nullable_to_non_nullable
as String,cancelled: null == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PaymentType,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
