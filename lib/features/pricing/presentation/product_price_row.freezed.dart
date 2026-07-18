// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_price_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductPriceRow {
  PriceList get priceList => throw _privateConstructorUsedError;
  ProductPrice? get price => throw _privateConstructorUsedError;

  /// Create a copy of ProductPriceRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductPriceRowCopyWith<ProductPriceRow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductPriceRowCopyWith<$Res> {
  factory $ProductPriceRowCopyWith(
    ProductPriceRow value,
    $Res Function(ProductPriceRow) then,
  ) = _$ProductPriceRowCopyWithImpl<$Res, ProductPriceRow>;
  @useResult
  $Res call({PriceList priceList, ProductPrice? price});

  $PriceListCopyWith<$Res> get priceList;
  $ProductPriceCopyWith<$Res>? get price;
}

/// @nodoc
class _$ProductPriceRowCopyWithImpl<$Res, $Val extends ProductPriceRow>
    implements $ProductPriceRowCopyWith<$Res> {
  _$ProductPriceRowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductPriceRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? priceList = null, Object? price = freezed}) {
    return _then(
      _value.copyWith(
            priceList: null == priceList
                ? _value.priceList
                : priceList // ignore: cast_nullable_to_non_nullable
                      as PriceList,
            price: freezed == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as ProductPrice?,
          )
          as $Val,
    );
  }

  /// Create a copy of ProductPriceRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceListCopyWith<$Res> get priceList {
    return $PriceListCopyWith<$Res>(_value.priceList, (value) {
      return _then(_value.copyWith(priceList: value) as $Val);
    });
  }

  /// Create a copy of ProductPriceRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductPriceCopyWith<$Res>? get price {
    if (_value.price == null) {
      return null;
    }

    return $ProductPriceCopyWith<$Res>(_value.price!, (value) {
      return _then(_value.copyWith(price: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductPriceRowImplCopyWith<$Res>
    implements $ProductPriceRowCopyWith<$Res> {
  factory _$$ProductPriceRowImplCopyWith(
    _$ProductPriceRowImpl value,
    $Res Function(_$ProductPriceRowImpl) then,
  ) = __$$ProductPriceRowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PriceList priceList, ProductPrice? price});

  @override
  $PriceListCopyWith<$Res> get priceList;
  @override
  $ProductPriceCopyWith<$Res>? get price;
}

/// @nodoc
class __$$ProductPriceRowImplCopyWithImpl<$Res>
    extends _$ProductPriceRowCopyWithImpl<$Res, _$ProductPriceRowImpl>
    implements _$$ProductPriceRowImplCopyWith<$Res> {
  __$$ProductPriceRowImplCopyWithImpl(
    _$ProductPriceRowImpl _value,
    $Res Function(_$ProductPriceRowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductPriceRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? priceList = null, Object? price = freezed}) {
    return _then(
      _$ProductPriceRowImpl(
        priceList: null == priceList
            ? _value.priceList
            : priceList // ignore: cast_nullable_to_non_nullable
                  as PriceList,
        price: freezed == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as ProductPrice?,
      ),
    );
  }
}

/// @nodoc

class _$ProductPriceRowImpl implements _ProductPriceRow {
  const _$ProductPriceRowImpl({required this.priceList, this.price});

  @override
  final PriceList priceList;
  @override
  final ProductPrice? price;

  @override
  String toString() {
    return 'ProductPriceRow(priceList: $priceList, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductPriceRowImpl &&
            (identical(other.priceList, priceList) ||
                other.priceList == priceList) &&
            (identical(other.price, price) || other.price == price));
  }

  @override
  int get hashCode => Object.hash(runtimeType, priceList, price);

  /// Create a copy of ProductPriceRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductPriceRowImplCopyWith<_$ProductPriceRowImpl> get copyWith =>
      __$$ProductPriceRowImplCopyWithImpl<_$ProductPriceRowImpl>(
        this,
        _$identity,
      );
}

abstract class _ProductPriceRow implements ProductPriceRow {
  const factory _ProductPriceRow({
    required final PriceList priceList,
    final ProductPrice? price,
  }) = _$ProductPriceRowImpl;

  @override
  PriceList get priceList;
  @override
  ProductPrice? get price;

  /// Create a copy of ProductPriceRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductPriceRowImplCopyWith<_$ProductPriceRowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
