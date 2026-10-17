// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facility_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FacilityListItem {

 int get facilityId; String get code; String get name; FacilityType get type; EntityStatus get status;
/// Create a copy of FacilityListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilityListItemCopyWith<FacilityListItem> get copyWith => _$FacilityListItemCopyWithImpl<FacilityListItem>(this as FacilityListItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FacilityListItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FacilityListItem&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as FacilityListItem;
  return Object.hash(runtimeType,_this.facilityId,_this.code,_this.name,_this.type,_this.status);
}

@override
String toString() {
  final _this = this as FacilityListItem;
  return 'FacilityListItem(facilityId: ${_this.facilityId}, code: ${_this.code}, name: ${_this.name}, type: ${_this.type}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $FacilityListItemCopyWith<$Res>  {
  factory $FacilityListItemCopyWith(FacilityListItem value, $Res Function(FacilityListItem) _then) = _$FacilityListItemCopyWithImpl;
@useResult
$Res call({
 int facilityId, String code, String name, FacilityType type, EntityStatus status
});




}
/// @nodoc
class _$FacilityListItemCopyWithImpl<$Res>
    implements $FacilityListItemCopyWith<$Res> {
  _$FacilityListItemCopyWithImpl(this._self, this._then);

  final FacilityListItem _self;
  final $Res Function(FacilityListItem) _then;

/// Create a copy of FacilityListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? facilityId = null,Object? code = null,Object? name = null,Object? type = null,Object? status = null,}) {
  return _then(FacilityListItem(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FacilityType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [FacilityListItem].
extension FacilityListItemPatterns on FacilityListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FacilityListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FacilityListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FacilityListItem value)  $default,){
final _that = this;
switch (_that) {
case _FacilityListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FacilityListItem value)?  $default,){
final _that = this;
switch (_that) {
case _FacilityListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int facilityId,  String code,  String name,  FacilityType type,  EntityStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FacilityListItem() when $default != null:
return $default(_that.facilityId,_that.code,_that.name,_that.type,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int facilityId,  String code,  String name,  FacilityType type,  EntityStatus status)  $default,) {final _that = this;
switch (_that) {
case _FacilityListItem():
return $default(_that.facilityId,_that.code,_that.name,_that.type,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int facilityId,  String code,  String name,  FacilityType type,  EntityStatus status)?  $default,) {final _that = this;
switch (_that) {
case _FacilityListItem() when $default != null:
return $default(_that.facilityId,_that.code,_that.name,_that.type,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _FacilityListItem implements FacilityListItem {
  const _FacilityListItem({required this.facilityId, required this.code, required this.name, required this.type, required this.status});
  

@override final  int facilityId;
@override final  String code;
@override final  String name;
@override final  FacilityType type;
@override final  EntityStatus status;

/// Create a copy of FacilityListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilityListItemCopyWith<_FacilityListItem> get copyWith => __$FacilityListItemCopyWithImpl<_FacilityListItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FacilityListItem&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,facilityId,code,name,type,status);
}

@override
String toString() {
    return 'FacilityListItem(facilityId: $facilityId, code: $code, name: $name, type: $type, status: $status)';
}


}

/// @nodoc
abstract mixin class _$FacilityListItemCopyWith<$Res> implements $FacilityListItemCopyWith<$Res> {
  factory _$FacilityListItemCopyWith(_FacilityListItem value, $Res Function(_FacilityListItem) _then) = __$FacilityListItemCopyWithImpl;
@override @useResult
$Res call({
 int facilityId, String code, String name, FacilityType type, EntityStatus status
});




}
/// @nodoc
class __$FacilityListItemCopyWithImpl<$Res>
    implements _$FacilityListItemCopyWith<$Res> {
  __$FacilityListItemCopyWithImpl(this._self, this._then);

  final _FacilityListItem _self;
  final $Res Function(_FacilityListItem) _then;

/// Create a copy of FacilityListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? facilityId = null,Object? code = null,Object? name = null,Object? type = null,Object? status = null,}) {
  return _then(_FacilityListItem(
facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FacilityType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}


}

// dart format on
