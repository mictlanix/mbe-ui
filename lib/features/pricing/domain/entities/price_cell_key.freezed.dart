// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_cell_key.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PriceCellKey {
  int get productId => throw _privateConstructorUsedError;
  int get priceListId => throw _privateConstructorUsedError;

  /// Create a copy of PriceCellKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceCellKeyCopyWith<PriceCellKey> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceCellKeyCopyWith<$Res> {
  factory $PriceCellKeyCopyWith(
    PriceCellKey value,
    $Res Function(PriceCellKey) then,
  ) = _$PriceCellKeyCopyWithImpl<$Res, PriceCellKey>;
  @useResult
  $Res call({int productId, int priceListId});
}

/// @nodoc
class _$PriceCellKeyCopyWithImpl<$Res, $Val extends PriceCellKey>
    implements $PriceCellKeyCopyWith<$Res> {
  _$PriceCellKeyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceCellKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? productId = null, Object? priceListId = null}) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as int,
            priceListId: null == priceListId
                ? _value.priceListId
                : priceListId // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PriceCellKeyImplCopyWith<$Res>
    implements $PriceCellKeyCopyWith<$Res> {
  factory _$$PriceCellKeyImplCopyWith(
    _$PriceCellKeyImpl value,
    $Res Function(_$PriceCellKeyImpl) then,
  ) = __$$PriceCellKeyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int productId, int priceListId});
}

/// @nodoc
class __$$PriceCellKeyImplCopyWithImpl<$Res>
    extends _$PriceCellKeyCopyWithImpl<$Res, _$PriceCellKeyImpl>
    implements _$$PriceCellKeyImplCopyWith<$Res> {
  __$$PriceCellKeyImplCopyWithImpl(
    _$PriceCellKeyImpl _value,
    $Res Function(_$PriceCellKeyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PriceCellKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? productId = null, Object? priceListId = null}) {
    return _then(
      _$PriceCellKeyImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as int,
        priceListId: null == priceListId
            ? _value.priceListId
            : priceListId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$PriceCellKeyImpl implements _PriceCellKey {
  const _$PriceCellKeyImpl({
    required this.productId,
    required this.priceListId,
  });

  @override
  final int productId;
  @override
  final int priceListId;

  @override
  String toString() {
    return 'PriceCellKey(productId: $productId, priceListId: $priceListId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceCellKeyImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.priceListId, priceListId) ||
                other.priceListId == priceListId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, productId, priceListId);

  /// Create a copy of PriceCellKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceCellKeyImplCopyWith<_$PriceCellKeyImpl> get copyWith =>
      __$$PriceCellKeyImplCopyWithImpl<_$PriceCellKeyImpl>(this, _$identity);
}

abstract class _PriceCellKey implements PriceCellKey {
  const factory _PriceCellKey({
    required final int productId,
    required final int priceListId,
  }) = _$PriceCellKeyImpl;

  @override
  int get productId;
  @override
  int get priceListId;

  /// Create a copy of PriceCellKey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceCellKeyImplCopyWith<_$PriceCellKeyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
