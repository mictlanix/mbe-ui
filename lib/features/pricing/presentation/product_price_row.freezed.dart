// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_price_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductPriceRow {

 PriceList get priceList; ProductPrice? get price;
/// Create a copy of ProductPriceRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductPriceRowCopyWith<ProductPriceRow> get copyWith => _$ProductPriceRowCopyWithImpl<ProductPriceRow>(this as ProductPriceRow, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductPriceRow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductPriceRow&&(identical(other.priceList, _this.priceList) || other.priceList == _this.priceList)&&(identical(other.price, _this.price) || other.price == _this.price));
}


@override
int get hashCode {
  final _this = this as ProductPriceRow;
  return Object.hash(runtimeType,_this.priceList,_this.price);
}

@override
String toString() {
  final _this = this as ProductPriceRow;
  return 'ProductPriceRow(priceList: ${_this.priceList}, price: ${_this.price})';
}


}

/// @nodoc
abstract mixin class $ProductPriceRowCopyWith<$Res>  {
  factory $ProductPriceRowCopyWith(ProductPriceRow value, $Res Function(ProductPriceRow) _then) = _$ProductPriceRowCopyWithImpl;
@useResult
$Res call({
 PriceList priceList, ProductPrice? price
});


$PriceListCopyWith<$Res> get priceList;$ProductPriceCopyWith<$Res>? get price;

}
/// @nodoc
class _$ProductPriceRowCopyWithImpl<$Res>
    implements $ProductPriceRowCopyWith<$Res> {
  _$ProductPriceRowCopyWithImpl(this._self, this._then);

  final ProductPriceRow _self;
  final $Res Function(ProductPriceRow) _then;

/// Create a copy of ProductPriceRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? priceList = null,Object? price = freezed,}) {
  return _then(ProductPriceRow(
priceList: null == priceList ? _self.priceList : priceList // ignore: cast_nullable_to_non_nullable
as PriceList,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as ProductPrice?,
  ));
}
/// Create a copy of ProductPriceRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceListCopyWith<$Res> get priceList {
  
  return $PriceListCopyWith<$Res>(_self.priceList, (value) {
    return _then(_self.copyWith(priceList: value));
  });
}/// Create a copy of ProductPriceRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductPriceCopyWith<$Res>? get price {
    if (_self.price == null) {
    return null;
  }

  return $ProductPriceCopyWith<$Res>(_self.price!, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProductPriceRow].
extension ProductPriceRowPatterns on ProductPriceRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductPriceRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductPriceRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductPriceRow value)  $default,){
final _that = this;
switch (_that) {
case _ProductPriceRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductPriceRow value)?  $default,){
final _that = this;
switch (_that) {
case _ProductPriceRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PriceList priceList,  ProductPrice? price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductPriceRow() when $default != null:
return $default(_that.priceList,_that.price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PriceList priceList,  ProductPrice? price)  $default,) {final _that = this;
switch (_that) {
case _ProductPriceRow():
return $default(_that.priceList,_that.price);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PriceList priceList,  ProductPrice? price)?  $default,) {final _that = this;
switch (_that) {
case _ProductPriceRow() when $default != null:
return $default(_that.priceList,_that.price);case _:
  return null;

}
}

}

/// @nodoc


class _ProductPriceRow implements ProductPriceRow {
  const _ProductPriceRow({required this.priceList, this.price});
  

@override final  PriceList priceList;
@override final  ProductPrice? price;

/// Create a copy of ProductPriceRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductPriceRowCopyWith<_ProductPriceRow> get copyWith => __$ProductPriceRowCopyWithImpl<_ProductPriceRow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductPriceRow&&(identical(other.priceList, priceList) || other.priceList == priceList)&&(identical(other.price, price) || other.price == price));
}


@override
int get hashCode {
    return Object.hash(runtimeType,priceList,price);
}

@override
String toString() {
    return 'ProductPriceRow(priceList: $priceList, price: $price)';
}


}

/// @nodoc
abstract mixin class _$ProductPriceRowCopyWith<$Res> implements $ProductPriceRowCopyWith<$Res> {
  factory _$ProductPriceRowCopyWith(_ProductPriceRow value, $Res Function(_ProductPriceRow) _then) = __$ProductPriceRowCopyWithImpl;
@override @useResult
$Res call({
 PriceList priceList, ProductPrice? price
});


@override $PriceListCopyWith<$Res> get priceList;@override $ProductPriceCopyWith<$Res>? get price;

}
/// @nodoc
class __$ProductPriceRowCopyWithImpl<$Res>
    implements _$ProductPriceRowCopyWith<$Res> {
  __$ProductPriceRowCopyWithImpl(this._self, this._then);

  final _ProductPriceRow _self;
  final $Res Function(_ProductPriceRow) _then;

/// Create a copy of ProductPriceRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? priceList = null,Object? price = freezed,}) {
  return _then(_ProductPriceRow(
priceList: null == priceList ? _self.priceList : priceList // ignore: cast_nullable_to_non_nullable
as PriceList,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as ProductPrice?,
  ));
}

/// Create a copy of ProductPriceRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceListCopyWith<$Res> get priceList {
  
  return $PriceListCopyWith<$Res>(_self.priceList, (value) {
    return _then(_self.copyWith(priceList: value));
  });
}/// Create a copy of ProductPriceRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductPriceCopyWith<$Res>? get price {
    if (_self.price == null) {
    return null;
  }

  return $ProductPriceCopyWith<$Res>(_self.price!, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}

// dart format on
