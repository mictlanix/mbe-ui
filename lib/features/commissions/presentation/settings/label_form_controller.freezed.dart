// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'label_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommissionLabelFormState {

 String get name;/// The rate as typed, a percentage ("2.5").
 String get rate; String get comment; bool get submitting; bool get nameRequired; PercentInputError? get rateError;/// The server's refusal of the last write.
 AppError? get error;
/// Create a copy of CommissionLabelFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionLabelFormStateCopyWith<CommissionLabelFormState> get copyWith => _$CommissionLabelFormStateCopyWithImpl<CommissionLabelFormState>(this as CommissionLabelFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionLabelFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionLabelFormState&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.rate, _this.rate) || other.rate == _this.rate)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.nameRequired, _this.nameRequired) || other.nameRequired == _this.nameRequired)&&(identical(other.rateError, _this.rateError) || other.rateError == _this.rateError)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as CommissionLabelFormState;
  return Object.hash(runtimeType,_this.name,_this.rate,_this.comment,_this.submitting,_this.nameRequired,_this.rateError,_this.error);
}

@override
String toString() {
  final _this = this as CommissionLabelFormState;
  return 'CommissionLabelFormState(name: ${_this.name}, rate: ${_this.rate}, comment: ${_this.comment}, submitting: ${_this.submitting}, nameRequired: ${_this.nameRequired}, rateError: ${_this.rateError}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $CommissionLabelFormStateCopyWith<$Res>  {
  factory $CommissionLabelFormStateCopyWith(CommissionLabelFormState value, $Res Function(CommissionLabelFormState) _then) = _$CommissionLabelFormStateCopyWithImpl;
@useResult
$Res call({
 String name, String rate, String comment, bool submitting, bool nameRequired, PercentInputError? rateError, AppError? error
});


$AppErrorCopyWith<$Res>? get error;

}
/// @nodoc
class _$CommissionLabelFormStateCopyWithImpl<$Res>
    implements $CommissionLabelFormStateCopyWith<$Res> {
  _$CommissionLabelFormStateCopyWithImpl(this._self, this._then);

  final CommissionLabelFormState _self;
  final $Res Function(CommissionLabelFormState) _then;

/// Create a copy of CommissionLabelFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? rate = null,Object? comment = null,Object? submitting = null,Object? nameRequired = null,Object? rateError = freezed,Object? error = freezed,}) {
  return _then(CommissionLabelFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,nameRequired: null == nameRequired ? _self.nameRequired : nameRequired // ignore: cast_nullable_to_non_nullable
as bool,rateError: freezed == rateError ? _self.rateError : rateError // ignore: cast_nullable_to_non_nullable
as PercentInputError?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}
/// Create a copy of CommissionLabelFormState
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


/// Adds pattern-matching-related methods to [CommissionLabelFormState].
extension CommissionLabelFormStatePatterns on CommissionLabelFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionLabelFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionLabelFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionLabelFormState value)  $default,){
final _that = this;
switch (_that) {
case _CommissionLabelFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionLabelFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionLabelFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String rate,  String comment,  bool submitting,  bool nameRequired,  PercentInputError? rateError,  AppError? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionLabelFormState() when $default != null:
return $default(_that.name,_that.rate,_that.comment,_that.submitting,_that.nameRequired,_that.rateError,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String rate,  String comment,  bool submitting,  bool nameRequired,  PercentInputError? rateError,  AppError? error)  $default,) {final _that = this;
switch (_that) {
case _CommissionLabelFormState():
return $default(_that.name,_that.rate,_that.comment,_that.submitting,_that.nameRequired,_that.rateError,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String rate,  String comment,  bool submitting,  bool nameRequired,  PercentInputError? rateError,  AppError? error)?  $default,) {final _that = this;
switch (_that) {
case _CommissionLabelFormState() when $default != null:
return $default(_that.name,_that.rate,_that.comment,_that.submitting,_that.nameRequired,_that.rateError,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionLabelFormState implements CommissionLabelFormState {
  const _CommissionLabelFormState({this.name = '', this.rate = '', this.comment = '', this.submitting = false, this.nameRequired = false, this.rateError, this.error});
  

@override@JsonKey() final  String name;
/// The rate as typed, a percentage ("2.5").
@override@JsonKey() final  String rate;
@override@JsonKey() final  String comment;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool nameRequired;
@override final  PercentInputError? rateError;
/// The server's refusal of the last write.
@override final  AppError? error;

/// Create a copy of CommissionLabelFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionLabelFormStateCopyWith<_CommissionLabelFormState> get copyWith => __$CommissionLabelFormStateCopyWithImpl<_CommissionLabelFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionLabelFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.nameRequired, nameRequired) || other.nameRequired == nameRequired)&&(identical(other.rateError, rateError) || other.rateError == rateError)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,rate,comment,submitting,nameRequired,rateError,error);
}

@override
String toString() {
    return 'CommissionLabelFormState(name: $name, rate: $rate, comment: $comment, submitting: $submitting, nameRequired: $nameRequired, rateError: $rateError, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CommissionLabelFormStateCopyWith<$Res> implements $CommissionLabelFormStateCopyWith<$Res> {
  factory _$CommissionLabelFormStateCopyWith(_CommissionLabelFormState value, $Res Function(_CommissionLabelFormState) _then) = __$CommissionLabelFormStateCopyWithImpl;
@override @useResult
$Res call({
 String name, String rate, String comment, bool submitting, bool nameRequired, PercentInputError? rateError, AppError? error
});


@override $AppErrorCopyWith<$Res>? get error;

}
/// @nodoc
class __$CommissionLabelFormStateCopyWithImpl<$Res>
    implements _$CommissionLabelFormStateCopyWith<$Res> {
  __$CommissionLabelFormStateCopyWithImpl(this._self, this._then);

  final _CommissionLabelFormState _self;
  final $Res Function(_CommissionLabelFormState) _then;

/// Create a copy of CommissionLabelFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? rate = null,Object? comment = null,Object? submitting = null,Object? nameRequired = null,Object? rateError = freezed,Object? error = freezed,}) {
  return _then(_CommissionLabelFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as String,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,nameRequired: null == nameRequired ? _self.nameRequired : nameRequired // ignore: cast_nullable_to_non_nullable
as bool,rateError: freezed == rateError ? _self.rateError : rateError // ignore: cast_nullable_to_non_nullable
as PercentInputError?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}

/// Create a copy of CommissionLabelFormState
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
