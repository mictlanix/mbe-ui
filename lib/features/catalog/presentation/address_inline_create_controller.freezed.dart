// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_inline_create_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddressInlineCreateState {

 String get street; String get exteriorNumber; String get interiorNumber; String get postalCode; String get neighborhood; String get locality; String get borough; String get addressState; String get city; String get country; String get nickname; AddressType? get type; String get comment; bool get submitting; AddressListItem? get created; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of AddressInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressInlineCreateStateCopyWith<AddressInlineCreateState> get copyWith => _$AddressInlineCreateStateCopyWithImpl<AddressInlineCreateState>(this as AddressInlineCreateState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AddressInlineCreateState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressInlineCreateState&&(identical(other.street, _this.street) || other.street == _this.street)&&(identical(other.exteriorNumber, _this.exteriorNumber) || other.exteriorNumber == _this.exteriorNumber)&&(identical(other.interiorNumber, _this.interiorNumber) || other.interiorNumber == _this.interiorNumber)&&(identical(other.postalCode, _this.postalCode) || other.postalCode == _this.postalCode)&&(identical(other.neighborhood, _this.neighborhood) || other.neighborhood == _this.neighborhood)&&(identical(other.locality, _this.locality) || other.locality == _this.locality)&&(identical(other.borough, _this.borough) || other.borough == _this.borough)&&(identical(other.addressState, _this.addressState) || other.addressState == _this.addressState)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.country, _this.country) || other.country == _this.country)&&(identical(other.nickname, _this.nickname) || other.nickname == _this.nickname)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.created, _this.created) || other.created == _this.created)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as AddressInlineCreateState;
  return Object.hash(runtimeType,_this.street,_this.exteriorNumber,_this.interiorNumber,_this.postalCode,_this.neighborhood,_this.locality,_this.borough,_this.addressState,_this.city,_this.country,_this.nickname,_this.type,_this.comment,_this.submitting,_this.created,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as AddressInlineCreateState;
  return 'AddressInlineCreateState(street: ${_this.street}, exteriorNumber: ${_this.exteriorNumber}, interiorNumber: ${_this.interiorNumber}, postalCode: ${_this.postalCode}, neighborhood: ${_this.neighborhood}, locality: ${_this.locality}, borough: ${_this.borough}, addressState: ${_this.addressState}, city: ${_this.city}, country: ${_this.country}, nickname: ${_this.nickname}, type: ${_this.type}, comment: ${_this.comment}, submitting: ${_this.submitting}, created: ${_this.created}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $AddressInlineCreateStateCopyWith<$Res>  {
  factory $AddressInlineCreateStateCopyWith(AddressInlineCreateState value, $Res Function(AddressInlineCreateState) _then) = _$AddressInlineCreateStateCopyWithImpl;
@useResult
$Res call({
 String street, String exteriorNumber, String interiorNumber, String postalCode, String neighborhood, String locality, String borough, String addressState, String city, String country, String nickname, AddressType? type, String comment, bool submitting, AddressListItem? created, String? error, String? errorDetail, Map<String, String> fieldErrors
});


$AddressListItemCopyWith<$Res>? get created;

}
/// @nodoc
class _$AddressInlineCreateStateCopyWithImpl<$Res>
    implements $AddressInlineCreateStateCopyWith<$Res> {
  _$AddressInlineCreateStateCopyWithImpl(this._self, this._then);

  final AddressInlineCreateState _self;
  final $Res Function(AddressInlineCreateState) _then;

/// Create a copy of AddressInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? street = null,Object? exteriorNumber = null,Object? interiorNumber = null,Object? postalCode = null,Object? neighborhood = null,Object? locality = null,Object? borough = null,Object? addressState = null,Object? city = null,Object? country = null,Object? nickname = null,Object? type = freezed,Object? comment = null,Object? submitting = null,Object? created = freezed,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(AddressInlineCreateState(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,exteriorNumber: null == exteriorNumber ? _self.exteriorNumber : exteriorNumber // ignore: cast_nullable_to_non_nullable
as String,interiorNumber: null == interiorNumber ? _self.interiorNumber : interiorNumber // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,locality: null == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String,borough: null == borough ? _self.borough : borough // ignore: cast_nullable_to_non_nullable
as String,addressState: null == addressState ? _self.addressState : addressState // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AddressType?,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as AddressListItem?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of AddressInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressListItemCopyWith<$Res>? get created {
    if (_self.created == null) {
    return null;
  }

  return $AddressListItemCopyWith<$Res>(_self.created!, (value) {
    return _then(_self.copyWith(created: value));
  });
}
}


/// Adds pattern-matching-related methods to [AddressInlineCreateState].
extension AddressInlineCreateStatePatterns on AddressInlineCreateState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressInlineCreateState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressInlineCreateState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressInlineCreateState value)  $default,){
final _that = this;
switch (_that) {
case _AddressInlineCreateState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressInlineCreateState value)?  $default,){
final _that = this;
switch (_that) {
case _AddressInlineCreateState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String street,  String exteriorNumber,  String interiorNumber,  String postalCode,  String neighborhood,  String locality,  String borough,  String addressState,  String city,  String country,  String nickname,  AddressType? type,  String comment,  bool submitting,  AddressListItem? created,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressInlineCreateState() when $default != null:
return $default(_that.street,_that.exteriorNumber,_that.interiorNumber,_that.postalCode,_that.neighborhood,_that.locality,_that.borough,_that.addressState,_that.city,_that.country,_that.nickname,_that.type,_that.comment,_that.submitting,_that.created,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String street,  String exteriorNumber,  String interiorNumber,  String postalCode,  String neighborhood,  String locality,  String borough,  String addressState,  String city,  String country,  String nickname,  AddressType? type,  String comment,  bool submitting,  AddressListItem? created,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _AddressInlineCreateState():
return $default(_that.street,_that.exteriorNumber,_that.interiorNumber,_that.postalCode,_that.neighborhood,_that.locality,_that.borough,_that.addressState,_that.city,_that.country,_that.nickname,_that.type,_that.comment,_that.submitting,_that.created,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String street,  String exteriorNumber,  String interiorNumber,  String postalCode,  String neighborhood,  String locality,  String borough,  String addressState,  String city,  String country,  String nickname,  AddressType? type,  String comment,  bool submitting,  AddressListItem? created,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _AddressInlineCreateState() when $default != null:
return $default(_that.street,_that.exteriorNumber,_that.interiorNumber,_that.postalCode,_that.neighborhood,_that.locality,_that.borough,_that.addressState,_that.city,_that.country,_that.nickname,_that.type,_that.comment,_that.submitting,_that.created,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _AddressInlineCreateState implements AddressInlineCreateState {
  const _AddressInlineCreateState({this.street = '', this.exteriorNumber = '', this.interiorNumber = '', this.postalCode = '', this.neighborhood = '', this.locality = '', this.borough = '', this.addressState = '', this.city = '', this.country = '', this.nickname = '', this.type, this.comment = '', this.submitting = false, this.created, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override@JsonKey() final  String street;
@override@JsonKey() final  String exteriorNumber;
@override@JsonKey() final  String interiorNumber;
@override@JsonKey() final  String postalCode;
@override@JsonKey() final  String neighborhood;
@override@JsonKey() final  String locality;
@override@JsonKey() final  String borough;
@override@JsonKey() final  String addressState;
@override@JsonKey() final  String city;
@override@JsonKey() final  String country;
@override@JsonKey() final  String nickname;
@override final  AddressType? type;
@override@JsonKey() final  String comment;
@override@JsonKey() final  bool submitting;
@override final  AddressListItem? created;
@override final  String? error;
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of AddressInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressInlineCreateStateCopyWith<_AddressInlineCreateState> get copyWith => __$AddressInlineCreateStateCopyWithImpl<_AddressInlineCreateState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressInlineCreateState&&(identical(other.street, street) || other.street == street)&&(identical(other.exteriorNumber, exteriorNumber) || other.exteriorNumber == exteriorNumber)&&(identical(other.interiorNumber, interiorNumber) || other.interiorNumber == interiorNumber)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.borough, borough) || other.borough == borough)&&(identical(other.addressState, addressState) || other.addressState == addressState)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.type, type) || other.type == type)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.created, created) || other.created == created)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,street,exteriorNumber,interiorNumber,postalCode,neighborhood,locality,borough,addressState,city,country,nickname,type,comment,submitting,created,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'AddressInlineCreateState(street: $street, exteriorNumber: $exteriorNumber, interiorNumber: $interiorNumber, postalCode: $postalCode, neighborhood: $neighborhood, locality: $locality, borough: $borough, addressState: $addressState, city: $city, country: $country, nickname: $nickname, type: $type, comment: $comment, submitting: $submitting, created: $created, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$AddressInlineCreateStateCopyWith<$Res> implements $AddressInlineCreateStateCopyWith<$Res> {
  factory _$AddressInlineCreateStateCopyWith(_AddressInlineCreateState value, $Res Function(_AddressInlineCreateState) _then) = __$AddressInlineCreateStateCopyWithImpl;
@override @useResult
$Res call({
 String street, String exteriorNumber, String interiorNumber, String postalCode, String neighborhood, String locality, String borough, String addressState, String city, String country, String nickname, AddressType? type, String comment, bool submitting, AddressListItem? created, String? error, String? errorDetail, Map<String, String> fieldErrors
});


@override $AddressListItemCopyWith<$Res>? get created;

}
/// @nodoc
class __$AddressInlineCreateStateCopyWithImpl<$Res>
    implements _$AddressInlineCreateStateCopyWith<$Res> {
  __$AddressInlineCreateStateCopyWithImpl(this._self, this._then);

  final _AddressInlineCreateState _self;
  final $Res Function(_AddressInlineCreateState) _then;

/// Create a copy of AddressInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? street = null,Object? exteriorNumber = null,Object? interiorNumber = null,Object? postalCode = null,Object? neighborhood = null,Object? locality = null,Object? borough = null,Object? addressState = null,Object? city = null,Object? country = null,Object? nickname = null,Object? type = freezed,Object? comment = null,Object? submitting = null,Object? created = freezed,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_AddressInlineCreateState(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,exteriorNumber: null == exteriorNumber ? _self.exteriorNumber : exteriorNumber // ignore: cast_nullable_to_non_nullable
as String,interiorNumber: null == interiorNumber ? _self.interiorNumber : interiorNumber // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,locality: null == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String,borough: null == borough ? _self.borough : borough // ignore: cast_nullable_to_non_nullable
as String,addressState: null == addressState ? _self.addressState : addressState // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AddressType?,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as AddressListItem?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of AddressInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressListItemCopyWith<$Res>? get created {
    if (_self.created == null) {
    return null;
  }

  return $AddressListItemCopyWith<$Res>(_self.created!, (value) {
    return _then(_self.copyWith(created: value));
  });
}
}

// dart format on
