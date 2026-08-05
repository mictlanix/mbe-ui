// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'current_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CurrentSession {
  SessionState get state => throw _privateConstructorUsedError;
  CashSession? get session => throw _privateConstructorUsedError;

  /// Create a copy of CurrentSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CurrentSessionCopyWith<CurrentSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrentSessionCopyWith<$Res> {
  factory $CurrentSessionCopyWith(
    CurrentSession value,
    $Res Function(CurrentSession) then,
  ) = _$CurrentSessionCopyWithImpl<$Res, CurrentSession>;
  @useResult
  $Res call({SessionState state, CashSession? session});

  $CashSessionCopyWith<$Res>? get session;
}

/// @nodoc
class _$CurrentSessionCopyWithImpl<$Res, $Val extends CurrentSession>
    implements $CurrentSessionCopyWith<$Res> {
  _$CurrentSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CurrentSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? state = null, Object? session = freezed}) {
    return _then(
      _value.copyWith(
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as SessionState,
            session: freezed == session
                ? _value.session
                : session // ignore: cast_nullable_to_non_nullable
                      as CashSession?,
          )
          as $Val,
    );
  }

  /// Create a copy of CurrentSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CashSessionCopyWith<$Res>? get session {
    if (_value.session == null) {
      return null;
    }

    return $CashSessionCopyWith<$Res>(_value.session!, (value) {
      return _then(_value.copyWith(session: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CurrentSessionImplCopyWith<$Res>
    implements $CurrentSessionCopyWith<$Res> {
  factory _$$CurrentSessionImplCopyWith(
    _$CurrentSessionImpl value,
    $Res Function(_$CurrentSessionImpl) then,
  ) = __$$CurrentSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SessionState state, CashSession? session});

  @override
  $CashSessionCopyWith<$Res>? get session;
}

/// @nodoc
class __$$CurrentSessionImplCopyWithImpl<$Res>
    extends _$CurrentSessionCopyWithImpl<$Res, _$CurrentSessionImpl>
    implements _$$CurrentSessionImplCopyWith<$Res> {
  __$$CurrentSessionImplCopyWithImpl(
    _$CurrentSessionImpl _value,
    $Res Function(_$CurrentSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CurrentSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? state = null, Object? session = freezed}) {
    return _then(
      _$CurrentSessionImpl(
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as SessionState,
        session: freezed == session
            ? _value.session
            : session // ignore: cast_nullable_to_non_nullable
                  as CashSession?,
      ),
    );
  }
}

/// @nodoc

class _$CurrentSessionImpl implements _CurrentSession {
  const _$CurrentSessionImpl({required this.state, this.session});

  @override
  final SessionState state;
  @override
  final CashSession? session;

  @override
  String toString() {
    return 'CurrentSession(state: $state, session: $session)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrentSessionImpl &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.session, session) || other.session == session));
  }

  @override
  int get hashCode => Object.hash(runtimeType, state, session);

  /// Create a copy of CurrentSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrentSessionImplCopyWith<_$CurrentSessionImpl> get copyWith =>
      __$$CurrentSessionImplCopyWithImpl<_$CurrentSessionImpl>(
        this,
        _$identity,
      );
}

abstract class _CurrentSession implements CurrentSession {
  const factory _CurrentSession({
    required final SessionState state,
    final CashSession? session,
  }) = _$CurrentSessionImpl;

  @override
  SessionState get state;
  @override
  CashSession? get session;

  /// Create a copy of CurrentSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CurrentSessionImplCopyWith<_$CurrentSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
