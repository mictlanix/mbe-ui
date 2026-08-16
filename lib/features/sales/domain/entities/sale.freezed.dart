// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Sale {
  int get id => throw _privateConstructorUsedError;
  int? get serial => throw _privateConstructorUsedError;
  int get facility => throw _privateConstructorUsedError;
  int get pointSale => throw _privateConstructorUsedError;
  int get salesperson => throw _privateConstructorUsedError;
  int get customer => throw _privateConstructorUsedError;
  String? get customerName => throw _privateConstructorUsedError;
  PaymentTerms get paymentTerms => throw _privateConstructorUsedError;
  Currency get currency => throw _privateConstructorUsedError;
  String get exchangeRate => throw _privateConstructorUsedError;
  int? get shipTo =>
      throw _privateConstructorUsedError; // `null` for a sale predating mbe-api#171 or raised by a client that
  // never asked — "not recorded", not "delivery" (FulfillmentMode.fromApi
  // keeps that distinction rather than guessing). The capture step writes
  // this via `updateHeader` once the cashier picks a mode.
  FulfillmentMode? get fulfillmentIntent => throw _privateConstructorUsedError;
  DateTime get promiseDate => throw _privateConstructorUsedError;
  SaleStatus get status => throw _privateConstructorUsedError;
  List<SaleLine> get lines => throw _privateConstructorUsedError;
  String get subtotal => throw _privateConstructorUsedError;
  String get taxTotal => throw _privateConstructorUsedError;
  String get total => throw _privateConstructorUsedError;
  String get balance => throw _privateConstructorUsedError;

  /// Create a copy of Sale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SaleCopyWith<Sale> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaleCopyWith<$Res> {
  factory $SaleCopyWith(Sale value, $Res Function(Sale) then) =
      _$SaleCopyWithImpl<$Res, Sale>;
  @useResult
  $Res call({
    int id,
    int? serial,
    int facility,
    int pointSale,
    int salesperson,
    int customer,
    String? customerName,
    PaymentTerms paymentTerms,
    Currency currency,
    String exchangeRate,
    int? shipTo,
    FulfillmentMode? fulfillmentIntent,
    DateTime promiseDate,
    SaleStatus status,
    List<SaleLine> lines,
    String subtotal,
    String taxTotal,
    String total,
    String balance,
  });
}

/// @nodoc
class _$SaleCopyWithImpl<$Res, $Val extends Sale>
    implements $SaleCopyWith<$Res> {
  _$SaleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Sale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serial = freezed,
    Object? facility = null,
    Object? pointSale = null,
    Object? salesperson = null,
    Object? customer = null,
    Object? customerName = freezed,
    Object? paymentTerms = null,
    Object? currency = null,
    Object? exchangeRate = null,
    Object? shipTo = freezed,
    Object? fulfillmentIntent = freezed,
    Object? promiseDate = null,
    Object? status = null,
    Object? lines = null,
    Object? subtotal = null,
    Object? taxTotal = null,
    Object? total = null,
    Object? balance = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            serial: freezed == serial
                ? _value.serial
                : serial // ignore: cast_nullable_to_non_nullable
                      as int?,
            facility: null == facility
                ? _value.facility
                : facility // ignore: cast_nullable_to_non_nullable
                      as int,
            pointSale: null == pointSale
                ? _value.pointSale
                : pointSale // ignore: cast_nullable_to_non_nullable
                      as int,
            salesperson: null == salesperson
                ? _value.salesperson
                : salesperson // ignore: cast_nullable_to_non_nullable
                      as int,
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as int,
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentTerms: null == paymentTerms
                ? _value.paymentTerms
                : paymentTerms // ignore: cast_nullable_to_non_nullable
                      as PaymentTerms,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as Currency,
            exchangeRate: null == exchangeRate
                ? _value.exchangeRate
                : exchangeRate // ignore: cast_nullable_to_non_nullable
                      as String,
            shipTo: freezed == shipTo
                ? _value.shipTo
                : shipTo // ignore: cast_nullable_to_non_nullable
                      as int?,
            fulfillmentIntent: freezed == fulfillmentIntent
                ? _value.fulfillmentIntent
                : fulfillmentIntent // ignore: cast_nullable_to_non_nullable
                      as FulfillmentMode?,
            promiseDate: null == promiseDate
                ? _value.promiseDate
                : promiseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SaleStatus,
            lines: null == lines
                ? _value.lines
                : lines // ignore: cast_nullable_to_non_nullable
                      as List<SaleLine>,
            subtotal: null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                      as String,
            taxTotal: null == taxTotal
                ? _value.taxTotal
                : taxTotal // ignore: cast_nullable_to_non_nullable
                      as String,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as String,
            balance: null == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SaleImplCopyWith<$Res> implements $SaleCopyWith<$Res> {
  factory _$$SaleImplCopyWith(
    _$SaleImpl value,
    $Res Function(_$SaleImpl) then,
  ) = __$$SaleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int? serial,
    int facility,
    int pointSale,
    int salesperson,
    int customer,
    String? customerName,
    PaymentTerms paymentTerms,
    Currency currency,
    String exchangeRate,
    int? shipTo,
    FulfillmentMode? fulfillmentIntent,
    DateTime promiseDate,
    SaleStatus status,
    List<SaleLine> lines,
    String subtotal,
    String taxTotal,
    String total,
    String balance,
  });
}

/// @nodoc
class __$$SaleImplCopyWithImpl<$Res>
    extends _$SaleCopyWithImpl<$Res, _$SaleImpl>
    implements _$$SaleImplCopyWith<$Res> {
  __$$SaleImplCopyWithImpl(_$SaleImpl _value, $Res Function(_$SaleImpl) _then)
    : super(_value, _then);

  /// Create a copy of Sale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serial = freezed,
    Object? facility = null,
    Object? pointSale = null,
    Object? salesperson = null,
    Object? customer = null,
    Object? customerName = freezed,
    Object? paymentTerms = null,
    Object? currency = null,
    Object? exchangeRate = null,
    Object? shipTo = freezed,
    Object? fulfillmentIntent = freezed,
    Object? promiseDate = null,
    Object? status = null,
    Object? lines = null,
    Object? subtotal = null,
    Object? taxTotal = null,
    Object? total = null,
    Object? balance = null,
  }) {
    return _then(
      _$SaleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        serial: freezed == serial
            ? _value.serial
            : serial // ignore: cast_nullable_to_non_nullable
                  as int?,
        facility: null == facility
            ? _value.facility
            : facility // ignore: cast_nullable_to_non_nullable
                  as int,
        pointSale: null == pointSale
            ? _value.pointSale
            : pointSale // ignore: cast_nullable_to_non_nullable
                  as int,
        salesperson: null == salesperson
            ? _value.salesperson
            : salesperson // ignore: cast_nullable_to_non_nullable
                  as int,
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as int,
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentTerms: null == paymentTerms
            ? _value.paymentTerms
            : paymentTerms // ignore: cast_nullable_to_non_nullable
                  as PaymentTerms,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as Currency,
        exchangeRate: null == exchangeRate
            ? _value.exchangeRate
            : exchangeRate // ignore: cast_nullable_to_non_nullable
                  as String,
        shipTo: freezed == shipTo
            ? _value.shipTo
            : shipTo // ignore: cast_nullable_to_non_nullable
                  as int?,
        fulfillmentIntent: freezed == fulfillmentIntent
            ? _value.fulfillmentIntent
            : fulfillmentIntent // ignore: cast_nullable_to_non_nullable
                  as FulfillmentMode?,
        promiseDate: null == promiseDate
            ? _value.promiseDate
            : promiseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SaleStatus,
        lines: null == lines
            ? _value._lines
            : lines // ignore: cast_nullable_to_non_nullable
                  as List<SaleLine>,
        subtotal: null == subtotal
            ? _value.subtotal
            : subtotal // ignore: cast_nullable_to_non_nullable
                  as String,
        taxTotal: null == taxTotal
            ? _value.taxTotal
            : taxTotal // ignore: cast_nullable_to_non_nullable
                  as String,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as String,
        balance: null == balance
            ? _value.balance
            : balance // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SaleImpl extends _Sale {
  const _$SaleImpl({
    required this.id,
    this.serial,
    required this.facility,
    required this.pointSale,
    required this.salesperson,
    required this.customer,
    this.customerName,
    required this.paymentTerms,
    required this.currency,
    required this.exchangeRate,
    this.shipTo,
    this.fulfillmentIntent,
    required this.promiseDate,
    required this.status,
    final List<SaleLine> lines = const <SaleLine>[],
    required this.subtotal,
    required this.taxTotal,
    required this.total,
    required this.balance,
  }) : _lines = lines,
       super._();

  @override
  final int id;
  @override
  final int? serial;
  @override
  final int facility;
  @override
  final int pointSale;
  @override
  final int salesperson;
  @override
  final int customer;
  @override
  final String? customerName;
  @override
  final PaymentTerms paymentTerms;
  @override
  final Currency currency;
  @override
  final String exchangeRate;
  @override
  final int? shipTo;
  // `null` for a sale predating mbe-api#171 or raised by a client that
  // never asked — "not recorded", not "delivery" (FulfillmentMode.fromApi
  // keeps that distinction rather than guessing). The capture step writes
  // this via `updateHeader` once the cashier picks a mode.
  @override
  final FulfillmentMode? fulfillmentIntent;
  @override
  final DateTime promiseDate;
  @override
  final SaleStatus status;
  final List<SaleLine> _lines;
  @override
  @JsonKey()
  List<SaleLine> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  final String subtotal;
  @override
  final String taxTotal;
  @override
  final String total;
  @override
  final String balance;

  @override
  String toString() {
    return 'Sale(id: $id, serial: $serial, facility: $facility, pointSale: $pointSale, salesperson: $salesperson, customer: $customer, customerName: $customerName, paymentTerms: $paymentTerms, currency: $currency, exchangeRate: $exchangeRate, shipTo: $shipTo, fulfillmentIntent: $fulfillmentIntent, promiseDate: $promiseDate, status: $status, lines: $lines, subtotal: $subtotal, taxTotal: $taxTotal, total: $total, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.facility, facility) ||
                other.facility == facility) &&
            (identical(other.pointSale, pointSale) ||
                other.pointSale == pointSale) &&
            (identical(other.salesperson, salesperson) ||
                other.salesperson == salesperson) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.paymentTerms, paymentTerms) ||
                other.paymentTerms == paymentTerms) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.exchangeRate, exchangeRate) ||
                other.exchangeRate == exchangeRate) &&
            (identical(other.shipTo, shipTo) || other.shipTo == shipTo) &&
            (identical(other.fulfillmentIntent, fulfillmentIntent) ||
                other.fulfillmentIntent == fulfillmentIntent) &&
            (identical(other.promiseDate, promiseDate) ||
                other.promiseDate == promiseDate) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._lines, _lines) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.taxTotal, taxTotal) ||
                other.taxTotal == taxTotal) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.balance, balance) || other.balance == balance));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    serial,
    facility,
    pointSale,
    salesperson,
    customer,
    customerName,
    paymentTerms,
    currency,
    exchangeRate,
    shipTo,
    fulfillmentIntent,
    promiseDate,
    status,
    const DeepCollectionEquality().hash(_lines),
    subtotal,
    taxTotal,
    total,
    balance,
  ]);

  /// Create a copy of Sale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SaleImplCopyWith<_$SaleImpl> get copyWith =>
      __$$SaleImplCopyWithImpl<_$SaleImpl>(this, _$identity);
}

abstract class _Sale extends Sale {
  const factory _Sale({
    required final int id,
    final int? serial,
    required final int facility,
    required final int pointSale,
    required final int salesperson,
    required final int customer,
    final String? customerName,
    required final PaymentTerms paymentTerms,
    required final Currency currency,
    required final String exchangeRate,
    final int? shipTo,
    final FulfillmentMode? fulfillmentIntent,
    required final DateTime promiseDate,
    required final SaleStatus status,
    final List<SaleLine> lines,
    required final String subtotal,
    required final String taxTotal,
    required final String total,
    required final String balance,
  }) = _$SaleImpl;
  const _Sale._() : super._();

  @override
  int get id;
  @override
  int? get serial;
  @override
  int get facility;
  @override
  int get pointSale;
  @override
  int get salesperson;
  @override
  int get customer;
  @override
  String? get customerName;
  @override
  PaymentTerms get paymentTerms;
  @override
  Currency get currency;
  @override
  String get exchangeRate;
  @override
  int? get shipTo; // `null` for a sale predating mbe-api#171 or raised by a client that
  // never asked — "not recorded", not "delivery" (FulfillmentMode.fromApi
  // keeps that distinction rather than guessing). The capture step writes
  // this via `updateHeader` once the cashier picks a mode.
  @override
  FulfillmentMode? get fulfillmentIntent;
  @override
  DateTime get promiseDate;
  @override
  SaleStatus get status;
  @override
  List<SaleLine> get lines;
  @override
  String get subtotal;
  @override
  String get taxTotal;
  @override
  String get total;
  @override
  String get balance;

  /// Create a copy of Sale
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SaleImplCopyWith<_$SaleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
