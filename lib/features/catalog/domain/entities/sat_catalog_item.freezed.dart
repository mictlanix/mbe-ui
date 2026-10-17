// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sat_catalog_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SatCatalogItem {

 String get code; String? get description;
/// Create a copy of SatCatalogItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SatCatalogItemCopyWith<SatCatalogItem> get copyWith => _$SatCatalogItemCopyWithImpl<SatCatalogItem>(this as SatCatalogItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SatCatalogItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SatCatalogItem&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.description, _this.description) || other.description == _this.description));
}


@override
int get hashCode {
  final _this = this as SatCatalogItem;
  return Object.hash(runtimeType,_this.code,_this.description);
}

@override
String toString() {
  final _this = this as SatCatalogItem;
  return 'SatCatalogItem(code: ${_this.code}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $SatCatalogItemCopyWith<$Res>  {
  factory $SatCatalogItemCopyWith(SatCatalogItem value, $Res Function(SatCatalogItem) _then) = _$SatCatalogItemCopyWithImpl;
@useResult
$Res call({
 String code, String? description
});




}
/// @nodoc
class _$SatCatalogItemCopyWithImpl<$Res>
    implements $SatCatalogItemCopyWith<$Res> {
  _$SatCatalogItemCopyWithImpl(this._self, this._then);

  final SatCatalogItem _self;
  final $Res Function(SatCatalogItem) _then;

/// Create a copy of SatCatalogItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? description = freezed,}) {
  return _then(SatCatalogItem(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SatCatalogItem].
extension SatCatalogItemPatterns on SatCatalogItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SatCatalogItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SatCatalogItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SatCatalogItem value)  $default,){
final _that = this;
switch (_that) {
case _SatCatalogItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SatCatalogItem value)?  $default,){
final _that = this;
switch (_that) {
case _SatCatalogItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SatCatalogItem() when $default != null:
return $default(_that.code,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String? description)  $default,) {final _that = this;
switch (_that) {
case _SatCatalogItem():
return $default(_that.code,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _SatCatalogItem() when $default != null:
return $default(_that.code,_that.description);case _:
  return null;

}
}

}

/// @nodoc


class _SatCatalogItem implements SatCatalogItem {
  const _SatCatalogItem({required this.code, this.description});
  

@override final  String code;
@override final  String? description;

/// Create a copy of SatCatalogItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SatCatalogItemCopyWith<_SatCatalogItem> get copyWith => __$SatCatalogItemCopyWithImpl<_SatCatalogItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SatCatalogItem&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code,description);
}

@override
String toString() {
    return 'SatCatalogItem(code: $code, description: $description)';
}


}

/// @nodoc
abstract mixin class _$SatCatalogItemCopyWith<$Res> implements $SatCatalogItemCopyWith<$Res> {
  factory _$SatCatalogItemCopyWith(_SatCatalogItem value, $Res Function(_SatCatalogItem) _then) = __$SatCatalogItemCopyWithImpl;
@override @useResult
$Res call({
 String code, String? description
});




}
/// @nodoc
class __$SatCatalogItemCopyWithImpl<$Res>
    implements _$SatCatalogItemCopyWith<$Res> {
  __$SatCatalogItemCopyWithImpl(this._self, this._then);

  final _SatCatalogItem _self;
  final $Res Function(_SatCatalogItem) _then;

/// Create a copy of SatCatalogItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? description = freezed,}) {
  return _then(_SatCatalogItem(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
