// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pricing_grid_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PricingGridRow {
  ProductListItem get product => throw _privateConstructorUsedError;
  Map<int, ProductPrice> get prices => throw _privateConstructorUsedError;

  /// Create a copy of PricingGridRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PricingGridRowCopyWith<PricingGridRow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PricingGridRowCopyWith<$Res> {
  factory $PricingGridRowCopyWith(
    PricingGridRow value,
    $Res Function(PricingGridRow) then,
  ) = _$PricingGridRowCopyWithImpl<$Res, PricingGridRow>;
  @useResult
  $Res call({ProductListItem product, Map<int, ProductPrice> prices});

  $ProductListItemCopyWith<$Res> get product;
}

/// @nodoc
class _$PricingGridRowCopyWithImpl<$Res, $Val extends PricingGridRow>
    implements $PricingGridRowCopyWith<$Res> {
  _$PricingGridRowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PricingGridRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? product = null, Object? prices = null}) {
    return _then(
      _value.copyWith(
            product: null == product
                ? _value.product
                : product // ignore: cast_nullable_to_non_nullable
                      as ProductListItem,
            prices: null == prices
                ? _value.prices
                : prices // ignore: cast_nullable_to_non_nullable
                      as Map<int, ProductPrice>,
          )
          as $Val,
    );
  }

  /// Create a copy of PricingGridRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductListItemCopyWith<$Res> get product {
    return $ProductListItemCopyWith<$Res>(_value.product, (value) {
      return _then(_value.copyWith(product: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PricingGridRowImplCopyWith<$Res>
    implements $PricingGridRowCopyWith<$Res> {
  factory _$$PricingGridRowImplCopyWith(
    _$PricingGridRowImpl value,
    $Res Function(_$PricingGridRowImpl) then,
  ) = __$$PricingGridRowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ProductListItem product, Map<int, ProductPrice> prices});

  @override
  $ProductListItemCopyWith<$Res> get product;
}

/// @nodoc
class __$$PricingGridRowImplCopyWithImpl<$Res>
    extends _$PricingGridRowCopyWithImpl<$Res, _$PricingGridRowImpl>
    implements _$$PricingGridRowImplCopyWith<$Res> {
  __$$PricingGridRowImplCopyWithImpl(
    _$PricingGridRowImpl _value,
    $Res Function(_$PricingGridRowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PricingGridRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? product = null, Object? prices = null}) {
    return _then(
      _$PricingGridRowImpl(
        product: null == product
            ? _value.product
            : product // ignore: cast_nullable_to_non_nullable
                  as ProductListItem,
        prices: null == prices
            ? _value._prices
            : prices // ignore: cast_nullable_to_non_nullable
                  as Map<int, ProductPrice>,
      ),
    );
  }
}

/// @nodoc

class _$PricingGridRowImpl implements _PricingGridRow {
  const _$PricingGridRowImpl({
    required this.product,
    required final Map<int, ProductPrice> prices,
  }) : _prices = prices;

  @override
  final ProductListItem product;
  final Map<int, ProductPrice> _prices;
  @override
  Map<int, ProductPrice> get prices {
    if (_prices is EqualUnmodifiableMapView) return _prices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_prices);
  }

  @override
  String toString() {
    return 'PricingGridRow(product: $product, prices: $prices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PricingGridRowImpl &&
            (identical(other.product, product) || other.product == product) &&
            const DeepCollectionEquality().equals(other._prices, _prices));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    product,
    const DeepCollectionEquality().hash(_prices),
  );

  /// Create a copy of PricingGridRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PricingGridRowImplCopyWith<_$PricingGridRowImpl> get copyWith =>
      __$$PricingGridRowImplCopyWithImpl<_$PricingGridRowImpl>(
        this,
        _$identity,
      );
}

abstract class _PricingGridRow implements PricingGridRow {
  const factory _PricingGridRow({
    required final ProductListItem product,
    required final Map<int, ProductPrice> prices,
  }) = _$PricingGridRowImpl;

  @override
  ProductListItem get product;
  @override
  Map<int, ProductPrice> get prices;

  /// Create a copy of PricingGridRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PricingGridRowImplCopyWith<_$PricingGridRowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
