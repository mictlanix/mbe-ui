// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommissionAgentFormState {

/// The chosen employee; fixed when editing.
 int? get employeeId; CommissionScheme get scheme; bool get submitting; bool get employeeRequired;/// The server's refusal of the last write.
 AppError? get error;
/// Create a copy of CommissionAgentFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionAgentFormStateCopyWith<CommissionAgentFormState> get copyWith => _$CommissionAgentFormStateCopyWithImpl<CommissionAgentFormState>(this as CommissionAgentFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionAgentFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionAgentFormState&&(identical(other.employeeId, _this.employeeId) || other.employeeId == _this.employeeId)&&(identical(other.scheme, _this.scheme) || other.scheme == _this.scheme)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.employeeRequired, _this.employeeRequired) || other.employeeRequired == _this.employeeRequired)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as CommissionAgentFormState;
  return Object.hash(runtimeType,_this.employeeId,_this.scheme,_this.submitting,_this.employeeRequired,_this.error);
}

@override
String toString() {
  final _this = this as CommissionAgentFormState;
  return 'CommissionAgentFormState(employeeId: ${_this.employeeId}, scheme: ${_this.scheme}, submitting: ${_this.submitting}, employeeRequired: ${_this.employeeRequired}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $CommissionAgentFormStateCopyWith<$Res>  {
  factory $CommissionAgentFormStateCopyWith(CommissionAgentFormState value, $Res Function(CommissionAgentFormState) _then) = _$CommissionAgentFormStateCopyWithImpl;
@useResult
$Res call({
 int? employeeId, CommissionScheme scheme, bool submitting, bool employeeRequired, AppError? error
});


$AppErrorCopyWith<$Res>? get error;

}
/// @nodoc
class _$CommissionAgentFormStateCopyWithImpl<$Res>
    implements $CommissionAgentFormStateCopyWith<$Res> {
  _$CommissionAgentFormStateCopyWithImpl(this._self, this._then);

  final CommissionAgentFormState _self;
  final $Res Function(CommissionAgentFormState) _then;

/// Create a copy of CommissionAgentFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? employeeId = freezed,Object? scheme = null,Object? submitting = null,Object? employeeRequired = null,Object? error = freezed,}) {
  return _then(CommissionAgentFormState(
employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int?,scheme: null == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as CommissionScheme,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,employeeRequired: null == employeeRequired ? _self.employeeRequired : employeeRequired // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}
/// Create a copy of CommissionAgentFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $AppErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommissionAgentFormState].
extension CommissionAgentFormStatePatterns on CommissionAgentFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionAgentFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionAgentFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionAgentFormState value)  $default,){
final _that = this;
switch (_that) {
case _CommissionAgentFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionAgentFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionAgentFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? employeeId,  CommissionScheme scheme,  bool submitting,  bool employeeRequired,  AppError? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionAgentFormState() when $default != null:
return $default(_that.employeeId,_that.scheme,_that.submitting,_that.employeeRequired,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? employeeId,  CommissionScheme scheme,  bool submitting,  bool employeeRequired,  AppError? error)  $default,) {final _that = this;
switch (_that) {
case _CommissionAgentFormState():
return $default(_that.employeeId,_that.scheme,_that.submitting,_that.employeeRequired,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? employeeId,  CommissionScheme scheme,  bool submitting,  bool employeeRequired,  AppError? error)?  $default,) {final _that = this;
switch (_that) {
case _CommissionAgentFormState() when $default != null:
return $default(_that.employeeId,_that.scheme,_that.submitting,_that.employeeRequired,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionAgentFormState implements CommissionAgentFormState {
  const _CommissionAgentFormState({this.employeeId, this.scheme = CommissionScheme.fullyPaid, this.submitting = false, this.employeeRequired = false, this.error});
  

/// The chosen employee; fixed when editing.
@override final  int? employeeId;
@override@JsonKey() final  CommissionScheme scheme;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool employeeRequired;
/// The server's refusal of the last write.
@override final  AppError? error;

/// Create a copy of CommissionAgentFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionAgentFormStateCopyWith<_CommissionAgentFormState> get copyWith => __$CommissionAgentFormStateCopyWithImpl<_CommissionAgentFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionAgentFormState&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.scheme, scheme) || other.scheme == scheme)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.employeeRequired, employeeRequired) || other.employeeRequired == employeeRequired)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,employeeId,scheme,submitting,employeeRequired,error);
}

@override
String toString() {
    return 'CommissionAgentFormState(employeeId: $employeeId, scheme: $scheme, submitting: $submitting, employeeRequired: $employeeRequired, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CommissionAgentFormStateCopyWith<$Res> implements $CommissionAgentFormStateCopyWith<$Res> {
  factory _$CommissionAgentFormStateCopyWith(_CommissionAgentFormState value, $Res Function(_CommissionAgentFormState) _then) = __$CommissionAgentFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? employeeId, CommissionScheme scheme, bool submitting, bool employeeRequired, AppError? error
});


@override $AppErrorCopyWith<$Res>? get error;

}
/// @nodoc
class __$CommissionAgentFormStateCopyWithImpl<$Res>
    implements _$CommissionAgentFormStateCopyWith<$Res> {
  __$CommissionAgentFormStateCopyWithImpl(this._self, this._then);

  final _CommissionAgentFormState _self;
  final $Res Function(_CommissionAgentFormState) _then;

/// Create a copy of CommissionAgentFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? employeeId = freezed,Object? scheme = null,Object? submitting = null,Object? employeeRequired = null,Object? error = freezed,}) {
  return _then(_CommissionAgentFormState(
employeeId: freezed == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int?,scheme: null == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as CommissionScheme,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,employeeRequired: null == employeeRequired ? _self.employeeRequired : employeeRequired // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}

/// Create a copy of CommissionAgentFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppErrorCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $AppErrorCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
