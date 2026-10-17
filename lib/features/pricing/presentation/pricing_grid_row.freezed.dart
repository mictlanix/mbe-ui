// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pricing_grid_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PricingGridRow {

 ProductListItem get product; Map<int, ProductPrice> get prices;
/// Create a copy of PricingGridRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PricingGridRowCopyWith<PricingGridRow> get copyWith => _$PricingGridRowCopyWithImpl<PricingGridRow>(this as PricingGridRow, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PricingGridRow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PricingGridRow&&(identical(other.product, _this.product) || other.product == _this.product)&&const DeepCollectionEquality().equals(other.prices, _this.prices));
}


@override
int get hashCode {
  final _this = this as PricingGridRow;
  return Object.hash(runtimeType,_this.product,const DeepCollectionEquality().hash(_this.prices));
}

@override
String toString() {
  final _this = this as PricingGridRow;
  return 'PricingGridRow(product: ${_this.product}, prices: ${_this.prices})';
}


}

/// @nodoc
abstract mixin class $PricingGridRowCopyWith<$Res>  {
  factory $PricingGridRowCopyWith(PricingGridRow value, $Res Function(PricingGridRow) _then) = _$PricingGridRowCopyWithImpl;
@useResult
$Res call({
 ProductListItem product, Map<int, ProductPrice> prices
});


$ProductListItemCopyWith<$Res> get product;

}
/// @nodoc
class _$PricingGridRowCopyWithImpl<$Res>
    implements $PricingGridRowCopyWith<$Res> {
  _$PricingGridRowCopyWithImpl(this._self, this._then);

  final PricingGridRow _self;
  final $Res Function(PricingGridRow) _then;

/// Create a copy of PricingGridRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? product = null,Object? prices = null,}) {
  return _then(PricingGridRow(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductListItem,prices: null == prices ? _self.prices : prices // ignore: cast_nullable_to_non_nullable
as Map<int, ProductPrice>,
  ));
}
/// Create a copy of PricingGridRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductListItemCopyWith<$Res> get product {
  
  return $ProductListItemCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [PricingGridRow].
extension PricingGridRowPatterns on PricingGridRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PricingGridRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PricingGridRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PricingGridRow value)  $default,){
final _that = this;
switch (_that) {
case _PricingGridRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PricingGridRow value)?  $default,){
final _that = this;
switch (_that) {
case _PricingGridRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProductListItem product,  Map<int, ProductPrice> prices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PricingGridRow() when $default != null:
return $default(_that.product,_that.prices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProductListItem product,  Map<int, ProductPrice> prices)  $default,) {final _that = this;
switch (_that) {
case _PricingGridRow():
return $default(_that.product,_that.prices);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProductListItem product,  Map<int, ProductPrice> prices)?  $default,) {final _that = this;
switch (_that) {
case _PricingGridRow() when $default != null:
return $default(_that.product,_that.prices);case _:
  return null;

}
}

}

/// @nodoc


class _PricingGridRow implements PricingGridRow {
  const _PricingGridRow({required this.product, required  Map<int, ProductPrice> prices}): _prices = prices;
  

@override final  ProductListItem product;
 final  Map<int, ProductPrice> _prices;
@override Map<int, ProductPrice> get prices {
  if (_prices is EqualUnmodifiableMapView) return _prices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_prices);
}


/// Create a copy of PricingGridRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PricingGridRowCopyWith<_PricingGridRow> get copyWith => __$PricingGridRowCopyWithImpl<_PricingGridRow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PricingGridRow&&(identical(other.product, product) || other.product == product)&&const DeepCollectionEquality().equals(other.prices, _prices));
}


@override
int get hashCode {
    return Object.hash(runtimeType,product,const DeepCollectionEquality().hash(_prices));
}

@override
String toString() {
    return 'PricingGridRow(product: $product, prices: $prices)';
}


}

/// @nodoc
abstract mixin class _$PricingGridRowCopyWith<$Res> implements $PricingGridRowCopyWith<$Res> {
  factory _$PricingGridRowCopyWith(_PricingGridRow value, $Res Function(_PricingGridRow) _then) = __$PricingGridRowCopyWithImpl;
@override @useResult
$Res call({
 ProductListItem product, Map<int, ProductPrice> prices
});


@override $ProductListItemCopyWith<$Res> get product;

}
/// @nodoc
class __$PricingGridRowCopyWithImpl<$Res>
    implements _$PricingGridRowCopyWith<$Res> {
  __$PricingGridRowCopyWithImpl(this._self, this._then);

  final _PricingGridRow _self;
  final $Res Function(_PricingGridRow) _then;

/// Create a copy of PricingGridRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = null,Object? prices = null,}) {
  return _then(_PricingGridRow(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as ProductListItem,prices: null == prices ? _self._prices : prices // ignore: cast_nullable_to_non_nullable
as Map<int, ProductPrice>,
  ));
}

/// Create a copy of PricingGridRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductListItemCopyWith<$Res> get product {
  
  return $ProductListItemCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}

// dart format on
