// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'denomination_count.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DenominationCount {
  String get denomination => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;

  /// Create a copy of DenominationCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DenominationCountCopyWith<DenominationCount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DenominationCountCopyWith<$Res> {
  factory $DenominationCountCopyWith(
    DenominationCount value,
    $Res Function(DenominationCount) then,
  ) = _$DenominationCountCopyWithImpl<$Res, DenominationCount>;
  @useResult
  $Res call({String denomination, int quantity});
}

/// @nodoc
class _$DenominationCountCopyWithImpl<$Res, $Val extends DenominationCount>
    implements $DenominationCountCopyWith<$Res> {
  _$DenominationCountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DenominationCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? denomination = null, Object? quantity = null}) {
    return _then(
      _value.copyWith(
            denomination: null == denomination
                ? _value.denomination
                : denomination // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DenominationCountImplCopyWith<$Res>
    implements $DenominationCountCopyWith<$Res> {
  factory _$$DenominationCountImplCopyWith(
    _$DenominationCountImpl value,
    $Res Function(_$DenominationCountImpl) then,
  ) = __$$DenominationCountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String denomination, int quantity});
}

/// @nodoc
class __$$DenominationCountImplCopyWithImpl<$Res>
    extends _$DenominationCountCopyWithImpl<$Res, _$DenominationCountImpl>
    implements _$$DenominationCountImplCopyWith<$Res> {
  __$$DenominationCountImplCopyWithImpl(
    _$DenominationCountImpl _value,
    $Res Function(_$DenominationCountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DenominationCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? denomination = null, Object? quantity = null}) {
    return _then(
      _$DenominationCountImpl(
        denomination: null == denomination
            ? _value.denomination
            : denomination // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$DenominationCountImpl implements _DenominationCount {
  const _$DenominationCountImpl({
    required this.denomination,
    required this.quantity,
  });

  @override
  final String denomination;
  @override
  final int quantity;

  @override
  String toString() {
    return 'DenominationCount(denomination: $denomination, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DenominationCountImpl &&
            (identical(other.denomination, denomination) ||
                other.denomination == denomination) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @override
  int get hashCode => Object.hash(runtimeType, denomination, quantity);

  /// Create a copy of DenominationCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DenominationCountImplCopyWith<_$DenominationCountImpl> get copyWith =>
      __$$DenominationCountImplCopyWithImpl<_$DenominationCountImpl>(
        this,
        _$identity,
      );
}

abstract class _DenominationCount implements DenominationCount {
  const factory _DenominationCount({
    required final String denomination,
    required final int quantity,
  }) = _$DenominationCountImpl;

  @override
  String get denomination;
  @override
  int get quantity;

  /// Create a copy of DenominationCount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DenominationCountImplCopyWith<_$DenominationCountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
