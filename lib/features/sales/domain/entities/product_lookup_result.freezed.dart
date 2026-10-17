// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_lookup_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductLookupResult {

 int get product; String get code; String get name; String? get sku; String? get brand; String? get model; String? get barCode; String? get unit; String? get photo; String get price; String get taxRate; bool get taxIncluded; int get minOrderQty; bool get stockRequired; bool get stockable; List<WarehouseStock> get stock;
/// Create a copy of ProductLookupResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductLookupResultCopyWith<ProductLookupResult> get copyWith => _$ProductLookupResultCopyWithImpl<ProductLookupResult>(this as ProductLookupResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductLookupResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductLookupResult&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.sku, _this.sku) || other.sku == _this.sku)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.barCode, _this.barCode) || other.barCode == _this.barCode)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.photo, _this.photo) || other.photo == _this.photo)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.taxRate, _this.taxRate) || other.taxRate == _this.taxRate)&&(identical(other.taxIncluded, _this.taxIncluded) || other.taxIncluded == _this.taxIncluded)&&(identical(other.minOrderQty, _this.minOrderQty) || other.minOrderQty == _this.minOrderQty)&&(identical(other.stockRequired, _this.stockRequired) || other.stockRequired == _this.stockRequired)&&(identical(other.stockable, _this.stockable) || other.stockable == _this.stockable)&&const DeepCollectionEquality().equals(other.stock, _this.stock));
}


@override
int get hashCode {
  final _this = this as ProductLookupResult;
  return Object.hash(runtimeType,_this.product,_this.code,_this.name,_this.sku,_this.brand,_this.model,_this.barCode,_this.unit,_this.photo,_this.price,_this.taxRate,_this.taxIncluded,_this.minOrderQty,_this.stockRequired,_this.stockable,const DeepCollectionEquality().hash(_this.stock));
}

@override
String toString() {
  final _this = this as ProductLookupResult;
  return 'ProductLookupResult(product: ${_this.product}, code: ${_this.code}, name: ${_this.name}, sku: ${_this.sku}, brand: ${_this.brand}, model: ${_this.model}, barCode: ${_this.barCode}, unit: ${_this.unit}, photo: ${_this.photo}, price: ${_this.price}, taxRate: ${_this.taxRate}, taxIncluded: ${_this.taxIncluded}, minOrderQty: ${_this.minOrderQty}, stockRequired: ${_this.stockRequired}, stockable: ${_this.stockable}, stock: ${_this.stock})';
}


}

/// @nodoc
abstract mixin class $ProductLookupResultCopyWith<$Res>  {
  factory $ProductLookupResultCopyWith(ProductLookupResult value, $Res Function(ProductLookupResult) _then) = _$ProductLookupResultCopyWithImpl;
@useResult
$Res call({
 int product, String code, String name, String? sku, String? brand, String? model, String? barCode, String? unit, String? photo, String price, String taxRate, bool taxIncluded, int minOrderQty, bool stockRequired, bool stockable, List<WarehouseStock> stock
});




}
/// @nodoc
class _$ProductLookupResultCopyWithImpl<$Res>
    implements $ProductLookupResultCopyWith<$Res> {
  _$ProductLookupResultCopyWithImpl(this._self, this._then);

  final ProductLookupResult _self;
  final $Res Function(ProductLookupResult) _then;

/// Create a copy of ProductLookupResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? product = null,Object? code = null,Object? name = null,Object? sku = freezed,Object? brand = freezed,Object? model = freezed,Object? barCode = freezed,Object? unit = freezed,Object? photo = freezed,Object? price = null,Object? taxRate = null,Object? taxIncluded = null,Object? minOrderQty = null,Object? stockRequired = null,Object? stockable = null,Object? stock = null,}) {
  return _then(ProductLookupResult(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,barCode: freezed == barCode ? _self.barCode : barCode // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as String,taxIncluded: null == taxIncluded ? _self.taxIncluded : taxIncluded // ignore: cast_nullable_to_non_nullable
as bool,minOrderQty: null == minOrderQty ? _self.minOrderQty : minOrderQty // ignore: cast_nullable_to_non_nullable
as int,stockRequired: null == stockRequired ? _self.stockRequired : stockRequired // ignore: cast_nullable_to_non_nullable
as bool,stockable: null == stockable ? _self.stockable : stockable // ignore: cast_nullable_to_non_nullable
as bool,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as List<WarehouseStock>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductLookupResult].
extension ProductLookupResultPatterns on ProductLookupResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductLookupResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductLookupResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductLookupResult value)  $default,){
final _that = this;
switch (_that) {
case _ProductLookupResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductLookupResult value)?  $default,){
final _that = this;
switch (_that) {
case _ProductLookupResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int product,  String code,  String name,  String? sku,  String? brand,  String? model,  String? barCode,  String? unit,  String? photo,  String price,  String taxRate,  bool taxIncluded,  int minOrderQty,  bool stockRequired,  bool stockable,  List<WarehouseStock> stock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductLookupResult() when $default != null:
return $default(_that.product,_that.code,_that.name,_that.sku,_that.brand,_that.model,_that.barCode,_that.unit,_that.photo,_that.price,_that.taxRate,_that.taxIncluded,_that.minOrderQty,_that.stockRequired,_that.stockable,_that.stock);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int product,  String code,  String name,  String? sku,  String? brand,  String? model,  String? barCode,  String? unit,  String? photo,  String price,  String taxRate,  bool taxIncluded,  int minOrderQty,  bool stockRequired,  bool stockable,  List<WarehouseStock> stock)  $default,) {final _that = this;
switch (_that) {
case _ProductLookupResult():
return $default(_that.product,_that.code,_that.name,_that.sku,_that.brand,_that.model,_that.barCode,_that.unit,_that.photo,_that.price,_that.taxRate,_that.taxIncluded,_that.minOrderQty,_that.stockRequired,_that.stockable,_that.stock);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int product,  String code,  String name,  String? sku,  String? brand,  String? model,  String? barCode,  String? unit,  String? photo,  String price,  String taxRate,  bool taxIncluded,  int minOrderQty,  bool stockRequired,  bool stockable,  List<WarehouseStock> stock)?  $default,) {final _that = this;
switch (_that) {
case _ProductLookupResult() when $default != null:
return $default(_that.product,_that.code,_that.name,_that.sku,_that.brand,_that.model,_that.barCode,_that.unit,_that.photo,_that.price,_that.taxRate,_that.taxIncluded,_that.minOrderQty,_that.stockRequired,_that.stockable,_that.stock);case _:
  return null;

}
}

}

/// @nodoc


class _ProductLookupResult implements ProductLookupResult {
  const _ProductLookupResult({required this.product, required this.code, required this.name, this.sku, this.brand, this.model, this.barCode, this.unit, this.photo, required this.price, required this.taxRate, required this.taxIncluded, required this.minOrderQty, required this.stockRequired, required this.stockable,  List<WarehouseStock> stock = const <WarehouseStock>[]}): _stock = stock;
  

@override final  int product;
@override final  String code;
@override final  String name;
@override final  String? sku;
@override final  String? brand;
@override final  String? model;
@override final  String? barCode;
@override final  String? unit;
@override final  String? photo;
@override final  String price;
@override final  String taxRate;
@override final  bool taxIncluded;
@override final  int minOrderQty;
@override final  bool stockRequired;
@override final  bool stockable;
 final  List<WarehouseStock> _stock;
@override@JsonKey() List<WarehouseStock> get stock {
  if (_stock is EqualUnmodifiableListView) return _stock;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stock);
}


/// Create a copy of ProductLookupResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductLookupResultCopyWith<_ProductLookupResult> get copyWith => __$ProductLookupResultCopyWithImpl<_ProductLookupResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductLookupResult&&(identical(other.product, product) || other.product == product)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.barCode, barCode) || other.barCode == barCode)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.price, price) || other.price == price)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.taxIncluded, taxIncluded) || other.taxIncluded == taxIncluded)&&(identical(other.minOrderQty, minOrderQty) || other.minOrderQty == minOrderQty)&&(identical(other.stockRequired, stockRequired) || other.stockRequired == stockRequired)&&(identical(other.stockable, stockable) || other.stockable == stockable)&&const DeepCollectionEquality().equals(other.stock, _stock));
}


@override
int get hashCode {
    return Object.hash(runtimeType,product,code,name,sku,brand,model,barCode,unit,photo,price,taxRate,taxIncluded,minOrderQty,stockRequired,stockable,const DeepCollectionEquality().hash(_stock));
}

@override
String toString() {
    return 'ProductLookupResult(product: $product, code: $code, name: $name, sku: $sku, brand: $brand, model: $model, barCode: $barCode, unit: $unit, photo: $photo, price: $price, taxRate: $taxRate, taxIncluded: $taxIncluded, minOrderQty: $minOrderQty, stockRequired: $stockRequired, stockable: $stockable, stock: $stock)';
}


}

/// @nodoc
abstract mixin class _$ProductLookupResultCopyWith<$Res> implements $ProductLookupResultCopyWith<$Res> {
  factory _$ProductLookupResultCopyWith(_ProductLookupResult value, $Res Function(_ProductLookupResult) _then) = __$ProductLookupResultCopyWithImpl;
@override @useResult
$Res call({
 int product, String code, String name, String? sku, String? brand, String? model, String? barCode, String? unit, String? photo, String price, String taxRate, bool taxIncluded, int minOrderQty, bool stockRequired, bool stockable, List<WarehouseStock> stock
});




}
/// @nodoc
class __$ProductLookupResultCopyWithImpl<$Res>
    implements _$ProductLookupResultCopyWith<$Res> {
  __$ProductLookupResultCopyWithImpl(this._self, this._then);

  final _ProductLookupResult _self;
  final $Res Function(_ProductLookupResult) _then;

/// Create a copy of ProductLookupResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = null,Object? code = null,Object? name = null,Object? sku = freezed,Object? brand = freezed,Object? model = freezed,Object? barCode = freezed,Object? unit = freezed,Object? photo = freezed,Object? price = null,Object? taxRate = null,Object? taxIncluded = null,Object? minOrderQty = null,Object? stockRequired = null,Object? stockable = null,Object? stock = null,}) {
  return _then(_ProductLookupResult(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,barCode: freezed == barCode ? _self.barCode : barCode // ignore: cast_nullable_to_non_nullable
as String?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as String,taxIncluded: null == taxIncluded ? _self.taxIncluded : taxIncluded // ignore: cast_nullable_to_non_nullable
as bool,minOrderQty: null == minOrderQty ? _self.minOrderQty : minOrderQty // ignore: cast_nullable_to_non_nullable
as int,stockRequired: null == stockRequired ? _self.stockRequired : stockRequired // ignore: cast_nullable_to_non_nullable
as bool,stockable: null == stockable ? _self.stockable : stockable // ignore: cast_nullable_to_non_nullable
as bool,stock: null == stock ? _self._stock : stock // ignore: cast_nullable_to_non_nullable
as List<WarehouseStock>,
  ));
}


}

/// @nodoc
mixin _$WarehouseStock {

 int get warehouse; String? get warehouseName; String get onHand; String get available;
/// Create a copy of WarehouseStock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarehouseStockCopyWith<WarehouseStock> get copyWith => _$WarehouseStockCopyWithImpl<WarehouseStock>(this as WarehouseStock, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WarehouseStock;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WarehouseStock&&(identical(other.warehouse, _this.warehouse) || other.warehouse == _this.warehouse)&&(identical(other.warehouseName, _this.warehouseName) || other.warehouseName == _this.warehouseName)&&(identical(other.onHand, _this.onHand) || other.onHand == _this.onHand)&&(identical(other.available, _this.available) || other.available == _this.available));
}


@override
int get hashCode {
  final _this = this as WarehouseStock;
  return Object.hash(runtimeType,_this.warehouse,_this.warehouseName,_this.onHand,_this.available);
}

@override
String toString() {
  final _this = this as WarehouseStock;
  return 'WarehouseStock(warehouse: ${_this.warehouse}, warehouseName: ${_this.warehouseName}, onHand: ${_this.onHand}, available: ${_this.available})';
}


}

/// @nodoc
abstract mixin class $WarehouseStockCopyWith<$Res>  {
  factory $WarehouseStockCopyWith(WarehouseStock value, $Res Function(WarehouseStock) _then) = _$WarehouseStockCopyWithImpl;
@useResult
$Res call({
 int warehouse, String? warehouseName, String onHand, String available
});




}
/// @nodoc
class _$WarehouseStockCopyWithImpl<$Res>
    implements $WarehouseStockCopyWith<$Res> {
  _$WarehouseStockCopyWithImpl(this._self, this._then);

  final WarehouseStock _self;
  final $Res Function(WarehouseStock) _then;

/// Create a copy of WarehouseStock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? warehouse = null,Object? warehouseName = freezed,Object? onHand = null,Object? available = null,}) {
  return _then(WarehouseStock(
warehouse: null == warehouse ? _self.warehouse : warehouse // ignore: cast_nullable_to_non_nullable
as int,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,onHand: null == onHand ? _self.onHand : onHand // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WarehouseStock].
extension WarehouseStockPatterns on WarehouseStock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WarehouseStock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WarehouseStock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WarehouseStock value)  $default,){
final _that = this;
switch (_that) {
case _WarehouseStock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WarehouseStock value)?  $default,){
final _that = this;
switch (_that) {
case _WarehouseStock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int warehouse,  String? warehouseName,  String onHand,  String available)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WarehouseStock() when $default != null:
return $default(_that.warehouse,_that.warehouseName,_that.onHand,_that.available);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int warehouse,  String? warehouseName,  String onHand,  String available)  $default,) {final _that = this;
switch (_that) {
case _WarehouseStock():
return $default(_that.warehouse,_that.warehouseName,_that.onHand,_that.available);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int warehouse,  String? warehouseName,  String onHand,  String available)?  $default,) {final _that = this;
switch (_that) {
case _WarehouseStock() when $default != null:
return $default(_that.warehouse,_that.warehouseName,_that.onHand,_that.available);case _:
  return null;

}
}

}

/// @nodoc


class _WarehouseStock implements WarehouseStock {
  const _WarehouseStock({required this.warehouse, this.warehouseName, required this.onHand, required this.available});
  

@override final  int warehouse;
@override final  String? warehouseName;
@override final  String onHand;
@override final  String available;

/// Create a copy of WarehouseStock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WarehouseStockCopyWith<_WarehouseStock> get copyWith => __$WarehouseStockCopyWithImpl<_WarehouseStock>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WarehouseStock&&(identical(other.warehouse, warehouse) || other.warehouse == warehouse)&&(identical(other.warehouseName, warehouseName) || other.warehouseName == warehouseName)&&(identical(other.onHand, onHand) || other.onHand == onHand)&&(identical(other.available, available) || other.available == available));
}


@override
int get hashCode {
    return Object.hash(runtimeType,warehouse,warehouseName,onHand,available);
}

@override
String toString() {
    return 'WarehouseStock(warehouse: $warehouse, warehouseName: $warehouseName, onHand: $onHand, available: $available)';
}


}

/// @nodoc
abstract mixin class _$WarehouseStockCopyWith<$Res> implements $WarehouseStockCopyWith<$Res> {
  factory _$WarehouseStockCopyWith(_WarehouseStock value, $Res Function(_WarehouseStock) _then) = __$WarehouseStockCopyWithImpl;
@override @useResult
$Res call({
 int warehouse, String? warehouseName, String onHand, String available
});




}
/// @nodoc
class __$WarehouseStockCopyWithImpl<$Res>
    implements _$WarehouseStockCopyWith<$Res> {
  __$WarehouseStockCopyWithImpl(this._self, this._then);

  final _WarehouseStock _self;
  final $Res Function(_WarehouseStock) _then;

/// Create a copy of WarehouseStock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? warehouse = null,Object? warehouseName = freezed,Object? onHand = null,Object? available = null,}) {
  return _then(_WarehouseStock(
warehouse: null == warehouse ? _self.warehouse : warehouse // ignore: cast_nullable_to_non_nullable
as int,warehouseName: freezed == warehouseName ? _self.warehouseName : warehouseName // ignore: cast_nullable_to_non_nullable
as String?,onHand: null == onHand ? _self.onHand : onHand // ignore: cast_nullable_to_non_nullable
as String,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
