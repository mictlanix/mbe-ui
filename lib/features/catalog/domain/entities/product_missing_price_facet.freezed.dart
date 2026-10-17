// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_missing_price_facet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductMissingPriceFacet {

 int get priceListId; int get missingCount;
/// Create a copy of ProductMissingPriceFacet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductMissingPriceFacetCopyWith<ProductMissingPriceFacet> get copyWith => _$ProductMissingPriceFacetCopyWithImpl<ProductMissingPriceFacet>(this as ProductMissingPriceFacet, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductMissingPriceFacet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductMissingPriceFacet&&(identical(other.priceListId, _this.priceListId) || other.priceListId == _this.priceListId)&&(identical(other.missingCount, _this.missingCount) || other.missingCount == _this.missingCount));
}


@override
int get hashCode {
  final _this = this as ProductMissingPriceFacet;
  return Object.hash(runtimeType,_this.priceListId,_this.missingCount);
}

@override
String toString() {
  final _this = this as ProductMissingPriceFacet;
  return 'ProductMissingPriceFacet(priceListId: ${_this.priceListId}, missingCount: ${_this.missingCount})';
}


}

/// @nodoc
abstract mixin class $ProductMissingPriceFacetCopyWith<$Res>  {
  factory $ProductMissingPriceFacetCopyWith(ProductMissingPriceFacet value, $Res Function(ProductMissingPriceFacet) _then) = _$ProductMissingPriceFacetCopyWithImpl;
@useResult
$Res call({
 int priceListId, int missingCount
});




}
/// @nodoc
class _$ProductMissingPriceFacetCopyWithImpl<$Res>
    implements $ProductMissingPriceFacetCopyWith<$Res> {
  _$ProductMissingPriceFacetCopyWithImpl(this._self, this._then);

  final ProductMissingPriceFacet _self;
  final $Res Function(ProductMissingPriceFacet) _then;

/// Create a copy of ProductMissingPriceFacet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? priceListId = null,Object? missingCount = null,}) {
  return _then(ProductMissingPriceFacet(
priceListId: null == priceListId ? _self.priceListId : priceListId // ignore: cast_nullable_to_non_nullable
as int,missingCount: null == missingCount ? _self.missingCount : missingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductMissingPriceFacet].
extension ProductMissingPriceFacetPatterns on ProductMissingPriceFacet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductMissingPriceFacet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductMissingPriceFacet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductMissingPriceFacet value)  $default,){
final _that = this;
switch (_that) {
case _ProductMissingPriceFacet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductMissingPriceFacet value)?  $default,){
final _that = this;
switch (_that) {
case _ProductMissingPriceFacet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int priceListId,  int missingCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductMissingPriceFacet() when $default != null:
return $default(_that.priceListId,_that.missingCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int priceListId,  int missingCount)  $default,) {final _that = this;
switch (_that) {
case _ProductMissingPriceFacet():
return $default(_that.priceListId,_that.missingCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int priceListId,  int missingCount)?  $default,) {final _that = this;
switch (_that) {
case _ProductMissingPriceFacet() when $default != null:
return $default(_that.priceListId,_that.missingCount);case _:
  return null;

}
}

}

/// @nodoc


class _ProductMissingPriceFacet implements ProductMissingPriceFacet {
  const _ProductMissingPriceFacet({required this.priceListId, required this.missingCount});
  

@override final  int priceListId;
@override final  int missingCount;

/// Create a copy of ProductMissingPriceFacet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductMissingPriceFacetCopyWith<_ProductMissingPriceFacet> get copyWith => __$ProductMissingPriceFacetCopyWithImpl<_ProductMissingPriceFacet>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductMissingPriceFacet&&(identical(other.priceListId, priceListId) || other.priceListId == priceListId)&&(identical(other.missingCount, missingCount) || other.missingCount == missingCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,priceListId,missingCount);
}

@override
String toString() {
    return 'ProductMissingPriceFacet(priceListId: $priceListId, missingCount: $missingCount)';
}


}

/// @nodoc
abstract mixin class _$ProductMissingPriceFacetCopyWith<$Res> implements $ProductMissingPriceFacetCopyWith<$Res> {
  factory _$ProductMissingPriceFacetCopyWith(_ProductMissingPriceFacet value, $Res Function(_ProductMissingPriceFacet) _then) = __$ProductMissingPriceFacetCopyWithImpl;
@override @useResult
$Res call({
 int priceListId, int missingCount
});




}
/// @nodoc
class __$ProductMissingPriceFacetCopyWithImpl<$Res>
    implements _$ProductMissingPriceFacetCopyWith<$Res> {
  __$ProductMissingPriceFacetCopyWithImpl(this._self, this._then);

  final _ProductMissingPriceFacet _self;
  final $Res Function(_ProductMissingPriceFacet) _then;

/// Create a copy of ProductMissingPriceFacet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? priceListId = null,Object? missingCount = null,}) {
  return _then(_ProductMissingPriceFacet(
priceListId: null == priceListId ? _self.priceListId : priceListId // ignore: cast_nullable_to_non_nullable
as int,missingCount: null == missingCount ? _self.missingCount : missingCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
