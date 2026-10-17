// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Sale {

 int get id; int? get serial; int get facility; int? get pointSale; int get salesperson; int get customer; String? get customerName; PaymentTerms get paymentTerms; Currency get currency; String get exchangeRate; int? get shipTo; FulfillmentMode? get fulfillmentIntent; SaleOrigin? get origin; DateTime? get promiseDate; SaleStatus get status; List<SaleLine> get lines; String get subtotal; String get taxTotal; String get total; String? get balance; DateTime get date; DateTime get dueDate; int? get contact; String? get recipient; String? get recipientName; Priority? get priority; String? get comment; bool get hasExpired;
/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleCopyWith<Sale> get copyWith => _$SaleCopyWithImpl<Sale>(this as Sale, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Sale;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sale&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.facility, _this.facility) || other.facility == _this.facility)&&(identical(other.pointSale, _this.pointSale) || other.pointSale == _this.pointSale)&&(identical(other.salesperson, _this.salesperson) || other.salesperson == _this.salesperson)&&(identical(other.customer, _this.customer) || other.customer == _this.customer)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.paymentTerms, _this.paymentTerms) || other.paymentTerms == _this.paymentTerms)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.exchangeRate, _this.exchangeRate) || other.exchangeRate == _this.exchangeRate)&&(identical(other.shipTo, _this.shipTo) || other.shipTo == _this.shipTo)&&(identical(other.fulfillmentIntent, _this.fulfillmentIntent) || other.fulfillmentIntent == _this.fulfillmentIntent)&&(identical(other.origin, _this.origin) || other.origin == _this.origin)&&(identical(other.promiseDate, _this.promiseDate) || other.promiseDate == _this.promiseDate)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal)&&(identical(other.taxTotal, _this.taxTotal) || other.taxTotal == _this.taxTotal)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.balance, _this.balance) || other.balance == _this.balance)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.contact, _this.contact) || other.contact == _this.contact)&&(identical(other.recipient, _this.recipient) || other.recipient == _this.recipient)&&(identical(other.recipientName, _this.recipientName) || other.recipientName == _this.recipientName)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.hasExpired, _this.hasExpired) || other.hasExpired == _this.hasExpired));
}


@override
int get hashCode {
  final _this = this as Sale;
  return Object.hashAll([runtimeType,_this.id,_this.serial,_this.facility,_this.pointSale,_this.salesperson,_this.customer,_this.customerName,_this.paymentTerms,_this.currency,_this.exchangeRate,_this.shipTo,_this.fulfillmentIntent,_this.origin,_this.promiseDate,_this.status,const DeepCollectionEquality().hash(_this.lines),_this.subtotal,_this.taxTotal,_this.total,_this.balance,_this.date,_this.dueDate,_this.contact,_this.recipient,_this.recipientName,_this.priority,_this.comment,_this.hasExpired]);
}

@override
String toString() {
  final _this = this as Sale;
  return 'Sale(id: ${_this.id}, serial: ${_this.serial}, facility: ${_this.facility}, pointSale: ${_this.pointSale}, salesperson: ${_this.salesperson}, customer: ${_this.customer}, customerName: ${_this.customerName}, paymentTerms: ${_this.paymentTerms}, currency: ${_this.currency}, exchangeRate: ${_this.exchangeRate}, shipTo: ${_this.shipTo}, fulfillmentIntent: ${_this.fulfillmentIntent}, origin: ${_this.origin}, promiseDate: ${_this.promiseDate}, status: ${_this.status}, lines: ${_this.lines}, subtotal: ${_this.subtotal}, taxTotal: ${_this.taxTotal}, total: ${_this.total}, balance: ${_this.balance}, date: ${_this.date}, dueDate: ${_this.dueDate}, contact: ${_this.contact}, recipient: ${_this.recipient}, recipientName: ${_this.recipientName}, priority: ${_this.priority}, comment: ${_this.comment}, hasExpired: ${_this.hasExpired})';
}


}

/// @nodoc
abstract mixin class $SaleCopyWith<$Res>  {
  factory $SaleCopyWith(Sale value, $Res Function(Sale) _then) = _$SaleCopyWithImpl;
@useResult
$Res call({
 int id, int? serial, int facility, int? pointSale, int salesperson, int customer, String? customerName, PaymentTerms paymentTerms, Currency currency, String exchangeRate, int? shipTo, FulfillmentMode? fulfillmentIntent, SaleOrigin? origin, DateTime? promiseDate, SaleStatus status, List<SaleLine> lines, String subtotal, String taxTotal, String total, String? balance, DateTime date, DateTime dueDate, int? contact, String? recipient, String? recipientName, Priority? priority, String? comment, bool hasExpired
});




}
/// @nodoc
class _$SaleCopyWithImpl<$Res>
    implements $SaleCopyWith<$Res> {
  _$SaleCopyWithImpl(this._self, this._then);

  final Sale _self;
  final $Res Function(Sale) _then;

/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? serial = freezed,Object? facility = null,Object? pointSale = freezed,Object? salesperson = null,Object? customer = null,Object? customerName = freezed,Object? paymentTerms = null,Object? currency = null,Object? exchangeRate = null,Object? shipTo = freezed,Object? fulfillmentIntent = freezed,Object? origin = freezed,Object? promiseDate = freezed,Object? status = null,Object? lines = null,Object? subtotal = null,Object? taxTotal = null,Object? total = null,Object? balance = freezed,Object? date = null,Object? dueDate = null,Object? contact = freezed,Object? recipient = freezed,Object? recipientName = freezed,Object? priority = freezed,Object? comment = freezed,Object? hasExpired = null,}) {
  return _then(Sale(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,facility: null == facility ? _self.facility : facility // ignore: cast_nullable_to_non_nullable
as int,pointSale: freezed == pointSale ? _self.pointSale : pointSale // ignore: cast_nullable_to_non_nullable
as int?,salesperson: null == salesperson ? _self.salesperson : salesperson // ignore: cast_nullable_to_non_nullable
as int,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as int,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,paymentTerms: null == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as PaymentTerms,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as String,shipTo: freezed == shipTo ? _self.shipTo : shipTo // ignore: cast_nullable_to_non_nullable
as int?,fulfillmentIntent: freezed == fulfillmentIntent ? _self.fulfillmentIntent : fulfillmentIntent // ignore: cast_nullable_to_non_nullable
as FulfillmentMode?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as SaleOrigin?,promiseDate: freezed == promiseDate ? _self.promiseDate : promiseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SaleStatus,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<SaleLine>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as String,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as int?,recipient: freezed == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as String?,recipientName: freezed == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,hasExpired: null == hasExpired ? _self.hasExpired : hasExpired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Sale].
extension SalePatterns on Sale {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sale() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sale value)  $default,){
final _that = this;
switch (_that) {
case _Sale():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sale value)?  $default,){
final _that = this;
switch (_that) {
case _Sale() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? serial,  int facility,  int? pointSale,  int salesperson,  int customer,  String? customerName,  PaymentTerms paymentTerms,  Currency currency,  String exchangeRate,  int? shipTo,  FulfillmentMode? fulfillmentIntent,  SaleOrigin? origin,  DateTime? promiseDate,  SaleStatus status,  List<SaleLine> lines,  String subtotal,  String taxTotal,  String total,  String? balance,  DateTime date,  DateTime dueDate,  int? contact,  String? recipient,  String? recipientName,  Priority? priority,  String? comment,  bool hasExpired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sale() when $default != null:
return $default(_that.id,_that.serial,_that.facility,_that.pointSale,_that.salesperson,_that.customer,_that.customerName,_that.paymentTerms,_that.currency,_that.exchangeRate,_that.shipTo,_that.fulfillmentIntent,_that.origin,_that.promiseDate,_that.status,_that.lines,_that.subtotal,_that.taxTotal,_that.total,_that.balance,_that.date,_that.dueDate,_that.contact,_that.recipient,_that.recipientName,_that.priority,_that.comment,_that.hasExpired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? serial,  int facility,  int? pointSale,  int salesperson,  int customer,  String? customerName,  PaymentTerms paymentTerms,  Currency currency,  String exchangeRate,  int? shipTo,  FulfillmentMode? fulfillmentIntent,  SaleOrigin? origin,  DateTime? promiseDate,  SaleStatus status,  List<SaleLine> lines,  String subtotal,  String taxTotal,  String total,  String? balance,  DateTime date,  DateTime dueDate,  int? contact,  String? recipient,  String? recipientName,  Priority? priority,  String? comment,  bool hasExpired)  $default,) {final _that = this;
switch (_that) {
case _Sale():
return $default(_that.id,_that.serial,_that.facility,_that.pointSale,_that.salesperson,_that.customer,_that.customerName,_that.paymentTerms,_that.currency,_that.exchangeRate,_that.shipTo,_that.fulfillmentIntent,_that.origin,_that.promiseDate,_that.status,_that.lines,_that.subtotal,_that.taxTotal,_that.total,_that.balance,_that.date,_that.dueDate,_that.contact,_that.recipient,_that.recipientName,_that.priority,_that.comment,_that.hasExpired);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? serial,  int facility,  int? pointSale,  int salesperson,  int customer,  String? customerName,  PaymentTerms paymentTerms,  Currency currency,  String exchangeRate,  int? shipTo,  FulfillmentMode? fulfillmentIntent,  SaleOrigin? origin,  DateTime? promiseDate,  SaleStatus status,  List<SaleLine> lines,  String subtotal,  String taxTotal,  String total,  String? balance,  DateTime date,  DateTime dueDate,  int? contact,  String? recipient,  String? recipientName,  Priority? priority,  String? comment,  bool hasExpired)?  $default,) {final _that = this;
switch (_that) {
case _Sale() when $default != null:
return $default(_that.id,_that.serial,_that.facility,_that.pointSale,_that.salesperson,_that.customer,_that.customerName,_that.paymentTerms,_that.currency,_that.exchangeRate,_that.shipTo,_that.fulfillmentIntent,_that.origin,_that.promiseDate,_that.status,_that.lines,_that.subtotal,_that.taxTotal,_that.total,_that.balance,_that.date,_that.dueDate,_that.contact,_that.recipient,_that.recipientName,_that.priority,_that.comment,_that.hasExpired);case _:
  return null;

}
}

}

/// @nodoc


class _Sale extends Sale {
  const _Sale({required this.id, this.serial, required this.facility, this.pointSale, required this.salesperson, required this.customer, this.customerName, required this.paymentTerms, required this.currency, required this.exchangeRate, this.shipTo, this.fulfillmentIntent, this.origin, this.promiseDate, required this.status,  List<SaleLine> lines = const <SaleLine>[], required this.subtotal, required this.taxTotal, required this.total, this.balance, required this.date, required this.dueDate, this.contact, this.recipient, this.recipientName, this.priority, this.comment, this.hasExpired = false}): _lines = lines,super._();
  

@override final  int id;
@override final  int? serial;
@override final  int facility;
@override final  int? pointSale;
@override final  int salesperson;
@override final  int customer;
@override final  String? customerName;
@override final  PaymentTerms paymentTerms;
@override final  Currency currency;
@override final  String exchangeRate;
@override final  int? shipTo;
@override final  FulfillmentMode? fulfillmentIntent;
@override final  SaleOrigin? origin;
@override final  DateTime? promiseDate;
@override final  SaleStatus status;
 final  List<SaleLine> _lines;
@override@JsonKey() List<SaleLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override final  String subtotal;
@override final  String taxTotal;
@override final  String total;
@override final  String? balance;
@override final  DateTime date;
@override final  DateTime dueDate;
@override final  int? contact;
@override final  String? recipient;
@override final  String? recipientName;
@override final  Priority? priority;
@override final  String? comment;
@override@JsonKey() final  bool hasExpired;

/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleCopyWith<_Sale> get copyWith => __$SaleCopyWithImpl<_Sale>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sale&&(identical(other.id, id) || other.id == id)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.facility, facility) || other.facility == facility)&&(identical(other.pointSale, pointSale) || other.pointSale == pointSale)&&(identical(other.salesperson, salesperson) || other.salesperson == salesperson)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.paymentTerms, paymentTerms) || other.paymentTerms == paymentTerms)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.exchangeRate, exchangeRate) || other.exchangeRate == exchangeRate)&&(identical(other.shipTo, shipTo) || other.shipTo == shipTo)&&(identical(other.fulfillmentIntent, fulfillmentIntent) || other.fulfillmentIntent == fulfillmentIntent)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.promiseDate, promiseDate) || other.promiseDate == promiseDate)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.total, total) || other.total == total)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.date, date) || other.date == date)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.hasExpired, hasExpired) || other.hasExpired == hasExpired));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,serial,facility,pointSale,salesperson,customer,customerName,paymentTerms,currency,exchangeRate,shipTo,fulfillmentIntent,origin,promiseDate,status,const DeepCollectionEquality().hash(_lines),subtotal,taxTotal,total,balance,date,dueDate,contact,recipient,recipientName,priority,comment,hasExpired]);
}

@override
String toString() {
    return 'Sale(id: $id, serial: $serial, facility: $facility, pointSale: $pointSale, salesperson: $salesperson, customer: $customer, customerName: $customerName, paymentTerms: $paymentTerms, currency: $currency, exchangeRate: $exchangeRate, shipTo: $shipTo, fulfillmentIntent: $fulfillmentIntent, origin: $origin, promiseDate: $promiseDate, status: $status, lines: $lines, subtotal: $subtotal, taxTotal: $taxTotal, total: $total, balance: $balance, date: $date, dueDate: $dueDate, contact: $contact, recipient: $recipient, recipientName: $recipientName, priority: $priority, comment: $comment, hasExpired: $hasExpired)';
}


}

/// @nodoc
abstract mixin class _$SaleCopyWith<$Res> implements $SaleCopyWith<$Res> {
  factory _$SaleCopyWith(_Sale value, $Res Function(_Sale) _then) = __$SaleCopyWithImpl;
@override @useResult
$Res call({
 int id, int? serial, int facility, int? pointSale, int salesperson, int customer, String? customerName, PaymentTerms paymentTerms, Currency currency, String exchangeRate, int? shipTo, FulfillmentMode? fulfillmentIntent, SaleOrigin? origin, DateTime? promiseDate, SaleStatus status, List<SaleLine> lines, String subtotal, String taxTotal, String total, String? balance, DateTime date, DateTime dueDate, int? contact, String? recipient, String? recipientName, Priority? priority, String? comment, bool hasExpired
});




}
/// @nodoc
class __$SaleCopyWithImpl<$Res>
    implements _$SaleCopyWith<$Res> {
  __$SaleCopyWithImpl(this._self, this._then);

  final _Sale _self;
  final $Res Function(_Sale) _then;

/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? serial = freezed,Object? facility = null,Object? pointSale = freezed,Object? salesperson = null,Object? customer = null,Object? customerName = freezed,Object? paymentTerms = null,Object? currency = null,Object? exchangeRate = null,Object? shipTo = freezed,Object? fulfillmentIntent = freezed,Object? origin = freezed,Object? promiseDate = freezed,Object? status = null,Object? lines = null,Object? subtotal = null,Object? taxTotal = null,Object? total = null,Object? balance = freezed,Object? date = null,Object? dueDate = null,Object? contact = freezed,Object? recipient = freezed,Object? recipientName = freezed,Object? priority = freezed,Object? comment = freezed,Object? hasExpired = null,}) {
  return _then(_Sale(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,facility: null == facility ? _self.facility : facility // ignore: cast_nullable_to_non_nullable
as int,pointSale: freezed == pointSale ? _self.pointSale : pointSale // ignore: cast_nullable_to_non_nullable
as int?,salesperson: null == salesperson ? _self.salesperson : salesperson // ignore: cast_nullable_to_non_nullable
as int,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as int,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,paymentTerms: null == paymentTerms ? _self.paymentTerms : paymentTerms // ignore: cast_nullable_to_non_nullable
as PaymentTerms,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,exchangeRate: null == exchangeRate ? _self.exchangeRate : exchangeRate // ignore: cast_nullable_to_non_nullable
as String,shipTo: freezed == shipTo ? _self.shipTo : shipTo // ignore: cast_nullable_to_non_nullable
as int?,fulfillmentIntent: freezed == fulfillmentIntent ? _self.fulfillmentIntent : fulfillmentIntent // ignore: cast_nullable_to_non_nullable
as FulfillmentMode?,origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as SaleOrigin?,promiseDate: freezed == promiseDate ? _self.promiseDate : promiseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SaleStatus,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<SaleLine>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as String,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,contact: freezed == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as int?,recipient: freezed == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as String?,recipientName: freezed == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as Priority?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,hasExpired: null == hasExpired ? _self.hasExpired : hasExpired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
