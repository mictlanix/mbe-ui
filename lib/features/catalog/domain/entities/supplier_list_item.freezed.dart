// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supplier_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SupplierListItem {

 int get supplierId; String get code; String get name;
/// Create a copy of SupplierListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplierListItemCopyWith<SupplierListItem> get copyWith => _$SupplierListItemCopyWithImpl<SupplierListItem>(this as SupplierListItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SupplierListItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupplierListItem&&(identical(other.supplierId, _this.supplierId) || other.supplierId == _this.supplierId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as SupplierListItem;
  return Object.hash(runtimeType,_this.supplierId,_this.code,_this.name);
}

@override
String toString() {
  final _this = this as SupplierListItem;
  return 'SupplierListItem(supplierId: ${_this.supplierId}, code: ${_this.code}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $SupplierListItemCopyWith<$Res>  {
  factory $SupplierListItemCopyWith(SupplierListItem value, $Res Function(SupplierListItem) _then) = _$SupplierListItemCopyWithImpl;
@useResult
$Res call({
 int supplierId, String code, String name
});




}
/// @nodoc
class _$SupplierListItemCopyWithImpl<$Res>
    implements $SupplierListItemCopyWith<$Res> {
  _$SupplierListItemCopyWithImpl(this._self, this._then);

  final SupplierListItem _self;
  final $Res Function(SupplierListItem) _then;

/// Create a copy of SupplierListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? supplierId = null,Object? code = null,Object? name = null,}) {
  return _then(SupplierListItem(
supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SupplierListItem].
extension SupplierListItemPatterns on SupplierListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupplierListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupplierListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupplierListItem value)  $default,){
final _that = this;
switch (_that) {
case _SupplierListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupplierListItem value)?  $default,){
final _that = this;
switch (_that) {
case _SupplierListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int supplierId,  String code,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupplierListItem() when $default != null:
return $default(_that.supplierId,_that.code,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int supplierId,  String code,  String name)  $default,) {final _that = this;
switch (_that) {
case _SupplierListItem():
return $default(_that.supplierId,_that.code,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int supplierId,  String code,  String name)?  $default,) {final _that = this;
switch (_that) {
case _SupplierListItem() when $default != null:
return $default(_that.supplierId,_that.code,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _SupplierListItem implements SupplierListItem {
  const _SupplierListItem({required this.supplierId, required this.code, required this.name});
  

@override final  int supplierId;
@override final  String code;
@override final  String name;

/// Create a copy of SupplierListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupplierListItemCopyWith<_SupplierListItem> get copyWith => __$SupplierListItemCopyWithImpl<_SupplierListItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupplierListItem&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,supplierId,code,name);
}

@override
String toString() {
    return 'SupplierListItem(supplierId: $supplierId, code: $code, name: $name)';
}


}

/// @nodoc
abstract mixin class _$SupplierListItemCopyWith<$Res> implements $SupplierListItemCopyWith<$Res> {
  factory _$SupplierListItemCopyWith(_SupplierListItem value, $Res Function(_SupplierListItem) _then) = __$SupplierListItemCopyWithImpl;
@override @useResult
$Res call({
 int supplierId, String code, String name
});




}
/// @nodoc
class __$SupplierListItemCopyWithImpl<$Res>
    implements _$SupplierListItemCopyWith<$Res> {
  __$SupplierListItemCopyWithImpl(this._self, this._then);

  final _SupplierListItem _self;
  final $Res Function(_SupplierListItem) _then;

/// Create a copy of SupplierListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? supplierId = null,Object? code = null,Object? name = null,}) {
  return _then(_SupplierListItem(
supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
