// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'destination_line.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DestinationLine {

 int get id; int? get salesOrderDetail; int get product; String get productCode; String get productName; String get quantity; int? get warehouse;
/// Create a copy of DestinationLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DestinationLineCopyWith<DestinationLine> get copyWith => _$DestinationLineCopyWithImpl<DestinationLine>(this as DestinationLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DestinationLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DestinationLine&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.salesOrderDetail, _this.salesOrderDetail) || other.salesOrderDetail == _this.salesOrderDetail)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.warehouse, _this.warehouse) || other.warehouse == _this.warehouse));
}


@override
int get hashCode {
  final _this = this as DestinationLine;
  return Object.hash(runtimeType,_this.id,_this.salesOrderDetail,_this.product,_this.productCode,_this.productName,_this.quantity,_this.warehouse);
}

@override
String toString() {
  final _this = this as DestinationLine;
  return 'DestinationLine(id: ${_this.id}, salesOrderDetail: ${_this.salesOrderDetail}, product: ${_this.product}, productCode: ${_this.productCode}, productName: ${_this.productName}, quantity: ${_this.quantity}, warehouse: ${_this.warehouse})';
}


}

/// @nodoc
abstract mixin class $DestinationLineCopyWith<$Res>  {
  factory $DestinationLineCopyWith(DestinationLine value, $Res Function(DestinationLine) _then) = _$DestinationLineCopyWithImpl;
@useResult
$Res call({
 int id, int? salesOrderDetail, int product, String productCode, String productName, String quantity, int? warehouse
});




}
/// @nodoc
class _$DestinationLineCopyWithImpl<$Res>
    implements $DestinationLineCopyWith<$Res> {
  _$DestinationLineCopyWithImpl(this._self, this._then);

  final DestinationLine _self;
  final $Res Function(DestinationLine) _then;

/// Create a copy of DestinationLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? salesOrderDetail = freezed,Object? product = null,Object? productCode = null,Object? productName = null,Object? quantity = null,Object? warehouse = freezed,}) {
  return _then(DestinationLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,salesOrderDetail: freezed == salesOrderDetail ? _self.salesOrderDetail : salesOrderDetail // ignore: cast_nullable_to_non_nullable
as int?,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,warehouse: freezed == warehouse ? _self.warehouse : warehouse // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DestinationLine].
extension DestinationLinePatterns on DestinationLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DestinationLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DestinationLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DestinationLine value)  $default,){
final _that = this;
switch (_that) {
case _DestinationLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DestinationLine value)?  $default,){
final _that = this;
switch (_that) {
case _DestinationLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? salesOrderDetail,  int product,  String productCode,  String productName,  String quantity,  int? warehouse)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DestinationLine() when $default != null:
return $default(_that.id,_that.salesOrderDetail,_that.product,_that.productCode,_that.productName,_that.quantity,_that.warehouse);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? salesOrderDetail,  int product,  String productCode,  String productName,  String quantity,  int? warehouse)  $default,) {final _that = this;
switch (_that) {
case _DestinationLine():
return $default(_that.id,_that.salesOrderDetail,_that.product,_that.productCode,_that.productName,_that.quantity,_that.warehouse);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? salesOrderDetail,  int product,  String productCode,  String productName,  String quantity,  int? warehouse)?  $default,) {final _that = this;
switch (_that) {
case _DestinationLine() when $default != null:
return $default(_that.id,_that.salesOrderDetail,_that.product,_that.productCode,_that.productName,_that.quantity,_that.warehouse);case _:
  return null;

}
}

}

/// @nodoc


class _DestinationLine implements DestinationLine {
  const _DestinationLine({required this.id, this.salesOrderDetail, required this.product, required this.productCode, required this.productName, required this.quantity, this.warehouse});
  

@override final  int id;
@override final  int? salesOrderDetail;
@override final  int product;
@override final  String productCode;
@override final  String productName;
@override final  String quantity;
@override final  int? warehouse;

/// Create a copy of DestinationLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DestinationLineCopyWith<_DestinationLine> get copyWith => __$DestinationLineCopyWithImpl<_DestinationLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DestinationLine&&(identical(other.id, id) || other.id == id)&&(identical(other.salesOrderDetail, salesOrderDetail) || other.salesOrderDetail == salesOrderDetail)&&(identical(other.product, product) || other.product == product)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.warehouse, warehouse) || other.warehouse == warehouse));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,salesOrderDetail,product,productCode,productName,quantity,warehouse);
}

@override
String toString() {
    return 'DestinationLine(id: $id, salesOrderDetail: $salesOrderDetail, product: $product, productCode: $productCode, productName: $productName, quantity: $quantity, warehouse: $warehouse)';
}


}

/// @nodoc
abstract mixin class _$DestinationLineCopyWith<$Res> implements $DestinationLineCopyWith<$Res> {
  factory _$DestinationLineCopyWith(_DestinationLine value, $Res Function(_DestinationLine) _then) = __$DestinationLineCopyWithImpl;
@override @useResult
$Res call({
 int id, int? salesOrderDetail, int product, String productCode, String productName, String quantity, int? warehouse
});




}
/// @nodoc
class __$DestinationLineCopyWithImpl<$Res>
    implements _$DestinationLineCopyWith<$Res> {
  __$DestinationLineCopyWithImpl(this._self, this._then);

  final _DestinationLine _self;
  final $Res Function(_DestinationLine) _then;

/// Create a copy of DestinationLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? salesOrderDetail = freezed,Object? product = null,Object? productCode = null,Object? productName = null,Object? quantity = null,Object? warehouse = freezed,}) {
  return _then(_DestinationLine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,salesOrderDetail: freezed == salesOrderDetail ? _self.salesOrderDetail : salesOrderDetail // ignore: cast_nullable_to_non_nullable
as int?,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as String,warehouse: freezed == warehouse ? _self.warehouse : warehouse // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
