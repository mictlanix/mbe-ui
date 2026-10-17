// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_label_facet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductLabelFacet {

 int get labelId; int get count;
/// Create a copy of ProductLabelFacet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductLabelFacetCopyWith<ProductLabelFacet> get copyWith => _$ProductLabelFacetCopyWithImpl<ProductLabelFacet>(this as ProductLabelFacet, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductLabelFacet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductLabelFacet&&(identical(other.labelId, _this.labelId) || other.labelId == _this.labelId)&&(identical(other.count, _this.count) || other.count == _this.count));
}


@override
int get hashCode {
  final _this = this as ProductLabelFacet;
  return Object.hash(runtimeType,_this.labelId,_this.count);
}

@override
String toString() {
  final _this = this as ProductLabelFacet;
  return 'ProductLabelFacet(labelId: ${_this.labelId}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $ProductLabelFacetCopyWith<$Res>  {
  factory $ProductLabelFacetCopyWith(ProductLabelFacet value, $Res Function(ProductLabelFacet) _then) = _$ProductLabelFacetCopyWithImpl;
@useResult
$Res call({
 int labelId, int count
});




}
/// @nodoc
class _$ProductLabelFacetCopyWithImpl<$Res>
    implements $ProductLabelFacetCopyWith<$Res> {
  _$ProductLabelFacetCopyWithImpl(this._self, this._then);

  final ProductLabelFacet _self;
  final $Res Function(ProductLabelFacet) _then;

/// Create a copy of ProductLabelFacet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? labelId = null,Object? count = null,}) {
  return _then(ProductLabelFacet(
labelId: null == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductLabelFacet].
extension ProductLabelFacetPatterns on ProductLabelFacet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductLabelFacet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductLabelFacet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductLabelFacet value)  $default,){
final _that = this;
switch (_that) {
case _ProductLabelFacet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductLabelFacet value)?  $default,){
final _that = this;
switch (_that) {
case _ProductLabelFacet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int labelId,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductLabelFacet() when $default != null:
return $default(_that.labelId,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int labelId,  int count)  $default,) {final _that = this;
switch (_that) {
case _ProductLabelFacet():
return $default(_that.labelId,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int labelId,  int count)?  $default,) {final _that = this;
switch (_that) {
case _ProductLabelFacet() when $default != null:
return $default(_that.labelId,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class _ProductLabelFacet implements ProductLabelFacet {
  const _ProductLabelFacet({required this.labelId, required this.count});
  

@override final  int labelId;
@override final  int count;

/// Create a copy of ProductLabelFacet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductLabelFacetCopyWith<_ProductLabelFacet> get copyWith => __$ProductLabelFacetCopyWithImpl<_ProductLabelFacet>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductLabelFacet&&(identical(other.labelId, labelId) || other.labelId == labelId)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode {
    return Object.hash(runtimeType,labelId,count);
}

@override
String toString() {
    return 'ProductLabelFacet(labelId: $labelId, count: $count)';
}


}

/// @nodoc
abstract mixin class _$ProductLabelFacetCopyWith<$Res> implements $ProductLabelFacetCopyWith<$Res> {
  factory _$ProductLabelFacetCopyWith(_ProductLabelFacet value, $Res Function(_ProductLabelFacet) _then) = __$ProductLabelFacetCopyWithImpl;
@override @useResult
$Res call({
 int labelId, int count
});




}
/// @nodoc
class __$ProductLabelFacetCopyWithImpl<$Res>
    implements _$ProductLabelFacetCopyWith<$Res> {
  __$ProductLabelFacetCopyWithImpl(this._self, this._then);

  final _ProductLabelFacet _self;
  final $Res Function(_ProductLabelFacet) _then;

/// Create a copy of ProductLabelFacet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? labelId = null,Object? count = null,}) {
  return _then(_ProductLabelFacet(
labelId: null == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
