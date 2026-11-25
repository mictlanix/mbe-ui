// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'participation_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommissionParticipationFormState {

 String get name; bool get submitting; bool get nameRequired;/// The server's refusal of the last write.
 AppError? get error;
/// Create a copy of CommissionParticipationFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommissionParticipationFormStateCopyWith<CommissionParticipationFormState> get copyWith => _$CommissionParticipationFormStateCopyWithImpl<CommissionParticipationFormState>(this as CommissionParticipationFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CommissionParticipationFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommissionParticipationFormState&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.submitting, _this.submitting) || other.submitting == _this.submitting)&&(identical(other.nameRequired, _this.nameRequired) || other.nameRequired == _this.nameRequired)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as CommissionParticipationFormState;
  return Object.hash(runtimeType,_this.name,_this.submitting,_this.nameRequired,_this.error);
}

@override
String toString() {
  final _this = this as CommissionParticipationFormState;
  return 'CommissionParticipationFormState(name: ${_this.name}, submitting: ${_this.submitting}, nameRequired: ${_this.nameRequired}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $CommissionParticipationFormStateCopyWith<$Res>  {
  factory $CommissionParticipationFormStateCopyWith(CommissionParticipationFormState value, $Res Function(CommissionParticipationFormState) _then) = _$CommissionParticipationFormStateCopyWithImpl;
@useResult
$Res call({
 String name, bool submitting, bool nameRequired, AppError? error
});


$AppErrorCopyWith<$Res>? get error;

}
/// @nodoc
class _$CommissionParticipationFormStateCopyWithImpl<$Res>
    implements $CommissionParticipationFormStateCopyWith<$Res> {
  _$CommissionParticipationFormStateCopyWithImpl(this._self, this._then);

  final CommissionParticipationFormState _self;
  final $Res Function(CommissionParticipationFormState) _then;

/// Create a copy of CommissionParticipationFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? submitting = null,Object? nameRequired = null,Object? error = freezed,}) {
  return _then(CommissionParticipationFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,nameRequired: null == nameRequired ? _self.nameRequired : nameRequired // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}
/// Create a copy of CommissionParticipationFormState
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


/// Adds pattern-matching-related methods to [CommissionParticipationFormState].
extension CommissionParticipationFormStatePatterns on CommissionParticipationFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommissionParticipationFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommissionParticipationFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommissionParticipationFormState value)  $default,){
final _that = this;
switch (_that) {
case _CommissionParticipationFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommissionParticipationFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CommissionParticipationFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  bool submitting,  bool nameRequired,  AppError? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommissionParticipationFormState() when $default != null:
return $default(_that.name,_that.submitting,_that.nameRequired,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  bool submitting,  bool nameRequired,  AppError? error)  $default,) {final _that = this;
switch (_that) {
case _CommissionParticipationFormState():
return $default(_that.name,_that.submitting,_that.nameRequired,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  bool submitting,  bool nameRequired,  AppError? error)?  $default,) {final _that = this;
switch (_that) {
case _CommissionParticipationFormState() when $default != null:
return $default(_that.name,_that.submitting,_that.nameRequired,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CommissionParticipationFormState implements CommissionParticipationFormState {
  const _CommissionParticipationFormState({this.name = '', this.submitting = false, this.nameRequired = false, this.error});
  

@override@JsonKey() final  String name;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool nameRequired;
/// The server's refusal of the last write.
@override final  AppError? error;

/// Create a copy of CommissionParticipationFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommissionParticipationFormStateCopyWith<_CommissionParticipationFormState> get copyWith => __$CommissionParticipationFormStateCopyWithImpl<_CommissionParticipationFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommissionParticipationFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.nameRequired, nameRequired) || other.nameRequired == nameRequired)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,submitting,nameRequired,error);
}

@override
String toString() {
    return 'CommissionParticipationFormState(name: $name, submitting: $submitting, nameRequired: $nameRequired, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CommissionParticipationFormStateCopyWith<$Res> implements $CommissionParticipationFormStateCopyWith<$Res> {
  factory _$CommissionParticipationFormStateCopyWith(_CommissionParticipationFormState value, $Res Function(_CommissionParticipationFormState) _then) = __$CommissionParticipationFormStateCopyWithImpl;
@override @useResult
$Res call({
 String name, bool submitting, bool nameRequired, AppError? error
});


@override $AppErrorCopyWith<$Res>? get error;

}
/// @nodoc
class __$CommissionParticipationFormStateCopyWithImpl<$Res>
    implements _$CommissionParticipationFormStateCopyWith<$Res> {
  __$CommissionParticipationFormStateCopyWithImpl(this._self, this._then);

  final _CommissionParticipationFormState _self;
  final $Res Function(_CommissionParticipationFormState) _then;

/// Create a copy of CommissionParticipationFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? submitting = null,Object? nameRequired = null,Object? error = freezed,}) {
  return _then(_CommissionParticipationFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,nameRequired: null == nameRequired ? _self.nameRequired : nameRequired // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError?,
  ));
}

/// Create a copy of CommissionParticipationFormState
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
