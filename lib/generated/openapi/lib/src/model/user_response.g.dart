// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserResponse extends UserResponse {
  @override
  final String userId;
  @override
  final String email;
  @override
  final int? employeeId;
  @override
  final bool administrator;
  @override
  final bool disabled;
  @override
  final int sessionVersion;
  @override
  final UserSettingsResponse? settings;
  @override
  final BuiltList<PrivilegeResponse> privileges;

  factory _$UserResponse([void Function(UserResponseBuilder)? updates]) =>
      (UserResponseBuilder()..update(updates))._build();

  _$UserResponse._(
      {required this.userId,
      required this.email,
      this.employeeId,
      required this.administrator,
      required this.disabled,
      required this.sessionVersion,
      this.settings,
      required this.privileges})
      : super._();
  @override
  UserResponse rebuild(void Function(UserResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserResponseBuilder toBuilder() => UserResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserResponse &&
        userId == other.userId &&
        email == other.email &&
        employeeId == other.employeeId &&
        administrator == other.administrator &&
        disabled == other.disabled &&
        sessionVersion == other.sessionVersion &&
        settings == other.settings &&
        privileges == other.privileges;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, employeeId.hashCode);
    _$hash = $jc(_$hash, administrator.hashCode);
    _$hash = $jc(_$hash, disabled.hashCode);
    _$hash = $jc(_$hash, sessionVersion.hashCode);
    _$hash = $jc(_$hash, settings.hashCode);
    _$hash = $jc(_$hash, privileges.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserResponse')
          ..add('userId', userId)
          ..add('email', email)
          ..add('employeeId', employeeId)
          ..add('administrator', administrator)
          ..add('disabled', disabled)
          ..add('sessionVersion', sessionVersion)
          ..add('settings', settings)
          ..add('privileges', privileges))
        .toString();
  }
}

class UserResponseBuilder
    implements Builder<UserResponse, UserResponseBuilder> {
  _$UserResponse? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  int? _employeeId;
  int? get employeeId => _$this._employeeId;
  set employeeId(int? employeeId) => _$this._employeeId = employeeId;

  bool? _administrator;
  bool? get administrator => _$this._administrator;
  set administrator(bool? administrator) =>
      _$this._administrator = administrator;

  bool? _disabled;
  bool? get disabled => _$this._disabled;
  set disabled(bool? disabled) => _$this._disabled = disabled;

  int? _sessionVersion;
  int? get sessionVersion => _$this._sessionVersion;
  set sessionVersion(int? sessionVersion) =>
      _$this._sessionVersion = sessionVersion;

  UserSettingsResponseBuilder? _settings;
  UserSettingsResponseBuilder get settings =>
      _$this._settings ??= UserSettingsResponseBuilder();
  set settings(UserSettingsResponseBuilder? settings) =>
      _$this._settings = settings;

  ListBuilder<PrivilegeResponse>? _privileges;
  ListBuilder<PrivilegeResponse> get privileges =>
      _$this._privileges ??= ListBuilder<PrivilegeResponse>();
  set privileges(ListBuilder<PrivilegeResponse>? privileges) =>
      _$this._privileges = privileges;

  UserResponseBuilder() {
    UserResponse._defaults(this);
  }

  UserResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _email = $v.email;
      _employeeId = $v.employeeId;
      _administrator = $v.administrator;
      _disabled = $v.disabled;
      _sessionVersion = $v.sessionVersion;
      _settings = $v.settings?.toBuilder();
      _privileges = $v.privileges.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserResponse other) {
    _$v = other as _$UserResponse;
  }

  @override
  void update(void Function(UserResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserResponse build() => _build();

  _$UserResponse _build() {
    _$UserResponse _$result;
    try {
      _$result = _$v ??
          _$UserResponse._(
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'UserResponse', 'userId'),
            email: BuiltValueNullFieldError.checkNotNull(
                email, r'UserResponse', 'email'),
            employeeId: employeeId,
            administrator: BuiltValueNullFieldError.checkNotNull(
                administrator, r'UserResponse', 'administrator'),
            disabled: BuiltValueNullFieldError.checkNotNull(
                disabled, r'UserResponse', 'disabled'),
            sessionVersion: BuiltValueNullFieldError.checkNotNull(
                sessionVersion, r'UserResponse', 'sessionVersion'),
            settings: _settings?.build(),
            privileges: privileges.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'settings';
        _settings?.build();
        _$failedField = 'privileges';
        privileges.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
