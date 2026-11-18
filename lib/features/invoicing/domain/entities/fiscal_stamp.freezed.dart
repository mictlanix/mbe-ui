// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fiscal_stamp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FiscalStamp {

 String get uuid; DateTime? get stamped; String? get satCertificate; String? get providerRfc; bool get simulated;
/// Create a copy of FiscalStamp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FiscalStampCopyWith<FiscalStamp> get copyWith => _$FiscalStampCopyWithImpl<FiscalStamp>(this as FiscalStamp, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FiscalStamp;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FiscalStamp&&(identical(other.uuid, _this.uuid) || other.uuid == _this.uuid)&&(identical(other.stamped, _this.stamped) || other.stamped == _this.stamped)&&(identical(other.satCertificate, _this.satCertificate) || other.satCertificate == _this.satCertificate)&&(identical(other.providerRfc, _this.providerRfc) || other.providerRfc == _this.providerRfc)&&(identical(other.simulated, _this.simulated) || other.simulated == _this.simulated));
}


@override
int get hashCode {
  final _this = this as FiscalStamp;
  return Object.hash(runtimeType,_this.uuid,_this.stamped,_this.satCertificate,_this.providerRfc,_this.simulated);
}

@override
String toString() {
  final _this = this as FiscalStamp;
  return 'FiscalStamp(uuid: ${_this.uuid}, stamped: ${_this.stamped}, satCertificate: ${_this.satCertificate}, providerRfc: ${_this.providerRfc}, simulated: ${_this.simulated})';
}


}

/// @nodoc
abstract mixin class $FiscalStampCopyWith<$Res>  {
  factory $FiscalStampCopyWith(FiscalStamp value, $Res Function(FiscalStamp) _then) = _$FiscalStampCopyWithImpl;
@useResult
$Res call({
 String uuid, DateTime? stamped, String? satCertificate, String? providerRfc, bool simulated
});




}
/// @nodoc
class _$FiscalStampCopyWithImpl<$Res>
    implements $FiscalStampCopyWith<$Res> {
  _$FiscalStampCopyWithImpl(this._self, this._then);

  final FiscalStamp _self;
  final $Res Function(FiscalStamp) _then;

/// Create a copy of FiscalStamp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? stamped = freezed,Object? satCertificate = freezed,Object? providerRfc = freezed,Object? simulated = null,}) {
  return _then(FiscalStamp(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,stamped: freezed == stamped ? _self.stamped : stamped // ignore: cast_nullable_to_non_nullable
as DateTime?,satCertificate: freezed == satCertificate ? _self.satCertificate : satCertificate // ignore: cast_nullable_to_non_nullable
as String?,providerRfc: freezed == providerRfc ? _self.providerRfc : providerRfc // ignore: cast_nullable_to_non_nullable
as String?,simulated: null == simulated ? _self.simulated : simulated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FiscalStamp].
extension FiscalStampPatterns on FiscalStamp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FiscalStamp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FiscalStamp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FiscalStamp value)  $default,){
final _that = this;
switch (_that) {
case _FiscalStamp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FiscalStamp value)?  $default,){
final _that = this;
switch (_that) {
case _FiscalStamp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  DateTime? stamped,  String? satCertificate,  String? providerRfc,  bool simulated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FiscalStamp() when $default != null:
return $default(_that.uuid,_that.stamped,_that.satCertificate,_that.providerRfc,_that.simulated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  DateTime? stamped,  String? satCertificate,  String? providerRfc,  bool simulated)  $default,) {final _that = this;
switch (_that) {
case _FiscalStamp():
return $default(_that.uuid,_that.stamped,_that.satCertificate,_that.providerRfc,_that.simulated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  DateTime? stamped,  String? satCertificate,  String? providerRfc,  bool simulated)?  $default,) {final _that = this;
switch (_that) {
case _FiscalStamp() when $default != null:
return $default(_that.uuid,_that.stamped,_that.satCertificate,_that.providerRfc,_that.simulated);case _:
  return null;

}
}

}

/// @nodoc


class _FiscalStamp implements FiscalStamp {
  const _FiscalStamp({required this.uuid, this.stamped, this.satCertificate, this.providerRfc, this.simulated = false});
  

@override final  String uuid;
@override final  DateTime? stamped;
@override final  String? satCertificate;
@override final  String? providerRfc;
@override@JsonKey() final  bool simulated;

/// Create a copy of FiscalStamp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FiscalStampCopyWith<_FiscalStamp> get copyWith => __$FiscalStampCopyWithImpl<_FiscalStamp>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FiscalStamp&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.stamped, stamped) || other.stamped == stamped)&&(identical(other.satCertificate, satCertificate) || other.satCertificate == satCertificate)&&(identical(other.providerRfc, providerRfc) || other.providerRfc == providerRfc)&&(identical(other.simulated, simulated) || other.simulated == simulated));
}


@override
int get hashCode {
    return Object.hash(runtimeType,uuid,stamped,satCertificate,providerRfc,simulated);
}

@override
String toString() {
    return 'FiscalStamp(uuid: $uuid, stamped: $stamped, satCertificate: $satCertificate, providerRfc: $providerRfc, simulated: $simulated)';
}


}

/// @nodoc
abstract mixin class _$FiscalStampCopyWith<$Res> implements $FiscalStampCopyWith<$Res> {
  factory _$FiscalStampCopyWith(_FiscalStamp value, $Res Function(_FiscalStamp) _then) = __$FiscalStampCopyWithImpl;
@override @useResult
$Res call({
 String uuid, DateTime? stamped, String? satCertificate, String? providerRfc, bool simulated
});




}
/// @nodoc
class __$FiscalStampCopyWithImpl<$Res>
    implements _$FiscalStampCopyWith<$Res> {
  __$FiscalStampCopyWithImpl(this._self, this._then);

  final _FiscalStamp _self;
  final $Res Function(_FiscalStamp) _then;

/// Create a copy of FiscalStamp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? stamped = freezed,Object? satCertificate = freezed,Object? providerRfc = freezed,Object? simulated = null,}) {
  return _then(_FiscalStamp(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,stamped: freezed == stamped ? _self.stamped : stamped // ignore: cast_nullable_to_non_nullable
as DateTime?,satCertificate: freezed == satCertificate ? _self.satCertificate : satCertificate // ignore: cast_nullable_to_non_nullable
as String?,providerRfc: freezed == providerRfc ? _self.providerRfc : providerRfc // ignore: cast_nullable_to_non_nullable
as String?,simulated: null == simulated ? _self.simulated : simulated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
