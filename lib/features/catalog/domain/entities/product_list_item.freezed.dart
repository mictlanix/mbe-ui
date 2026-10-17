// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductListItem {

 int get productId; String get code; String get name; String? get sku; String? get brand; String? get model; String get unitOfMeasurementCode; String get unitOfMeasurementName; String get taxRate; EntityStatus get status;/// A fully-resolved, ready-to-fetch photo URL, same as `Product.photo`
/// (mictlanix/mbe-api#71 — the list endpoint now resolves this the same
/// way the detail endpoint always has).
 String? get photo;
/// Create a copy of ProductListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductListItemCopyWith<ProductListItem> get copyWith => _$ProductListItemCopyWithImpl<ProductListItem>(this as ProductListItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductListItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductListItem&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.sku, _this.sku) || other.sku == _this.sku)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.unitOfMeasurementCode, _this.unitOfMeasurementCode) || other.unitOfMeasurementCode == _this.unitOfMeasurementCode)&&(identical(other.unitOfMeasurementName, _this.unitOfMeasurementName) || other.unitOfMeasurementName == _this.unitOfMeasurementName)&&(identical(other.taxRate, _this.taxRate) || other.taxRate == _this.taxRate)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.photo, _this.photo) || other.photo == _this.photo));
}


@override
int get hashCode {
  final _this = this as ProductListItem;
  return Object.hash(runtimeType,_this.productId,_this.code,_this.name,_this.sku,_this.brand,_this.model,_this.unitOfMeasurementCode,_this.unitOfMeasurementName,_this.taxRate,_this.status,_this.photo);
}

@override
String toString() {
  final _this = this as ProductListItem;
  return 'ProductListItem(productId: ${_this.productId}, code: ${_this.code}, name: ${_this.name}, sku: ${_this.sku}, brand: ${_this.brand}, model: ${_this.model}, unitOfMeasurementCode: ${_this.unitOfMeasurementCode}, unitOfMeasurementName: ${_this.unitOfMeasurementName}, taxRate: ${_this.taxRate}, status: ${_this.status}, photo: ${_this.photo})';
}


}

/// @nodoc
abstract mixin class $ProductListItemCopyWith<$Res>  {
  factory $ProductListItemCopyWith(ProductListItem value, $Res Function(ProductListItem) _then) = _$ProductListItemCopyWithImpl;
@useResult
$Res call({
 int productId, String code, String name, String? sku, String? brand, String? model, String unitOfMeasurementCode, String unitOfMeasurementName, String taxRate, EntityStatus status, String? photo
});




}
/// @nodoc
class _$ProductListItemCopyWithImpl<$Res>
    implements $ProductListItemCopyWith<$Res> {
  _$ProductListItemCopyWithImpl(this._self, this._then);

  final ProductListItem _self;
  final $Res Function(ProductListItem) _then;

/// Create a copy of ProductListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? code = null,Object? name = null,Object? sku = freezed,Object? brand = freezed,Object? model = freezed,Object? unitOfMeasurementCode = null,Object? unitOfMeasurementName = null,Object? taxRate = null,Object? status = null,Object? photo = freezed,}) {
  return _then(ProductListItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,unitOfMeasurementCode: null == unitOfMeasurementCode ? _self.unitOfMeasurementCode : unitOfMeasurementCode // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasurementName: null == unitOfMeasurementName ? _self.unitOfMeasurementName : unitOfMeasurementName // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductListItem].
extension ProductListItemPatterns on ProductListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductListItem value)  $default,){
final _that = this;
switch (_that) {
case _ProductListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductListItem value)?  $default,){
final _that = this;
switch (_that) {
case _ProductListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String code,  String name,  String? sku,  String? brand,  String? model,  String unitOfMeasurementCode,  String unitOfMeasurementName,  String taxRate,  EntityStatus status,  String? photo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductListItem() when $default != null:
return $default(_that.productId,_that.code,_that.name,_that.sku,_that.brand,_that.model,_that.unitOfMeasurementCode,_that.unitOfMeasurementName,_that.taxRate,_that.status,_that.photo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String code,  String name,  String? sku,  String? brand,  String? model,  String unitOfMeasurementCode,  String unitOfMeasurementName,  String taxRate,  EntityStatus status,  String? photo)  $default,) {final _that = this;
switch (_that) {
case _ProductListItem():
return $default(_that.productId,_that.code,_that.name,_that.sku,_that.brand,_that.model,_that.unitOfMeasurementCode,_that.unitOfMeasurementName,_that.taxRate,_that.status,_that.photo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String code,  String name,  String? sku,  String? brand,  String? model,  String unitOfMeasurementCode,  String unitOfMeasurementName,  String taxRate,  EntityStatus status,  String? photo)?  $default,) {final _that = this;
switch (_that) {
case _ProductListItem() when $default != null:
return $default(_that.productId,_that.code,_that.name,_that.sku,_that.brand,_that.model,_that.unitOfMeasurementCode,_that.unitOfMeasurementName,_that.taxRate,_that.status,_that.photo);case _:
  return null;

}
}

}

/// @nodoc


class _ProductListItem implements ProductListItem {
  const _ProductListItem({required this.productId, required this.code, required this.name, this.sku, this.brand, this.model, required this.unitOfMeasurementCode, required this.unitOfMeasurementName, required this.taxRate, required this.status, this.photo});
  

@override final  int productId;
@override final  String code;
@override final  String name;
@override final  String? sku;
@override final  String? brand;
@override final  String? model;
@override final  String unitOfMeasurementCode;
@override final  String unitOfMeasurementName;
@override final  String taxRate;
@override final  EntityStatus status;
/// A fully-resolved, ready-to-fetch photo URL, same as `Product.photo`
/// (mictlanix/mbe-api#71 — the list endpoint now resolves this the same
/// way the detail endpoint always has).
@override final  String? photo;

/// Create a copy of ProductListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductListItemCopyWith<_ProductListItem> get copyWith => __$ProductListItemCopyWithImpl<_ProductListItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductListItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.unitOfMeasurementCode, unitOfMeasurementCode) || other.unitOfMeasurementCode == unitOfMeasurementCode)&&(identical(other.unitOfMeasurementName, unitOfMeasurementName) || other.unitOfMeasurementName == unitOfMeasurementName)&&(identical(other.taxRate, taxRate) || other.taxRate == taxRate)&&(identical(other.status, status) || other.status == status)&&(identical(other.photo, photo) || other.photo == photo));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,code,name,sku,brand,model,unitOfMeasurementCode,unitOfMeasurementName,taxRate,status,photo);
}

@override
String toString() {
    return 'ProductListItem(productId: $productId, code: $code, name: $name, sku: $sku, brand: $brand, model: $model, unitOfMeasurementCode: $unitOfMeasurementCode, unitOfMeasurementName: $unitOfMeasurementName, taxRate: $taxRate, status: $status, photo: $photo)';
}


}

/// @nodoc
abstract mixin class _$ProductListItemCopyWith<$Res> implements $ProductListItemCopyWith<$Res> {
  factory _$ProductListItemCopyWith(_ProductListItem value, $Res Function(_ProductListItem) _then) = __$ProductListItemCopyWithImpl;
@override @useResult
$Res call({
 int productId, String code, String name, String? sku, String? brand, String? model, String unitOfMeasurementCode, String unitOfMeasurementName, String taxRate, EntityStatus status, String? photo
});




}
/// @nodoc
class __$ProductListItemCopyWithImpl<$Res>
    implements _$ProductListItemCopyWith<$Res> {
  __$ProductListItemCopyWithImpl(this._self, this._then);

  final _ProductListItem _self;
  final $Res Function(_ProductListItem) _then;

/// Create a copy of ProductListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? code = null,Object? name = null,Object? sku = freezed,Object? brand = freezed,Object? model = freezed,Object? unitOfMeasurementCode = null,Object? unitOfMeasurementName = null,Object? taxRate = null,Object? status = null,Object? photo = freezed,}) {
  return _then(_ProductListItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,unitOfMeasurementCode: null == unitOfMeasurementCode ? _self.unitOfMeasurementCode : unitOfMeasurementCode // ignore: cast_nullable_to_non_nullable
as String,unitOfMeasurementName: null == unitOfMeasurementName ? _self.unitOfMeasurementName : unitOfMeasurementName // ignore: cast_nullable_to_non_nullable
as String,taxRate: null == taxRate ? _self.taxRate : taxRate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
