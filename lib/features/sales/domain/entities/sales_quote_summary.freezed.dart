// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_quote_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SalesQuoteSummary {
  int get id => throw _privateConstructorUsedError;
  int? get serial => throw _privateConstructorUsedError;
  int get customer => throw _privateConstructorUsedError;

  /// The customer's own name, joined server-side (mbe-api#213) — the same
  /// join `OpenSale.customerDisplayName` reads for orders. Null only if
  /// the customer row is gone.
  String? get customerDisplayName => throw _privateConstructorUsedError;
  int get salesperson => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  /// The quote's expiry (spec 040 FR-024, FR-037).
  DateTime get dueDate => throw _privateConstructorUsedError;
  Currency get currency => throw _privateConstructorUsedError;
  SaleStatus get status => throw _privateConstructorUsedError;

  /// Orthogonal to [status] — a quote can be both `completed` and
  /// expired. Rendered as a **separate marker**, never folded into the
  /// status chip (FR-024, FR-037).
  bool get hasExpired => throw _privateConstructorUsedError;
  String get total => throw _privateConstructorUsedError;

  /// Create a copy of SalesQuoteSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesQuoteSummaryCopyWith<SalesQuoteSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesQuoteSummaryCopyWith<$Res> {
  factory $SalesQuoteSummaryCopyWith(
    SalesQuoteSummary value,
    $Res Function(SalesQuoteSummary) then,
  ) = _$SalesQuoteSummaryCopyWithImpl<$Res, SalesQuoteSummary>;
  @useResult
  $Res call({
    int id,
    int? serial,
    int customer,
    String? customerDisplayName,
    int salesperson,
    DateTime date,
    DateTime dueDate,
    Currency currency,
    SaleStatus status,
    bool hasExpired,
    String total,
  });
}

/// @nodoc
class _$SalesQuoteSummaryCopyWithImpl<$Res, $Val extends SalesQuoteSummary>
    implements $SalesQuoteSummaryCopyWith<$Res> {
  _$SalesQuoteSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesQuoteSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serial = freezed,
    Object? customer = null,
    Object? customerDisplayName = freezed,
    Object? salesperson = null,
    Object? date = null,
    Object? dueDate = null,
    Object? currency = null,
    Object? status = null,
    Object? hasExpired = null,
    Object? total = null,
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
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as int,
            customerDisplayName: freezed == customerDisplayName
                ? _value.customerDisplayName
                : customerDisplayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            salesperson: null == salesperson
                ? _value.salesperson
                : salesperson // ignore: cast_nullable_to_non_nullable
                      as int,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as Currency,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SaleStatus,
            hasExpired: null == hasExpired
                ? _value.hasExpired
                : hasExpired // ignore: cast_nullable_to_non_nullable
                      as bool,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalesQuoteSummaryImplCopyWith<$Res>
    implements $SalesQuoteSummaryCopyWith<$Res> {
  factory _$$SalesQuoteSummaryImplCopyWith(
    _$SalesQuoteSummaryImpl value,
    $Res Function(_$SalesQuoteSummaryImpl) then,
  ) = __$$SalesQuoteSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int? serial,
    int customer,
    String? customerDisplayName,
    int salesperson,
    DateTime date,
    DateTime dueDate,
    Currency currency,
    SaleStatus status,
    bool hasExpired,
    String total,
  });
}

/// @nodoc
class __$$SalesQuoteSummaryImplCopyWithImpl<$Res>
    extends _$SalesQuoteSummaryCopyWithImpl<$Res, _$SalesQuoteSummaryImpl>
    implements _$$SalesQuoteSummaryImplCopyWith<$Res> {
  __$$SalesQuoteSummaryImplCopyWithImpl(
    _$SalesQuoteSummaryImpl _value,
    $Res Function(_$SalesQuoteSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalesQuoteSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serial = freezed,
    Object? customer = null,
    Object? customerDisplayName = freezed,
    Object? salesperson = null,
    Object? date = null,
    Object? dueDate = null,
    Object? currency = null,
    Object? status = null,
    Object? hasExpired = null,
    Object? total = null,
  }) {
    return _then(
      _$SalesQuoteSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        serial: freezed == serial
            ? _value.serial
            : serial // ignore: cast_nullable_to_non_nullable
                  as int?,
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as int,
        customerDisplayName: freezed == customerDisplayName
            ? _value.customerDisplayName
            : customerDisplayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        salesperson: null == salesperson
            ? _value.salesperson
            : salesperson // ignore: cast_nullable_to_non_nullable
                  as int,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as Currency,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SaleStatus,
        hasExpired: null == hasExpired
            ? _value.hasExpired
            : hasExpired // ignore: cast_nullable_to_non_nullable
                  as bool,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SalesQuoteSummaryImpl implements _SalesQuoteSummary {
  const _$SalesQuoteSummaryImpl({
    required this.id,
    this.serial,
    required this.customer,
    this.customerDisplayName,
    required this.salesperson,
    required this.date,
    required this.dueDate,
    required this.currency,
    required this.status,
    required this.hasExpired,
    required this.total,
  });

  @override
  final int id;
  @override
  final int? serial;
  @override
  final int customer;

  /// The customer's own name, joined server-side (mbe-api#213) — the same
  /// join `OpenSale.customerDisplayName` reads for orders. Null only if
  /// the customer row is gone.
  @override
  final String? customerDisplayName;
  @override
  final int salesperson;
  @override
  final DateTime date;

  /// The quote's expiry (spec 040 FR-024, FR-037).
  @override
  final DateTime dueDate;
  @override
  final Currency currency;
  @override
  final SaleStatus status;

  /// Orthogonal to [status] — a quote can be both `completed` and
  /// expired. Rendered as a **separate marker**, never folded into the
  /// status chip (FR-024, FR-037).
  @override
  final bool hasExpired;
  @override
  final String total;

  @override
  String toString() {
    return 'SalesQuoteSummary(id: $id, serial: $serial, customer: $customer, customerDisplayName: $customerDisplayName, salesperson: $salesperson, date: $date, dueDate: $dueDate, currency: $currency, status: $status, hasExpired: $hasExpired, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesQuoteSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerDisplayName, customerDisplayName) ||
                other.customerDisplayName == customerDisplayName) &&
            (identical(other.salesperson, salesperson) ||
                other.salesperson == salesperson) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.hasExpired, hasExpired) ||
                other.hasExpired == hasExpired) &&
            (identical(other.total, total) || other.total == total));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    serial,
    customer,
    customerDisplayName,
    salesperson,
    date,
    dueDate,
    currency,
    status,
    hasExpired,
    total,
  );

  /// Create a copy of SalesQuoteSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesQuoteSummaryImplCopyWith<_$SalesQuoteSummaryImpl> get copyWith =>
      __$$SalesQuoteSummaryImplCopyWithImpl<_$SalesQuoteSummaryImpl>(
        this,
        _$identity,
      );
}

abstract class _SalesQuoteSummary implements SalesQuoteSummary {
  const factory _SalesQuoteSummary({
    required final int id,
    final int? serial,
    required final int customer,
    final String? customerDisplayName,
    required final int salesperson,
    required final DateTime date,
    required final DateTime dueDate,
    required final Currency currency,
    required final SaleStatus status,
    required final bool hasExpired,
    required final String total,
  }) = _$SalesQuoteSummaryImpl;

  @override
  int get id;
  @override
  int? get serial;
  @override
  int get customer;

  /// The customer's own name, joined server-side (mbe-api#213) — the same
  /// join `OpenSale.customerDisplayName` reads for orders. Null only if
  /// the customer row is gone.
  @override
  String? get customerDisplayName;
  @override
  int get salesperson;
  @override
  DateTime get date;

  /// The quote's expiry (spec 040 FR-024, FR-037).
  @override
  DateTime get dueDate;
  @override
  Currency get currency;
  @override
  SaleStatus get status;

  /// Orthogonal to [status] — a quote can be both `completed` and
  /// expired. Rendered as a **separate marker**, never folded into the
  /// status chip (FR-024, FR-037).
  @override
  bool get hasExpired;
  @override
  String get total;

  /// Create a copy of SalesQuoteSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesQuoteSummaryImplCopyWith<_$SalesQuoteSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
