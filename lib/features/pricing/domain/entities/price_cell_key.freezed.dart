// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_cell_key.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PriceCellKey {

 int get productId; int get priceListId;
/// Create a copy of PriceCellKey
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceCellKeyCopyWith<PriceCellKey> get copyWith => _$PriceCellKeyCopyWithImpl<PriceCellKey>(this as PriceCellKey, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PriceCellKey;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceCellKey&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.priceListId, _this.priceListId) || other.priceListId == _this.priceListId));
}


@override
int get hashCode {
  final _this = this as PriceCellKey;
  return Object.hash(runtimeType,_this.productId,_this.priceListId);
}

@override
String toString() {
  final _this = this as PriceCellKey;
  return 'PriceCellKey(productId: ${_this.productId}, priceListId: ${_this.priceListId})';
}


}

/// @nodoc
abstract mixin class $PriceCellKeyCopyWith<$Res>  {
  factory $PriceCellKeyCopyWith(PriceCellKey value, $Res Function(PriceCellKey) _then) = _$PriceCellKeyCopyWithImpl;
@useResult
$Res call({
 int productId, int priceListId
});




}
/// @nodoc
class _$PriceCellKeyCopyWithImpl<$Res>
    implements $PriceCellKeyCopyWith<$Res> {
  _$PriceCellKeyCopyWithImpl(this._self, this._then);

  final PriceCellKey _self;
  final $Res Function(PriceCellKey) _then;

/// Create a copy of PriceCellKey
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? priceListId = null,}) {
  return _then(PriceCellKey(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,priceListId: null == priceListId ? _self.priceListId : priceListId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceCellKey].
extension PriceCellKeyPatterns on PriceCellKey {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceCellKey value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceCellKey() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceCellKey value)  $default,){
final _that = this;
switch (_that) {
case _PriceCellKey():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceCellKey value)?  $default,){
final _that = this;
switch (_that) {
case _PriceCellKey() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  int priceListId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceCellKey() when $default != null:
return $default(_that.productId,_that.priceListId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  int priceListId)  $default,) {final _that = this;
switch (_that) {
case _PriceCellKey():
return $default(_that.productId,_that.priceListId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  int priceListId)?  $default,) {final _that = this;
switch (_that) {
case _PriceCellKey() when $default != null:
return $default(_that.productId,_that.priceListId);case _:
  return null;

}
}

}

/// @nodoc


class _PriceCellKey implements PriceCellKey {
  const _PriceCellKey({required this.productId, required this.priceListId});
  

@override final  int productId;
@override final  int priceListId;

/// Create a copy of PriceCellKey
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceCellKeyCopyWith<_PriceCellKey> get copyWith => __$PriceCellKeyCopyWithImpl<_PriceCellKey>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceCellKey&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.priceListId, priceListId) || other.priceListId == priceListId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,priceListId);
}

@override
String toString() {
    return 'PriceCellKey(productId: $productId, priceListId: $priceListId)';
}


}

/// @nodoc
abstract mixin class _$PriceCellKeyCopyWith<$Res> implements $PriceCellKeyCopyWith<$Res> {
  factory _$PriceCellKeyCopyWith(_PriceCellKey value, $Res Function(_PriceCellKey) _then) = __$PriceCellKeyCopyWithImpl;
@override @useResult
$Res call({
 int productId, int priceListId
});




}
/// @nodoc
class __$PriceCellKeyCopyWithImpl<$Res>
    implements _$PriceCellKeyCopyWith<$Res> {
  __$PriceCellKeyCopyWithImpl(this._self, this._then);

  final _PriceCellKey _self;
  final $Res Function(_PriceCellKey) _then;

/// Create a copy of PriceCellKey
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? priceListId = null,}) {
  return _then(_PriceCellKey(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,priceListId: null == priceListId ? _self.priceListId : priceListId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
