// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ChangePasswordFormState {
  String get oldPassword => throw _privateConstructorUsedError;
  String get newPassword => throw _privateConstructorUsedError;
  bool get submitting => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of ChangePasswordFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChangePasswordFormStateCopyWith<ChangePasswordFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChangePasswordFormStateCopyWith<$Res> {
  factory $ChangePasswordFormStateCopyWith(
    ChangePasswordFormState value,
    $Res Function(ChangePasswordFormState) then,
  ) = _$ChangePasswordFormStateCopyWithImpl<$Res, ChangePasswordFormState>;
  @useResult
  $Res call({
    String oldPassword,
    String newPassword,
    bool submitting,
    bool success,
    String? error,
  });
}

/// @nodoc
class _$ChangePasswordFormStateCopyWithImpl<
  $Res,
  $Val extends ChangePasswordFormState
>
    implements $ChangePasswordFormStateCopyWith<$Res> {
  _$ChangePasswordFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChangePasswordFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? oldPassword = null,
    Object? newPassword = null,
    Object? submitting = null,
    Object? success = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            oldPassword: null == oldPassword
                ? _value.oldPassword
                : oldPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            newPassword: null == newPassword
                ? _value.newPassword
                : newPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            submitting: null == submitting
                ? _value.submitting
                : submitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChangePasswordFormStateImplCopyWith<$Res>
    implements $ChangePasswordFormStateCopyWith<$Res> {
  factory _$$ChangePasswordFormStateImplCopyWith(
    _$ChangePasswordFormStateImpl value,
    $Res Function(_$ChangePasswordFormStateImpl) then,
  ) = __$$ChangePasswordFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String oldPassword,
    String newPassword,
    bool submitting,
    bool success,
    String? error,
  });
}

/// @nodoc
class __$$ChangePasswordFormStateImplCopyWithImpl<$Res>
    extends
        _$ChangePasswordFormStateCopyWithImpl<
          $Res,
          _$ChangePasswordFormStateImpl
        >
    implements _$$ChangePasswordFormStateImplCopyWith<$Res> {
  __$$ChangePasswordFormStateImplCopyWithImpl(
    _$ChangePasswordFormStateImpl _value,
    $Res Function(_$ChangePasswordFormStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChangePasswordFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? oldPassword = null,
    Object? newPassword = null,
    Object? submitting = null,
    Object? success = null,
    Object? error = freezed,
  }) {
    return _then(
      _$ChangePasswordFormStateImpl(
        oldPassword: null == oldPassword
            ? _value.oldPassword
            : oldPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        newPassword: null == newPassword
            ? _value.newPassword
            : newPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        submitting: null == submitting
            ? _value.submitting
            : submitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ChangePasswordFormStateImpl implements _ChangePasswordFormState {
  const _$ChangePasswordFormStateImpl({
    this.oldPassword = '',
    this.newPassword = '',
    this.submitting = false,
    this.success = false,
    this.error,
  });

  @override
  @JsonKey()
  final String oldPassword;
  @override
  @JsonKey()
  final String newPassword;
  @override
  @JsonKey()
  final bool submitting;
  @override
  @JsonKey()
  final bool success;
  @override
  final String? error;

  @override
  String toString() {
    return 'ChangePasswordFormState(oldPassword: $oldPassword, newPassword: $newPassword, submitting: $submitting, success: $success, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChangePasswordFormStateImpl &&
            (identical(other.oldPassword, oldPassword) ||
                other.oldPassword == oldPassword) &&
            (identical(other.newPassword, newPassword) ||
                other.newPassword == newPassword) &&
            (identical(other.submitting, submitting) ||
                other.submitting == submitting) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    oldPassword,
    newPassword,
    submitting,
    success,
    error,
  );

  /// Create a copy of ChangePasswordFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChangePasswordFormStateImplCopyWith<_$ChangePasswordFormStateImpl>
  get copyWith =>
      __$$ChangePasswordFormStateImplCopyWithImpl<
        _$ChangePasswordFormStateImpl
      >(this, _$identity);
}

abstract class _ChangePasswordFormState implements ChangePasswordFormState {
  const factory _ChangePasswordFormState({
    final String oldPassword,
    final String newPassword,
    final bool submitting,
    final bool success,
    final String? error,
  }) = _$ChangePasswordFormStateImpl;

  @override
  String get oldPassword;
  @override
  String get newPassword;
  @override
  bool get submitting;
  @override
  bool get success;
  @override
  String? get error;

  /// Create a copy of ChangePasswordFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChangePasswordFormStateImplCopyWith<_$ChangePasswordFormStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RecoveryFormState {
  String get recoveryToken => throw _privateConstructorUsedError;
  String get newPassword => throw _privateConstructorUsedError;
  bool get submitting => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of RecoveryFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecoveryFormStateCopyWith<RecoveryFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecoveryFormStateCopyWith<$Res> {
  factory $RecoveryFormStateCopyWith(
    RecoveryFormState value,
    $Res Function(RecoveryFormState) then,
  ) = _$RecoveryFormStateCopyWithImpl<$Res, RecoveryFormState>;
  @useResult
  $Res call({
    String recoveryToken,
    String newPassword,
    bool submitting,
    bool success,
    String? error,
  });
}

/// @nodoc
class _$RecoveryFormStateCopyWithImpl<$Res, $Val extends RecoveryFormState>
    implements $RecoveryFormStateCopyWith<$Res> {
  _$RecoveryFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecoveryFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recoveryToken = null,
    Object? newPassword = null,
    Object? submitting = null,
    Object? success = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            recoveryToken: null == recoveryToken
                ? _value.recoveryToken
                : recoveryToken // ignore: cast_nullable_to_non_nullable
                      as String,
            newPassword: null == newPassword
                ? _value.newPassword
                : newPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            submitting: null == submitting
                ? _value.submitting
                : submitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecoveryFormStateImplCopyWith<$Res>
    implements $RecoveryFormStateCopyWith<$Res> {
  factory _$$RecoveryFormStateImplCopyWith(
    _$RecoveryFormStateImpl value,
    $Res Function(_$RecoveryFormStateImpl) then,
  ) = __$$RecoveryFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String recoveryToken,
    String newPassword,
    bool submitting,
    bool success,
    String? error,
  });
}

/// @nodoc
class __$$RecoveryFormStateImplCopyWithImpl<$Res>
    extends _$RecoveryFormStateCopyWithImpl<$Res, _$RecoveryFormStateImpl>
    implements _$$RecoveryFormStateImplCopyWith<$Res> {
  __$$RecoveryFormStateImplCopyWithImpl(
    _$RecoveryFormStateImpl _value,
    $Res Function(_$RecoveryFormStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecoveryFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recoveryToken = null,
    Object? newPassword = null,
    Object? submitting = null,
    Object? success = null,
    Object? error = freezed,
  }) {
    return _then(
      _$RecoveryFormStateImpl(
        recoveryToken: null == recoveryToken
            ? _value.recoveryToken
            : recoveryToken // ignore: cast_nullable_to_non_nullable
                  as String,
        newPassword: null == newPassword
            ? _value.newPassword
            : newPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        submitting: null == submitting
            ? _value.submitting
            : submitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$RecoveryFormStateImpl implements _RecoveryFormState {
  const _$RecoveryFormStateImpl({
    this.recoveryToken = '',
    this.newPassword = '',
    this.submitting = false,
    this.success = false,
    this.error,
  });

  @override
  @JsonKey()
  final String recoveryToken;
  @override
  @JsonKey()
  final String newPassword;
  @override
  @JsonKey()
  final bool submitting;
  @override
  @JsonKey()
  final bool success;
  @override
  final String? error;

  @override
  String toString() {
    return 'RecoveryFormState(recoveryToken: $recoveryToken, newPassword: $newPassword, submitting: $submitting, success: $success, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecoveryFormStateImpl &&
            (identical(other.recoveryToken, recoveryToken) ||
                other.recoveryToken == recoveryToken) &&
            (identical(other.newPassword, newPassword) ||
                other.newPassword == newPassword) &&
            (identical(other.submitting, submitting) ||
                other.submitting == submitting) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    recoveryToken,
    newPassword,
    submitting,
    success,
    error,
  );

  /// Create a copy of RecoveryFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecoveryFormStateImplCopyWith<_$RecoveryFormStateImpl> get copyWith =>
      __$$RecoveryFormStateImplCopyWithImpl<_$RecoveryFormStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RecoveryFormState implements RecoveryFormState {
  const factory _RecoveryFormState({
    final String recoveryToken,
    final String newPassword,
    final bool submitting,
    final bool success,
    final String? error,
  }) = _$RecoveryFormStateImpl;

  @override
  String get recoveryToken;
  @override
  String get newPassword;
  @override
  bool get submitting;
  @override
  bool get success;
  @override
  String? get error;

  /// Create a copy of RecoveryFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecoveryFormStateImplCopyWith<_$RecoveryFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
