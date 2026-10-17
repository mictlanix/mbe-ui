// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Product {

 int get productId; String get code; String get name; String? get photo; String? get sku; String? get brand; String? get model; String? get barCode; String? get location; String get unitOfMeasurementCode; String get unitOfMeasurementName; String? get unitOfMeasurementDescription; String? get unitOfMeasurementSymbol; String? get satKeyCode; String? get satKeyDescription; String get taxRate; bool get taxIncluded; int get priceType; int get currency; int get minOrderQty; int? get supplierId; String? get supplierName; bool get stockable; bool get perishable; bool get seriable; bool get purchasable; bool get salable; bool get invoiceable; bool get stockRequired; EntityStatus get status; String? get comment; List<ProductLabel> get labels;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Product;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.photo, _this.photo) || other.photo == _this.photo)&&(identical(other.sku, _this.sku) || other.sku == _this.sku)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.barCode, _this.barCode) || other.barCode == _this.barCode)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.unitOfMeasurementCode, _this.unitOfMeasurementCode) || other.unitOfMeasurementCode == _this.unitOfMeasurementCode)&&(identical(other.unitOfMeasurementName, _this.unitOfMeasurementName) || other.unitOfMeasurementName == _this.unitOfMeasurementName)&&(identical(other.unitOfMeasurementDescription, _this.unitOfMeasurementDescription) || other.unitOfMeasurementDescription == _this.unitOfMeasurementDescription)&&(identical(other.unitOfMeasurementSymbol, _this.unitOfMeasurementSymbol) || other.unitOfMeasurementSymbol == _this.unitOfMeasurementSymbol)&&(identical(other.satKeyCode, _this.satKeyCode) || other.satKeyCode == _this.satKeyCode)&&(identical(other.satKeyDescription, _this.satKeyDescription) || other.satKeyDescription == _this.satKeyDescription)&&(identical(other.taxRate, _this.taxRate) || other.taxRate == _this.taxRate)&&(identical(other.taxIncluded, _this.taxIncluded) || other.taxIncluded == _this.taxIncluded)&&(identical(other.priceType, _this.priceType) || other.priceType == _this.priceType)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.minOrderQty, _this.minOrderQty) || other.minOrderQty == _this.minOrderQty)&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.supplierName, _this.supplierName) || other.supplierName == _this.supplierName)&&(identical(other.stockable, _this.stockable) || other.stockable == _this.stockable)&&(identical(other.perishable, _this.perishable) || other.perishable == _this.perishable)&&(identical(other.seriable, _this.seriable) || other.seriable == _this.seriable)&&(identical(other.purchasable, _this.purchasable) || other.purchasable == _this.purchasable)&&(identical(other.salable, _this.salable) || other.salable == _this.salable)&&(identical(other.invoiceable, _this.invoiceable) || other.invoiceable == _this.invoiceable)&&(identical(other.stockRequired, _this.stockRequired) || other.stockRequired == _this.stockRequired)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&const DeepCollectionEquality().equals(other.labels, _this.labels));
}


@override
int get hashCode {
  final _this = this as Product;
  return Object.hashAll([runtimeType,_this.productId,_this.code,_this.name,_this.photo,_this.sku,_this.brand,_this.model,_this.barCode,_this.location,_this.unitOfMeasurementCode,_this.unitOfMeasurementName,_this.unitOfMeasurementDescription,_this.unitOfMeasurementSymbol,_this.satKeyCode,_this.satKeyDescription,_this.taxRate,_this.taxIncluded,_this.priceType,_this.currency,_this.minOrderQty,_this.supplierId,_this.supplierName,_this.stockable,_this.perishable,_this.seriable,_this.purchasable,_this.salable,_this.invoiceable,_this.stockRequired,_this.status,_this.comment,const DeepCollectionEquality().hash(_this.labels)]);
}

@override
String toString() {
  final _this = this as Product;
  return 'Product(productId: ${_this.productId}, code: ${_this.code}, name: ${_this.name}, photo: ${_this.photo}, sku: ${_this.sku}, brand: ${_this.brand}, model: ${_this.model}, barCode: ${_this.barCode}, location: ${_this.location}, unitOfMeasurementCode: ${_this.unitOfMeasurementCode}, unitOfMeasurementName: ${_this.unitOfMeasurementName}, unitOfMeasurementDescription: ${_this.unitOfMeasurementDescription}, unitOfMeasurementSymbol: ${_this.unitOfMeasurementSymbol}, satKeyCode: ${_this.satKeyCode}, satKeyDescription: ${_this.satKeyDescription}, taxRate: ${_this.taxRate}, taxIncluded: ${_this.taxIncluded}, priceType: ${_this.priceType}, currency: ${_this.currency}, minOrderQty: ${_this.minOrderQty}, supplierId: ${_this.supplierId}, supplierName: ${_this.supplierName}, stockable: ${_this.stockable}, perishable: ${_this.perishable}, seriable: ${_this.seriable}, purchasable: ${_this.purchasable}, salable: ${_this.salable}, invoiceable: ${_this.invoiceable}, stockRequired: ${_this.stockRequired}, status: ${_this.status}, comment: ${_this.comment}, labels: ${_this.labels})';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 int productId, String code, String name, String? photo, String? sku, String? brand, String? model, String? barCode, String? location, String unitOfMeasurementCode, String unitOfMeasurementName, String? unitOfMeasurementDescription, String? unitOfMeasurementSymbol, String? satKeyCode, String? satKeyDescription, String taxRate, bool taxIncluded, int priceType, int currency, int minOrderQty, int? supplierId, String? supplierName, bool stockable, bool perishable, bool seriable, bool purchasable, bool salable, bool invoiceable, bool stockRequired, EntityStatus status, String? comment, List<ProductLabel> labels
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? code = null,Object? name = null,Object? photo = freezed,Object? sku = freezed,Object? brand = freezed,Object? model = freezed,Object? barCode = freezed,Object? location = freezed,Object? unitOfMeasurementCode = null,Object? unitOfMeasurementName = null,Object? unitOfMeasurementDescription = freezed,Object? unitOfMeasurementSymbol = freezed,Object? satKeyCode = freezed,Object? satKeyDescription = freezed,Object? taxRate = null,Object? taxIncluded = null,Object? priceType = null,Object? currency = null,Object? minOrderQty = null,Object? supplierId = freezed,Object? supplierName = freezed,Object? stockable = null,Object? perishable = null,Object? seriable = null,Object? purchasable = null,Object? salable = null,Object? invoiceable = null,Object? stockRequired = null,Object? status = null,Object? comment = freezed,Object? labels = null,}) {
  return _then(Product(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,barCode: freezed == barCode ? _self.barCode : barCode // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,unitOfMeasurementCode: null == unitOfMeasurementCode ? _self.unitOfMeasurementCode : unitOfMeasurementCode // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasurementName: null == unitOfMeasurementName ? _self.unitOfMeasurementName : unitOfMeasurementName // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasurementDescription: freezed == unitOfMeasurementDescription ? _self.unitOfMeasurementDescription : unitOfMeasurementDescription // ignore: cast_nullable_to_non_nullable
as String?,unitOfMeasurementSymbol: freezed == unitOfMeasurementSymbol ? _self.unitOfMeasurementSymbol : unitOfMeasurementSymbol // ignore: cast_nullable_to_non_nullable
as String?,satKeyCode: freezed == satKeyCode ? _self.satKeyCode : satKeyCode // ignore: cast_nullable_to_non_nullable
as String?,satKeyDescription: freezed == satKeyDescription ? _self.satKeyDescription : satKeyDescription // ignore: cast_nullable_to_non_nullable
as String?,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as String,taxIncluded: null == taxIncluded ? _self.taxIncluded : taxIncluded // ignore: cast_nullable_to_non_nullable
as bool,priceType: null == priceType ? _self.priceType : priceType // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as int,minOrderQty: null == minOrderQty ? _self.minOrderQty : minOrderQty // ignore: cast_nullable_to_non_nullable
as int,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,stockable: null == stockable ? _self.stockable : stockable // ignore: cast_nullable_to_non_nullable
as bool,perishable: null == perishable ? _self.perishable : perishable // ignore: cast_nullable_to_non_nullable
as bool,seriable: null == seriable ? _self.seriable : seriable // ignore: cast_nullable_to_non_nullable
as bool,purchasable: null == purchasable ? _self.purchasable : purchasable // ignore: cast_nullable_to_non_nullable
as bool,salable: null == salable ? _self.salable : salable // ignore: cast_nullable_to_non_nullable
as bool,invoiceable: null == invoiceable ? _self.invoiceable : invoiceable // ignore: cast_nullable_to_non_nullable
as bool,stockRequired: null == stockRequired ? _self.stockRequired : stockRequired // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<ProductLabel>,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String code,  String name,  String? photo,  String? sku,  String? brand,  String? model,  String? barCode,  String? location,  String unitOfMeasurementCode,  String unitOfMeasurementName,  String? unitOfMeasurementDescription,  String? unitOfMeasurementSymbol,  String? satKeyCode,  String? satKeyDescription,  String taxRate,  bool taxIncluded,  int priceType,  int currency,  int minOrderQty,  int? supplierId,  String? supplierName,  bool stockable,  bool perishable,  bool seriable,  bool purchasable,  bool salable,  bool invoiceable,  bool stockRequired,  EntityStatus status,  String? comment,  List<ProductLabel> labels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.productId,_that.code,_that.name,_that.photo,_that.sku,_that.brand,_that.model,_that.barCode,_that.location,_that.unitOfMeasurementCode,_that.unitOfMeasurementName,_that.unitOfMeasurementDescription,_that.unitOfMeasurementSymbol,_that.satKeyCode,_that.satKeyDescription,_that.taxRate,_that.taxIncluded,_that.priceType,_that.currency,_that.minOrderQty,_that.supplierId,_that.supplierName,_that.stockable,_that.perishable,_that.seriable,_that.purchasable,_that.salable,_that.invoiceable,_that.stockRequired,_that.status,_that.comment,_that.labels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String code,  String name,  String? photo,  String? sku,  String? brand,  String? model,  String? barCode,  String? location,  String unitOfMeasurementCode,  String unitOfMeasurementName,  String? unitOfMeasurementDescription,  String? unitOfMeasurementSymbol,  String? satKeyCode,  String? satKeyDescription,  String taxRate,  bool taxIncluded,  int priceType,  int currency,  int minOrderQty,  int? supplierId,  String? supplierName,  bool stockable,  bool perishable,  bool seriable,  bool purchasable,  bool salable,  bool invoiceable,  bool stockRequired,  EntityStatus status,  String? comment,  List<ProductLabel> labels)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.productId,_that.code,_that.name,_that.photo,_that.sku,_that.brand,_that.model,_that.barCode,_that.location,_that.unitOfMeasurementCode,_that.unitOfMeasurementName,_that.unitOfMeasurementDescription,_that.unitOfMeasurementSymbol,_that.satKeyCode,_that.satKeyDescription,_that.taxRate,_that.taxIncluded,_that.priceType,_that.currency,_that.minOrderQty,_that.supplierId,_that.supplierName,_that.stockable,_that.perishable,_that.seriable,_that.purchasable,_that.salable,_that.invoiceable,_that.stockRequired,_that.status,_that.comment,_that.labels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String code,  String name,  String? photo,  String? sku,  String? brand,  String? model,  String? barCode,  String? location,  String unitOfMeasurementCode,  String unitOfMeasurementName,  String? unitOfMeasurementDescription,  String? unitOfMeasurementSymbol,  String? satKeyCode,  String? satKeyDescription,  String taxRate,  bool taxIncluded,  int priceType,  int currency,  int minOrderQty,  int? supplierId,  String? supplierName,  bool stockable,  bool perishable,  bool seriable,  bool purchasable,  bool salable,  bool invoiceable,  bool stockRequired,  EntityStatus status,  String? comment,  List<ProductLabel> labels)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.productId,_that.code,_that.name,_that.photo,_that.sku,_that.brand,_that.model,_that.barCode,_that.location,_that.unitOfMeasurementCode,_that.unitOfMeasurementName,_that.unitOfMeasurementDescription,_that.unitOfMeasurementSymbol,_that.satKeyCode,_that.satKeyDescription,_that.taxRate,_that.taxIncluded,_that.priceType,_that.currency,_that.minOrderQty,_that.supplierId,_that.supplierName,_that.stockable,_that.perishable,_that.seriable,_that.purchasable,_that.salable,_that.invoiceable,_that.stockRequired,_that.status,_that.comment,_that.labels);case _:
  return null;

}
}

}

/// @nodoc


class _Product implements Product {
  const _Product({required this.productId, required this.code, required this.name, this.photo, this.sku, this.brand, this.model, this.barCode, this.location, required this.unitOfMeasurementCode, required this.unitOfMeasurementName, this.unitOfMeasurementDescription, this.unitOfMeasurementSymbol, this.satKeyCode, this.satKeyDescription, required this.taxRate, required this.taxIncluded, required this.priceType, required this.currency, required this.minOrderQty, this.supplierId, this.supplierName, required this.stockable, required this.perishable, required this.seriable, required this.purchasable, required this.salable, required this.invoiceable, required this.stockRequired, required this.status, this.comment,  List<ProductLabel> labels = const []}): _labels = labels;
  

@override final  int productId;
@override final  String code;
@override final  String name;
@override final  String? photo;
@override final  String? sku;
@override final  String? brand;
@override final  String? model;
@override final  String? barCode;
@override final  String? location;
@override final  String unitOfMeasurementCode;
@override final  String unitOfMeasurementName;
@override final  String? unitOfMeasurementDescription;
@override final  String? unitOfMeasurementSymbol;
@override final  String? satKeyCode;
@override final  String? satKeyDescription;
@override final  String taxRate;
@override final  bool taxIncluded;
@override final  int priceType;
@override final  int currency;
@override final  int minOrderQty;
@override final  int? supplierId;
@override final  String? supplierName;
@override final  bool stockable;
@override final  bool perishable;
@override final  bool seriable;
@override final  bool purchasable;
@override final  bool salable;
@override final  bool invoiceable;
@override final  bool stockRequired;
@override final  EntityStatus status;
@override final  String? comment;
 final  List<ProductLabel> _labels;
@override@JsonKey() List<ProductLabel> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}


/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.barCode, barCode) || other.barCode == barCode)&&(identical(other.location, location) || other.location == location)&&(identical(other.unitOfMeasurementCode, unitOfMeasurementCode) || other.unitOfMeasurementCode == unitOfMeasurementCode)&&(identical(other.unitOfMeasurementName, unitOfMeasurementName) || other.unitOfMeasurementName == unitOfMeasurementName)&&(identical(other.unitOfMeasurementDescription, unitOfMeasurementDescription) || other.unitOfMeasurementDescription == unitOfMeasurementDescription)&&(identical(other.unitOfMeasurementSymbol, unitOfMeasurementSymbol) || other.unitOfMeasurementSymbol == unitOfMeasurementSymbol)&&(identical(other.satKeyCode, satKeyCode) || other.satKeyCode == satKeyCode)&&(identical(other.satKeyDescription, satKeyDescription) || other.satKeyDescription == satKeyDescription)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.taxIncluded, taxIncluded) || other.taxIncluded == taxIncluded)&&(identical(other.priceType, priceType) || other.priceType == priceType)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.minOrderQty, minOrderQty) || other.minOrderQty == minOrderQty)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.stockable, stockable) || other.stockable == stockable)&&(identical(other.perishable, perishable) || other.perishable == perishable)&&(identical(other.seriable, seriable) || other.seriable == seriable)&&(identical(other.purchasable, purchasable) || other.purchasable == purchasable)&&(identical(other.salable, salable) || other.salable == salable)&&(identical(other.invoiceable, invoiceable) || other.invoiceable == invoiceable)&&(identical(other.stockRequired, stockRequired) || other.stockRequired == stockRequired)&&(identical(other.status, status) || other.status == status)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other.labels, _labels));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,productId,code,name,photo,sku,brand,model,barCode,location,unitOfMeasurementCode,unitOfMeasurementName,unitOfMeasurementDescription,unitOfMeasurementSymbol,satKeyCode,satKeyDescription,taxRate,taxIncluded,priceType,currency,minOrderQty,supplierId,supplierName,stockable,perishable,seriable,purchasable,salable,invoiceable,stockRequired,status,comment,const DeepCollectionEquality().hash(_labels)]);
}

@override
String toString() {
    return 'Product(productId: $productId, code: $code, name: $name, photo: $photo, sku: $sku, brand: $brand, model: $model, barCode: $barCode, location: $location, unitOfMeasurementCode: $unitOfMeasurementCode, unitOfMeasurementName: $unitOfMeasurementName, unitOfMeasurementDescription: $unitOfMeasurementDescription, unitOfMeasurementSymbol: $unitOfMeasurementSymbol, satKeyCode: $satKeyCode, satKeyDescription: $satKeyDescription, taxRate: $taxRate, taxIncluded: $taxIncluded, priceType: $priceType, currency: $currency, minOrderQty: $minOrderQty, supplierId: $supplierId, supplierName: $supplierName, stockable: $stockable, perishable: $perishable, seriable: $seriable, purchasable: $purchasable, salable: $salable, invoiceable: $invoiceable, stockRequired: $stockRequired, status: $status, comment: $comment, labels: $labels)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 int productId, String code, String name, String? photo, String? sku, String? brand, String? model, String? barCode, String? location, String unitOfMeasurementCode, String unitOfMeasurementName, String? unitOfMeasurementDescription, String? unitOfMeasurementSymbol, String? satKeyCode, String? satKeyDescription, String taxRate, bool taxIncluded, int priceType, int currency, int minOrderQty, int? supplierId, String? supplierName, bool stockable, bool perishable, bool seriable, bool purchasable, bool salable, bool invoiceable, bool stockRequired, EntityStatus status, String? comment, List<ProductLabel> labels
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? code = null,Object? name = null,Object? photo = freezed,Object? sku = freezed,Object? brand = freezed,Object? model = freezed,Object? barCode = freezed,Object? location = freezed,Object? unitOfMeasurementCode = null,Object? unitOfMeasurementName = null,Object? unitOfMeasurementDescription = freezed,Object? unitOfMeasurementSymbol = freezed,Object? satKeyCode = freezed,Object? satKeyDescription = freezed,Object? taxRate = null,Object? taxIncluded = null,Object? priceType = null,Object? currency = null,Object? minOrderQty = null,Object? supplierId = freezed,Object? supplierName = freezed,Object? stockable = null,Object? perishable = null,Object? seriable = null,Object? purchasable = null,Object? salable = null,Object? invoiceable = null,Object? stockRequired = null,Object? status = null,Object? comment = freezed,Object? labels = null,}) {
  return _then(_Product(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,barCode: freezed == barCode ? _self.barCode : barCode // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,unitOfMeasurementCode: null == unitOfMeasurementCode ? _self.unitOfMeasurementCode : unitOfMeasurementCode // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasurementName: null == unitOfMeasurementName ? _self.unitOfMeasurementName : unitOfMeasurementName // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasurementDescription: freezed == unitOfMeasurementDescription ? _self.unitOfMeasurementDescription : unitOfMeasurementDescription // ignore: cast_nullable_to_non_nullable
as String?,unitOfMeasurementSymbol: freezed == unitOfMeasurementSymbol ? _self.unitOfMeasurementSymbol : unitOfMeasurementSymbol // ignore: cast_nullable_to_non_nullable
as String?,satKeyCode: freezed == satKeyCode ? _self.satKeyCode : satKeyCode // ignore: cast_nullable_to_non_nullable
as String?,satKeyDescription: freezed == satKeyDescription ? _self.satKeyDescription : satKeyDescription // ignore: cast_nullable_to_non_nullable
as String?,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as String,taxIncluded: null == taxIncluded ? _self.taxIncluded : taxIncluded // ignore: cast_nullable_to_non_nullable
as bool,priceType: null == priceType ? _self.priceType : priceType // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as int,minOrderQty: null == minOrderQty ? _self.minOrderQty : minOrderQty // ignore: cast_nullable_to_non_nullable
as int,supplierId: freezed == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,stockable: null == stockable ? _self.stockable : stockable // ignore: cast_nullable_to_non_nullable
as bool,perishable: null == perishable ? _self.perishable : perishable // ignore: cast_nullable_to_non_nullable
as bool,seriable: null == seriable ? _self.seriable : seriable // ignore: cast_nullable_to_non_nullable
as bool,purchasable: null == purchasable ? _self.purchasable : purchasable // ignore: cast_nullable_to_non_nullable
as bool,salable: null == salable ? _self.salable : salable // ignore: cast_nullable_to_non_nullable
as bool,invoiceable: null == invoiceable ? _self.invoiceable : invoiceable // ignore: cast_nullable_to_non_nullable
as bool,stockRequired: null == stockRequired ? _self.stockRequired : stockRequired // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<ProductLabel>,
  ));
}


}

// dart format on
