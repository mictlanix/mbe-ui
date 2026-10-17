// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_label.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductLabel {

 int get labelId; String get name;
/// Create a copy of ProductLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductLabelCopyWith<ProductLabel> get copyWith => _$ProductLabelCopyWithImpl<ProductLabel>(this as ProductLabel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductLabel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductLabel&&(identical(other.labelId, _this.labelId) || other.labelId == _this.labelId)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as ProductLabel;
  return Object.hash(runtimeType,_this.labelId,_this.name);
}

@override
String toString() {
  final _this = this as ProductLabel;
  return 'ProductLabel(labelId: ${_this.labelId}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $ProductLabelCopyWith<$Res>  {
  factory $ProductLabelCopyWith(ProductLabel value, $Res Function(ProductLabel) _then) = _$ProductLabelCopyWithImpl;
@useResult
$Res call({
 int labelId, String name
});




}
/// @nodoc
class _$ProductLabelCopyWithImpl<$Res>
    implements $ProductLabelCopyWith<$Res> {
  _$ProductLabelCopyWithImpl(this._self, this._then);

  final ProductLabel _self;
  final $Res Function(ProductLabel) _then;

/// Create a copy of ProductLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? labelId = null,Object? name = null,}) {
  return _then(ProductLabel(
labelId: null == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductLabel].
extension ProductLabelPatterns on ProductLabel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductLabel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductLabel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductLabel value)  $default,){
final _that = this;
switch (_that) {
case _ProductLabel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductLabel value)?  $default,){
final _that = this;
switch (_that) {
case _ProductLabel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int labelId,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductLabel() when $default != null:
return $default(_that.labelId,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int labelId,  String name)  $default,) {final _that = this;
switch (_that) {
case _ProductLabel():
return $default(_that.labelId,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int labelId,  String name)?  $default,) {final _that = this;
switch (_that) {
case _ProductLabel() when $default != null:
return $default(_that.labelId,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _ProductLabel implements ProductLabel {
  const _ProductLabel({required this.labelId, required this.name});
  

@override final  int labelId;
@override final  String name;

/// Create a copy of ProductLabel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductLabelCopyWith<_ProductLabel> get copyWith => __$ProductLabelCopyWithImpl<_ProductLabel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductLabel&&(identical(other.labelId, labelId) || other.labelId == labelId)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,labelId,name);
}

@override
String toString() {
    return 'ProductLabel(labelId: $labelId, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ProductLabelCopyWith<$Res> implements $ProductLabelCopyWith<$Res> {
  factory _$ProductLabelCopyWith(_ProductLabel value, $Res Function(_ProductLabel) _then) = __$ProductLabelCopyWithImpl;
@override @useResult
$Res call({
 int labelId, String name
});




}
/// @nodoc
class __$ProductLabelCopyWithImpl<$Res>
    implements _$ProductLabelCopyWith<$Res> {
  __$ProductLabelCopyWithImpl(this._self, this._then);

  final _ProductLabel _self;
  final $Res Function(_ProductLabel) _then;

/// Create a copy of ProductLabel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? labelId = null,Object? name = null,}) {
  return _then(_ProductLabel(
labelId: null == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
