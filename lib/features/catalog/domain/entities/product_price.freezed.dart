// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_price.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductPrice {
  int get productPriceId => throw _privateConstructorUsedError;
  int get priceList => throw _privateConstructorUsedError;
  String get price => throw _privateConstructorUsedError;
  String get lowProfit => throw _privateConstructorUsedError;
  String get highProfit => throw _privateConstructorUsedError;

  /// Create a copy of ProductPrice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductPriceCopyWith<ProductPrice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductPriceCopyWith<$Res> {
  factory $ProductPriceCopyWith(
    ProductPrice value,
    $Res Function(ProductPrice) then,
  ) = _$ProductPriceCopyWithImpl<$Res, ProductPrice>;
  @useResult
  $Res call({
    int productPriceId,
    int priceList,
    String price,
    String lowProfit,
    String highProfit,
  });
}

/// @nodoc
class _$ProductPriceCopyWithImpl<$Res, $Val extends ProductPrice>
    implements $ProductPriceCopyWith<$Res> {
  _$ProductPriceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductPrice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productPriceId = null,
    Object? priceList = null,
    Object? price = null,
    Object? lowProfit = null,
    Object? highProfit = null,
  }) {
    return _then(
      _value.copyWith(
            productPriceId: null == productPriceId
                ? _value.productPriceId
                : productPriceId // ignore: cast_nullable_to_non_nullable
                      as int,
            priceList: null == priceList
                ? _value.priceList
                : priceList // ignore: cast_nullable_to_non_nullable
                      as int,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as String,
            lowProfit: null == lowProfit
                ? _value.lowProfit
                : lowProfit // ignore: cast_nullable_to_non_nullable
                      as String,
            highProfit: null == highProfit
                ? _value.highProfit
                : highProfit // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductPriceImplCopyWith<$Res>
    implements $ProductPriceCopyWith<$Res> {
  factory _$$ProductPriceImplCopyWith(
    _$ProductPriceImpl value,
    $Res Function(_$ProductPriceImpl) then,
  ) = __$$ProductPriceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int productPriceId,
    int priceList,
    String price,
    String lowProfit,
    String highProfit,
  });
}

/// @nodoc
class __$$ProductPriceImplCopyWithImpl<$Res>
    extends _$ProductPriceCopyWithImpl<$Res, _$ProductPriceImpl>
    implements _$$ProductPriceImplCopyWith<$Res> {
  __$$ProductPriceImplCopyWithImpl(
    _$ProductPriceImpl _value,
    $Res Function(_$ProductPriceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductPrice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productPriceId = null,
    Object? priceList = null,
    Object? price = null,
    Object? lowProfit = null,
    Object? highProfit = null,
  }) {
    return _then(
      _$ProductPriceImpl(
        productPriceId: null == productPriceId
            ? _value.productPriceId
            : productPriceId // ignore: cast_nullable_to_non_nullable
                  as int,
        priceList: null == priceList
            ? _value.priceList
            : priceList // ignore: cast_nullable_to_non_nullable
                  as int,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as String,
        lowProfit: null == lowProfit
            ? _value.lowProfit
            : lowProfit // ignore: cast_nullable_to_non_nullable
                  as String,
        highProfit: null == highProfit
            ? _value.highProfit
            : highProfit // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ProductPriceImpl implements _ProductPrice {
  const _$ProductPriceImpl({
    required this.productPriceId,
    required this.priceList,
    required this.price,
    required this.lowProfit,
    required this.highProfit,
  });

  @override
  final int productPriceId;
  @override
  final int priceList;
  @override
  final String price;
  @override
  final String lowProfit;
  @override
  final String highProfit;

  @override
  String toString() {
    return 'ProductPrice(productPriceId: $productPriceId, priceList: $priceList, price: $price, lowProfit: $lowProfit, highProfit: $highProfit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductPriceImpl &&
            (identical(other.productPriceId, productPriceId) ||
                other.productPriceId == productPriceId) &&
            (identical(other.priceList, priceList) ||
                other.priceList == priceList) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.lowProfit, lowProfit) ||
                other.lowProfit == lowProfit) &&
            (identical(other.highProfit, highProfit) ||
                other.highProfit == highProfit));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    productPriceId,
    priceList,
    price,
    lowProfit,
    highProfit,
  );

  /// Create a copy of ProductPrice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductPriceImplCopyWith<_$ProductPriceImpl> get copyWith =>
      __$$ProductPriceImplCopyWithImpl<_$ProductPriceImpl>(this, _$identity);
}

abstract class _ProductPrice implements ProductPrice {
  const factory _ProductPrice({
    required final int productPriceId,
    required final int priceList,
    required final String price,
    required final String lowProfit,
    required final String highProfit,
  }) = _$ProductPriceImpl;

  @override
  int get productPriceId;
  @override
  int get priceList;
  @override
  String get price;
  @override
  String get lowProfit;
  @override
  String get highProfit;

  /// Create a copy of ProductPrice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductPriceImplCopyWith<_$ProductPriceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
