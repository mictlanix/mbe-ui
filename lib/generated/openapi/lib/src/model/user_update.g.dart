// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserUpdate extends UserUpdate {
  @override
  final String? email;
  @override
  final int? employeeId;
  @override
  final bool? administrator;
  @override
  final bool? disabled;
  @override
  final BuiltList<PrivilegeUpdate>? privileges;
  @override
  final UserSettingsUpdate? settings;

  factory _$UserUpdate([void Function(UserUpdateBuilder)? updates]) =>
      (UserUpdateBuilder()..update(updates))._build();

  _$UserUpdate._(
      {this.email,
      this.employeeId,
      this.administrator,
      this.disabled,
      this.privileges,
      this.settings})
      : super._();
  @override
  UserUpdate rebuild(void Function(UserUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserUpdateBuilder toBuilder() => UserUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserUpdate &&
        email == other.email &&
        employeeId == other.employeeId &&
        administrator == other.administrator &&
        disabled == other.disabled &&
        privileges == other.privileges &&
        settings == other.settings;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, employeeId.hashCode);
    _$hash = $jc(_$hash, administrator.hashCode);
    _$hash = $jc(_$hash, disabled.hashCode);
    _$hash = $jc(_$hash, privileges.hashCode);
    _$hash = $jc(_$hash, settings.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserUpdate')
          ..add('email', email)
          ..add('employeeId', employeeId)
          ..add('administrator', administrator)
          ..add('disabled', disabled)
          ..add('privileges', privileges)
          ..add('settings', settings))
        .toString();
  }
}

class UserUpdateBuilder implements Builder<UserUpdate, UserUpdateBuilder> {
  _$UserUpdate? _$v;

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

  ListBuilder<PrivilegeUpdate>? _privileges;
  ListBuilder<PrivilegeUpdate> get privileges =>
      _$this._privileges ??= ListBuilder<PrivilegeUpdate>();
  set privileges(ListBuilder<PrivilegeUpdate>? privileges) =>
      _$this._privileges = privileges;

  UserSettingsUpdateBuilder? _settings;
  UserSettingsUpdateBuilder get settings =>
      _$this._settings ??= UserSettingsUpdateBuilder();
  set settings(UserSettingsUpdateBuilder? settings) =>
      _$this._settings = settings;

  UserUpdateBuilder() {
    UserUpdate._defaults(this);
  }

  UserUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _employeeId = $v.employeeId;
      _administrator = $v.administrator;
      _disabled = $v.disabled;
      _privileges = $v.privileges?.toBuilder();
      _settings = $v.settings?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserUpdate other) {
    _$v = other as _$UserUpdate;
  }

  @override
  void update(void Function(UserUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserUpdate build() => _build();

  _$UserUpdate _build() {
    _$UserUpdate _$result;
    try {
      _$result = _$v ??
          _$UserUpdate._(
            email: email,
            employeeId: employeeId,
            administrator: administrator,
            disabled: disabled,
            privileges: _privileges?.build(),
            settings: _settings?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'privileges';
        _privileges?.build();
        _$failedField = 'settings';
        _settings?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserUpdate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
