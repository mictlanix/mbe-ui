// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'privilege.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Privilege {

 SystemObject get systemObject; int get rawValue;
/// Create a copy of Privilege
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrivilegeCopyWith<Privilege> get copyWith => _$PrivilegeCopyWithImpl<Privilege>(this as Privilege, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Privilege;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Privilege&&(identical(other.systemObject, _this.systemObject) || other.systemObject == _this.systemObject)&&(identical(other.rawValue, _this.rawValue) || other.rawValue == _this.rawValue));
}


@override
int get hashCode {
  final _this = this as Privilege;
  return Object.hash(runtimeType,_this.systemObject,_this.rawValue);
}

@override
String toString() {
  final _this = this as Privilege;
  return 'Privilege(systemObject: ${_this.systemObject}, rawValue: ${_this.rawValue})';
}


}

/// @nodoc
abstract mixin class $PrivilegeCopyWith<$Res>  {
  factory $PrivilegeCopyWith(Privilege value, $Res Function(Privilege) _then) = _$PrivilegeCopyWithImpl;
@useResult
$Res call({
 SystemObject systemObject, int rawValue
});




}
/// @nodoc
class _$PrivilegeCopyWithImpl<$Res>
    implements $PrivilegeCopyWith<$Res> {
  _$PrivilegeCopyWithImpl(this._self, this._then);

  final Privilege _self;
  final $Res Function(Privilege) _then;

/// Create a copy of Privilege
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? systemObject = null,Object? rawValue = null,}) {
  return _then(Privilege(
systemObject: null == systemObject ? _self.systemObject : systemObject // ignore: cast_nullable_to_non_nullable
as SystemObject,rawValue: null == rawValue ? _self.rawValue : rawValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Privilege].
extension PrivilegePatterns on Privilege {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Privilege value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Privilege() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Privilege value)  $default,){
final _that = this;
switch (_that) {
case _Privilege():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Privilege value)?  $default,){
final _that = this;
switch (_that) {
case _Privilege() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SystemObject systemObject,  int rawValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Privilege() when $default != null:
return $default(_that.systemObject,_that.rawValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SystemObject systemObject,  int rawValue)  $default,) {final _that = this;
switch (_that) {
case _Privilege():
return $default(_that.systemObject,_that.rawValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SystemObject systemObject,  int rawValue)?  $default,) {final _that = this;
switch (_that) {
case _Privilege() when $default != null:
return $default(_that.systemObject,_that.rawValue);case _:
  return null;

}
}

}

/// @nodoc


class _Privilege extends Privilege {
  const _Privilege({required this.systemObject, required this.rawValue}): assert(rawValue >= 0 && rawValue <= 15, 'rawValue must be in 0..15'),super._();
  

@override final  SystemObject systemObject;
@override final  int rawValue;

/// Create a copy of Privilege
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrivilegeCopyWith<_Privilege> get copyWith => __$PrivilegeCopyWithImpl<_Privilege>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Privilege&&(identical(other.systemObject, systemObject) || other.systemObject == systemObject)&&(identical(other.rawValue, rawValue) || other.rawValue == rawValue));
}


@override
int get hashCode {
    return Object.hash(runtimeType,systemObject,rawValue);
}

@override
String toString() {
    return 'Privilege(systemObject: $systemObject, rawValue: $rawValue)';
}


}

/// @nodoc
abstract mixin class _$PrivilegeCopyWith<$Res> implements $PrivilegeCopyWith<$Res> {
  factory _$PrivilegeCopyWith(_Privilege value, $Res Function(_Privilege) _then) = __$PrivilegeCopyWithImpl;
@override @useResult
$Res call({
 SystemObject systemObject, int rawValue
});




}
/// @nodoc
class __$PrivilegeCopyWithImpl<$Res>
    implements _$PrivilegeCopyWith<$Res> {
  __$PrivilegeCopyWithImpl(this._self, this._then);

  final _Privilege _self;
  final $Res Function(_Privilege) _then;

/// Create a copy of Privilege
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? systemObject = null,Object? rawValue = null,}) {
  return _then(_Privilege(
systemObject: null == systemObject ? _self.systemObject : systemObject // ignore: cast_nullable_to_non_nullable
as SystemObject,rawValue: null == rawValue ? _self.rawValue : rawValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
