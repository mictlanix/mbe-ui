// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'users_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserFormState {
  String get userId => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  int? get employeeId => throw _privateConstructorUsedError;
  bool get administrator => throw _privateConstructorUsedError;
  bool get disabled => throw _privateConstructorUsedError;
  List<Privilege> get privileges => throw _privateConstructorUsedError;
  UserSettings? get settings => throw _privateConstructorUsedError;
  bool get loading => throw _privateConstructorUsedError;
  bool get submitting => throw _privateConstructorUsedError;
  bool get saved => throw _privateConstructorUsedError;
  bool get deleted => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// The server-provided detail behind [error] (e.g. mbe-api's `detail`
  /// string on a `404`/`5xx`), shown alongside the localized [error]
  /// message since it can't be localized client-side. `null` for
  /// client-side-only errors and for a [ValidationError]'s message
  /// (already raw server text stored directly in `error`).
  String? get errorDetail => throw _privateConstructorUsedError;
  String? get recoveryToken => throw _privateConstructorUsedError;
  String? get recoveryExpiresAt => throw _privateConstructorUsedError;

  /// Create a copy of UserFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserFormStateCopyWith<UserFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserFormStateCopyWith<$Res> {
  factory $UserFormStateCopyWith(
    UserFormState value,
    $Res Function(UserFormState) then,
  ) = _$UserFormStateCopyWithImpl<$Res, UserFormState>;
  @useResult
  $Res call({
    String userId,
    String password,
    String email,
    int? employeeId,
    bool administrator,
    bool disabled,
    List<Privilege> privileges,
    UserSettings? settings,
    bool loading,
    bool submitting,
    bool saved,
    bool deleted,
    String? error,
    String? errorDetail,
    String? recoveryToken,
    String? recoveryExpiresAt,
  });

  $UserSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class _$UserFormStateCopyWithImpl<$Res, $Val extends UserFormState>
    implements $UserFormStateCopyWith<$Res> {
  _$UserFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? password = null,
    Object? email = null,
    Object? employeeId = freezed,
    Object? administrator = null,
    Object? disabled = null,
    Object? privileges = null,
    Object? settings = freezed,
    Object? loading = null,
    Object? submitting = null,
    Object? saved = null,
    Object? deleted = null,
    Object? error = freezed,
    Object? errorDetail = freezed,
    Object? recoveryToken = freezed,
    Object? recoveryExpiresAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            employeeId: freezed == employeeId
                ? _value.employeeId
                : employeeId // ignore: cast_nullable_to_non_nullable
                      as int?,
            administrator: null == administrator
                ? _value.administrator
                : administrator // ignore: cast_nullable_to_non_nullable
                      as bool,
            disabled: null == disabled
                ? _value.disabled
                : disabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            privileges: null == privileges
                ? _value.privileges
                : privileges // ignore: cast_nullable_to_non_nullable
                      as List<Privilege>,
            settings: freezed == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as UserSettings?,
            loading: null == loading
                ? _value.loading
                : loading // ignore: cast_nullable_to_non_nullable
                      as bool,
            submitting: null == submitting
                ? _value.submitting
                : submitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            saved: null == saved
                ? _value.saved
                : saved // ignore: cast_nullable_to_non_nullable
                      as bool,
            deleted: null == deleted
                ? _value.deleted
                : deleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorDetail: freezed == errorDetail
                ? _value.errorDetail
                : errorDetail // ignore: cast_nullable_to_non_nullable
                      as String?,
            recoveryToken: freezed == recoveryToken
                ? _value.recoveryToken
                : recoveryToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            recoveryExpiresAt: freezed == recoveryExpiresAt
                ? _value.recoveryExpiresAt
                : recoveryExpiresAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of UserFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserSettingsCopyWith<$Res>? get settings {
    if (_value.settings == null) {
      return null;
    }

    return $UserSettingsCopyWith<$Res>(_value.settings!, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserFormStateImplCopyWith<$Res>
    implements $UserFormStateCopyWith<$Res> {
  factory _$$UserFormStateImplCopyWith(
    _$UserFormStateImpl value,
    $Res Function(_$UserFormStateImpl) then,
  ) = __$$UserFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String password,
    String email,
    int? employeeId,
    bool administrator,
    bool disabled,
    List<Privilege> privileges,
    UserSettings? settings,
    bool loading,
    bool submitting,
    bool saved,
    bool deleted,
    String? error,
    String? errorDetail,
    String? recoveryToken,
    String? recoveryExpiresAt,
  });

  @override
  $UserSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class __$$UserFormStateImplCopyWithImpl<$Res>
    extends _$UserFormStateCopyWithImpl<$Res, _$UserFormStateImpl>
    implements _$$UserFormStateImplCopyWith<$Res> {
  __$$UserFormStateImplCopyWithImpl(
    _$UserFormStateImpl _value,
    $Res Function(_$UserFormStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? password = null,
    Object? email = null,
    Object? employeeId = freezed,
    Object? administrator = null,
    Object? disabled = null,
    Object? privileges = null,
    Object? settings = freezed,
    Object? loading = null,
    Object? submitting = null,
    Object? saved = null,
    Object? deleted = null,
    Object? error = freezed,
    Object? errorDetail = freezed,
    Object? recoveryToken = freezed,
    Object? recoveryExpiresAt = freezed,
  }) {
    return _then(
      _$UserFormStateImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeId: freezed == employeeId
            ? _value.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as int?,
        administrator: null == administrator
            ? _value.administrator
            : administrator // ignore: cast_nullable_to_non_nullable
                  as bool,
        disabled: null == disabled
            ? _value.disabled
            : disabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        privileges: null == privileges
            ? _value._privileges
            : privileges // ignore: cast_nullable_to_non_nullable
                  as List<Privilege>,
        settings: freezed == settings
            ? _value.settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as UserSettings?,
        loading: null == loading
            ? _value.loading
            : loading // ignore: cast_nullable_to_non_nullable
                  as bool,
        submitting: null == submitting
            ? _value.submitting
            : submitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        saved: null == saved
            ? _value.saved
            : saved // ignore: cast_nullable_to_non_nullable
                  as bool,
        deleted: null == deleted
            ? _value.deleted
            : deleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorDetail: freezed == errorDetail
            ? _value.errorDetail
            : errorDetail // ignore: cast_nullable_to_non_nullable
                  as String?,
        recoveryToken: freezed == recoveryToken
            ? _value.recoveryToken
            : recoveryToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        recoveryExpiresAt: freezed == recoveryExpiresAt
            ? _value.recoveryExpiresAt
            : recoveryExpiresAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$UserFormStateImpl implements _UserFormState {
  const _$UserFormStateImpl({
    this.userId = '',
    this.password = '',
    this.email = '',
    this.employeeId,
    this.administrator = false,
    this.disabled = false,
    final List<Privilege> privileges = const <Privilege>[],
    this.settings,
    this.loading = false,
    this.submitting = false,
    this.saved = false,
    this.deleted = false,
    this.error,
    this.errorDetail,
    this.recoveryToken,
    this.recoveryExpiresAt,
  }) : _privileges = privileges;

  @override
  @JsonKey()
  final String userId;
  @override
  @JsonKey()
  final String password;
  @override
  @JsonKey()
  final String email;
  @override
  final int? employeeId;
  @override
  @JsonKey()
  final bool administrator;
  @override
  @JsonKey()
  final bool disabled;
  final List<Privilege> _privileges;
  @override
  @JsonKey()
  List<Privilege> get privileges {
    if (_privileges is EqualUnmodifiableListView) return _privileges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_privileges);
  }

  @override
  final UserSettings? settings;
  @override
  @JsonKey()
  final bool loading;
  @override
  @JsonKey()
  final bool submitting;
  @override
  @JsonKey()
  final bool saved;
  @override
  @JsonKey()
  final bool deleted;
  @override
  final String? error;

  /// The server-provided detail behind [error] (e.g. mbe-api's `detail`
  /// string on a `404`/`5xx`), shown alongside the localized [error]
  /// message since it can't be localized client-side. `null` for
  /// client-side-only errors and for a [ValidationError]'s message
  /// (already raw server text stored directly in `error`).
  @override
  final String? errorDetail;
  @override
  final String? recoveryToken;
  @override
  final String? recoveryExpiresAt;

  @override
  String toString() {
    return 'UserFormState(userId: $userId, password: $password, email: $email, employeeId: $employeeId, administrator: $administrator, disabled: $disabled, privileges: $privileges, settings: $settings, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail, recoveryToken: $recoveryToken, recoveryExpiresAt: $recoveryExpiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserFormStateImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.administrator, administrator) ||
                other.administrator == administrator) &&
            (identical(other.disabled, disabled) ||
                other.disabled == disabled) &&
            const DeepCollectionEquality().equals(
              other._privileges,
              _privileges,
            ) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.submitting, submitting) ||
                other.submitting == submitting) &&
            (identical(other.saved, saved) || other.saved == saved) &&
            (identical(other.deleted, deleted) || other.deleted == deleted) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.errorDetail, errorDetail) ||
                other.errorDetail == errorDetail) &&
            (identical(other.recoveryToken, recoveryToken) ||
                other.recoveryToken == recoveryToken) &&
            (identical(other.recoveryExpiresAt, recoveryExpiresAt) ||
                other.recoveryExpiresAt == recoveryExpiresAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    password,
    email,
    employeeId,
    administrator,
    disabled,
    const DeepCollectionEquality().hash(_privileges),
    settings,
    loading,
    submitting,
    saved,
    deleted,
    error,
    errorDetail,
    recoveryToken,
    recoveryExpiresAt,
  );

  /// Create a copy of UserFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserFormStateImplCopyWith<_$UserFormStateImpl> get copyWith =>
      __$$UserFormStateImplCopyWithImpl<_$UserFormStateImpl>(this, _$identity);
}

abstract class _UserFormState implements UserFormState {
  const factory _UserFormState({
    final String userId,
    final String password,
    final String email,
    final int? employeeId,
    final bool administrator,
    final bool disabled,
    final List<Privilege> privileges,
    final UserSettings? settings,
    final bool loading,
    final bool submitting,
    final bool saved,
    final bool deleted,
    final String? error,
    final String? errorDetail,
    final String? recoveryToken,
    final String? recoveryExpiresAt,
  }) = _$UserFormStateImpl;

  @override
  String get userId;
  @override
  String get password;
  @override
  String get email;
  @override
  int? get employeeId;
  @override
  bool get administrator;
  @override
  bool get disabled;
  @override
  List<Privilege> get privileges;
  @override
  UserSettings? get settings;
  @override
  bool get loading;
  @override
  bool get submitting;
  @override
  bool get saved;
  @override
  bool get deleted;
  @override
  String? get error;

  /// The server-provided detail behind [error] (e.g. mbe-api's `detail`
  /// string on a `404`/`5xx`), shown alongside the localized [error]
  /// message since it can't be localized client-side. `null` for
  /// client-side-only errors and for a [ValidationError]'s message
  /// (already raw server text stored directly in `error`).
  @override
  String? get errorDetail;
  @override
  String? get recoveryToken;
  @override
  String? get recoveryExpiresAt;

  /// Create a copy of UserFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserFormStateImplCopyWith<_$UserFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
