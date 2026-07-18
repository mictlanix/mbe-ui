// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exchange_rates_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ExchangeRateFilter {
  DateTime? get dateFrom => throw _privateConstructorUsedError;
  DateTime? get dateTo => throw _privateConstructorUsedError;
  int? get base => throw _privateConstructorUsedError;
  int? get target => throw _privateConstructorUsedError;

  /// Create a copy of ExchangeRateFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExchangeRateFilterCopyWith<ExchangeRateFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExchangeRateFilterCopyWith<$Res> {
  factory $ExchangeRateFilterCopyWith(
    ExchangeRateFilter value,
    $Res Function(ExchangeRateFilter) then,
  ) = _$ExchangeRateFilterCopyWithImpl<$Res, ExchangeRateFilter>;
  @useResult
  $Res call({DateTime? dateFrom, DateTime? dateTo, int? base, int? target});
}

/// @nodoc
class _$ExchangeRateFilterCopyWithImpl<$Res, $Val extends ExchangeRateFilter>
    implements $ExchangeRateFilterCopyWith<$Res> {
  _$ExchangeRateFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExchangeRateFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateFrom = freezed,
    Object? dateTo = freezed,
    Object? base = freezed,
    Object? target = freezed,
  }) {
    return _then(
      _value.copyWith(
            dateFrom: freezed == dateFrom
                ? _value.dateFrom
                : dateFrom // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dateTo: freezed == dateTo
                ? _value.dateTo
                : dateTo // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            base: freezed == base
                ? _value.base
                : base // ignore: cast_nullable_to_non_nullable
                      as int?,
            target: freezed == target
                ? _value.target
                : target // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExchangeRateFilterImplCopyWith<$Res>
    implements $ExchangeRateFilterCopyWith<$Res> {
  factory _$$ExchangeRateFilterImplCopyWith(
    _$ExchangeRateFilterImpl value,
    $Res Function(_$ExchangeRateFilterImpl) then,
  ) = __$$ExchangeRateFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime? dateFrom, DateTime? dateTo, int? base, int? target});
}

/// @nodoc
class __$$ExchangeRateFilterImplCopyWithImpl<$Res>
    extends _$ExchangeRateFilterCopyWithImpl<$Res, _$ExchangeRateFilterImpl>
    implements _$$ExchangeRateFilterImplCopyWith<$Res> {
  __$$ExchangeRateFilterImplCopyWithImpl(
    _$ExchangeRateFilterImpl _value,
    $Res Function(_$ExchangeRateFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExchangeRateFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateFrom = freezed,
    Object? dateTo = freezed,
    Object? base = freezed,
    Object? target = freezed,
  }) {
    return _then(
      _$ExchangeRateFilterImpl(
        dateFrom: freezed == dateFrom
            ? _value.dateFrom
            : dateFrom // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dateTo: freezed == dateTo
            ? _value.dateTo
            : dateTo // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        base: freezed == base
            ? _value.base
            : base // ignore: cast_nullable_to_non_nullable
                  as int?,
        target: freezed == target
            ? _value.target
            : target // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$ExchangeRateFilterImpl implements _ExchangeRateFilter {
  const _$ExchangeRateFilterImpl({
    this.dateFrom,
    this.dateTo,
    this.base,
    this.target,
  });

  @override
  final DateTime? dateFrom;
  @override
  final DateTime? dateTo;
  @override
  final int? base;
  @override
  final int? target;

  @override
  String toString() {
    return 'ExchangeRateFilter(dateFrom: $dateFrom, dateTo: $dateTo, base: $base, target: $target)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExchangeRateFilterImpl &&
            (identical(other.dateFrom, dateFrom) ||
                other.dateFrom == dateFrom) &&
            (identical(other.dateTo, dateTo) || other.dateTo == dateTo) &&
            (identical(other.base, base) || other.base == base) &&
            (identical(other.target, target) || other.target == target));
  }

  @override
  int get hashCode => Object.hash(runtimeType, dateFrom, dateTo, base, target);

  /// Create a copy of ExchangeRateFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExchangeRateFilterImplCopyWith<_$ExchangeRateFilterImpl> get copyWith =>
      __$$ExchangeRateFilterImplCopyWithImpl<_$ExchangeRateFilterImpl>(
        this,
        _$identity,
      );
}

abstract class _ExchangeRateFilter implements ExchangeRateFilter {
  const factory _ExchangeRateFilter({
    final DateTime? dateFrom,
    final DateTime? dateTo,
    final int? base,
    final int? target,
  }) = _$ExchangeRateFilterImpl;

  @override
  DateTime? get dateFrom;
  @override
  DateTime? get dateTo;
  @override
  int? get base;
  @override
  int? get target;

  /// Create a copy of ExchangeRateFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExchangeRateFilterImplCopyWith<_$ExchangeRateFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
