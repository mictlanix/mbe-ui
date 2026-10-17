// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale_line.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SaleLine {

 int get id; int get product; String get productCode; String get productName; String? get unit; String? get photo; String get quantity; String? get cost; String get price; String get discountRate; String get taxRate; bool get taxIncluded; int? get warehouse; String? get comment; String get subtotal; String get taxTotal; String get total; String? get availability; String? get priceAdjustment;
/// Create a copy of SaleLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleLineCopyWith<SaleLine> get copyWith => _$SaleLineCopyWithImpl<SaleLine>(this as SaleLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SaleLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.photo, _this.photo) || other.photo == _this.photo)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.cost, _this.cost) || other.cost == _this.cost)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.discountRate, _this.discountRate) || other.discountRate == _this.discountRate)&&(identical(other.taxRate, _this.taxRate) || other.taxRate == _this.taxRate)&&(identical(other.taxIncluded, _this.taxIncluded) || other.taxIncluded == _this.taxIncluded)&&(identical(other.warehouse, _this.warehouse) || other.warehouse == _this.warehouse)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal)&&(identical(other.taxTotal, _this.taxTotal) || other.taxTotal == _this.taxTotal)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.availability, _this.availability) || other.availability == _this.availability)&&(identical(other.priceAdjustment, _this.priceAdjustment) || other.priceAdjustment == _this.priceAdjustment));
}


@override
int get hashCode {
  final _this = this as SaleLine;
  return Object.hashAll([runtimeType,_this.id,_this.product,_this.productCode,_this.productName,_this.unit,_this.photo,_this.quantity,_this.cost,_this.price,_this.discountRate,_this.taxRate,_this.taxIncluded,_this.warehouse,_this.comment,_this.subtotal,_this.taxTotal,_this.total,_this.availability,_this.priceAdjustment]);
}

@override
String toString() {
  final _this = this as SaleLine;
  return 'SaleLine(id: ${_this.id}, product: ${_this.product}, productCode: ${_this.productCode}, productName: ${_this.productName}, unit: ${_this.unit}, photo: ${_this.photo}, quantity: ${_this.quantity}, cost: ${_this.cost}, price: ${_this.price}, discountRate: ${_this.discountRate}, taxRate: ${_this.taxRate}, taxIncluded: ${_this.taxIncluded}, warehouse: ${_this.warehouse}, comment: ${_this.comment}, subtotal: ${_this.subtotal}, taxTotal: ${_this.taxTotal}, total: ${_this.total}, availability: ${_this.availability}, priceAdjustment: ${_this.priceAdjustment})';
}


}

/// @nodoc
abstract mixin class $SaleLineCopyWith<$Res>  {
  factory $SaleLineCopyWith(SaleLine value, $Res Function(SaleLine) _then) = _$SaleLineCopyWithImpl;
@useResult
$Res call({
 int id, int product, String productCode, String productName, String? unit, String? photo, String quantity, String? cost, String price, String discountRate, String taxRate, bool taxIncluded, int? warehouse, String? comment, String subtotal, String taxTotal, String total, String? availability, String? priceAdjustment
});




}
/// @nodoc
class _$SaleLineCopyWithImpl<$Res>
    implements $SaleLineCopyWith<$Res> {
  _$SaleLineCopyWithImpl(this._self, this._then);

  final SaleLine _self;
  final $Res Function(SaleLine) _then;

/// Create a copy of SaleLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? product = null,Object? productCode = null,Object? productName = null,Object? unit = freezed,Object? photo = freezed,Object? quantity = null,Object? cost = freezed,Object? price = null,Object? discountRate = null,Object? taxRate = null,Object? taxIncluded = null,Object? warehouse = freezed,Object? comment = freezed,Object? subtotal = null,Object? taxTotal = null,Object? total = null,Object? availability = freezed,Object? priceAdjustment = freezed,}) {
  return _then(SaleLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,discountRate: null == discountRate ? _self.discountRate : discountRate // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as String,taxIncluded: null == taxIncluded ? _self.taxIncluded : taxIncluded // ignore: cast_nullable_to_non_nullable
as bool,warehouse: freezed == warehouse ? _self.warehouse : warehouse // ignore: cast_nullable_to_non_nullable
as int?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as String,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,availability: freezed == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as String?,priceAdjustment: freezed == priceAdjustment ? _self.priceAdjustment : priceAdjustment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleLine].
extension SaleLinePatterns on SaleLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleLine value)  $default,){
final _that = this;
switch (_that) {
case _SaleLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleLine value)?  $default,){
final _that = this;
switch (_that) {
case _SaleLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int product,  String productCode,  String productName,  String? unit,  String? photo,  String quantity,  String? cost,  String price,  String discountRate,  String taxRate,  bool taxIncluded,  int? warehouse,  String? comment,  String subtotal,  String taxTotal,  String total,  String? availability,  String? priceAdjustment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleLine() when $default != null:
return $default(_that.id,_that.product,_that.productCode,_that.productName,_that.unit,_that.photo,_that.quantity,_that.cost,_that.price,_that.discountRate,_that.taxRate,_that.taxIncluded,_that.warehouse,_that.comment,_that.subtotal,_that.taxTotal,_that.total,_that.availability,_that.priceAdjustment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int product,  String productCode,  String productName,  String? unit,  String? photo,  String quantity,  String? cost,  String price,  String discountRate,  String taxRate,  bool taxIncluded,  int? warehouse,  String? comment,  String subtotal,  String taxTotal,  String total,  String? availability,  String? priceAdjustment)  $default,) {final _that = this;
switch (_that) {
case _SaleLine():
return $default(_that.id,_that.product,_that.productCode,_that.productName,_that.unit,_that.photo,_that.quantity,_that.cost,_that.price,_that.discountRate,_that.taxRate,_that.taxIncluded,_that.warehouse,_that.comment,_that.subtotal,_that.taxTotal,_that.total,_that.availability,_that.priceAdjustment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int product,  String productCode,  String productName,  String? unit,  String? photo,  String quantity,  String? cost,  String price,  String discountRate,  String taxRate,  bool taxIncluded,  int? warehouse,  String? comment,  String subtotal,  String taxTotal,  String total,  String? availability,  String? priceAdjustment)?  $default,) {final _that = this;
switch (_that) {
case _SaleLine() when $default != null:
return $default(_that.id,_that.product,_that.productCode,_that.productName,_that.unit,_that.photo,_that.quantity,_that.cost,_that.price,_that.discountRate,_that.taxRate,_that.taxIncluded,_that.warehouse,_that.comment,_that.subtotal,_that.taxTotal,_that.total,_that.availability,_that.priceAdjustment);case _:
  return null;

}
}

}

/// @nodoc


class _SaleLine implements SaleLine {
  const _SaleLine({required this.id, required this.product, required this.productCode, required this.productName, this.unit, this.photo, required this.quantity, this.cost, required this.price, required this.discountRate, required this.taxRate, required this.taxIncluded, this.warehouse, this.comment, required this.subtotal, required this.taxTotal, required this.total, this.availability, this.priceAdjustment});
  

@override final  int id;
@override final  int product;
@override final  String productCode;
@override final  String productName;
@override final  String? unit;
@override final  String? photo;
@override final  String quantity;
@override final  String? cost;
@override final  String price;
@override final  String discountRate;
@override final  String taxRate;
@override final  bool taxIncluded;
@override final  int? warehouse;
@override final  String? comment;
@override final  String subtotal;
@override final  String taxTotal;
@override final  String total;
@override final  String? availability;
@override final  String? priceAdjustment;

/// Create a copy of SaleLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleLineCopyWith<_SaleLine> get copyWith => __$SaleLineCopyWithImpl<_SaleLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleLine&&(identical(other.id, id) || other.id == id)&&(identical(other.product, product) || other.product == product)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.price, price) || other.price == price)&&(identical(other.discountRate, discountRate) || other.discountRate == discountRate)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.taxIncluded, taxIncluded) || other.taxIncluded == taxIncluded)&&(identical(other.warehouse, warehouse) || other.warehouse == warehouse)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.total, total) || other.total == total)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.priceAdjustment, priceAdjustment) || other.priceAdjustment == priceAdjustment));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,product,productCode,productName,unit,photo,quantity,cost,price,discountRate,taxRate,taxIncluded,warehouse,comment,subtotal,taxTotal,total,availability,priceAdjustment]);
}

@override
String toString() {
    return 'SaleLine(id: $id, product: $product, productCode: $productCode, productName: $productName, unit: $unit, photo: $photo, quantity: $quantity, cost: $cost, price: $price, discountRate: $discountRate, taxRate: $taxRate, taxIncluded: $taxIncluded, warehouse: $warehouse, comment: $comment, subtotal: $subtotal, taxTotal: $taxTotal, total: $total, availability: $availability, priceAdjustment: $priceAdjustment)';
}


}

/// @nodoc
abstract mixin class _$SaleLineCopyWith<$Res> implements $SaleLineCopyWith<$Res> {
  factory _$SaleLineCopyWith(_SaleLine value, $Res Function(_SaleLine) _then) = __$SaleLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int product, String productCode, String productName, String? unit, String? photo, String quantity, String? cost, String price, String discountRate, String taxRate, bool taxIncluded, int? warehouse, String? comment, String subtotal, String taxTotal, String total, String? availability, String? priceAdjustment
});




}
/// @nodoc
class __$SaleLineCopyWithImpl<$Res>
    implements _$SaleLineCopyWith<$Res> {
  __$SaleLineCopyWithImpl(this._self, this._then);

  final _SaleLine _self;
  final $Res Function(_SaleLine) _then;

/// Create a copy of SaleLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? product = null,Object? productCode = null,Object? productName = null,Object? unit = freezed,Object? photo = freezed,Object? quantity = null,Object? cost = freezed,Object? price = null,Object? discountRate = null,Object? taxRate = null,Object? taxIncluded = null,Object? warehouse = freezed,Object? comment = freezed,Object? subtotal = null,Object? taxTotal = null,Object? total = null,Object? availability = freezed,Object? priceAdjustment = freezed,}) {
  return _then(_SaleLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,discountRate: null == discountRate ? _self.discountRate : discountRate // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as String,taxIncluded: null == taxIncluded ? _self.taxIncluded : taxIncluded // ignore: cast_nullable_to_non_nullable
as bool,warehouse: freezed == warehouse ? _self.warehouse : warehouse // ignore: cast_nullable_to_non_nullable
as int?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as String,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as String,availability: freezed == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as String?,priceAdjustment: freezed == priceAdjustment ? _self.priceAdjustment : priceAdjustment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
