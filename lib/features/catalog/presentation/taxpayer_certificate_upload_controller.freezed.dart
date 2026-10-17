// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_certificate_upload_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaxpayerCertificateUploadState {

 String get taxpayer; List<int>? get certificateBytes; String get certificateFileName; List<int>? get keyBytes; String get keyFileName; String get keyPassword; bool get submitting; TaxpayerCertificate? get uploaded; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of TaxpayerCertificateUploadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxpayerCertificateUploadStateCopyWith<TaxpayerCertificateUploadState> get copyWith => _$TaxpayerCertificateUploadStateCopyWithImpl<TaxpayerCertificateUploadState>(this as TaxpayerCertificateUploadState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaxpayerCertificateUploadState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxpayerCertificateUploadState&&(identical(other.taxpayer, _this.taxpayer) || other.taxpayer == _this.taxpayer)&&const DeepCollectionEquality().equals(other.certificateBytes, _this.certificateBytes)&&(identical(other.certificateFileName, _this.certificateFileName) || other.certificateFileName == _this.certificateFileName)&&const DeepCollectionEquality().equals(other.keyBytes, _this.keyBytes)&&(identical(other.keyFileName, _this.keyFileName) || other.keyFileName == _this.keyFileName)&&(identical(other.keyPassword, _this.keyPassword) || other.keyPassword == _this.keyPassword)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.uploaded, _this.uploaded) || other.uploaded == _this.uploaded)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as TaxpayerCertificateUploadState;
  return Object.hash(runtimeType,_this.taxpayer,const DeepCollectionEquality().hash(_this.certificateBytes),_this.certificateFileName,const DeepCollectionEquality().hash(_this.keyBytes),_this.keyFileName,_this.keyPassword,_this.submitting,_this.uploaded,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as TaxpayerCertificateUploadState;
  return 'TaxpayerCertificateUploadState(taxpayer: ${_this.taxpayer}, certificateBytes: ${_this.certificateBytes}, certificateFileName: ${_this.certificateFileName}, keyBytes: ${_this.keyBytes}, keyFileName: ${_this.keyFileName}, keyPassword: ${_this.keyPassword}, submitting: ${_this.submitting}, uploaded: ${_this.uploaded}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $TaxpayerCertificateUploadStateCopyWith<$Res>  {
  factory $TaxpayerCertificateUploadStateCopyWith(TaxpayerCertificateUploadState value, $Res Function(TaxpayerCertificateUploadState) _then) = _$TaxpayerCertificateUploadStateCopyWithImpl;
@useResult
$Res call({
 String taxpayer, List<int>? certificateBytes, String certificateFileName, List<int>? keyBytes, String keyFileName, String keyPassword, bool submitting, TaxpayerCertificate? uploaded, String? error, String? errorDetail, Map<String, String> fieldErrors
});


$TaxpayerCertificateCopyWith<$Res>? get uploaded;

}
/// @nodoc
class _$TaxpayerCertificateUploadStateCopyWithImpl<$Res>
    implements $TaxpayerCertificateUploadStateCopyWith<$Res> {
  _$TaxpayerCertificateUploadStateCopyWithImpl(this._self, this._then);

  final TaxpayerCertificateUploadState _self;
  final $Res Function(TaxpayerCertificateUploadState) _then;

/// Create a copy of TaxpayerCertificateUploadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taxpayer = null,Object? certificateBytes = freezed,Object? certificateFileName = null,Object? keyBytes = freezed,Object? keyFileName = null,Object? keyPassword = null,Object? submitting = null,Object? uploaded = freezed,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(TaxpayerCertificateUploadState(
taxpayer: null == taxpayer ? _self.taxpayer : taxpayer // ignore: cast_nullable_to_non_nullable
as String,certificateBytes: freezed == certificateBytes ? _self.certificateBytes : certificateBytes // ignore: cast_nullable_to_non_nullable
as List<int>?,certificateFileName: null == certificateFileName ? _self.certificateFileName : certificateFileName // ignore: cast_nullable_to_non_nullable
as String,keyBytes: freezed == keyBytes ? _self.keyBytes : keyBytes // ignore: cast_nullable_to_non_nullable
as List<int>?,keyFileName: null == keyFileName ? _self.keyFileName : keyFileName // ignore: cast_nullable_to_non_nullable
as String,keyPassword: null == keyPassword ? _self.keyPassword : keyPassword // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,uploaded: freezed == uploaded ? _self.uploaded : uploaded // ignore: cast_nullable_to_non_nullable
as TaxpayerCertificate?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of TaxpayerCertificateUploadState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaxpayerCertificateCopyWith<$Res>? get uploaded {
    if (_self.uploaded == null) {
    return null;
  }

  return $TaxpayerCertificateCopyWith<$Res>(_self.uploaded!, (value) {
    return _then(_self.copyWith(uploaded: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaxpayerCertificateUploadState].
extension TaxpayerCertificateUploadStatePatterns on TaxpayerCertificateUploadState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxpayerCertificateUploadState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxpayerCertificateUploadState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxpayerCertificateUploadState value)  $default,){
final _that = this;
switch (_that) {
case _TaxpayerCertificateUploadState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxpayerCertificateUploadState value)?  $default,){
final _that = this;
switch (_that) {
case _TaxpayerCertificateUploadState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taxpayer,  List<int>? certificateBytes,  String certificateFileName,  List<int>? keyBytes,  String keyFileName,  String keyPassword,  bool submitting,  TaxpayerCertificate? uploaded,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxpayerCertificateUploadState() when $default != null:
return $default(_that.taxpayer,_that.certificateBytes,_that.certificateFileName,_that.keyBytes,_that.keyFileName,_that.keyPassword,_that.submitting,_that.uploaded,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taxpayer,  List<int>? certificateBytes,  String certificateFileName,  List<int>? keyBytes,  String keyFileName,  String keyPassword,  bool submitting,  TaxpayerCertificate? uploaded,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _TaxpayerCertificateUploadState():
return $default(_that.taxpayer,_that.certificateBytes,_that.certificateFileName,_that.keyBytes,_that.keyFileName,_that.keyPassword,_that.submitting,_that.uploaded,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taxpayer,  List<int>? certificateBytes,  String certificateFileName,  List<int>? keyBytes,  String keyFileName,  String keyPassword,  bool submitting,  TaxpayerCertificate? uploaded,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _TaxpayerCertificateUploadState() when $default != null:
return $default(_that.taxpayer,_that.certificateBytes,_that.certificateFileName,_that.keyBytes,_that.keyFileName,_that.keyPassword,_that.submitting,_that.uploaded,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _TaxpayerCertificateUploadState implements TaxpayerCertificateUploadState {
  const _TaxpayerCertificateUploadState({required this.taxpayer,  List<int>? certificateBytes, this.certificateFileName = '',  List<int>? keyBytes, this.keyFileName = '', this.keyPassword = '', this.submitting = false, this.uploaded, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _certificateBytes = certificateBytes,_keyBytes = keyBytes,_fieldErrors = fieldErrors;
  

@override final  String taxpayer;
 final  List<int>? _certificateBytes;
@override List<int>? get certificateBytes {
  final value = _certificateBytes;
  if (value == null) return null;
  if (_certificateBytes is EqualUnmodifiableListView) return _certificateBytes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  String certificateFileName;
 final  List<int>? _keyBytes;
@override List<int>? get keyBytes {
  final value = _keyBytes;
  if (value == null) return null;
  if (_keyBytes is EqualUnmodifiableListView) return _keyBytes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  String keyFileName;
@override@JsonKey() final  String keyPassword;
@override@JsonKey() final  bool submitting;
@override final  TaxpayerCertificate? uploaded;
@override final  String? error;
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of TaxpayerCertificateUploadState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxpayerCertificateUploadStateCopyWith<_TaxpayerCertificateUploadState> get copyWith => __$TaxpayerCertificateUploadStateCopyWithImpl<_TaxpayerCertificateUploadState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxpayerCertificateUploadState&&(identical(other.taxpayer, taxpayer) || other.taxpayer == taxpayer)&&const DeepCollectionEquality().equals(other.certificateBytes, _certificateBytes)&&(identical(other.certificateFileName, certificateFileName) || other.certificateFileName == certificateFileName)&&const DeepCollectionEquality().equals(other.keyBytes, _keyBytes)&&(identical(other.keyFileName, keyFileName) || other.keyFileName == keyFileName)&&(identical(other.keyPassword, keyPassword) || other.keyPassword == keyPassword)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.uploaded, uploaded) || other.uploaded == uploaded)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,taxpayer,const DeepCollectionEquality().hash(_certificateBytes),certificateFileName,const DeepCollectionEquality().hash(_keyBytes),keyFileName,keyPassword,submitting,uploaded,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'TaxpayerCertificateUploadState(taxpayer: $taxpayer, certificateBytes: $certificateBytes, certificateFileName: $certificateFileName, keyBytes: $keyBytes, keyFileName: $keyFileName, keyPassword: $keyPassword, submitting: $submitting, uploaded: $uploaded, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$TaxpayerCertificateUploadStateCopyWith<$Res> implements $TaxpayerCertificateUploadStateCopyWith<$Res> {
  factory _$TaxpayerCertificateUploadStateCopyWith(_TaxpayerCertificateUploadState value, $Res Function(_TaxpayerCertificateUploadState) _then) = __$TaxpayerCertificateUploadStateCopyWithImpl;
@override @useResult
$Res call({
 String taxpayer, List<int>? certificateBytes, String certificateFileName, List<int>? keyBytes, String keyFileName, String keyPassword, bool submitting, TaxpayerCertificate? uploaded, String? error, String? errorDetail, Map<String, String> fieldErrors
});


@override $TaxpayerCertificateCopyWith<$Res>? get uploaded;

}
/// @nodoc
class __$TaxpayerCertificateUploadStateCopyWithImpl<$Res>
    implements _$TaxpayerCertificateUploadStateCopyWith<$Res> {
  __$TaxpayerCertificateUploadStateCopyWithImpl(this._self, this._then);

  final _TaxpayerCertificateUploadState _self;
  final $Res Function(_TaxpayerCertificateUploadState) _then;

/// Create a copy of TaxpayerCertificateUploadState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taxpayer = null,Object? certificateBytes = freezed,Object? certificateFileName = null,Object? keyBytes = freezed,Object? keyFileName = null,Object? keyPassword = null,Object? submitting = null,Object? uploaded = freezed,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_TaxpayerCertificateUploadState(
taxpayer: null == taxpayer ? _self.taxpayer : taxpayer // ignore: cast_nullable_to_non_nullable
as String,certificateBytes: freezed == certificateBytes ? _self._certificateBytes : certificateBytes // ignore: cast_nullable_to_non_nullable
as List<int>?,certificateFileName: null == certificateFileName ? _self.certificateFileName : certificateFileName // ignore: cast_nullable_to_non_nullable
as String,keyBytes: freezed == keyBytes ? _self._keyBytes : keyBytes // ignore: cast_nullable_to_non_nullable
as List<int>?,keyFileName: null == keyFileName ? _self.keyFileName : keyFileName // ignore: cast_nullable_to_non_nullable
as String,keyPassword: null == keyPassword ? _self.keyPassword : keyPassword // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,uploaded: freezed == uploaded ? _self.uploaded : uploaded // ignore: cast_nullable_to_non_nullable
as TaxpayerCertificate?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of TaxpayerCertificateUploadState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaxpayerCertificateCopyWith<$Res>? get uploaded {
    if (_self.uploaded == null) {
    return null;
  }

  return $TaxpayerCertificateCopyWith<$Res>(_self.uploaded!, (value) {
    return _then(_self.copyWith(uploaded: value));
  });
}
}

// dart format on
