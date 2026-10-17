// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddressListItem {

 int get addressId; String get label; AddressType get type; EntityStatus get status;
/// Create a copy of AddressListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressListItemCopyWith<AddressListItem> get copyWith => _$AddressListItemCopyWithImpl<AddressListItem>(this as AddressListItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AddressListItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressListItem&&(identical(other.addressId, _this.addressId) || other.addressId == _this.addressId)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as AddressListItem;
  return Object.hash(runtimeType,_this.addressId,_this.label,_this.type,_this.status);
}

@override
String toString() {
  final _this = this as AddressListItem;
  return 'AddressListItem(addressId: ${_this.addressId}, label: ${_this.label}, type: ${_this.type}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $AddressListItemCopyWith<$Res>  {
  factory $AddressListItemCopyWith(AddressListItem value, $Res Function(AddressListItem) _then) = _$AddressListItemCopyWithImpl;
@useResult
$Res call({
 int addressId, String label, AddressType type, EntityStatus status
});




}
/// @nodoc
class _$AddressListItemCopyWithImpl<$Res>
    implements $AddressListItemCopyWith<$Res> {
  _$AddressListItemCopyWithImpl(this._self, this._then);

  final AddressListItem _self;
  final $Res Function(AddressListItem) _then;

/// Create a copy of AddressListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? addressId = null,Object? label = null,Object? type = null,Object? status = null,}) {
  return _then(AddressListItem(
addressId: null == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AddressType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressListItem].
extension AddressListItemPatterns on AddressListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressListItem value)  $default,){
final _that = this;
switch (_that) {
case _AddressListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressListItem value)?  $default,){
final _that = this;
switch (_that) {
case _AddressListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int addressId,  String label,  AddressType type,  EntityStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressListItem() when $default != null:
return $default(_that.addressId,_that.label,_that.type,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int addressId,  String label,  AddressType type,  EntityStatus status)  $default,) {final _that = this;
switch (_that) {
case _AddressListItem():
return $default(_that.addressId,_that.label,_that.type,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int addressId,  String label,  AddressType type,  EntityStatus status)?  $default,) {final _that = this;
switch (_that) {
case _AddressListItem() when $default != null:
return $default(_that.addressId,_that.label,_that.type,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _AddressListItem implements AddressListItem {
  const _AddressListItem({required this.addressId, required this.label, required this.type, this.status = EntityStatus.active});
  

@override final  int addressId;
@override final  String label;
@override final  AddressType type;
@override@JsonKey() final  EntityStatus status;

/// Create a copy of AddressListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressListItemCopyWith<_AddressListItem> get copyWith => __$AddressListItemCopyWithImpl<_AddressListItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressListItem&&(identical(other.addressId, addressId) || other.addressId == addressId)&&(identical(other.label, label) || other.label == label)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,addressId,label,type,status);
}

@override
String toString() {
    return 'AddressListItem(addressId: $addressId, label: $label, type: $type, status: $status)';
}


}

/// @nodoc
abstract mixin class _$AddressListItemCopyWith<$Res> implements $AddressListItemCopyWith<$Res> {
  factory _$AddressListItemCopyWith(_AddressListItem value, $Res Function(_AddressListItem) _then) = __$AddressListItemCopyWithImpl;
@override @useResult
$Res call({
 int addressId, String label, AddressType type, EntityStatus status
});




}
/// @nodoc
class __$AddressListItemCopyWithImpl<$Res>
    implements _$AddressListItemCopyWith<$Res> {
  __$AddressListItemCopyWithImpl(this._self, this._then);

  final _AddressListItem _self;
  final $Res Function(_AddressListItem) _then;

/// Create a copy of AddressListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? addressId = null,Object? label = null,Object? type = null,Object? status = null,}) {
  return _then(_AddressListItem(
addressId: null == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AddressType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}


}

// dart format on
