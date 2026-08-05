// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CashSession {
  int get cashSessionId => throw _privateConstructorUsedError;
  int get cashDrawerId => throw _privateConstructorUsedError;
  String get cashDrawerName => throw _privateConstructorUsedError;
  String get cashDrawerCode => throw _privateConstructorUsedError;
  int get cashierId => throw _privateConstructorUsedError;
  String get cashierName => throw _privateConstructorUsedError;
  DateTime get start => throw _privateConstructorUsedError;
  DateTime? get end => throw _privateConstructorUsedError;
  int? get cashSupervisorId => throw _privateConstructorUsedError;
  String? get cashSupervisorName => throw _privateConstructorUsedError;
  String get openingAmount => throw _privateConstructorUsedError;
  List<PaymentMethodTotal> get paymentsByMethod =>
      throw _privateConstructorUsedError;

  /// Create a copy of CashSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CashSessionCopyWith<CashSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashSessionCopyWith<$Res> {
  factory $CashSessionCopyWith(
    CashSession value,
    $Res Function(CashSession) then,
  ) = _$CashSessionCopyWithImpl<$Res, CashSession>;
  @useResult
  $Res call({
    int cashSessionId,
    int cashDrawerId,
    String cashDrawerName,
    String cashDrawerCode,
    int cashierId,
    String cashierName,
    DateTime start,
    DateTime? end,
    int? cashSupervisorId,
    String? cashSupervisorName,
    String openingAmount,
    List<PaymentMethodTotal> paymentsByMethod,
  });
}

/// @nodoc
class _$CashSessionCopyWithImpl<$Res, $Val extends CashSession>
    implements $CashSessionCopyWith<$Res> {
  _$CashSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CashSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cashSessionId = null,
    Object? cashDrawerId = null,
    Object? cashDrawerName = null,
    Object? cashDrawerCode = null,
    Object? cashierId = null,
    Object? cashierName = null,
    Object? start = null,
    Object? end = freezed,
    Object? cashSupervisorId = freezed,
    Object? cashSupervisorName = freezed,
    Object? openingAmount = null,
    Object? paymentsByMethod = null,
  }) {
    return _then(
      _value.copyWith(
            cashSessionId: null == cashSessionId
                ? _value.cashSessionId
                : cashSessionId // ignore: cast_nullable_to_non_nullable
                      as int,
            cashDrawerId: null == cashDrawerId
                ? _value.cashDrawerId
                : cashDrawerId // ignore: cast_nullable_to_non_nullable
                      as int,
            cashDrawerName: null == cashDrawerName
                ? _value.cashDrawerName
                : cashDrawerName // ignore: cast_nullable_to_non_nullable
                      as String,
            cashDrawerCode: null == cashDrawerCode
                ? _value.cashDrawerCode
                : cashDrawerCode // ignore: cast_nullable_to_non_nullable
                      as String,
            cashierId: null == cashierId
                ? _value.cashierId
                : cashierId // ignore: cast_nullable_to_non_nullable
                      as int,
            cashierName: null == cashierName
                ? _value.cashierName
                : cashierName // ignore: cast_nullable_to_non_nullable
                      as String,
            start: null == start
                ? _value.start
                : start // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            end: freezed == end
                ? _value.end
                : end // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            cashSupervisorId: freezed == cashSupervisorId
                ? _value.cashSupervisorId
                : cashSupervisorId // ignore: cast_nullable_to_non_nullable
                      as int?,
            cashSupervisorName: freezed == cashSupervisorName
                ? _value.cashSupervisorName
                : cashSupervisorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            openingAmount: null == openingAmount
                ? _value.openingAmount
                : openingAmount // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentsByMethod: null == paymentsByMethod
                ? _value.paymentsByMethod
                : paymentsByMethod // ignore: cast_nullable_to_non_nullable
                      as List<PaymentMethodTotal>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CashSessionImplCopyWith<$Res>
    implements $CashSessionCopyWith<$Res> {
  factory _$$CashSessionImplCopyWith(
    _$CashSessionImpl value,
    $Res Function(_$CashSessionImpl) then,
  ) = __$$CashSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int cashSessionId,
    int cashDrawerId,
    String cashDrawerName,
    String cashDrawerCode,
    int cashierId,
    String cashierName,
    DateTime start,
    DateTime? end,
    int? cashSupervisorId,
    String? cashSupervisorName,
    String openingAmount,
    List<PaymentMethodTotal> paymentsByMethod,
  });
}

/// @nodoc
class __$$CashSessionImplCopyWithImpl<$Res>
    extends _$CashSessionCopyWithImpl<$Res, _$CashSessionImpl>
    implements _$$CashSessionImplCopyWith<$Res> {
  __$$CashSessionImplCopyWithImpl(
    _$CashSessionImpl _value,
    $Res Function(_$CashSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CashSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cashSessionId = null,
    Object? cashDrawerId = null,
    Object? cashDrawerName = null,
    Object? cashDrawerCode = null,
    Object? cashierId = null,
    Object? cashierName = null,
    Object? start = null,
    Object? end = freezed,
    Object? cashSupervisorId = freezed,
    Object? cashSupervisorName = freezed,
    Object? openingAmount = null,
    Object? paymentsByMethod = null,
  }) {
    return _then(
      _$CashSessionImpl(
        cashSessionId: null == cashSessionId
            ? _value.cashSessionId
            : cashSessionId // ignore: cast_nullable_to_non_nullable
                  as int,
        cashDrawerId: null == cashDrawerId
            ? _value.cashDrawerId
            : cashDrawerId // ignore: cast_nullable_to_non_nullable
                  as int,
        cashDrawerName: null == cashDrawerName
            ? _value.cashDrawerName
            : cashDrawerName // ignore: cast_nullable_to_non_nullable
                  as String,
        cashDrawerCode: null == cashDrawerCode
            ? _value.cashDrawerCode
            : cashDrawerCode // ignore: cast_nullable_to_non_nullable
                  as String,
        cashierId: null == cashierId
            ? _value.cashierId
            : cashierId // ignore: cast_nullable_to_non_nullable
                  as int,
        cashierName: null == cashierName
            ? _value.cashierName
            : cashierName // ignore: cast_nullable_to_non_nullable
                  as String,
        start: null == start
            ? _value.start
            : start // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        end: freezed == end
            ? _value.end
            : end // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        cashSupervisorId: freezed == cashSupervisorId
            ? _value.cashSupervisorId
            : cashSupervisorId // ignore: cast_nullable_to_non_nullable
                  as int?,
        cashSupervisorName: freezed == cashSupervisorName
            ? _value.cashSupervisorName
            : cashSupervisorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        openingAmount: null == openingAmount
            ? _value.openingAmount
            : openingAmount // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentsByMethod: null == paymentsByMethod
            ? _value._paymentsByMethod
            : paymentsByMethod // ignore: cast_nullable_to_non_nullable
                  as List<PaymentMethodTotal>,
      ),
    );
  }
}

/// @nodoc

class _$CashSessionImpl implements _CashSession {
  const _$CashSessionImpl({
    required this.cashSessionId,
    required this.cashDrawerId,
    required this.cashDrawerName,
    required this.cashDrawerCode,
    required this.cashierId,
    required this.cashierName,
    required this.start,
    this.end,
    this.cashSupervisorId,
    this.cashSupervisorName,
    required this.openingAmount,
    final List<PaymentMethodTotal> paymentsByMethod =
        const <PaymentMethodTotal>[],
  }) : _paymentsByMethod = paymentsByMethod;

  @override
  final int cashSessionId;
  @override
  final int cashDrawerId;
  @override
  final String cashDrawerName;
  @override
  final String cashDrawerCode;
  @override
  final int cashierId;
  @override
  final String cashierName;
  @override
  final DateTime start;
  @override
  final DateTime? end;
  @override
  final int? cashSupervisorId;
  @override
  final String? cashSupervisorName;
  @override
  final String openingAmount;
  final List<PaymentMethodTotal> _paymentsByMethod;
  @override
  @JsonKey()
  List<PaymentMethodTotal> get paymentsByMethod {
    if (_paymentsByMethod is EqualUnmodifiableListView)
      return _paymentsByMethod;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_paymentsByMethod);
  }

  @override
  String toString() {
    return 'CashSession(cashSessionId: $cashSessionId, cashDrawerId: $cashDrawerId, cashDrawerName: $cashDrawerName, cashDrawerCode: $cashDrawerCode, cashierId: $cashierId, cashierName: $cashierName, start: $start, end: $end, cashSupervisorId: $cashSupervisorId, cashSupervisorName: $cashSupervisorName, openingAmount: $openingAmount, paymentsByMethod: $paymentsByMethod)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashSessionImpl &&
            (identical(other.cashSessionId, cashSessionId) ||
                other.cashSessionId == cashSessionId) &&
            (identical(other.cashDrawerId, cashDrawerId) ||
                other.cashDrawerId == cashDrawerId) &&
            (identical(other.cashDrawerName, cashDrawerName) ||
                other.cashDrawerName == cashDrawerName) &&
            (identical(other.cashDrawerCode, cashDrawerCode) ||
                other.cashDrawerCode == cashDrawerCode) &&
            (identical(other.cashierId, cashierId) ||
                other.cashierId == cashierId) &&
            (identical(other.cashierName, cashierName) ||
                other.cashierName == cashierName) &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.cashSupervisorId, cashSupervisorId) ||
                other.cashSupervisorId == cashSupervisorId) &&
            (identical(other.cashSupervisorName, cashSupervisorName) ||
                other.cashSupervisorName == cashSupervisorName) &&
            (identical(other.openingAmount, openingAmount) ||
                other.openingAmount == openingAmount) &&
            const DeepCollectionEquality().equals(
              other._paymentsByMethod,
              _paymentsByMethod,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    cashSessionId,
    cashDrawerId,
    cashDrawerName,
    cashDrawerCode,
    cashierId,
    cashierName,
    start,
    end,
    cashSupervisorId,
    cashSupervisorName,
    openingAmount,
    const DeepCollectionEquality().hash(_paymentsByMethod),
  );

  /// Create a copy of CashSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CashSessionImplCopyWith<_$CashSessionImpl> get copyWith =>
      __$$CashSessionImplCopyWithImpl<_$CashSessionImpl>(this, _$identity);
}

abstract class _CashSession implements CashSession {
  const factory _CashSession({
    required final int cashSessionId,
    required final int cashDrawerId,
    required final String cashDrawerName,
    required final String cashDrawerCode,
    required final int cashierId,
    required final String cashierName,
    required final DateTime start,
    final DateTime? end,
    final int? cashSupervisorId,
    final String? cashSupervisorName,
    required final String openingAmount,
    final List<PaymentMethodTotal> paymentsByMethod,
  }) = _$CashSessionImpl;

  @override
  int get cashSessionId;
  @override
  int get cashDrawerId;
  @override
  String get cashDrawerName;
  @override
  String get cashDrawerCode;
  @override
  int get cashierId;
  @override
  String get cashierName;
  @override
  DateTime get start;
  @override
  DateTime? get end;
  @override
  int? get cashSupervisorId;
  @override
  String? get cashSupervisorName;
  @override
  String get openingAmount;
  @override
  List<PaymentMethodTotal> get paymentsByMethod;

  /// Create a copy of CashSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CashSessionImplCopyWith<_$CashSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PaymentMethodTotal {
  int get method => throw _privateConstructorUsedError;
  String get total => throw _privateConstructorUsedError;

  /// Create a copy of PaymentMethodTotal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentMethodTotalCopyWith<PaymentMethodTotal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentMethodTotalCopyWith<$Res> {
  factory $PaymentMethodTotalCopyWith(
    PaymentMethodTotal value,
    $Res Function(PaymentMethodTotal) then,
  ) = _$PaymentMethodTotalCopyWithImpl<$Res, PaymentMethodTotal>;
  @useResult
  $Res call({int method, String total});
}

/// @nodoc
class _$PaymentMethodTotalCopyWithImpl<$Res, $Val extends PaymentMethodTotal>
    implements $PaymentMethodTotalCopyWith<$Res> {
  _$PaymentMethodTotalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentMethodTotal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? method = null, Object? total = null}) {
    return _then(
      _value.copyWith(
            method: null == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$PaymentMethodTotalImplCopyWith<$Res>
    implements $PaymentMethodTotalCopyWith<$Res> {
  factory _$$PaymentMethodTotalImplCopyWith(
    _$PaymentMethodTotalImpl value,
    $Res Function(_$PaymentMethodTotalImpl) then,
  ) = __$$PaymentMethodTotalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int method, String total});
}

/// @nodoc
class __$$PaymentMethodTotalImplCopyWithImpl<$Res>
    extends _$PaymentMethodTotalCopyWithImpl<$Res, _$PaymentMethodTotalImpl>
    implements _$$PaymentMethodTotalImplCopyWith<$Res> {
  __$$PaymentMethodTotalImplCopyWithImpl(
    _$PaymentMethodTotalImpl _value,
    $Res Function(_$PaymentMethodTotalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentMethodTotal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? method = null, Object? total = null}) {
    return _then(
      _$PaymentMethodTotalImpl(
        method: null == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PaymentMethodTotalImpl implements _PaymentMethodTotal {
  const _$PaymentMethodTotalImpl({required this.method, required this.total});

  @override
  final int method;
  @override
  final String total;

  @override
  String toString() {
    return 'PaymentMethodTotal(method: $method, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentMethodTotalImpl &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.total, total) || other.total == total));
  }

  @override
  int get hashCode => Object.hash(runtimeType, method, total);

  /// Create a copy of PaymentMethodTotal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentMethodTotalImplCopyWith<_$PaymentMethodTotalImpl> get copyWith =>
      __$$PaymentMethodTotalImplCopyWithImpl<_$PaymentMethodTotalImpl>(
        this,
        _$identity,
      );
}

abstract class _PaymentMethodTotal implements PaymentMethodTotal {
  const factory _PaymentMethodTotal({
    required final int method,
    required final String total,
  }) = _$PaymentMethodTotalImpl;

  @override
  int get method;
  @override
  String get total;

  /// Create a copy of PaymentMethodTotal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentMethodTotalImplCopyWith<_$PaymentMethodTotalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
