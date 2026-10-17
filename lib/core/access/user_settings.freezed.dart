// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserSettings {

 int? get facilityId; String? get facilityCode; String? get facilityName; int? get pointSaleId; String? get pointSaleCode; String? get pointSaleName; int? get cashDrawerId; String? get cashDrawerCode; String? get cashDrawerName;
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<UserSettings> get copyWith => _$UserSettingsCopyWithImpl<UserSettings>(this as UserSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettings&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.facilityCode, _this.facilityCode) || other.facilityCode == _this.facilityCode)&&(identical(other.facilityName, _this.facilityName) || other.facilityName == _this.facilityName)&&(identical(other.pointSaleId, _this.pointSaleId) || other.pointSaleId == _this.pointSaleId)&&(identical(other.pointSaleCode, _this.pointSaleCode) || other.pointSaleCode == _this.pointSaleCode)&&(identical(other.pointSaleName, _this.pointSaleName) || other.pointSaleName == _this.pointSaleName)&&(identical(other.cashDrawerId, _this.cashDrawerId) || other.cashDrawerId == _this.cashDrawerId)&&(identical(other.cashDrawerCode, _this.cashDrawerCode) || other.cashDrawerCode == _this.cashDrawerCode)&&(identical(other.cashDrawerName, _this.cashDrawerName) || other.cashDrawerName == _this.cashDrawerName));
}


@override
int get hashCode {
  final _this = this as UserSettings;
  return Object.hash(runtimeType,_this.facilityId,_this.facilityCode,_this.facilityName,_this.pointSaleId,_this.pointSaleCode,_this.pointSaleName,_this.cashDrawerId,_this.cashDrawerCode,_this.cashDrawerName);
}

@override
String toString() {
  final _this = this as UserSettings;
  return 'UserSettings(facilityId: ${_this.facilityId}, facilityCode: ${_this.facilityCode}, facilityName: ${_this.facilityName}, pointSaleId: ${_this.pointSaleId}, pointSaleCode: ${_this.pointSaleCode}, pointSaleName: ${_this.pointSaleName}, cashDrawerId: ${_this.cashDrawerId}, cashDrawerCode: ${_this.cashDrawerCode}, cashDrawerName: ${_this.cashDrawerName})';
}


}

/// @nodoc
abstract mixin class $UserSettingsCopyWith<$Res>  {
  factory $UserSettingsCopyWith(UserSettings value, $Res Function(UserSettings) _then) = _$UserSettingsCopyWithImpl;
@useResult
$Res call({
 int? facilityId, String? facilityCode, String? facilityName, int? pointSaleId, String? pointSaleCode, String? pointSaleName, int? cashDrawerId, String? cashDrawerCode, String? cashDrawerName
});




}
/// @nodoc
class _$UserSettingsCopyWithImpl<$Res>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._self, this._then);

  final UserSettings _self;
  final $Res Function(UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? facilityId = freezed,Object? facilityCode = freezed,Object? facilityName = freezed,Object? pointSaleId = freezed,Object? pointSaleCode = freezed,Object? pointSaleName = freezed,Object? cashDrawerId = freezed,Object? cashDrawerCode = freezed,Object? cashDrawerName = freezed,}) {
  return _then(UserSettings(
facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,facilityCode: freezed == facilityCode ? _self.facilityCode : facilityCode // ignore: cast_nullable_to_non_nullable
as String?,facilityName: freezed == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String?,pointSaleId: freezed == pointSaleId ? _self.pointSaleId : pointSaleId // ignore: cast_nullable_to_non_nullable
as int?,pointSaleCode: freezed == pointSaleCode ? _self.pointSaleCode : pointSaleCode // ignore: cast_nullable_to_non_nullable
as String?,pointSaleName: freezed == pointSaleName ? _self.pointSaleName : pointSaleName // ignore: cast_nullable_to_non_nullable
as String?,cashDrawerId: freezed == cashDrawerId ? _self.cashDrawerId : cashDrawerId // ignore: cast_nullable_to_non_nullable
as int?,cashDrawerCode: freezed == cashDrawerCode ? _self.cashDrawerCode : cashDrawerCode // ignore: cast_nullable_to_non_nullable
as String?,cashDrawerName: freezed == cashDrawerName ? _self.cashDrawerName : cashDrawerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserSettings].
extension UserSettingsPatterns on UserSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSettings value)  $default,){
final _that = this;
switch (_that) {
case _UserSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSettings value)?  $default,){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? facilityId,  String? facilityCode,  String? facilityName,  int? pointSaleId,  String? pointSaleCode,  String? pointSaleName,  int? cashDrawerId,  String? cashDrawerCode,  String? cashDrawerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.facilityId,_that.facilityCode,_that.facilityName,_that.pointSaleId,_that.pointSaleCode,_that.pointSaleName,_that.cashDrawerId,_that.cashDrawerCode,_that.cashDrawerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? facilityId,  String? facilityCode,  String? facilityName,  int? pointSaleId,  String? pointSaleCode,  String? pointSaleName,  int? cashDrawerId,  String? cashDrawerCode,  String? cashDrawerName)  $default,) {final _that = this;
switch (_that) {
case _UserSettings():
return $default(_that.facilityId,_that.facilityCode,_that.facilityName,_that.pointSaleId,_that.pointSaleCode,_that.pointSaleName,_that.cashDrawerId,_that.cashDrawerCode,_that.cashDrawerName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? facilityId,  String? facilityCode,  String? facilityName,  int? pointSaleId,  String? pointSaleCode,  String? pointSaleName,  int? cashDrawerId,  String? cashDrawerCode,  String? cashDrawerName)?  $default,) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.facilityId,_that.facilityCode,_that.facilityName,_that.pointSaleId,_that.pointSaleCode,_that.pointSaleName,_that.cashDrawerId,_that.cashDrawerCode,_that.cashDrawerName);case _:
  return null;

}
}

}

/// @nodoc


class _UserSettings extends UserSettings {
  const _UserSettings({this.facilityId, this.facilityCode, this.facilityName, this.pointSaleId, this.pointSaleCode, this.pointSaleName, this.cashDrawerId, this.cashDrawerCode, this.cashDrawerName}): super._();
  

@override final  int? facilityId;
@override final  String? facilityCode;
@override final  String? facilityName;
@override final  int? pointSaleId;
@override final  String? pointSaleCode;
@override final  String? pointSaleName;
@override final  int? cashDrawerId;
@override final  String? cashDrawerCode;
@override final  String? cashDrawerName;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSettingsCopyWith<_UserSettings> get copyWith => __$UserSettingsCopyWithImpl<_UserSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettings&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.facilityCode, facilityCode) || other.facilityCode == facilityCode)&&(identical(other.facilityName, facilityName) || other.facilityName == facilityName)&&(identical(other.pointSaleId, pointSaleId) || other.pointSaleId == pointSaleId)&&(identical(other.pointSaleCode, pointSaleCode) || other.pointSaleCode == pointSaleCode)&&(identical(other.pointSaleName, pointSaleName) || other.pointSaleName == pointSaleName)&&(identical(other.cashDrawerId, cashDrawerId) || other.cashDrawerId == cashDrawerId)&&(identical(other.cashDrawerCode, cashDrawerCode) || other.cashDrawerCode == cashDrawerCode)&&(identical(other.cashDrawerName, cashDrawerName) || other.cashDrawerName == cashDrawerName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,facilityId,facilityCode,facilityName,pointSaleId,pointSaleCode,pointSaleName,cashDrawerId,cashDrawerCode,cashDrawerName);
}

@override
String toString() {
    return 'UserSettings(facilityId: $facilityId, facilityCode: $facilityCode, facilityName: $facilityName, pointSaleId: $pointSaleId, pointSaleCode: $pointSaleCode, pointSaleName: $pointSaleName, cashDrawerId: $cashDrawerId, cashDrawerCode: $cashDrawerCode, cashDrawerName: $cashDrawerName)';
}


}

/// @nodoc
abstract mixin class _$UserSettingsCopyWith<$Res> implements $UserSettingsCopyWith<$Res> {
  factory _$UserSettingsCopyWith(_UserSettings value, $Res Function(_UserSettings) _then) = __$UserSettingsCopyWithImpl;
@override @useResult
$Res call({
 int? facilityId, String? facilityCode, String? facilityName, int? pointSaleId, String? pointSaleCode, String? pointSaleName, int? cashDrawerId, String? cashDrawerCode, String? cashDrawerName
});




}
/// @nodoc
class __$UserSettingsCopyWithImpl<$Res>
    implements _$UserSettingsCopyWith<$Res> {
  __$UserSettingsCopyWithImpl(this._self, this._then);

  final _UserSettings _self;
  final $Res Function(_UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? facilityId = freezed,Object? facilityCode = freezed,Object? facilityName = freezed,Object? pointSaleId = freezed,Object? pointSaleCode = freezed,Object? pointSaleName = freezed,Object? cashDrawerId = freezed,Object? cashDrawerCode = freezed,Object? cashDrawerName = freezed,}) {
  return _then(_UserSettings(
facilityId: freezed == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as int?,facilityCode: freezed == facilityCode ? _self.facilityCode : facilityCode // ignore: cast_nullable_to_non_nullable
as String?,facilityName: freezed == facilityName ? _self.facilityName : facilityName // ignore: cast_nullable_to_non_nullable
as String?,pointSaleId: freezed == pointSaleId ? _self.pointSaleId : pointSaleId // ignore: cast_nullable_to_non_nullable
as int?,pointSaleCode: freezed == pointSaleCode ? _self.pointSaleCode : pointSaleCode // ignore: cast_nullable_to_non_nullable
as String?,pointSaleName: freezed == pointSaleName ? _self.pointSaleName : pointSaleName // ignore: cast_nullable_to_non_nullable
as String?,cashDrawerId: freezed == cashDrawerId ? _self.cashDrawerId : cashDrawerId // ignore: cast_nullable_to_non_nullable
as int?,cashDrawerCode: freezed == cashDrawerCode ? _self.cashDrawerCode : cashDrawerCode // ignore: cast_nullable_to_non_nullable
as String?,cashDrawerName: freezed == cashDrawerName ? _self.cashDrawerName : cashDrawerName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
