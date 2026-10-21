// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppError {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AppError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AppError()';
}


}

/// @nodoc
class $AppErrorCopyWith<$Res>  {
$AppErrorCopyWith(AppError _, $Res Function(AppError) __);
}


/// Adds pattern-matching-related methods to [AppError].
extension AppErrorPatterns on AppError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ValidationError value)?  validation,TResult Function( AuthError value)?  auth,TResult Function( NotFoundError value)?  notFound,TResult Function( ServerError value)?  server,TResult Function( NetworkError value)?  network,TResult Function( CreditHoldError value)?  creditHold,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ValidationError() when validation != null:
return validation(_that);case AuthError() when auth != null:
return auth(_that);case NotFoundError() when notFound != null:
return notFound(_that);case ServerError() when server != null:
return server(_that);case NetworkError() when network != null:
return network(_that);case CreditHoldError() when creditHold != null:
return creditHold(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ValidationError value)  validation,required TResult Function( AuthError value)  auth,required TResult Function( NotFoundError value)  notFound,required TResult Function( ServerError value)  server,required TResult Function( NetworkError value)  network,required TResult Function( CreditHoldError value)  creditHold,}){
final _that = this;
switch (_that) {
case ValidationError():
return validation(_that);case AuthError():
return auth(_that);case NotFoundError():
return notFound(_that);case ServerError():
return server(_that);case NetworkError():
return network(_that);case CreditHoldError():
return creditHold(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ValidationError value)?  validation,TResult? Function( AuthError value)?  auth,TResult? Function( NotFoundError value)?  notFound,TResult? Function( ServerError value)?  server,TResult? Function( NetworkError value)?  network,TResult? Function( CreditHoldError value)?  creditHold,}){
final _that = this;
switch (_that) {
case ValidationError() when validation != null:
return validation(_that);case AuthError() when auth != null:
return auth(_that);case NotFoundError() when notFound != null:
return notFound(_that);case ServerError() when server != null:
return server(_that);case NetworkError() when network != null:
return network(_that);case CreditHoldError() when creditHold != null:
return creditHold(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<FieldError> errors)?  validation,TResult Function( String? message)?  auth,TResult Function( String? message)?  notFound,TResult Function( int? statusCode,  String? message)?  server,TResult Function( String? message)?  network,TResult Function( String? message)?  creditHold,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ValidationError() when validation != null:
return validation(_that.errors);case AuthError() when auth != null:
return auth(_that.message);case NotFoundError() when notFound != null:
return notFound(_that.message);case ServerError() when server != null:
return server(_that.statusCode,_that.message);case NetworkError() when network != null:
return network(_that.message);case CreditHoldError() when creditHold != null:
return creditHold(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<FieldError> errors)  validation,required TResult Function( String? message)  auth,required TResult Function( String? message)  notFound,required TResult Function( int? statusCode,  String? message)  server,required TResult Function( String? message)  network,required TResult Function( String? message)  creditHold,}) {final _that = this;
switch (_that) {
case ValidationError():
return validation(_that.errors);case AuthError():
return auth(_that.message);case NotFoundError():
return notFound(_that.message);case ServerError():
return server(_that.statusCode,_that.message);case NetworkError():
return network(_that.message);case CreditHoldError():
return creditHold(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<FieldError> errors)?  validation,TResult? Function( String? message)?  auth,TResult? Function( String? message)?  notFound,TResult? Function( int? statusCode,  String? message)?  server,TResult? Function( String? message)?  network,TResult? Function( String? message)?  creditHold,}) {final _that = this;
switch (_that) {
case ValidationError() when validation != null:
return validation(_that.errors);case AuthError() when auth != null:
return auth(_that.message);case NotFoundError() when notFound != null:
return notFound(_that.message);case ServerError() when server != null:
return server(_that.statusCode,_that.message);case NetworkError() when network != null:
return network(_that.message);case CreditHoldError() when creditHold != null:
return creditHold(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ValidationError implements AppError {
  const ValidationError( List<FieldError> errors): _errors = errors;
  

 final  List<FieldError> _errors;
 List<FieldError> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}


/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationErrorCopyWith<ValidationError> get copyWith => _$ValidationErrorCopyWithImpl<ValidationError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationError&&const DeepCollectionEquality().equals(other.errors, _errors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_errors));
}

@override
String toString() {
    return 'AppError.validation(errors: $errors)';
}


}

/// @nodoc
abstract mixin class $ValidationErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $ValidationErrorCopyWith(ValidationError value, $Res Function(ValidationError) _then) = _$ValidationErrorCopyWithImpl;
@useResult
$Res call({
 List<FieldError> errors
});




}
/// @nodoc
class _$ValidationErrorCopyWithImpl<$Res>
    implements $ValidationErrorCopyWith<$Res> {
  _$ValidationErrorCopyWithImpl(this._self, this._then);

  final ValidationError _self;
  final $Res Function(ValidationError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? errors = null,}) {
  return _then(ValidationError(
null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<FieldError>,
  ));
}


}

/// @nodoc


class AuthError implements AppError {
  const AuthError([this.message]);
  

 final  String? message;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthErrorCopyWith<AuthError> get copyWith => _$AuthErrorCopyWithImpl<AuthError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'AppError.auth(message: $message)';
}


}

/// @nodoc
abstract mixin class $AuthErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $AuthErrorCopyWith(AuthError value, $Res Function(AuthError) _then) = _$AuthErrorCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$AuthErrorCopyWithImpl<$Res>
    implements $AuthErrorCopyWith<$Res> {
  _$AuthErrorCopyWithImpl(this._self, this._then);

  final AuthError _self;
  final $Res Function(AuthError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(AuthError(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class NotFoundError implements AppError {
  const NotFoundError([this.message]);
  

 final  String? message;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotFoundErrorCopyWith<NotFoundError> get copyWith => _$NotFoundErrorCopyWithImpl<NotFoundError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFoundError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'AppError.notFound(message: $message)';
}


}

/// @nodoc
abstract mixin class $NotFoundErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $NotFoundErrorCopyWith(NotFoundError value, $Res Function(NotFoundError) _then) = _$NotFoundErrorCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$NotFoundErrorCopyWithImpl<$Res>
    implements $NotFoundErrorCopyWith<$Res> {
  _$NotFoundErrorCopyWithImpl(this._self, this._then);

  final NotFoundError _self;
  final $Res Function(NotFoundError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(NotFoundError(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ServerError implements AppError {
  const ServerError({this.statusCode, this.message});
  

 final  int? statusCode;
 final  String? message;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerErrorCopyWith<ServerError> get copyWith => _$ServerErrorCopyWithImpl<ServerError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerError&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,statusCode,message);
}

@override
String toString() {
    return 'AppError.server(statusCode: $statusCode, message: $message)';
}


}

/// @nodoc
abstract mixin class $ServerErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $ServerErrorCopyWith(ServerError value, $Res Function(ServerError) _then) = _$ServerErrorCopyWithImpl;
@useResult
$Res call({
 int? statusCode, String? message
});




}
/// @nodoc
class _$ServerErrorCopyWithImpl<$Res>
    implements $ServerErrorCopyWith<$Res> {
  _$ServerErrorCopyWithImpl(this._self, this._then);

  final ServerError _self;
  final $Res Function(ServerError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? statusCode = freezed,Object? message = freezed,}) {
  return _then(ServerError(
statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class NetworkError implements AppError {
  const NetworkError([this.message]);
  

 final  String? message;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkErrorCopyWith<NetworkError> get copyWith => _$NetworkErrorCopyWithImpl<NetworkError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'AppError.network(message: $message)';
}


}

/// @nodoc
abstract mixin class $NetworkErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $NetworkErrorCopyWith(NetworkError value, $Res Function(NetworkError) _then) = _$NetworkErrorCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$NetworkErrorCopyWithImpl<$Res>
    implements $NetworkErrorCopyWith<$Res> {
  _$NetworkErrorCopyWithImpl(this._self, this._then);

  final NetworkError _self;
  final $Res Function(NetworkError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(NetworkError(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class CreditHoldError implements AppError {
  const CreditHoldError([this.message]);
  

 final  String? message;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditHoldErrorCopyWith<CreditHoldError> get copyWith => _$CreditHoldErrorCopyWithImpl<CreditHoldError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditHoldError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'AppError.creditHold(message: $message)';
}


}

/// @nodoc
abstract mixin class $CreditHoldErrorCopyWith<$Res> implements $AppErrorCopyWith<$Res> {
  factory $CreditHoldErrorCopyWith(CreditHoldError value, $Res Function(CreditHoldError) _then) = _$CreditHoldErrorCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$CreditHoldErrorCopyWithImpl<$Res>
    implements $CreditHoldErrorCopyWith<$Res> {
  _$CreditHoldErrorCopyWithImpl(this._self, this._then);

  final CreditHoldError _self;
  final $Res Function(CreditHoldError) _then;

/// Create a copy of AppError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(CreditHoldError(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$FieldError {

 List<String> get loc; String get msg; String get type;/// The rule names in `ctx.failed` of a `password_policy` rejection.
 List<String> get failedRules;
/// Create a copy of FieldError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldErrorCopyWith<FieldError> get copyWith => _$FieldErrorCopyWithImpl<FieldError>(this as FieldError, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FieldError;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldError&&const DeepCollectionEquality().equals(other.loc, _this.loc)&&(identical(other.msg, _this.msg) || other.msg == _this.msg)&&(identical(other.type, _this.type) || other.type == _this.type)&&const DeepCollectionEquality().equals(other.failedRules, _this.failedRules));
}


@override
int get hashCode {
  final _this = this as FieldError;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.loc),_this.msg,_this.type,const DeepCollectionEquality().hash(_this.failedRules));
}

@override
String toString() {
  final _this = this as FieldError;
  return 'FieldError(loc: ${_this.loc}, msg: ${_this.msg}, type: ${_this.type}, failedRules: ${_this.failedRules})';
}


}

/// @nodoc
abstract mixin class $FieldErrorCopyWith<$Res>  {
  factory $FieldErrorCopyWith(FieldError value, $Res Function(FieldError) _then) = _$FieldErrorCopyWithImpl;
@useResult
$Res call({
 List<String> loc, String msg, String type, List<String> failedRules
});




}
/// @nodoc
class _$FieldErrorCopyWithImpl<$Res>
    implements $FieldErrorCopyWith<$Res> {
  _$FieldErrorCopyWithImpl(this._self, this._then);

  final FieldError _self;
  final $Res Function(FieldError) _then;

/// Create a copy of FieldError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loc = null,Object? msg = null,Object? type = null,Object? failedRules = null,}) {
  return _then(FieldError(
loc: null == loc ? _self.loc : loc // ignore: cast_nullable_to_non_nullable
as List<String>,msg: null == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,failedRules: null == failedRules ? _self.failedRules : failedRules // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [FieldError].
extension FieldErrorPatterns on FieldError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FieldError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FieldError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FieldError value)  $default,){
final _that = this;
switch (_that) {
case _FieldError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FieldError value)?  $default,){
final _that = this;
switch (_that) {
case _FieldError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> loc,  String msg,  String type,  List<String> failedRules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FieldError() when $default != null:
return $default(_that.loc,_that.msg,_that.type,_that.failedRules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> loc,  String msg,  String type,  List<String> failedRules)  $default,) {final _that = this;
switch (_that) {
case _FieldError():
return $default(_that.loc,_that.msg,_that.type,_that.failedRules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> loc,  String msg,  String type,  List<String> failedRules)?  $default,) {final _that = this;
switch (_that) {
case _FieldError() when $default != null:
return $default(_that.loc,_that.msg,_that.type,_that.failedRules);case _:
  return null;

}
}

}

/// @nodoc


class _FieldError implements FieldError {
  const _FieldError({required  List<String> loc, required this.msg, required this.type,  List<String> failedRules = const <String>[]}): _loc = loc,_failedRules = failedRules;
  

 final  List<String> _loc;
@override List<String> get loc {
  if (_loc is EqualUnmodifiableListView) return _loc;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_loc);
}

@override final  String msg;
@override final  String type;
/// The rule names in `ctx.failed` of a `password_policy` rejection.
 final  List<String> _failedRules;
/// The rule names in `ctx.failed` of a `password_policy` rejection.
@override@JsonKey() List<String> get failedRules {
  if (_failedRules is EqualUnmodifiableListView) return _failedRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_failedRules);
}


/// Create a copy of FieldError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldErrorCopyWith<_FieldError> get copyWith => __$FieldErrorCopyWithImpl<_FieldError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FieldError&&const DeepCollectionEquality().equals(other.loc, _loc)&&(identical(other.msg, msg) || other.msg == msg)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.failedRules, _failedRules));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_loc),msg,type,const DeepCollectionEquality().hash(_failedRules));
}

@override
String toString() {
    return 'FieldError(loc: $loc, msg: $msg, type: $type, failedRules: $failedRules)';
}


}

/// @nodoc
abstract mixin class _$FieldErrorCopyWith<$Res> implements $FieldErrorCopyWith<$Res> {
  factory _$FieldErrorCopyWith(_FieldError value, $Res Function(_FieldError) _then) = __$FieldErrorCopyWithImpl;
@override @useResult
$Res call({
 List<String> loc, String msg, String type, List<String> failedRules
});




}
/// @nodoc
class __$FieldErrorCopyWithImpl<$Res>
    implements _$FieldErrorCopyWith<$Res> {
  __$FieldErrorCopyWithImpl(this._self, this._then);

  final _FieldError _self;
  final $Res Function(_FieldError) _then;

/// Create a copy of FieldError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loc = null,Object? msg = null,Object? type = null,Object? failedRules = null,}) {
  return _then(_FieldError(
loc: null == loc ? _self._loc : loc // ignore: cast_nullable_to_non_nullable
as List<String>,msg: null == msg ? _self.msg : msg // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,failedRules: null == failedRules ? _self._failedRules : failedRules // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
