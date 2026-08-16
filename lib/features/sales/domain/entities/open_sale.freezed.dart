// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'open_sale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OpenSale {
  int get id => throw _privateConstructorUsedError;
  int? get serial => throw _privateConstructorUsedError;

  /// Who the sale is for. Carried because [customerName] is **not** the
  /// customer's name: mbe's data dictionary calls that column "Override
  /// customer name on docs", and mbe-api sets it only from what a client
  /// sends — so it is null on every ordinary sale, walk-in ones included.
  /// The name a list shows has to be resolved from this id, exactly as
  /// `CustomerBar` already does on the sale itself (FR-023).
  int get customer => throw _privateConstructorUsedError;

  /// The per-document name override, or `null` — see [customer].
  String? get customerName => throw _privateConstructorUsedError;
  String get total => throw _privateConstructorUsedError;
  String get balance => throw _privateConstructorUsedError;
  SaleStatus get status => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  /// Create a copy of OpenSale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OpenSaleCopyWith<OpenSale> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OpenSaleCopyWith<$Res> {
  factory $OpenSaleCopyWith(OpenSale value, $Res Function(OpenSale) then) =
      _$OpenSaleCopyWithImpl<$Res, OpenSale>;
  @useResult
  $Res call({
    int id,
    int? serial,
    int customer,
    String? customerName,
    String total,
    String balance,
    SaleStatus status,
    DateTime date,
  });
}

/// @nodoc
class _$OpenSaleCopyWithImpl<$Res, $Val extends OpenSale>
    implements $OpenSaleCopyWith<$Res> {
  _$OpenSaleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OpenSale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serial = freezed,
    Object? customer = null,
    Object? customerName = freezed,
    Object? total = null,
    Object? balance = null,
    Object? status = null,
    Object? date = null,
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
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as String,
            balance: null == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SaleStatus,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OpenSaleImplCopyWith<$Res>
    implements $OpenSaleCopyWith<$Res> {
  factory _$$OpenSaleImplCopyWith(
    _$OpenSaleImpl value,
    $Res Function(_$OpenSaleImpl) then,
  ) = __$$OpenSaleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int? serial,
    int customer,
    String? customerName,
    String total,
    String balance,
    SaleStatus status,
    DateTime date,
  });
}

/// @nodoc
class __$$OpenSaleImplCopyWithImpl<$Res>
    extends _$OpenSaleCopyWithImpl<$Res, _$OpenSaleImpl>
    implements _$$OpenSaleImplCopyWith<$Res> {
  __$$OpenSaleImplCopyWithImpl(
    _$OpenSaleImpl _value,
    $Res Function(_$OpenSaleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OpenSale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serial = freezed,
    Object? customer = null,
    Object? customerName = freezed,
    Object? total = null,
    Object? balance = null,
    Object? status = null,
    Object? date = null,
  }) {
    return _then(
      _$OpenSaleImpl(
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
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as String,
        balance: null == balance
            ? _value.balance
            : balance // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SaleStatus,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$OpenSaleImpl implements _OpenSale {
  const _$OpenSaleImpl({
    required this.id,
    this.serial,
    required this.customer,
    this.customerName,
    required this.total,
    required this.balance,
    required this.status,
    required this.date,
  });

  @override
  final int id;
  @override
  final int? serial;

  /// Who the sale is for. Carried because [customerName] is **not** the
  /// customer's name: mbe's data dictionary calls that column "Override
  /// customer name on docs", and mbe-api sets it only from what a client
  /// sends — so it is null on every ordinary sale, walk-in ones included.
  /// The name a list shows has to be resolved from this id, exactly as
  /// `CustomerBar` already does on the sale itself (FR-023).
  @override
  final int customer;

  /// The per-document name override, or `null` — see [customer].
  @override
  final String? customerName;
  @override
  final String total;
  @override
  final String balance;
  @override
  final SaleStatus status;
  @override
  final DateTime date;

  @override
  String toString() {
    return 'OpenSale(id: $id, serial: $serial, customer: $customer, customerName: $customerName, total: $total, balance: $balance, status: $status, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OpenSaleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serial, serial) || other.serial == serial) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.date, date) || other.date == date));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    serial,
    customer,
    customerName,
    total,
    balance,
    status,
    date,
  );

  /// Create a copy of OpenSale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OpenSaleImplCopyWith<_$OpenSaleImpl> get copyWith =>
      __$$OpenSaleImplCopyWithImpl<_$OpenSaleImpl>(this, _$identity);
}

abstract class _OpenSale implements OpenSale {
  const factory _OpenSale({
    required final int id,
    final int? serial,
    required final int customer,
    final String? customerName,
    required final String total,
    required final String balance,
    required final SaleStatus status,
    required final DateTime date,
  }) = _$OpenSaleImpl;

  @override
  int get id;
  @override
  int? get serial;

  /// Who the sale is for. Carried because [customerName] is **not** the
  /// customer's name: mbe's data dictionary calls that column "Override
  /// customer name on docs", and mbe-api sets it only from what a client
  /// sends — so it is null on every ordinary sale, walk-in ones included.
  /// The name a list shows has to be resolved from this id, exactly as
  /// `CustomerBar` already does on the sale itself (FR-023).
  @override
  int get customer;

  /// The per-document name override, or `null` — see [customer].
  @override
  String? get customerName;
  @override
  String get total;
  @override
  String get balance;
  @override
  SaleStatus get status;
  @override
  DateTime get date;

  /// Create a copy of OpenSale
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OpenSaleImplCopyWith<_$OpenSaleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
