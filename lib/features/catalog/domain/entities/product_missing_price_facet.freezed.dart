// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_missing_price_facet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductMissingPriceFacet {
  int get priceListId => throw _privateConstructorUsedError;
  int get missingCount => throw _privateConstructorUsedError;

  /// Create a copy of ProductMissingPriceFacet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductMissingPriceFacetCopyWith<ProductMissingPriceFacet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductMissingPriceFacetCopyWith<$Res> {
  factory $ProductMissingPriceFacetCopyWith(
    ProductMissingPriceFacet value,
    $Res Function(ProductMissingPriceFacet) then,
  ) = _$ProductMissingPriceFacetCopyWithImpl<$Res, ProductMissingPriceFacet>;
  @useResult
  $Res call({int priceListId, int missingCount});
}

/// @nodoc
class _$ProductMissingPriceFacetCopyWithImpl<
  $Res,
  $Val extends ProductMissingPriceFacet
>
    implements $ProductMissingPriceFacetCopyWith<$Res> {
  _$ProductMissingPriceFacetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductMissingPriceFacet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? priceListId = null, Object? missingCount = null}) {
    return _then(
      _value.copyWith(
            priceListId: null == priceListId
                ? _value.priceListId
                : priceListId // ignore: cast_nullable_to_non_nullable
                      as int,
            missingCount: null == missingCount
                ? _value.missingCount
                : missingCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductMissingPriceFacetImplCopyWith<$Res>
    implements $ProductMissingPriceFacetCopyWith<$Res> {
  factory _$$ProductMissingPriceFacetImplCopyWith(
    _$ProductMissingPriceFacetImpl value,
    $Res Function(_$ProductMissingPriceFacetImpl) then,
  ) = __$$ProductMissingPriceFacetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int priceListId, int missingCount});
}

/// @nodoc
class __$$ProductMissingPriceFacetImplCopyWithImpl<$Res>
    extends
        _$ProductMissingPriceFacetCopyWithImpl<
          $Res,
          _$ProductMissingPriceFacetImpl
        >
    implements _$$ProductMissingPriceFacetImplCopyWith<$Res> {
  __$$ProductMissingPriceFacetImplCopyWithImpl(
    _$ProductMissingPriceFacetImpl _value,
    $Res Function(_$ProductMissingPriceFacetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductMissingPriceFacet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? priceListId = null, Object? missingCount = null}) {
    return _then(
      _$ProductMissingPriceFacetImpl(
        priceListId: null == priceListId
            ? _value.priceListId
            : priceListId // ignore: cast_nullable_to_non_nullable
                  as int,
        missingCount: null == missingCount
            ? _value.missingCount
            : missingCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ProductMissingPriceFacetImpl implements _ProductMissingPriceFacet {
  const _$ProductMissingPriceFacetImpl({
    required this.priceListId,
    required this.missingCount,
  });

  @override
  final int priceListId;
  @override
  final int missingCount;

  @override
  String toString() {
    return 'ProductMissingPriceFacet(priceListId: $priceListId, missingCount: $missingCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductMissingPriceFacetImpl &&
            (identical(other.priceListId, priceListId) ||
                other.priceListId == priceListId) &&
            (identical(other.missingCount, missingCount) ||
                other.missingCount == missingCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, priceListId, missingCount);

  /// Create a copy of ProductMissingPriceFacet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductMissingPriceFacetImplCopyWith<_$ProductMissingPriceFacetImpl>
  get copyWith =>
      __$$ProductMissingPriceFacetImplCopyWithImpl<
        _$ProductMissingPriceFacetImpl
      >(this, _$identity);
}

abstract class _ProductMissingPriceFacet implements ProductMissingPriceFacet {
  const factory _ProductMissingPriceFacet({
    required final int priceListId,
    required final int missingCount,
  }) = _$ProductMissingPriceFacetImpl;

  @override
  int get priceListId;
  @override
  int get missingCount;

  /// Create a copy of ProductMissingPriceFacet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductMissingPriceFacetImplCopyWith<_$ProductMissingPriceFacetImpl>
  get copyWith => throw _privateConstructorUsedError;
}
