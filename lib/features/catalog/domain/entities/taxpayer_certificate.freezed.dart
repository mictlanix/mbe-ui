// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_certificate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaxpayerCertificate {

 String get taxpayerCertificateId; String get taxpayer; DateTime get validFrom; DateTime get validTo; EntityStatus get status;
/// Create a copy of TaxpayerCertificate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxpayerCertificateCopyWith<TaxpayerCertificate> get copyWith => _$TaxpayerCertificateCopyWithImpl<TaxpayerCertificate>(this as TaxpayerCertificate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaxpayerCertificate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxpayerCertificate&&(identical(other.taxpayerCertificateId, _this.taxpayerCertificateId) || other.taxpayerCertificateId == _this.taxpayerCertificateId)&&(identical(other.taxpayer, _this.taxpayer) || other.taxpayer == _this.taxpayer)&&(identical(other.validFrom, _this.validFrom) || other.validFrom == _this.validFrom)&&(identical(other.validTo, _this.validTo) || other.validTo == _this.validTo)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as TaxpayerCertificate;
  return Object.hash(runtimeType,_this.taxpayerCertificateId,_this.taxpayer,_this.validFrom,_this.validTo,_this.status);
}

@override
String toString() {
  final _this = this as TaxpayerCertificate;
  return 'TaxpayerCertificate(taxpayerCertificateId: ${_this.taxpayerCertificateId}, taxpayer: ${_this.taxpayer}, validFrom: ${_this.validFrom}, validTo: ${_this.validTo}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $TaxpayerCertificateCopyWith<$Res>  {
  factory $TaxpayerCertificateCopyWith(TaxpayerCertificate value, $Res Function(TaxpayerCertificate) _then) = _$TaxpayerCertificateCopyWithImpl;
@useResult
$Res call({
 String taxpayerCertificateId, String taxpayer, DateTime validFrom, DateTime validTo, EntityStatus status
});




}
/// @nodoc
class _$TaxpayerCertificateCopyWithImpl<$Res>
    implements $TaxpayerCertificateCopyWith<$Res> {
  _$TaxpayerCertificateCopyWithImpl(this._self, this._then);

  final TaxpayerCertificate _self;
  final $Res Function(TaxpayerCertificate) _then;

/// Create a copy of TaxpayerCertificate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taxpayerCertificateId = null,Object? taxpayer = null,Object? validFrom = null,Object? validTo = null,Object? status = null,}) {
  return _then(TaxpayerCertificate(
taxpayerCertificateId: null == taxpayerCertificateId ? _self.taxpayerCertificateId : taxpayerCertificateId // ignore: cast_nullable_to_non_nullable
as String,taxpayer: null == taxpayer ? _self.taxpayer : taxpayer // ignore: cast_nullable_to_non_nullable
as String,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,validTo: null == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [TaxpayerCertificate].
extension TaxpayerCertificatePatterns on TaxpayerCertificate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxpayerCertificate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxpayerCertificate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxpayerCertificate value)  $default,){
final _that = this;
switch (_that) {
case _TaxpayerCertificate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxpayerCertificate value)?  $default,){
final _that = this;
switch (_that) {
case _TaxpayerCertificate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taxpayerCertificateId,  String taxpayer,  DateTime validFrom,  DateTime validTo,  EntityStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxpayerCertificate() when $default != null:
return $default(_that.taxpayerCertificateId,_that.taxpayer,_that.validFrom,_that.validTo,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taxpayerCertificateId,  String taxpayer,  DateTime validFrom,  DateTime validTo,  EntityStatus status)  $default,) {final _that = this;
switch (_that) {
case _TaxpayerCertificate():
return $default(_that.taxpayerCertificateId,_that.taxpayer,_that.validFrom,_that.validTo,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taxpayerCertificateId,  String taxpayer,  DateTime validFrom,  DateTime validTo,  EntityStatus status)?  $default,) {final _that = this;
switch (_that) {
case _TaxpayerCertificate() when $default != null:
return $default(_that.taxpayerCertificateId,_that.taxpayer,_that.validFrom,_that.validTo,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _TaxpayerCertificate implements TaxpayerCertificate {
  const _TaxpayerCertificate({required this.taxpayerCertificateId, required this.taxpayer, required this.validFrom, required this.validTo, required this.status});
  

@override final  String taxpayerCertificateId;
@override final  String taxpayer;
@override final  DateTime validFrom;
@override final  DateTime validTo;
@override final  EntityStatus status;

/// Create a copy of TaxpayerCertificate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxpayerCertificateCopyWith<_TaxpayerCertificate> get copyWith => __$TaxpayerCertificateCopyWithImpl<_TaxpayerCertificate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxpayerCertificate&&(identical(other.taxpayerCertificateId, taxpayerCertificateId) || other.taxpayerCertificateId == taxpayerCertificateId)&&(identical(other.taxpayer, taxpayer) || other.taxpayer == taxpayer)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.validTo, validTo) || other.validTo == validTo)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,taxpayerCertificateId,taxpayer,validFrom,validTo,status);
}

@override
String toString() {
    return 'TaxpayerCertificate(taxpayerCertificateId: $taxpayerCertificateId, taxpayer: $taxpayer, validFrom: $validFrom, validTo: $validTo, status: $status)';
}


}

/// @nodoc
abstract mixin class _$TaxpayerCertificateCopyWith<$Res> implements $TaxpayerCertificateCopyWith<$Res> {
  factory _$TaxpayerCertificateCopyWith(_TaxpayerCertificate value, $Res Function(_TaxpayerCertificate) _then) = __$TaxpayerCertificateCopyWithImpl;
@override @useResult
$Res call({
 String taxpayerCertificateId, String taxpayer, DateTime validFrom, DateTime validTo, EntityStatus status
});




}
/// @nodoc
class __$TaxpayerCertificateCopyWithImpl<$Res>
    implements _$TaxpayerCertificateCopyWith<$Res> {
  __$TaxpayerCertificateCopyWithImpl(this._self, this._then);

  final _TaxpayerCertificate _self;
  final $Res Function(_TaxpayerCertificate) _then;

/// Create a copy of TaxpayerCertificate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taxpayerCertificateId = null,Object? taxpayer = null,Object? validFrom = null,Object? validTo = null,Object? status = null,}) {
  return _then(_TaxpayerCertificate(
taxpayerCertificateId: null == taxpayerCertificateId ? _self.taxpayerCertificateId : taxpayerCertificateId // ignore: cast_nullable_to_non_nullable
as String,taxpayer: null == taxpayer ? _self.taxpayer : taxpayer // ignore: cast_nullable_to_non_nullable
as String,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,validTo: null == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntityStatus,
  ));
}


}

/// @nodoc
mixin _$CertificateUpload {

 String get taxpayer; List<int>? get certificateBytes; String? get certificateFileName; List<int>? get keyBytes; String? get keyFileName; String get keyPassword;
/// Create a copy of CertificateUpload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CertificateUploadCopyWith<CertificateUpload> get copyWith => _$CertificateUploadCopyWithImpl<CertificateUpload>(this as CertificateUpload, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CertificateUpload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CertificateUpload&&(identical(other.taxpayer, _this.taxpayer) || other.taxpayer == _this.taxpayer)&&const DeepCollectionEquality().equals(other.certificateBytes, _this.certificateBytes)&&(identical(other.certificateFileName, _this.certificateFileName) || other.certificateFileName == _this.certificateFileName)&&const DeepCollectionEquality().equals(other.keyBytes, _this.keyBytes)&&(identical(other.keyFileName, _this.keyFileName) || other.keyFileName == _this.keyFileName)&&(identical(other.keyPassword, _this.keyPassword) || other.keyPassword == _this.keyPassword));
}


@override
int get hashCode {
  final _this = this as CertificateUpload;
  return Object.hash(runtimeType,_this.taxpayer,const DeepCollectionEquality().hash(_this.certificateBytes),_this.certificateFileName,const DeepCollectionEquality().hash(_this.keyBytes),_this.keyFileName,_this.keyPassword);
}

@override
String toString() {
  final _this = this as CertificateUpload;
  return 'CertificateUpload(taxpayer: ${_this.taxpayer}, certificateBytes: ${_this.certificateBytes}, certificateFileName: ${_this.certificateFileName}, keyBytes: ${_this.keyBytes}, keyFileName: ${_this.keyFileName}, keyPassword: ${_this.keyPassword})';
}


}

/// @nodoc
abstract mixin class $CertificateUploadCopyWith<$Res>  {
  factory $CertificateUploadCopyWith(CertificateUpload value, $Res Function(CertificateUpload) _then) = _$CertificateUploadCopyWithImpl;
@useResult
$Res call({
 String taxpayer, List<int>? certificateBytes, String? certificateFileName, List<int>? keyBytes, String? keyFileName, String keyPassword
});




}
/// @nodoc
class _$CertificateUploadCopyWithImpl<$Res>
    implements $CertificateUploadCopyWith<$Res> {
  _$CertificateUploadCopyWithImpl(this._self, this._then);

  final CertificateUpload _self;
  final $Res Function(CertificateUpload) _then;

/// Create a copy of CertificateUpload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taxpayer = null,Object? certificateBytes = freezed,Object? certificateFileName = freezed,Object? keyBytes = freezed,Object? keyFileName = freezed,Object? keyPassword = null,}) {
  return _then(CertificateUpload(
taxpayer: null == taxpayer ? _self.taxpayer : taxpayer // ignore: cast_nullable_to_non_nullable
as String,certificateBytes: freezed == certificateBytes ? _self.certificateBytes : certificateBytes // ignore: cast_nullable_to_non_nullable
as List<int>?,certificateFileName: freezed == certificateFileName ? _self.certificateFileName : certificateFileName // ignore: cast_nullable_to_non_nullable
as String?,keyBytes: freezed == keyBytes ? _self.keyBytes : keyBytes // ignore: cast_nullable_to_non_nullable
as List<int>?,keyFileName: freezed == keyFileName ? _self.keyFileName : keyFileName // ignore: cast_nullable_to_non_nullable
as String?,keyPassword: null == keyPassword ? _self.keyPassword : keyPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CertificateUpload].
extension CertificateUploadPatterns on CertificateUpload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CertificateUpload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CertificateUpload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CertificateUpload value)  $default,){
final _that = this;
switch (_that) {
case _CertificateUpload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CertificateUpload value)?  $default,){
final _that = this;
switch (_that) {
case _CertificateUpload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taxpayer,  List<int>? certificateBytes,  String? certificateFileName,  List<int>? keyBytes,  String? keyFileName,  String keyPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CertificateUpload() when $default != null:
return $default(_that.taxpayer,_that.certificateBytes,_that.certificateFileName,_that.keyBytes,_that.keyFileName,_that.keyPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taxpayer,  List<int>? certificateBytes,  String? certificateFileName,  List<int>? keyBytes,  String? keyFileName,  String keyPassword)  $default,) {final _that = this;
switch (_that) {
case _CertificateUpload():
return $default(_that.taxpayer,_that.certificateBytes,_that.certificateFileName,_that.keyBytes,_that.keyFileName,_that.keyPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taxpayer,  List<int>? certificateBytes,  String? certificateFileName,  List<int>? keyBytes,  String? keyFileName,  String keyPassword)?  $default,) {final _that = this;
switch (_that) {
case _CertificateUpload() when $default != null:
return $default(_that.taxpayer,_that.certificateBytes,_that.certificateFileName,_that.keyBytes,_that.keyFileName,_that.keyPassword);case _:
  return null;

}
}

}

/// @nodoc


class _CertificateUpload implements CertificateUpload {
  const _CertificateUpload({required this.taxpayer,  List<int>? certificateBytes, this.certificateFileName,  List<int>? keyBytes, this.keyFileName, this.keyPassword = ''}): _certificateBytes = certificateBytes,_keyBytes = keyBytes;
  

@override final  String taxpayer;
 final  List<int>? _certificateBytes;
@override List<int>? get certificateBytes {
  final value = _certificateBytes;
  if (value == null) return null;
  if (_certificateBytes is EqualUnmodifiableListView) return _certificateBytes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? certificateFileName;
 final  List<int>? _keyBytes;
@override List<int>? get keyBytes {
  final value = _keyBytes;
  if (value == null) return null;
  if (_keyBytes is EqualUnmodifiableListView) return _keyBytes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? keyFileName;
@override@JsonKey() final  String keyPassword;

/// Create a copy of CertificateUpload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CertificateUploadCopyWith<_CertificateUpload> get copyWith => __$CertificateUploadCopyWithImpl<_CertificateUpload>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CertificateUpload&&(identical(other.taxpayer, taxpayer) || other.taxpayer == taxpayer)&&const DeepCollectionEquality().equals(other.certificateBytes, _certificateBytes)&&(identical(other.certificateFileName, certificateFileName) || other.certificateFileName == certificateFileName)&&const DeepCollectionEquality().equals(other.keyBytes, _keyBytes)&&(identical(other.keyFileName, keyFileName) || other.keyFileName == keyFileName)&&(identical(other.keyPassword, keyPassword) || other.keyPassword == keyPassword));
}


@override
int get hashCode {
    return Object.hash(runtimeType,taxpayer,const DeepCollectionEquality().hash(_certificateBytes),certificateFileName,const DeepCollectionEquality().hash(_keyBytes),keyFileName,keyPassword);
}

@override
String toString() {
    return 'CertificateUpload(taxpayer: $taxpayer, certificateBytes: $certificateBytes, certificateFileName: $certificateFileName, keyBytes: $keyBytes, keyFileName: $keyFileName, keyPassword: $keyPassword)';
}


}

/// @nodoc
abstract mixin class _$CertificateUploadCopyWith<$Res> implements $CertificateUploadCopyWith<$Res> {
  factory _$CertificateUploadCopyWith(_CertificateUpload value, $Res Function(_CertificateUpload) _then) = __$CertificateUploadCopyWithImpl;
@override @useResult
$Res call({
 String taxpayer, List<int>? certificateBytes, String? certificateFileName, List<int>? keyBytes, String? keyFileName, String keyPassword
});




}
/// @nodoc
class __$CertificateUploadCopyWithImpl<$Res>
    implements _$CertificateUploadCopyWith<$Res> {
  __$CertificateUploadCopyWithImpl(this._self, this._then);

  final _CertificateUpload _self;
  final $Res Function(_CertificateUpload) _then;

/// Create a copy of CertificateUpload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taxpayer = null,Object? certificateBytes = freezed,Object? certificateFileName = freezed,Object? keyBytes = freezed,Object? keyFileName = freezed,Object? keyPassword = null,}) {
  return _then(_CertificateUpload(
taxpayer: null == taxpayer ? _self.taxpayer : taxpayer // ignore: cast_nullable_to_non_nullable
as String,certificateBytes: freezed == certificateBytes ? _self._certificateBytes : certificateBytes // ignore: cast_nullable_to_non_nullable
as List<int>?,certificateFileName: freezed == certificateFileName ? _self.certificateFileName : certificateFileName // ignore: cast_nullable_to_non_nullable
as String?,keyBytes: freezed == keyBytes ? _self._keyBytes : keyBytes // ignore: cast_nullable_to_non_nullable
as List<int>?,keyFileName: freezed == keyFileName ? _self.keyFileName : keyFileName // ignore: cast_nullable_to_non_nullable
as String?,keyPassword: null == keyPassword ? _self.keyPassword : keyPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
