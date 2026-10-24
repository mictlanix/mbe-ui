// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_discount.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CustomerDiscount {

 int get customerDiscountId; int get customerId; int get productId; String get productCode; String get productName; String get discount;
/// Create a copy of CustomerDiscount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerDiscountCopyWith<CustomerDiscount> get copyWith => _$CustomerDiscountCopyWithImpl<CustomerDiscount>(this as CustomerDiscount, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomerDiscount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerDiscount&&(identical(other.customerDiscountId, _this.customerDiscountId) || other.customerDiscountId == _this.customerDiscountId)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productCode, _this.productCode) || other.productCode == _this.productCode)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.discount, _this.discount) || other.discount == _this.discount));
}


@override
int get hashCode {
  final _this = this as CustomerDiscount;
  return Object.hash(runtimeType,_this.customerDiscountId,_this.customerId,_this.productId,_this.productCode,_this.productName,_this.discount);
}

@override
String toString() {
  final _this = this as CustomerDiscount;
  return 'CustomerDiscount(customerDiscountId: ${_this.customerDiscountId}, customerId: ${_this.customerId}, productId: ${_this.productId}, productCode: ${_this.productCode}, productName: ${_this.productName}, discount: ${_this.discount})';
}


}

/// @nodoc
abstract mixin class $CustomerDiscountCopyWith<$Res>  {
  factory $CustomerDiscountCopyWith(CustomerDiscount value, $Res Function(CustomerDiscount) _then) = _$CustomerDiscountCopyWithImpl;
@useResult
$Res call({
 int customerDiscountId, int customerId, int productId, String productCode, String productName, String discount
});




}
/// @nodoc
class _$CustomerDiscountCopyWithImpl<$Res>
    implements $CustomerDiscountCopyWith<$Res> {
  _$CustomerDiscountCopyWithImpl(this._self, this._then);

  final CustomerDiscount _self;
  final $Res Function(CustomerDiscount) _then;

/// Create a copy of CustomerDiscount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerDiscountId = null,Object? customerId = null,Object? productId = null,Object? productCode = null,Object? productName = null,Object? discount = null,}) {
  return _then(CustomerDiscount(
customerDiscountId: null == customerDiscountId ? _self.customerDiscountId : customerDiscountId // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerDiscount].
extension CustomerDiscountPatterns on CustomerDiscount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerDiscount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerDiscount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerDiscount value)  $default,){
final _that = this;
switch (_that) {
case _CustomerDiscount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerDiscount value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerDiscount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int customerDiscountId,  int customerId,  int productId,  String productCode,  String productName,  String discount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerDiscount() when $default != null:
return $default(_that.customerDiscountId,_that.customerId,_that.productId,_that.productCode,_that.productName,_that.discount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int customerDiscountId,  int customerId,  int productId,  String productCode,  String productName,  String discount)  $default,) {final _that = this;
switch (_that) {
case _CustomerDiscount():
return $default(_that.customerDiscountId,_that.customerId,_that.productId,_that.productCode,_that.productName,_that.discount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int customerDiscountId,  int customerId,  int productId,  String productCode,  String productName,  String discount)?  $default,) {final _that = this;
switch (_that) {
case _CustomerDiscount() when $default != null:
return $default(_that.customerDiscountId,_that.customerId,_that.productId,_that.productCode,_that.productName,_that.discount);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerDiscount implements CustomerDiscount {
  const _CustomerDiscount({required this.customerDiscountId, required this.customerId, required this.productId, required this.productCode, required this.productName, required this.discount});
  

@override final  int customerDiscountId;
@override final  int customerId;
@override final  int productId;
@override final  String productCode;
@override final  String productName;
@override final  String discount;

/// Create a copy of CustomerDiscount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerDiscountCopyWith<_CustomerDiscount> get copyWith => __$CustomerDiscountCopyWithImpl<_CustomerDiscount>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerDiscount&&(identical(other.customerDiscountId, customerDiscountId) || other.customerDiscountId == customerDiscountId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.discount, discount) || other.discount == discount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,customerDiscountId,customerId,productId,productCode,productName,discount);
}

@override
String toString() {
    return 'CustomerDiscount(customerDiscountId: $customerDiscountId, customerId: $customerId, productId: $productId, productCode: $productCode, productName: $productName, discount: $discount)';
}


}

/// @nodoc
abstract mixin class _$CustomerDiscountCopyWith<$Res> implements $CustomerDiscountCopyWith<$Res> {
  factory _$CustomerDiscountCopyWith(_CustomerDiscount value, $Res Function(_CustomerDiscount) _then) = __$CustomerDiscountCopyWithImpl;
@override @useResult
$Res call({
 int customerDiscountId, int customerId, int productId, String productCode, String productName, String discount
});




}
/// @nodoc
class __$CustomerDiscountCopyWithImpl<$Res>
    implements _$CustomerDiscountCopyWith<$Res> {
  __$CustomerDiscountCopyWithImpl(this._self, this._then);

  final _CustomerDiscount _self;
  final $Res Function(_CustomerDiscount) _then;

/// Create a copy of CustomerDiscount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerDiscountId = null,Object? customerId = null,Object? productId = null,Object? productCode = null,Object? productName = null,Object? discount = null,}) {
  return _then(_CustomerDiscount(
customerDiscountId: null == customerDiscountId ? _self.customerDiscountId : customerDiscountId // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productCode: null == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
