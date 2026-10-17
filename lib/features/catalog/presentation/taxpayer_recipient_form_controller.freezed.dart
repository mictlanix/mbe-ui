// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_recipient_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TaxpayerRecipientFormState {

 String? get existingTaxpayerRecipientId; String get taxpayerRecipientId; String get name; String get email; String? get postalCode; String get postalCodeDisplayText; String? get regime; String get regimeDisplayText; bool get loading; bool get submitting; bool get saved; bool get deleted;/// The recipient a successful create returned, so a caller that opened
/// the form to create one (the customer form's inline dialog,
/// 046-catalog-improvements research R7) receives it. `null` otherwise.
 TaxpayerRecipient? get created; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of TaxpayerRecipientFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaxpayerRecipientFormStateCopyWith<TaxpayerRecipientFormState> get copyWith => _$TaxpayerRecipientFormStateCopyWithImpl<TaxpayerRecipientFormState>(this as TaxpayerRecipientFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TaxpayerRecipientFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaxpayerRecipientFormState&&(identical(other.existingTaxpayerRecipientId, _this.existingTaxpayerRecipientId) || other.existingTaxpayerRecipientId == _this.existingTaxpayerRecipientId)&&(identical(other.taxpayerRecipientId, _this.taxpayerRecipientId) || other.taxpayerRecipientId == _this.taxpayerRecipientId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.postalCode, _this.postalCode) || other.postalCode == _this.postalCode)&&(identical(other.postalCodeDisplayText, _this.postalCodeDisplayText) || other.postalCodeDisplayText == _this.postalCodeDisplayText)&&(identical(other.regime, _this.regime) || other.regime == _this.regime)&&(identical(other.regimeDisplayText, _this.regimeDisplayText) || other.regimeDisplayText == _this.regimeDisplayText)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.saved, _this.saved) || other.saved == _this.saved)&&(identical(other.deleted, _this.deleted) || other.deleted == _this.deleted)&&(identical(other.created, _this.created) || other.created == _this.created)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as TaxpayerRecipientFormState;
  return Object.hash(runtimeType,_this.existingTaxpayerRecipientId,_this.taxpayerRecipientId,_this.name,_this.email,_this.postalCode,_this.postalCodeDisplayText,_this.regime,_this.regimeDisplayText,_this.loading,_this.submitting,_this.saved,_this.deleted,_this.created,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as TaxpayerRecipientFormState;
  return 'TaxpayerRecipientFormState(existingTaxpayerRecipientId: ${_this.existingTaxpayerRecipientId}, taxpayerRecipientId: ${_this.taxpayerRecipientId}, name: ${_this.name}, email: ${_this.email}, postalCode: ${_this.postalCode}, postalCodeDisplayText: ${_this.postalCodeDisplayText}, regime: ${_this.regime}, regimeDisplayText: ${_this.regimeDisplayText}, loading: ${_this.loading}, submitting: ${_this.submitting}, saved: ${_this.saved}, deleted: ${_this.deleted}, created: ${_this.created}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $TaxpayerRecipientFormStateCopyWith<$Res>  {
  factory $TaxpayerRecipientFormStateCopyWith(TaxpayerRecipientFormState value, $Res Function(TaxpayerRecipientFormState) _then) = _$TaxpayerRecipientFormStateCopyWithImpl;
@useResult
$Res call({
 String? existingTaxpayerRecipientId, String taxpayerRecipientId, String name, String email, String? postalCode, String postalCodeDisplayText, String? regime, String regimeDisplayText, bool loading, bool submitting, bool saved, bool deleted, TaxpayerRecipient? created, String? error, String? errorDetail, Map<String, String> fieldErrors
});


$TaxpayerRecipientCopyWith<$Res>? get created;

}
/// @nodoc
class _$TaxpayerRecipientFormStateCopyWithImpl<$Res>
    implements $TaxpayerRecipientFormStateCopyWith<$Res> {
  _$TaxpayerRecipientFormStateCopyWithImpl(this._self, this._then);

  final TaxpayerRecipientFormState _self;
  final $Res Function(TaxpayerRecipientFormState) _then;

/// Create a copy of TaxpayerRecipientFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? existingTaxpayerRecipientId = freezed,Object? taxpayerRecipientId = null,Object? name = null,Object? email = null,Object? postalCode = freezed,Object? postalCodeDisplayText = null,Object? regime = freezed,Object? regimeDisplayText = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? created = freezed,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(TaxpayerRecipientFormState(
existingTaxpayerRecipientId: freezed == existingTaxpayerRecipientId ? _self.existingTaxpayerRecipientId : existingTaxpayerRecipientId // ignore: cast_nullable_to_non_nullable
as String?,taxpayerRecipientId: null == taxpayerRecipientId ? _self.taxpayerRecipientId : taxpayerRecipientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,postalCodeDisplayText: null == postalCodeDisplayText ? _self.postalCodeDisplayText : postalCodeDisplayText // ignore: cast_nullable_to_non_nullable
as String,regime: freezed == regime ? _self.regime : regime // ignore: cast_nullable_to_non_nullable
as String?,regimeDisplayText: null == regimeDisplayText ? _self.regimeDisplayText : regimeDisplayText // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as TaxpayerRecipient?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of TaxpayerRecipientFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaxpayerRecipientCopyWith<$Res>? get created {
    if (_self.created == null) {
    return null;
  }

  return $TaxpayerRecipientCopyWith<$Res>(_self.created!, (value) {
    return _then(_self.copyWith(created: value));
  });
}
}


/// Adds pattern-matching-related methods to [TaxpayerRecipientFormState].
extension TaxpayerRecipientFormStatePatterns on TaxpayerRecipientFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaxpayerRecipientFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaxpayerRecipientFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaxpayerRecipientFormState value)  $default,){
final _that = this;
switch (_that) {
case _TaxpayerRecipientFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaxpayerRecipientFormState value)?  $default,){
final _that = this;
switch (_that) {
case _TaxpayerRecipientFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? existingTaxpayerRecipientId,  String taxpayerRecipientId,  String name,  String email,  String? postalCode,  String postalCodeDisplayText,  String? regime,  String regimeDisplayText,  bool loading,  bool submitting,  bool saved,  bool deleted,  TaxpayerRecipient? created,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaxpayerRecipientFormState() when $default != null:
return $default(_that.existingTaxpayerRecipientId,_that.taxpayerRecipientId,_that.name,_that.email,_that.postalCode,_that.postalCodeDisplayText,_that.regime,_that.regimeDisplayText,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.created,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? existingTaxpayerRecipientId,  String taxpayerRecipientId,  String name,  String email,  String? postalCode,  String postalCodeDisplayText,  String? regime,  String regimeDisplayText,  bool loading,  bool submitting,  bool saved,  bool deleted,  TaxpayerRecipient? created,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _TaxpayerRecipientFormState():
return $default(_that.existingTaxpayerRecipientId,_that.taxpayerRecipientId,_that.name,_that.email,_that.postalCode,_that.postalCodeDisplayText,_that.regime,_that.regimeDisplayText,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.created,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? existingTaxpayerRecipientId,  String taxpayerRecipientId,  String name,  String email,  String? postalCode,  String postalCodeDisplayText,  String? regime,  String regimeDisplayText,  bool loading,  bool submitting,  bool saved,  bool deleted,  TaxpayerRecipient? created,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _TaxpayerRecipientFormState() when $default != null:
return $default(_that.existingTaxpayerRecipientId,_that.taxpayerRecipientId,_that.name,_that.email,_that.postalCode,_that.postalCodeDisplayText,_that.regime,_that.regimeDisplayText,_that.loading,_that.submitting,_that.saved,_that.deleted,_that.created,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _TaxpayerRecipientFormState implements TaxpayerRecipientFormState {
  const _TaxpayerRecipientFormState({this.existingTaxpayerRecipientId, this.taxpayerRecipientId = '', this.name = '', this.email = '', this.postalCode, this.postalCodeDisplayText = '', this.regime, this.regimeDisplayText = '', this.loading = false, this.submitting = false, this.saved = false, this.deleted = false, this.created, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override final  String? existingTaxpayerRecipientId;
@override@JsonKey() final  String taxpayerRecipientId;
@override@JsonKey() final  String name;
@override@JsonKey() final  String email;
@override final  String? postalCode;
@override@JsonKey() final  String postalCodeDisplayText;
@override final  String? regime;
@override@JsonKey() final  String regimeDisplayText;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool saved;
@override@JsonKey() final  bool deleted;
/// The recipient a successful create returned, so a caller that opened
/// the form to create one (the customer form's inline dialog,
/// 046-catalog-improvements research R7) receives it. `null` otherwise.
@override final  TaxpayerRecipient? created;
@override final  String? error;
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of TaxpayerRecipientFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaxpayerRecipientFormStateCopyWith<_TaxpayerRecipientFormState> get copyWith => __$TaxpayerRecipientFormStateCopyWithImpl<_TaxpayerRecipientFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaxpayerRecipientFormState&&(identical(other.existingTaxpayerRecipientId, existingTaxpayerRecipientId) || other.existingTaxpayerRecipientId == existingTaxpayerRecipientId)&&(identical(other.taxpayerRecipientId, taxpayerRecipientId) || other.taxpayerRecipientId == taxpayerRecipientId)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.postalCodeDisplayText, postalCodeDisplayText) || other.postalCodeDisplayText == postalCodeDisplayText)&&(identical(other.regime, regime) || other.regime == regime)&&(identical(other.regimeDisplayText, regimeDisplayText) || other.regimeDisplayText == regimeDisplayText)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.created, created) || other.created == created)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,existingTaxpayerRecipientId,taxpayerRecipientId,name,email,postalCode,postalCodeDisplayText,regime,regimeDisplayText,loading,submitting,saved,deleted,created,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'TaxpayerRecipientFormState(existingTaxpayerRecipientId: $existingTaxpayerRecipientId, taxpayerRecipientId: $taxpayerRecipientId, name: $name, email: $email, postalCode: $postalCode, postalCodeDisplayText: $postalCodeDisplayText, regime: $regime, regimeDisplayText: $regimeDisplayText, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, created: $created, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$TaxpayerRecipientFormStateCopyWith<$Res> implements $TaxpayerRecipientFormStateCopyWith<$Res> {
  factory _$TaxpayerRecipientFormStateCopyWith(_TaxpayerRecipientFormState value, $Res Function(_TaxpayerRecipientFormState) _then) = __$TaxpayerRecipientFormStateCopyWithImpl;
@override @useResult
$Res call({
 String? existingTaxpayerRecipientId, String taxpayerRecipientId, String name, String email, String? postalCode, String postalCodeDisplayText, String? regime, String regimeDisplayText, bool loading, bool submitting, bool saved, bool deleted, TaxpayerRecipient? created, String? error, String? errorDetail, Map<String, String> fieldErrors
});


@override $TaxpayerRecipientCopyWith<$Res>? get created;

}
/// @nodoc
class __$TaxpayerRecipientFormStateCopyWithImpl<$Res>
    implements _$TaxpayerRecipientFormStateCopyWith<$Res> {
  __$TaxpayerRecipientFormStateCopyWithImpl(this._self, this._then);

  final _TaxpayerRecipientFormState _self;
  final $Res Function(_TaxpayerRecipientFormState) _then;

/// Create a copy of TaxpayerRecipientFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? existingTaxpayerRecipientId = freezed,Object? taxpayerRecipientId = null,Object? name = null,Object? email = null,Object? postalCode = freezed,Object? postalCodeDisplayText = null,Object? regime = freezed,Object? regimeDisplayText = null,Object? loading = null,Object? submitting = null,Object? saved = null,Object? deleted = null,Object? created = freezed,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_TaxpayerRecipientFormState(
existingTaxpayerRecipientId: freezed == existingTaxpayerRecipientId ? _self.existingTaxpayerRecipientId : existingTaxpayerRecipientId // ignore: cast_nullable_to_non_nullable
as String?,taxpayerRecipientId: null == taxpayerRecipientId ? _self.taxpayerRecipientId : taxpayerRecipientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,postalCodeDisplayText: null == postalCodeDisplayText ? _self.postalCodeDisplayText : postalCodeDisplayText // ignore: cast_nullable_to_non_nullable
as String,regime: freezed == regime ? _self.regime : regime // ignore: cast_nullable_to_non_nullable
as String?,regimeDisplayText: null == regimeDisplayText ? _self.regimeDisplayText : regimeDisplayText // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as TaxpayerRecipient?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of TaxpayerRecipientFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaxpayerRecipientCopyWith<$Res>? get created {
    if (_self.created == null) {
    return null;
  }

  return $TaxpayerRecipientCopyWith<$Res>(_self.created!, (value) {
    return _then(_self.copyWith(created: value));
  });
}
}

// dart format on
