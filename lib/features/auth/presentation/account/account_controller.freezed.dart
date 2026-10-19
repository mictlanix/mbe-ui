// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChangePasswordFormState {

 String get oldPassword; String get newPassword; String get confirmPassword; bool get submitting; bool get success;/// A [PasswordFormErrorCode] from the local checks.
 String? get error;/// A repository failure, surfaced through the shared `ErrorBanner`.
 AppError? get failure;
/// Create a copy of ChangePasswordFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangePasswordFormStateCopyWith<ChangePasswordFormState> get copyWith => _$ChangePasswordFormStateCopyWithImpl<ChangePasswordFormState>(this as ChangePasswordFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChangePasswordFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangePasswordFormState&&(identical(other.oldPassword, _this.oldPassword) || other.oldPassword == _this.oldPassword)&&(identical(other.newPassword, _this.newPassword) || other.newPassword == _this.newPassword)&&(identical(other.confirmPassword, _this.confirmPassword) || other.confirmPassword == _this.confirmPassword)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.success, _this.success) || other.success == _this.success)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as ChangePasswordFormState;
  return Object.hash(runtimeType,_this.oldPassword,_this.newPassword,_this.confirmPassword,_this.submitting,_this.success,_this.error,_this.failure);
}

@override
String toString() {
  final _this = this as ChangePasswordFormState;
  return 'ChangePasswordFormState(oldPassword: ${_this.oldPassword}, newPassword: ${_this.newPassword}, confirmPassword: ${_this.confirmPassword}, submitting: ${_this.submitting}, success: ${_this.success}, error: ${_this.error}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $ChangePasswordFormStateCopyWith<$Res>  {
  factory $ChangePasswordFormStateCopyWith(ChangePasswordFormState value, $Res Function(ChangePasswordFormState) _then) = _$ChangePasswordFormStateCopyWithImpl;
@useResult
$Res call({
 String oldPassword, String newPassword, String confirmPassword, bool submitting, bool success, String? error, AppError? failure
});


$AppErrorCopyWith<$Res>? get failure;

}
/// @nodoc
class _$ChangePasswordFormStateCopyWithImpl<$Res>
    implements $ChangePasswordFormStateCopyWith<$Res> {
  _$ChangePasswordFormStateCopyWithImpl(this._self, this._then);

  final ChangePasswordFormState _self;
  final $Res Function(ChangePasswordFormState) _then;

/// Create a copy of ChangePasswordFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? oldPassword = null,Object? newPassword = null,Object? confirmPassword = null,Object? submitting = null,Object? success = null,Object? error = freezed,Object? failure = freezed,}) {
  return _then(ChangePasswordFormState(
oldPassword: null == oldPassword ? _self.oldPassword : oldPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}
/// Create a copy of ChangePasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $AppErrorCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChangePasswordFormState].
extension ChangePasswordFormStatePatterns on ChangePasswordFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangePasswordFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangePasswordFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangePasswordFormState value)  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangePasswordFormState value)?  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String oldPassword,  String newPassword,  String confirmPassword,  bool submitting,  bool success,  String? error,  AppError? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangePasswordFormState() when $default != null:
return $default(_that.oldPassword,_that.newPassword,_that.confirmPassword,_that.submitting,_that.success,_that.error,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String oldPassword,  String newPassword,  String confirmPassword,  bool submitting,  bool success,  String? error,  AppError? failure)  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordFormState():
return $default(_that.oldPassword,_that.newPassword,_that.confirmPassword,_that.submitting,_that.success,_that.error,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String oldPassword,  String newPassword,  String confirmPassword,  bool submitting,  bool success,  String? error,  AppError? failure)?  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordFormState() when $default != null:
return $default(_that.oldPassword,_that.newPassword,_that.confirmPassword,_that.submitting,_that.success,_that.error,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _ChangePasswordFormState implements ChangePasswordFormState {
  const _ChangePasswordFormState({this.oldPassword = '', this.newPassword = '', this.confirmPassword = '', this.submitting = false, this.success = false, this.error, this.failure});
  

@override@JsonKey() final  String oldPassword;
@override@JsonKey() final  String newPassword;
@override@JsonKey() final  String confirmPassword;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool success;
/// A [PasswordFormErrorCode] from the local checks.
@override final  String? error;
/// A repository failure, surfaced through the shared `ErrorBanner`.
@override final  AppError? failure;

/// Create a copy of ChangePasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangePasswordFormStateCopyWith<_ChangePasswordFormState> get copyWith => __$ChangePasswordFormStateCopyWithImpl<_ChangePasswordFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangePasswordFormState&&(identical(other.oldPassword, oldPassword) || other.oldPassword == oldPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.error, error) || other.error == error)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,oldPassword,newPassword,confirmPassword,submitting,success,error,failure);
}

@override
String toString() {
    return 'ChangePasswordFormState(oldPassword: $oldPassword, newPassword: $newPassword, confirmPassword: $confirmPassword, submitting: $submitting, success: $success, error: $error, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$ChangePasswordFormStateCopyWith<$Res> implements $ChangePasswordFormStateCopyWith<$Res> {
  factory _$ChangePasswordFormStateCopyWith(_ChangePasswordFormState value, $Res Function(_ChangePasswordFormState) _then) = __$ChangePasswordFormStateCopyWithImpl;
@override @useResult
$Res call({
 String oldPassword, String newPassword, String confirmPassword, bool submitting, bool success, String? error, AppError? failure
});


@override $AppErrorCopyWith<$Res>? get failure;

}
/// @nodoc
class __$ChangePasswordFormStateCopyWithImpl<$Res>
    implements _$ChangePasswordFormStateCopyWith<$Res> {
  __$ChangePasswordFormStateCopyWithImpl(this._self, this._then);

  final _ChangePasswordFormState _self;
  final $Res Function(_ChangePasswordFormState) _then;

/// Create a copy of ChangePasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? oldPassword = null,Object? newPassword = null,Object? confirmPassword = null,Object? submitting = null,Object? success = null,Object? error = freezed,Object? failure = freezed,}) {
  return _then(_ChangePasswordFormState(
oldPassword: null == oldPassword ? _self.oldPassword : oldPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}

/// Create a copy of ChangePasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $AppErrorCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

/// @nodoc
mixin _$RecoveryFormState {

 String get recoveryToken; String get newPassword; String get confirmPassword; bool get submitting; bool get success;/// A [PasswordFormErrorCode] from the local checks.
 String? get error;/// A repository failure, surfaced through the shared `ErrorBanner`.
 AppError? get failure;
/// Create a copy of RecoveryFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecoveryFormStateCopyWith<RecoveryFormState> get copyWith => _$RecoveryFormStateCopyWithImpl<RecoveryFormState>(this as RecoveryFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecoveryFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecoveryFormState&&(identical(other.recoveryToken, _this.recoveryToken) || other.recoveryToken == _this.recoveryToken)&&(identical(other.newPassword, _this.newPassword) || other.newPassword == _this.newPassword)&&(identical(other.confirmPassword, _this.confirmPassword) || other.confirmPassword == _this.confirmPassword)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.success, _this.success) || other.success == _this.success)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.failure, _this.failure) || other.failure == _this.failure));
}


@override
int get hashCode {
  final _this = this as RecoveryFormState;
  return Object.hash(runtimeType,_this.recoveryToken,_this.newPassword,_this.confirmPassword,_this.submitting,_this.success,_this.error,_this.failure);
}

@override
String toString() {
  final _this = this as RecoveryFormState;
  return 'RecoveryFormState(recoveryToken: ${_this.recoveryToken}, newPassword: ${_this.newPassword}, confirmPassword: ${_this.confirmPassword}, submitting: ${_this.submitting}, success: ${_this.success}, error: ${_this.error}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $RecoveryFormStateCopyWith<$Res>  {
  factory $RecoveryFormStateCopyWith(RecoveryFormState value, $Res Function(RecoveryFormState) _then) = _$RecoveryFormStateCopyWithImpl;
@useResult
$Res call({
 String recoveryToken, String newPassword, String confirmPassword, bool submitting, bool success, String? error, AppError? failure
});


$AppErrorCopyWith<$Res>? get failure;

}
/// @nodoc
class _$RecoveryFormStateCopyWithImpl<$Res>
    implements $RecoveryFormStateCopyWith<$Res> {
  _$RecoveryFormStateCopyWithImpl(this._self, this._then);

  final RecoveryFormState _self;
  final $Res Function(RecoveryFormState) _then;

/// Create a copy of RecoveryFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recoveryToken = null,Object? newPassword = null,Object? confirmPassword = null,Object? submitting = null,Object? success = null,Object? error = freezed,Object? failure = freezed,}) {
  return _then(RecoveryFormState(
recoveryToken: null == recoveryToken ? _self.recoveryToken : recoveryToken // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}
/// Create a copy of RecoveryFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $AppErrorCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecoveryFormState].
extension RecoveryFormStatePatterns on RecoveryFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecoveryFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecoveryFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecoveryFormState value)  $default,){
final _that = this;
switch (_that) {
case _RecoveryFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecoveryFormState value)?  $default,){
final _that = this;
switch (_that) {
case _RecoveryFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String recoveryToken,  String newPassword,  String confirmPassword,  bool submitting,  bool success,  String? error,  AppError? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecoveryFormState() when $default != null:
return $default(_that.recoveryToken,_that.newPassword,_that.confirmPassword,_that.submitting,_that.success,_that.error,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String recoveryToken,  String newPassword,  String confirmPassword,  bool submitting,  bool success,  String? error,  AppError? failure)  $default,) {final _that = this;
switch (_that) {
case _RecoveryFormState():
return $default(_that.recoveryToken,_that.newPassword,_that.confirmPassword,_that.submitting,_that.success,_that.error,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String recoveryToken,  String newPassword,  String confirmPassword,  bool submitting,  bool success,  String? error,  AppError? failure)?  $default,) {final _that = this;
switch (_that) {
case _RecoveryFormState() when $default != null:
return $default(_that.recoveryToken,_that.newPassword,_that.confirmPassword,_that.submitting,_that.success,_that.error,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _RecoveryFormState implements RecoveryFormState {
  const _RecoveryFormState({this.recoveryToken = '', this.newPassword = '', this.confirmPassword = '', this.submitting = false, this.success = false, this.error, this.failure});
  

@override@JsonKey() final  String recoveryToken;
@override@JsonKey() final  String newPassword;
@override@JsonKey() final  String confirmPassword;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool success;
/// A [PasswordFormErrorCode] from the local checks.
@override final  String? error;
/// A repository failure, surfaced through the shared `ErrorBanner`.
@override final  AppError? failure;

/// Create a copy of RecoveryFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveryFormStateCopyWith<_RecoveryFormState> get copyWith => __$RecoveryFormStateCopyWithImpl<_RecoveryFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecoveryFormState&&(identical(other.recoveryToken, recoveryToken) || other.recoveryToken == recoveryToken)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.error, error) || other.error == error)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,recoveryToken,newPassword,confirmPassword,submitting,success,error,failure);
}

@override
String toString() {
    return 'RecoveryFormState(recoveryToken: $recoveryToken, newPassword: $newPassword, confirmPassword: $confirmPassword, submitting: $submitting, success: $success, error: $error, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$RecoveryFormStateCopyWith<$Res> implements $RecoveryFormStateCopyWith<$Res> {
  factory _$RecoveryFormStateCopyWith(_RecoveryFormState value, $Res Function(_RecoveryFormState) _then) = __$RecoveryFormStateCopyWithImpl;
@override @useResult
$Res call({
 String recoveryToken, String newPassword, String confirmPassword, bool submitting, bool success, String? error, AppError? failure
});


@override $AppErrorCopyWith<$Res>? get failure;

}
/// @nodoc
class __$RecoveryFormStateCopyWithImpl<$Res>
    implements _$RecoveryFormStateCopyWith<$Res> {
  __$RecoveryFormStateCopyWithImpl(this._self, this._then);

  final _RecoveryFormState _self;
  final $Res Function(_RecoveryFormState) _then;

/// Create a copy of RecoveryFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recoveryToken = null,Object? newPassword = null,Object? confirmPassword = null,Object? submitting = null,Object? success = null,Object? error = freezed,Object? failure = freezed,}) {
  return _then(_RecoveryFormState(
recoveryToken: null == recoveryToken ? _self.recoveryToken : recoveryToken // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}

/// Create a copy of RecoveryFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res>? get failure {
    if (_self.failure == null) {
    return null;
  }

  return $AppErrorCopyWith<$Res>(_self.failure!, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
