// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$User {
  String get userId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  int? get employeeId => throw _privateConstructorUsedError;
  bool get administrator => throw _privateConstructorUsedError;
  EntityStatus get status => throw _privateConstructorUsedError;
  int get sessionVersion => throw _privateConstructorUsedError;
  UserSettings? get settings => throw _privateConstructorUsedError;
  List<Privilege> get privileges => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    String userId,
    String email,
    int? employeeId,
    bool administrator,
    EntityStatus status,
    int sessionVersion,
    UserSettings? settings,
    List<Privilege> privileges,
  });

  $UserSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? employeeId = freezed,
    Object? administrator = null,
    Object? status = null,
    Object? sessionVersion = null,
    Object? settings = freezed,
    Object? privileges = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EntityStatus,
            sessionVersion: null == sessionVersion
                ? _value.sessionVersion
                : sessionVersion // ignore: cast_nullable_to_non_nullable
                      as int,
            settings: freezed == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as UserSettings?,
            privileges: null == privileges
                ? _value.privileges
                : privileges // ignore: cast_nullable_to_non_nullable
                      as List<Privilege>,
          )
          as $Val,
    );
  }

  /// Create a copy of User
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
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String email,
    int? employeeId,
    bool administrator,
    EntityStatus status,
    int sessionVersion,
    UserSettings? settings,
    List<Privilege> privileges,
  });

  @override
  $UserSettingsCopyWith<$Res>? get settings;
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? employeeId = freezed,
    Object? administrator = null,
    Object? status = null,
    Object? sessionVersion = null,
    Object? settings = freezed,
    Object? privileges = null,
  }) {
    return _then(
      _$UserImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
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
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus,
        sessionVersion: null == sessionVersion
            ? _value.sessionVersion
            : sessionVersion // ignore: cast_nullable_to_non_nullable
                  as int,
        settings: freezed == settings
            ? _value.settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as UserSettings?,
        privileges: null == privileges
            ? _value._privileges
            : privileges // ignore: cast_nullable_to_non_nullable
                  as List<Privilege>,
      ),
    );
  }
}

/// @nodoc

class _$UserImpl implements _User {
  const _$UserImpl({
    required this.userId,
    required this.email,
    this.employeeId,
    required this.administrator,
    required this.status,
    required this.sessionVersion,
    this.settings,
    required final List<Privilege> privileges,
  }) : _privileges = privileges;

  @override
  final String userId;
  @override
  final String email;
  @override
  final int? employeeId;
  @override
  final bool administrator;
  @override
  final EntityStatus status;
  @override
  final int sessionVersion;
  @override
  final UserSettings? settings;
  final List<Privilege> _privileges;
  @override
  List<Privilege> get privileges {
    if (_privileges is EqualUnmodifiableListView) return _privileges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_privileges);
  }

  @override
  String toString() {
    return 'User(userId: $userId, email: $email, employeeId: $employeeId, administrator: $administrator, status: $status, sessionVersion: $sessionVersion, settings: $settings, privileges: $privileges)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.administrator, administrator) ||
                other.administrator == administrator) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.sessionVersion, sessionVersion) ||
                other.sessionVersion == sessionVersion) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            const DeepCollectionEquality().equals(
              other._privileges,
              _privileges,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    email,
    employeeId,
    administrator,
    status,
    sessionVersion,
    settings,
    const DeepCollectionEquality().hash(_privileges),
  );

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);
}

abstract class _User implements User {
  const factory _User({
    required final String userId,
    required final String email,
    final int? employeeId,
    required final bool administrator,
    required final EntityStatus status,
    required final int sessionVersion,
    final UserSettings? settings,
    required final List<Privilege> privileges,
  }) = _$UserImpl;

  @override
  String get userId;
  @override
  String get email;
  @override
  int? get employeeId;
  @override
  bool get administrator;
  @override
  EntityStatus get status;
  @override
  int get sessionVersion;
  @override
  UserSettings? get settings;
  @override
  List<Privilege> get privileges;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserSummary {
  String get userId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  int? get employeeId => throw _privateConstructorUsedError;
  bool get administrator => throw _privateConstructorUsedError;
  EntityStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of UserSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSummaryCopyWith<UserSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSummaryCopyWith<$Res> {
  factory $UserSummaryCopyWith(
    UserSummary value,
    $Res Function(UserSummary) then,
  ) = _$UserSummaryCopyWithImpl<$Res, UserSummary>;
  @useResult
  $Res call({
    String userId,
    String email,
    int? employeeId,
    bool administrator,
    EntityStatus status,
  });
}

/// @nodoc
class _$UserSummaryCopyWithImpl<$Res, $Val extends UserSummary>
    implements $UserSummaryCopyWith<$Res> {
  _$UserSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? employeeId = freezed,
    Object? administrator = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EntityStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserSummaryImplCopyWith<$Res>
    implements $UserSummaryCopyWith<$Res> {
  factory _$$UserSummaryImplCopyWith(
    _$UserSummaryImpl value,
    $Res Function(_$UserSummaryImpl) then,
  ) = __$$UserSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String email,
    int? employeeId,
    bool administrator,
    EntityStatus status,
  });
}

/// @nodoc
class __$$UserSummaryImplCopyWithImpl<$Res>
    extends _$UserSummaryCopyWithImpl<$Res, _$UserSummaryImpl>
    implements _$$UserSummaryImplCopyWith<$Res> {
  __$$UserSummaryImplCopyWithImpl(
    _$UserSummaryImpl _value,
    $Res Function(_$UserSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? email = null,
    Object? employeeId = freezed,
    Object? administrator = null,
    Object? status = null,
  }) {
    return _then(
      _$UserSummaryImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
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
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus,
      ),
    );
  }
}

/// @nodoc

class _$UserSummaryImpl implements _UserSummary {
  const _$UserSummaryImpl({
    required this.userId,
    required this.email,
    this.employeeId,
    required this.administrator,
    required this.status,
  });

  @override
  final String userId;
  @override
  final String email;
  @override
  final int? employeeId;
  @override
  final bool administrator;
  @override
  final EntityStatus status;

  @override
  String toString() {
    return 'UserSummary(userId: $userId, email: $email, employeeId: $employeeId, administrator: $administrator, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSummaryImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.administrator, administrator) ||
                other.administrator == administrator) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    email,
    employeeId,
    administrator,
    status,
  );

  /// Create a copy of UserSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSummaryImplCopyWith<_$UserSummaryImpl> get copyWith =>
      __$$UserSummaryImplCopyWithImpl<_$UserSummaryImpl>(this, _$identity);
}

abstract class _UserSummary implements UserSummary {
  const factory _UserSummary({
    required final String userId,
    required final String email,
    final int? employeeId,
    required final bool administrator,
    required final EntityStatus status,
  }) = _$UserSummaryImpl;

  @override
  String get userId;
  @override
  String get email;
  @override
  int? get employeeId;
  @override
  bool get administrator;
  @override
  EntityStatus get status;

  /// Create a copy of UserSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSummaryImplCopyWith<_$UserSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
