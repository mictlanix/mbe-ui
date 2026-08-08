// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SalePayment {
  int get id => throw _privateConstructorUsedError;
  int get customerPayment => throw _privateConstructorUsedError;
  String get amount => throw _privateConstructorUsedError;
  PaymentMethod? get method => throw _privateConstructorUsedError;
  int get methodCode => throw _privateConstructorUsedError;
  Currency get currency => throw _privateConstructorUsedError;
  String? get reference => throw _privateConstructorUsedError;
  int? get verifier => throw _privateConstructorUsedError;
  String get changeAmount => throw _privateConstructorUsedError;
  bool get cancelled => throw _privateConstructorUsedError;
  DateTime get paymentDate => throw _privateConstructorUsedError;
  DateTime? get date => throw _privateConstructorUsedError;

  /// Create a copy of SalePayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalePaymentCopyWith<SalePayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalePaymentCopyWith<$Res> {
  factory $SalePaymentCopyWith(
    SalePayment value,
    $Res Function(SalePayment) then,
  ) = _$SalePaymentCopyWithImpl<$Res, SalePayment>;
  @useResult
  $Res call({
    int id,
    int customerPayment,
    String amount,
    PaymentMethod? method,
    int methodCode,
    Currency currency,
    String? reference,
    int? verifier,
    String changeAmount,
    bool cancelled,
    DateTime paymentDate,
    DateTime? date,
  });
}

/// @nodoc
class _$SalePaymentCopyWithImpl<$Res, $Val extends SalePayment>
    implements $SalePaymentCopyWith<$Res> {
  _$SalePaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalePayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerPayment = null,
    Object? amount = null,
    Object? method = freezed,
    Object? methodCode = null,
    Object? currency = null,
    Object? reference = freezed,
    Object? verifier = freezed,
    Object? changeAmount = null,
    Object? cancelled = null,
    Object? paymentDate = null,
    Object? date = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            customerPayment: null == customerPayment
                ? _value.customerPayment
                : customerPayment // ignore: cast_nullable_to_non_nullable
                      as int,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as String,
            method: freezed == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as PaymentMethod?,
            methodCode: null == methodCode
                ? _value.methodCode
                : methodCode // ignore: cast_nullable_to_non_nullable
                      as int,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as Currency,
            reference: freezed == reference
                ? _value.reference
                : reference // ignore: cast_nullable_to_non_nullable
                      as String?,
            verifier: freezed == verifier
                ? _value.verifier
                : verifier // ignore: cast_nullable_to_non_nullable
                      as int?,
            changeAmount: null == changeAmount
                ? _value.changeAmount
                : changeAmount // ignore: cast_nullable_to_non_nullable
                      as String,
            cancelled: null == cancelled
                ? _value.cancelled
                : cancelled // ignore: cast_nullable_to_non_nullable
                      as bool,
            paymentDate: null == paymentDate
                ? _value.paymentDate
                : paymentDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            date: freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalePaymentImplCopyWith<$Res>
    implements $SalePaymentCopyWith<$Res> {
  factory _$$SalePaymentImplCopyWith(
    _$SalePaymentImpl value,
    $Res Function(_$SalePaymentImpl) then,
  ) = __$$SalePaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int customerPayment,
    String amount,
    PaymentMethod? method,
    int methodCode,
    Currency currency,
    String? reference,
    int? verifier,
    String changeAmount,
    bool cancelled,
    DateTime paymentDate,
    DateTime? date,
  });
}

/// @nodoc
class __$$SalePaymentImplCopyWithImpl<$Res>
    extends _$SalePaymentCopyWithImpl<$Res, _$SalePaymentImpl>
    implements _$$SalePaymentImplCopyWith<$Res> {
  __$$SalePaymentImplCopyWithImpl(
    _$SalePaymentImpl _value,
    $Res Function(_$SalePaymentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalePayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerPayment = null,
    Object? amount = null,
    Object? method = freezed,
    Object? methodCode = null,
    Object? currency = null,
    Object? reference = freezed,
    Object? verifier = freezed,
    Object? changeAmount = null,
    Object? cancelled = null,
    Object? paymentDate = null,
    Object? date = freezed,
  }) {
    return _then(
      _$SalePaymentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        customerPayment: null == customerPayment
            ? _value.customerPayment
            : customerPayment // ignore: cast_nullable_to_non_nullable
                  as int,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as String,
        method: freezed == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as PaymentMethod?,
        methodCode: null == methodCode
            ? _value.methodCode
            : methodCode // ignore: cast_nullable_to_non_nullable
                  as int,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as Currency,
        reference: freezed == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as String?,
        verifier: freezed == verifier
            ? _value.verifier
            : verifier // ignore: cast_nullable_to_non_nullable
                  as int?,
        changeAmount: null == changeAmount
            ? _value.changeAmount
            : changeAmount // ignore: cast_nullable_to_non_nullable
                  as String,
        cancelled: null == cancelled
            ? _value.cancelled
            : cancelled // ignore: cast_nullable_to_non_nullable
                  as bool,
        paymentDate: null == paymentDate
            ? _value.paymentDate
            : paymentDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        date: freezed == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$SalePaymentImpl extends _SalePayment {
  const _$SalePaymentImpl({
    required this.id,
    required this.customerPayment,
    required this.amount,
    this.method,
    required this.methodCode,
    required this.currency,
    this.reference,
    this.verifier,
    required this.changeAmount,
    required this.cancelled,
    required this.paymentDate,
    this.date,
  }) : super._();

  @override
  final int id;
  @override
  final int customerPayment;
  @override
  final String amount;
  @override
  final PaymentMethod? method;
  @override
  final int methodCode;
  @override
  final Currency currency;
  @override
  final String? reference;
  @override
  final int? verifier;
  @override
  final String changeAmount;
  @override
  final bool cancelled;
  @override
  final DateTime paymentDate;
  @override
  final DateTime? date;

  @override
  String toString() {
    return 'SalePayment(id: $id, customerPayment: $customerPayment, amount: $amount, method: $method, methodCode: $methodCode, currency: $currency, reference: $reference, verifier: $verifier, changeAmount: $changeAmount, cancelled: $cancelled, paymentDate: $paymentDate, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalePaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerPayment, customerPayment) ||
                other.customerPayment == customerPayment) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.methodCode, methodCode) ||
                other.methodCode == methodCode) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.verifier, verifier) ||
                other.verifier == verifier) &&
            (identical(other.changeAmount, changeAmount) ||
                other.changeAmount == changeAmount) &&
            (identical(other.cancelled, cancelled) ||
                other.cancelled == cancelled) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.date, date) || other.date == date));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    customerPayment,
    amount,
    method,
    methodCode,
    currency,
    reference,
    verifier,
    changeAmount,
    cancelled,
    paymentDate,
    date,
  );

  /// Create a copy of SalePayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalePaymentImplCopyWith<_$SalePaymentImpl> get copyWith =>
      __$$SalePaymentImplCopyWithImpl<_$SalePaymentImpl>(this, _$identity);
}

abstract class _SalePayment extends SalePayment {
  const factory _SalePayment({
    required final int id,
    required final int customerPayment,
    required final String amount,
    final PaymentMethod? method,
    required final int methodCode,
    required final Currency currency,
    final String? reference,
    final int? verifier,
    required final String changeAmount,
    required final bool cancelled,
    required final DateTime paymentDate,
    final DateTime? date,
  }) = _$SalePaymentImpl;
  const _SalePayment._() : super._();

  @override
  int get id;
  @override
  int get customerPayment;
  @override
  String get amount;
  @override
  PaymentMethod? get method;
  @override
  int get methodCode;
  @override
  Currency get currency;
  @override
  String? get reference;
  @override
  int? get verifier;
  @override
  String get changeAmount;
  @override
  bool get cancelled;
  @override
  DateTime get paymentDate;
  @override
  DateTime? get date;

  /// Create a copy of SalePayment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalePaymentImplCopyWith<_$SalePaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
