// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exchange_rate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ExchangeRate {
  int get exchangeRateId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get rate => throw _privateConstructorUsedError;
  int get rawBase => throw _privateConstructorUsedError;
  int get rawTarget => throw _privateConstructorUsedError;
  Currency? get base => throw _privateConstructorUsedError;
  Currency? get target => throw _privateConstructorUsedError;

  /// Create a copy of ExchangeRate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExchangeRateCopyWith<ExchangeRate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExchangeRateCopyWith<$Res> {
  factory $ExchangeRateCopyWith(
    ExchangeRate value,
    $Res Function(ExchangeRate) then,
  ) = _$ExchangeRateCopyWithImpl<$Res, ExchangeRate>;
  @useResult
  $Res call({
    int exchangeRateId,
    DateTime date,
    String rate,
    int rawBase,
    int rawTarget,
    Currency? base,
    Currency? target,
  });
}

/// @nodoc
class _$ExchangeRateCopyWithImpl<$Res, $Val extends ExchangeRate>
    implements $ExchangeRateCopyWith<$Res> {
  _$ExchangeRateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExchangeRate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exchangeRateId = null,
    Object? date = null,
    Object? rate = null,
    Object? rawBase = null,
    Object? rawTarget = null,
    Object? base = freezed,
    Object? target = freezed,
  }) {
    return _then(
      _value.copyWith(
            exchangeRateId: null == exchangeRateId
                ? _value.exchangeRateId
                : exchangeRateId // ignore: cast_nullable_to_non_nullable
                      as int,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            rate: null == rate
                ? _value.rate
                : rate // ignore: cast_nullable_to_non_nullable
                      as String,
            rawBase: null == rawBase
                ? _value.rawBase
                : rawBase // ignore: cast_nullable_to_non_nullable
                      as int,
            rawTarget: null == rawTarget
                ? _value.rawTarget
                : rawTarget // ignore: cast_nullable_to_non_nullable
                      as int,
            base: freezed == base
                ? _value.base
                : base // ignore: cast_nullable_to_non_nullable
                      as Currency?,
            target: freezed == target
                ? _value.target
                : target // ignore: cast_nullable_to_non_nullable
                      as Currency?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExchangeRateImplCopyWith<$Res>
    implements $ExchangeRateCopyWith<$Res> {
  factory _$$ExchangeRateImplCopyWith(
    _$ExchangeRateImpl value,
    $Res Function(_$ExchangeRateImpl) then,
  ) = __$$ExchangeRateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int exchangeRateId,
    DateTime date,
    String rate,
    int rawBase,
    int rawTarget,
    Currency? base,
    Currency? target,
  });
}

/// @nodoc
class __$$ExchangeRateImplCopyWithImpl<$Res>
    extends _$ExchangeRateCopyWithImpl<$Res, _$ExchangeRateImpl>
    implements _$$ExchangeRateImplCopyWith<$Res> {
  __$$ExchangeRateImplCopyWithImpl(
    _$ExchangeRateImpl _value,
    $Res Function(_$ExchangeRateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExchangeRate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exchangeRateId = null,
    Object? date = null,
    Object? rate = null,
    Object? rawBase = null,
    Object? rawTarget = null,
    Object? base = freezed,
    Object? target = freezed,
  }) {
    return _then(
      _$ExchangeRateImpl(
        exchangeRateId: null == exchangeRateId
            ? _value.exchangeRateId
            : exchangeRateId // ignore: cast_nullable_to_non_nullable
                  as int,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        rate: null == rate
            ? _value.rate
            : rate // ignore: cast_nullable_to_non_nullable
                  as String,
        rawBase: null == rawBase
            ? _value.rawBase
            : rawBase // ignore: cast_nullable_to_non_nullable
                  as int,
        rawTarget: null == rawTarget
            ? _value.rawTarget
            : rawTarget // ignore: cast_nullable_to_non_nullable
                  as int,
        base: freezed == base
            ? _value.base
            : base // ignore: cast_nullable_to_non_nullable
                  as Currency?,
        target: freezed == target
            ? _value.target
            : target // ignore: cast_nullable_to_non_nullable
                  as Currency?,
      ),
    );
  }
}

/// @nodoc

class _$ExchangeRateImpl implements _ExchangeRate {
  const _$ExchangeRateImpl({
    required this.exchangeRateId,
    required this.date,
    required this.rate,
    required this.rawBase,
    required this.rawTarget,
    this.base,
    this.target,
  });

  @override
  final int exchangeRateId;
  @override
  final DateTime date;
  @override
  final String rate;
  @override
  final int rawBase;
  @override
  final int rawTarget;
  @override
  final Currency? base;
  @override
  final Currency? target;

  @override
  String toString() {
    return 'ExchangeRate(exchangeRateId: $exchangeRateId, date: $date, rate: $rate, rawBase: $rawBase, rawTarget: $rawTarget, base: $base, target: $target)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExchangeRateImpl &&
            (identical(other.exchangeRateId, exchangeRateId) ||
                other.exchangeRateId == exchangeRateId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.rawBase, rawBase) || other.rawBase == rawBase) &&
            (identical(other.rawTarget, rawTarget) ||
                other.rawTarget == rawTarget) &&
            (identical(other.base, base) || other.base == base) &&
            (identical(other.target, target) || other.target == target));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    exchangeRateId,
    date,
    rate,
    rawBase,
    rawTarget,
    base,
    target,
  );

  /// Create a copy of ExchangeRate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExchangeRateImplCopyWith<_$ExchangeRateImpl> get copyWith =>
      __$$ExchangeRateImplCopyWithImpl<_$ExchangeRateImpl>(this, _$identity);
}

abstract class _ExchangeRate implements ExchangeRate {
  const factory _ExchangeRate({
    required final int exchangeRateId,
    required final DateTime date,
    required final String rate,
    required final int rawBase,
    required final int rawTarget,
    final Currency? base,
    final Currency? target,
  }) = _$ExchangeRateImpl;

  @override
  int get exchangeRateId;
  @override
  DateTime get date;
  @override
  String get rate;
  @override
  int get rawBase;
  @override
  int get rawTarget;
  @override
  Currency? get base;
  @override
  Currency? get target;

  /// Create a copy of ExchangeRate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExchangeRateImplCopyWith<_$ExchangeRateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
