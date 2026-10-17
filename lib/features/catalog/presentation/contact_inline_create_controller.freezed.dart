// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_inline_create_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactInlineCreateState {

 String get name; String get jobTitle; String get phone; String get mobile; String get email; bool get submitting; Contact? get created; String? get error; String? get errorDetail; Map<String, String> get fieldErrors;
/// Create a copy of ContactInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactInlineCreateStateCopyWith<ContactInlineCreateState> get copyWith => _$ContactInlineCreateStateCopyWithImpl<ContactInlineCreateState>(this as ContactInlineCreateState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ContactInlineCreateState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactInlineCreateState&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.jobTitle, _this.jobTitle) || other.jobTitle == _this.jobTitle)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.mobile, _this.mobile) || other.mobile == _this.mobile)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.created, _this.created) || other.created == _this.created)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.errorDetail, _this.errorDetail) || other.errorDetail == _this.errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors));
}


@override
int get hashCode {
  final _this = this as ContactInlineCreateState;
  return Object.hash(runtimeType,_this.name,_this.jobTitle,_this.phone,_this.mobile,_this.email,_this.submitting,_this.created,_this.error,_this.errorDetail,const DeepCollectionEquality().hash(_this.fieldErrors));
}

@override
String toString() {
  final _this = this as ContactInlineCreateState;
  return 'ContactInlineCreateState(name: ${_this.name}, jobTitle: ${_this.jobTitle}, phone: ${_this.phone}, mobile: ${_this.mobile}, email: ${_this.email}, submitting: ${_this.submitting}, created: ${_this.created}, error: ${_this.error}, errorDetail: ${_this.errorDetail}, fieldErrors: ${_this.fieldErrors})';
}


}

/// @nodoc
abstract mixin class $ContactInlineCreateStateCopyWith<$Res>  {
  factory $ContactInlineCreateStateCopyWith(ContactInlineCreateState value, $Res Function(ContactInlineCreateState) _then) = _$ContactInlineCreateStateCopyWithImpl;
@useResult
$Res call({
 String name, String jobTitle, String phone, String mobile, String email, bool submitting, Contact? created, String? error, String? errorDetail, Map<String, String> fieldErrors
});


$ContactCopyWith<$Res>? get created;

}
/// @nodoc
class _$ContactInlineCreateStateCopyWithImpl<$Res>
    implements $ContactInlineCreateStateCopyWith<$Res> {
  _$ContactInlineCreateStateCopyWithImpl(this._self, this._then);

  final ContactInlineCreateState _self;
  final $Res Function(ContactInlineCreateState) _then;

/// Create a copy of ContactInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? jobTitle = null,Object? phone = null,Object? mobile = null,Object? email = null,Object? submitting = null,Object? created = freezed,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(ContactInlineCreateState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,jobTitle: null == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as Contact?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of ContactInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactCopyWith<$Res>? get created {
    if (_self.created == null) {
    return null;
  }

  return $ContactCopyWith<$Res>(_self.created!, (value) {
    return _then(_self.copyWith(created: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContactInlineCreateState].
extension ContactInlineCreateStatePatterns on ContactInlineCreateState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactInlineCreateState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactInlineCreateState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactInlineCreateState value)  $default,){
final _that = this;
switch (_that) {
case _ContactInlineCreateState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactInlineCreateState value)?  $default,){
final _that = this;
switch (_that) {
case _ContactInlineCreateState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String jobTitle,  String phone,  String mobile,  String email,  bool submitting,  Contact? created,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactInlineCreateState() when $default != null:
return $default(_that.name,_that.jobTitle,_that.phone,_that.mobile,_that.email,_that.submitting,_that.created,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String jobTitle,  String phone,  String mobile,  String email,  bool submitting,  Contact? created,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)  $default,) {final _that = this;
switch (_that) {
case _ContactInlineCreateState():
return $default(_that.name,_that.jobTitle,_that.phone,_that.mobile,_that.email,_that.submitting,_that.created,_that.error,_that.errorDetail,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String jobTitle,  String phone,  String mobile,  String email,  bool submitting,  Contact? created,  String? error,  String? errorDetail,  Map<String, String> fieldErrors)?  $default,) {final _that = this;
switch (_that) {
case _ContactInlineCreateState() when $default != null:
return $default(_that.name,_that.jobTitle,_that.phone,_that.mobile,_that.email,_that.submitting,_that.created,_that.error,_that.errorDetail,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class _ContactInlineCreateState implements ContactInlineCreateState {
  const _ContactInlineCreateState({this.name = '', this.jobTitle = '', this.phone = '', this.mobile = '', this.email = '', this.submitting = false, this.created, this.error, this.errorDetail,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String jobTitle;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String mobile;
@override@JsonKey() final  String email;
@override@JsonKey() final  bool submitting;
@override final  Contact? created;
@override final  String? error;
@override final  String? errorDetail;
 final  Map<String, String> _fieldErrors;
@override@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of ContactInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactInlineCreateStateCopyWith<_ContactInlineCreateState> get copyWith => __$ContactInlineCreateStateCopyWithImpl<_ContactInlineCreateState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactInlineCreateState&&(identical(other.name, name) || other.name == name)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.email, email) || other.email == email)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.created, created) || other.created == created)&&(identical(other.error, error) || other.error == error)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,jobTitle,phone,mobile,email,submitting,created,error,errorDetail,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'ContactInlineCreateState(name: $name, jobTitle: $jobTitle, phone: $phone, mobile: $mobile, email: $email, submitting: $submitting, created: $created, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class _$ContactInlineCreateStateCopyWith<$Res> implements $ContactInlineCreateStateCopyWith<$Res> {
  factory _$ContactInlineCreateStateCopyWith(_ContactInlineCreateState value, $Res Function(_ContactInlineCreateState) _then) = __$ContactInlineCreateStateCopyWithImpl;
@override @useResult
$Res call({
 String name, String jobTitle, String phone, String mobile, String email, bool submitting, Contact? created, String? error, String? errorDetail, Map<String, String> fieldErrors
});


@override $ContactCopyWith<$Res>? get created;

}
/// @nodoc
class __$ContactInlineCreateStateCopyWithImpl<$Res>
    implements _$ContactInlineCreateStateCopyWith<$Res> {
  __$ContactInlineCreateStateCopyWithImpl(this._self, this._then);

  final _ContactInlineCreateState _self;
  final $Res Function(_ContactInlineCreateState) _then;

/// Create a copy of ContactInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? jobTitle = null,Object? phone = null,Object? mobile = null,Object? email = null,Object? submitting = null,Object? created = freezed,Object? error = freezed,Object? errorDetail = freezed,Object? fieldErrors = null,}) {
  return _then(_ContactInlineCreateState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,jobTitle: null == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,mobile: null == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,created: freezed == created ? _self.created : created // ignore: cast_nullable_to_non_nullable
as Contact?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of ContactInlineCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactCopyWith<$Res>? get created {
    if (_self.created == null) {
    return null;
  }

  return $ContactCopyWith<$Res>(_self.created!, (value) {
    return _then(_self.copyWith(created: value));
  });
}
}

// dart format on
