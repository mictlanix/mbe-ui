// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_quote_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SalesQuoteSummary {

 int get id; int? get serial; int get customer;/// The customer's own name, joined server-side (mbe-api#213) — the same
/// join `OpenSale.customerDisplayName` reads for orders. Null only if
/// the customer row is gone.
 String? get customerDisplayName; int get salesperson; DateTime get date;/// The quote's expiry (spec 040 FR-024, FR-037).
 DateTime get dueDate; Currency get currency; SaleStatus get status;/// Orthogonal to [status] — a quote can be both `completed` and
/// expired. Rendered as a **separate marker**, never folded into the
/// status chip (FR-024, FR-037).
 bool get hasExpired; String get total;
/// Create a copy of SalesQuoteSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesQuoteSummaryCopyWith<SalesQuoteSummary> get copyWith => _$SalesQuoteSummaryCopyWithImpl<SalesQuoteSummary>(this as SalesQuoteSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SalesQuoteSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesQuoteSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.serial, _this.serial) || other.serial == _this.serial)&&(identical(other.customer, _this.customer) || other.customer == _this.customer)&&(identical(other.customerDisplayName, _this.customerDisplayName) || other.customerDisplayName == _this.customerDisplayName)&&(identical(other.salesperson, _this.salesperson) || other.salesperson == _this.salesperson)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.hasExpired, _this.hasExpired) || other.hasExpired == _this.hasExpired)&&(identical(other.total, _this.total) || other.total == _this.total));
}


@override
int get hashCode {
  final _this = this as SalesQuoteSummary;
  return Object.hash(runtimeType,_this.id,_this.serial,_this.customer,_this.customerDisplayName,_this.salesperson,_this.date,_this.dueDate,_this.currency,_this.status,_this.hasExpired,_this.total);
}

@override
String toString() {
  final _this = this as SalesQuoteSummary;
  return 'SalesQuoteSummary(id: ${_this.id}, serial: ${_this.serial}, customer: ${_this.customer}, customerDisplayName: ${_this.customerDisplayName}, salesperson: ${_this.salesperson}, date: ${_this.date}, dueDate: ${_this.dueDate}, currency: ${_this.currency}, status: ${_this.status}, hasExpired: ${_this.hasExpired}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $SalesQuoteSummaryCopyWith<$Res>  {
  factory $SalesQuoteSummaryCopyWith(SalesQuoteSummary value, $Res Function(SalesQuoteSummary) _then) = _$SalesQuoteSummaryCopyWithImpl;
@useResult
$Res call({
 int id, int? serial, int customer, String? customerDisplayName, int salesperson, DateTime date, DateTime dueDate, Currency currency, SaleStatus status, bool hasExpired, String total
});




}
/// @nodoc
class _$SalesQuoteSummaryCopyWithImpl<$Res>
    implements $SalesQuoteSummaryCopyWith<$Res> {
  _$SalesQuoteSummaryCopyWithImpl(this._self, this._then);

  final SalesQuoteSummary _self;
  final $Res Function(SalesQuoteSummary) _then;

/// Create a copy of SalesQuoteSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? serial = freezed,Object? customer = null,Object? customerDisplayName = freezed,Object? salesperson = null,Object? date = null,Object? dueDate = null,Object? currency = null,Object? status = null,Object? hasExpired = null,Object? total = null,}) {
  return _then(SalesQuoteSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as int,customerDisplayName: freezed == customerDisplayName ? _self.customerDisplayName : customerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,salesperson: null == salesperson ? _self.salesperson : salesperson // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SaleStatus,hasExpired: null == hasExpired ? _self.hasExpired : hasExpired // ignore: cast_nullable_to_non_nullable
as bool,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesQuoteSummary].
extension SalesQuoteSummaryPatterns on SalesQuoteSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesQuoteSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesQuoteSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesQuoteSummary value)  $default,){
final _that = this;
switch (_that) {
case _SalesQuoteSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesQuoteSummary value)?  $default,){
final _that = this;
switch (_that) {
case _SalesQuoteSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? serial,  int customer,  String? customerDisplayName,  int salesperson,  DateTime date,  DateTime dueDate,  Currency currency,  SaleStatus status,  bool hasExpired,  String total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesQuoteSummary() when $default != null:
return $default(_that.id,_that.serial,_that.customer,_that.customerDisplayName,_that.salesperson,_that.date,_that.dueDate,_that.currency,_that.status,_that.hasExpired,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? serial,  int customer,  String? customerDisplayName,  int salesperson,  DateTime date,  DateTime dueDate,  Currency currency,  SaleStatus status,  bool hasExpired,  String total)  $default,) {final _that = this;
switch (_that) {
case _SalesQuoteSummary():
return $default(_that.id,_that.serial,_that.customer,_that.customerDisplayName,_that.salesperson,_that.date,_that.dueDate,_that.currency,_that.status,_that.hasExpired,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? serial,  int customer,  String? customerDisplayName,  int salesperson,  DateTime date,  DateTime dueDate,  Currency currency,  SaleStatus status,  bool hasExpired,  String total)?  $default,) {final _that = this;
switch (_that) {
case _SalesQuoteSummary() when $default != null:
return $default(_that.id,_that.serial,_that.customer,_that.customerDisplayName,_that.salesperson,_that.date,_that.dueDate,_that.currency,_that.status,_that.hasExpired,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _SalesQuoteSummary implements SalesQuoteSummary {
  const _SalesQuoteSummary({required this.id, this.serial, required this.customer, this.customerDisplayName, required this.salesperson, required this.date, required this.dueDate, required this.currency, required this.status, required this.hasExpired, required this.total});
  

@override final  int id;
@override final  int? serial;
@override final  int customer;
/// The customer's own name, joined server-side (mbe-api#213) — the same
/// join `OpenSale.customerDisplayName` reads for orders. Null only if
/// the customer row is gone.
@override final  String? customerDisplayName;
@override final  int salesperson;
@override final  DateTime date;
/// The quote's expiry (spec 040 FR-024, FR-037).
@override final  DateTime dueDate;
@override final  Currency currency;
@override final  SaleStatus status;
/// Orthogonal to [status] — a quote can be both `completed` and
/// expired. Rendered as a **separate marker**, never folded into the
/// status chip (FR-024, FR-037).
@override final  bool hasExpired;
@override final  String total;

/// Create a copy of SalesQuoteSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesQuoteSummaryCopyWith<_SalesQuoteSummary> get copyWith => __$SalesQuoteSummaryCopyWithImpl<_SalesQuoteSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesQuoteSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.customerDisplayName, customerDisplayName) || other.customerDisplayName == customerDisplayName)&&(identical(other.salesperson, salesperson) || other.salesperson == salesperson)&&(identical(other.date, date) || other.date == date)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.hasExpired, hasExpired) || other.hasExpired == hasExpired)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,serial,customer,customerDisplayName,salesperson,date,dueDate,currency,status,hasExpired,total);
}

@override
String toString() {
    return 'SalesQuoteSummary(id: $id, serial: $serial, customer: $customer, customerDisplayName: $customerDisplayName, salesperson: $salesperson, date: $date, dueDate: $dueDate, currency: $currency, status: $status, hasExpired: $hasExpired, total: $total)';
}


}

/// @nodoc
abstract mixin class _$SalesQuoteSummaryCopyWith<$Res> implements $SalesQuoteSummaryCopyWith<$Res> {
  factory _$SalesQuoteSummaryCopyWith(_SalesQuoteSummary value, $Res Function(_SalesQuoteSummary) _then) = __$SalesQuoteSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, int? serial, int customer, String? customerDisplayName, int salesperson, DateTime date, DateTime dueDate, Currency currency, SaleStatus status, bool hasExpired, String total
});




}
/// @nodoc
class __$SalesQuoteSummaryCopyWithImpl<$Res>
    implements _$SalesQuoteSummaryCopyWith<$Res> {
  __$SalesQuoteSummaryCopyWithImpl(this._self, this._then);

  final _SalesQuoteSummary _self;
  final $Res Function(_SalesQuoteSummary) _then;

/// Create a copy of SalesQuoteSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? serial = freezed,Object? customer = null,Object? customerDisplayName = freezed,Object? salesperson = null,Object? date = null,Object? dueDate = null,Object? currency = null,Object? status = null,Object? hasExpired = null,Object? total = null,}) {
  return _then(_SalesQuoteSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as int?,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as int,customerDisplayName: freezed == customerDisplayName ? _self.customerDisplayName : customerDisplayName // ignore: cast_nullable_to_non_nullable
as String?,salesperson: null == salesperson ? _self.salesperson : salesperson // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SaleStatus,hasExpired: null == hasExpired ? _self.hasExpired : hasExpired // ignore: cast_nullable_to_non_nullable
as bool,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
