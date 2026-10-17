// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_price.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductPrice {

 int get productPriceId; int get productId; PriceList get priceList; String get price;
/// Create a copy of ProductPrice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductPriceCopyWith<ProductPrice> get copyWith => _$ProductPriceCopyWithImpl<ProductPrice>(this as ProductPrice, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductPrice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductPrice&&(identical(other.productPriceId, _this.productPriceId) || other.productPriceId == _this.productPriceId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.priceList, _this.priceList) || other.priceList == _this.priceList)&&(identical(other.price, _this.price) || other.price == _this.price));
}


@override
int get hashCode {
  final _this = this as ProductPrice;
  return Object.hash(runtimeType,_this.productPriceId,_this.productId,_this.priceList,_this.price);
}

@override
String toString() {
  final _this = this as ProductPrice;
  return 'ProductPrice(productPriceId: ${_this.productPriceId}, productId: ${_this.productId}, priceList: ${_this.priceList}, price: ${_this.price})';
}


}

/// @nodoc
abstract mixin class $ProductPriceCopyWith<$Res>  {
  factory $ProductPriceCopyWith(ProductPrice value, $Res Function(ProductPrice) _then) = _$ProductPriceCopyWithImpl;
@useResult
$Res call({
 int productPriceId, int productId, PriceList priceList, String price
});


$PriceListCopyWith<$Res> get priceList;

}
/// @nodoc
class _$ProductPriceCopyWithImpl<$Res>
    implements $ProductPriceCopyWith<$Res> {
  _$ProductPriceCopyWithImpl(this._self, this._then);

  final ProductPrice _self;
  final $Res Function(ProductPrice) _then;

/// Create a copy of ProductPrice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productPriceId = null,Object? productId = null,Object? priceList = null,Object? price = null,}) {
  return _then(ProductPrice(
productPriceId: null == productPriceId ? _self.productPriceId : productPriceId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,priceList: null == priceList ? _self.priceList : priceList // ignore: cast_nullable_to_non_nullable
as PriceList,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of ProductPrice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceListCopyWith<$Res> get priceList {
  
  return $PriceListCopyWith<$Res>(_self.priceList, (value) {
    return _then(_self.copyWith(priceList: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProductPrice].
extension ProductPricePatterns on ProductPrice {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductPrice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductPrice() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductPrice value)  $default,){
final _that = this;
switch (_that) {
case _ProductPrice():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductPrice value)?  $default,){
final _that = this;
switch (_that) {
case _ProductPrice() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productPriceId,  int productId,  PriceList priceList,  String price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductPrice() when $default != null:
return $default(_that.productPriceId,_that.productId,_that.priceList,_that.price);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productPriceId,  int productId,  PriceList priceList,  String price)  $default,) {final _that = this;
switch (_that) {
case _ProductPrice():
return $default(_that.productPriceId,_that.productId,_that.priceList,_that.price);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productPriceId,  int productId,  PriceList priceList,  String price)?  $default,) {final _that = this;
switch (_that) {
case _ProductPrice() when $default != null:
return $default(_that.productPriceId,_that.productId,_that.priceList,_that.price);case _:
  return null;

}
}

}

/// @nodoc


class _ProductPrice implements ProductPrice {
  const _ProductPrice({required this.productPriceId, required this.productId, required this.priceList, required this.price});
  

@override final  int productPriceId;
@override final  int productId;
@override final  PriceList priceList;
@override final  String price;

/// Create a copy of ProductPrice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductPriceCopyWith<_ProductPrice> get copyWith => __$ProductPriceCopyWithImpl<_ProductPrice>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductPrice&&(identical(other.productPriceId, productPriceId) || other.productPriceId == productPriceId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.priceList, priceList) || other.priceList == priceList)&&(identical(other.price, price) || other.price == price));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productPriceId,productId,priceList,price);
}

@override
String toString() {
    return 'ProductPrice(productPriceId: $productPriceId, productId: $productId, priceList: $priceList, price: $price)';
}


}

/// @nodoc
abstract mixin class _$ProductPriceCopyWith<$Res> implements $ProductPriceCopyWith<$Res> {
  factory _$ProductPriceCopyWith(_ProductPrice value, $Res Function(_ProductPrice) _then) = __$ProductPriceCopyWithImpl;
@override @useResult
$Res call({
 int productPriceId, int productId, PriceList priceList, String price
});


@override $PriceListCopyWith<$Res> get priceList;

}
/// @nodoc
class __$ProductPriceCopyWithImpl<$Res>
    implements _$ProductPriceCopyWith<$Res> {
  __$ProductPriceCopyWithImpl(this._self, this._then);

  final _ProductPrice _self;
  final $Res Function(_ProductPrice) _then;

/// Create a copy of ProductPrice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productPriceId = null,Object? productId = null,Object? priceList = null,Object? price = null,}) {
  return _then(_ProductPrice(
productPriceId: null == productPriceId ? _self.productPriceId : productPriceId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,priceList: null == priceList ? _self.priceList : priceList // ignore: cast_nullable_to_non_nullable
as PriceList,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ProductPrice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceListCopyWith<$Res> get priceList {
  
  return $PriceListCopyWith<$Res>(_self.priceList, (value) {
    return _then(_self.copyWith(priceList: value));
  });
}
}

// dart format on
