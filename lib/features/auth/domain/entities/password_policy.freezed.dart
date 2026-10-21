// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_policy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PasswordPolicy {

 int get minLength; bool get requireUpper; bool get requireLower; bool get requireDigit; bool get requireSymbol;
/// Create a copy of PasswordPolicy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordPolicyCopyWith<PasswordPolicy> get copyWith => _$PasswordPolicyCopyWithImpl<PasswordPolicy>(this as PasswordPolicy, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PasswordPolicy;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordPolicy&&(identical(other.minLength, _this.minLength) || other.minLength == _this.minLength)&&(identical(other.requireUpper, _this.requireUpper) || other.requireUpper == _this.requireUpper)&&(identical(other.requireLower, _this.requireLower) || other.requireLower == _this.requireLower)&&(identical(other.requireDigit, _this.requireDigit) || other.requireDigit == _this.requireDigit)&&(identical(other.requireSymbol, _this.requireSymbol) || other.requireSymbol == _this.requireSymbol));
}


@override
int get hashCode {
  final _this = this as PasswordPolicy;
  return Object.hash(runtimeType,_this.minLength,_this.requireUpper,_this.requireLower,_this.requireDigit,_this.requireSymbol);
}

@override
String toString() {
  final _this = this as PasswordPolicy;
  return 'PasswordPolicy(minLength: ${_this.minLength}, requireUpper: ${_this.requireUpper}, requireLower: ${_this.requireLower}, requireDigit: ${_this.requireDigit}, requireSymbol: ${_this.requireSymbol})';
}


}

/// @nodoc
abstract mixin class $PasswordPolicyCopyWith<$Res>  {
  factory $PasswordPolicyCopyWith(PasswordPolicy value, $Res Function(PasswordPolicy) _then) = _$PasswordPolicyCopyWithImpl;
@useResult
$Res call({
 int minLength, bool requireUpper, bool requireLower, bool requireDigit, bool requireSymbol
});




}
/// @nodoc
class _$PasswordPolicyCopyWithImpl<$Res>
    implements $PasswordPolicyCopyWith<$Res> {
  _$PasswordPolicyCopyWithImpl(this._self, this._then);

  final PasswordPolicy _self;
  final $Res Function(PasswordPolicy) _then;

/// Create a copy of PasswordPolicy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minLength = null,Object? requireUpper = null,Object? requireLower = null,Object? requireDigit = null,Object? requireSymbol = null,}) {
  return _then(PasswordPolicy(
minLength: null == minLength ? _self.minLength : minLength // ignore: cast_nullable_to_non_nullable
as int,requireUpper: null == requireUpper ? _self.requireUpper : requireUpper // ignore: cast_nullable_to_non_nullable
as bool,requireLower: null == requireLower ? _self.requireLower : requireLower // ignore: cast_nullable_to_non_nullable
as bool,requireDigit: null == requireDigit ? _self.requireDigit : requireDigit // ignore: cast_nullable_to_non_nullable
as bool,requireSymbol: null == requireSymbol ? _self.requireSymbol : requireSymbol // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordPolicy].
extension PasswordPolicyPatterns on PasswordPolicy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordPolicy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordPolicy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordPolicy value)  $default,){
final _that = this;
switch (_that) {
case _PasswordPolicy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordPolicy value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordPolicy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int minLength,  bool requireUpper,  bool requireLower,  bool requireDigit,  bool requireSymbol)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordPolicy() when $default != null:
return $default(_that.minLength,_that.requireUpper,_that.requireLower,_that.requireDigit,_that.requireSymbol);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int minLength,  bool requireUpper,  bool requireLower,  bool requireDigit,  bool requireSymbol)  $default,) {final _that = this;
switch (_that) {
case _PasswordPolicy():
return $default(_that.minLength,_that.requireUpper,_that.requireLower,_that.requireDigit,_that.requireSymbol);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int minLength,  bool requireUpper,  bool requireLower,  bool requireDigit,  bool requireSymbol)?  $default,) {final _that = this;
switch (_that) {
case _PasswordPolicy() when $default != null:
return $default(_that.minLength,_that.requireUpper,_that.requireLower,_that.requireDigit,_that.requireSymbol);case _:
  return null;

}
}

}

/// @nodoc


class _PasswordPolicy extends PasswordPolicy {
  const _PasswordPolicy({required this.minLength, required this.requireUpper, required this.requireLower, required this.requireDigit, required this.requireSymbol}): super._();
  

@override final  int minLength;
@override final  bool requireUpper;
@override final  bool requireLower;
@override final  bool requireDigit;
@override final  bool requireSymbol;

/// Create a copy of PasswordPolicy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordPolicyCopyWith<_PasswordPolicy> get copyWith => __$PasswordPolicyCopyWithImpl<_PasswordPolicy>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordPolicy&&(identical(other.minLength, minLength) || other.minLength == minLength)&&(identical(other.requireUpper, requireUpper) || other.requireUpper == requireUpper)&&(identical(other.requireLower, requireLower) || other.requireLower == requireLower)&&(identical(other.requireDigit, requireDigit) || other.requireDigit == requireDigit)&&(identical(other.requireSymbol, requireSymbol) || other.requireSymbol == requireSymbol));
}


@override
int get hashCode {
    return Object.hash(runtimeType,minLength,requireUpper,requireLower,requireDigit,requireSymbol);
}

@override
String toString() {
    return 'PasswordPolicy(minLength: $minLength, requireUpper: $requireUpper, requireLower: $requireLower, requireDigit: $requireDigit, requireSymbol: $requireSymbol)';
}


}

/// @nodoc
abstract mixin class _$PasswordPolicyCopyWith<$Res> implements $PasswordPolicyCopyWith<$Res> {
  factory _$PasswordPolicyCopyWith(_PasswordPolicy value, $Res Function(_PasswordPolicy) _then) = __$PasswordPolicyCopyWithImpl;
@override @useResult
$Res call({
 int minLength, bool requireUpper, bool requireLower, bool requireDigit, bool requireSymbol
});




}
/// @nodoc
class __$PasswordPolicyCopyWithImpl<$Res>
    implements _$PasswordPolicyCopyWith<$Res> {
  __$PasswordPolicyCopyWithImpl(this._self, this._then);

  final _PasswordPolicy _self;
  final $Res Function(_PasswordPolicy) _then;

/// Create a copy of PasswordPolicy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minLength = null,Object? requireUpper = null,Object? requireLower = null,Object? requireDigit = null,Object? requireSymbol = null,}) {
  return _then(_PasswordPolicy(
minLength: null == minLength ? _self.minLength : minLength // ignore: cast_nullable_to_non_nullable
as int,requireUpper: null == requireUpper ? _self.requireUpper : requireUpper // ignore: cast_nullable_to_non_nullable
as bool,requireLower: null == requireLower ? _self.requireLower : requireLower // ignore: cast_nullable_to_non_nullable
as bool,requireDigit: null == requireDigit ? _self.requireDigit : requireDigit // ignore: cast_nullable_to_non_nullable
as bool,requireSymbol: null == requireSymbol ? _self.requireSymbol : requireSymbol // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
