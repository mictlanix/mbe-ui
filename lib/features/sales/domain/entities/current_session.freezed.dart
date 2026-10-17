// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'current_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CurrentSession {

 SessionState get state; CashSession? get session;
/// Create a copy of CurrentSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentSessionCopyWith<CurrentSession> get copyWith => _$CurrentSessionCopyWithImpl<CurrentSession>(this as CurrentSession, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CurrentSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentSession&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.session, _this.session) || other.session == _this.session));
}


@override
int get hashCode {
  final _this = this as CurrentSession;
  return Object.hash(runtimeType,_this.state,_this.session);
}

@override
String toString() {
  final _this = this as CurrentSession;
  return 'CurrentSession(state: ${_this.state}, session: ${_this.session})';
}


}

/// @nodoc
abstract mixin class $CurrentSessionCopyWith<$Res>  {
  factory $CurrentSessionCopyWith(CurrentSession value, $Res Function(CurrentSession) _then) = _$CurrentSessionCopyWithImpl;
@useResult
$Res call({
 SessionState state, CashSession? session
});


$CashSessionCopyWith<$Res>? get session;

}
/// @nodoc
class _$CurrentSessionCopyWithImpl<$Res>
    implements $CurrentSessionCopyWith<$Res> {
  _$CurrentSessionCopyWithImpl(this._self, this._then);

  final CurrentSession _self;
  final $Res Function(CurrentSession) _then;

/// Create a copy of CurrentSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? state = null,Object? session = freezed,}) {
  return _then(CurrentSession(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as SessionState,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as CashSession?,
  ));
}
/// Create a copy of CurrentSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CashSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $CashSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}


/// Adds pattern-matching-related methods to [CurrentSession].
extension CurrentSessionPatterns on CurrentSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentSession value)  $default,){
final _that = this;
switch (_that) {
case _CurrentSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentSession value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SessionState state,  CashSession? session)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentSession() when $default != null:
return $default(_that.state,_that.session);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SessionState state,  CashSession? session)  $default,) {final _that = this;
switch (_that) {
case _CurrentSession():
return $default(_that.state,_that.session);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SessionState state,  CashSession? session)?  $default,) {final _that = this;
switch (_that) {
case _CurrentSession() when $default != null:
return $default(_that.state,_that.session);case _:
  return null;

}
}

}

/// @nodoc


class _CurrentSession implements CurrentSession {
  const _CurrentSession({required this.state, this.session});
  

@override final  SessionState state;
@override final  CashSession? session;

/// Create a copy of CurrentSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentSessionCopyWith<_CurrentSession> get copyWith => __$CurrentSessionCopyWithImpl<_CurrentSession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentSession&&(identical(other.state, state) || other.state == state)&&(identical(other.session, session) || other.session == session));
}


@override
int get hashCode {
    return Object.hash(runtimeType,state,session);
}

@override
String toString() {
    return 'CurrentSession(state: $state, session: $session)';
}


}

/// @nodoc
abstract mixin class _$CurrentSessionCopyWith<$Res> implements $CurrentSessionCopyWith<$Res> {
  factory _$CurrentSessionCopyWith(_CurrentSession value, $Res Function(_CurrentSession) _then) = __$CurrentSessionCopyWithImpl;
@override @useResult
$Res call({
 SessionState state, CashSession? session
});


@override $CashSessionCopyWith<$Res>? get session;

}
/// @nodoc
class __$CurrentSessionCopyWithImpl<$Res>
    implements _$CurrentSessionCopyWith<$Res> {
  __$CurrentSessionCopyWithImpl(this._self, this._then);

  final _CurrentSession _self;
  final $Res Function(_CurrentSession) _then;

/// Create a copy of CurrentSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? state = null,Object? session = freezed,}) {
  return _then(_CurrentSession(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as SessionState,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as CashSession?,
  ));
}

/// Create a copy of CurrentSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CashSessionCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $CashSessionCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

// dart format on
