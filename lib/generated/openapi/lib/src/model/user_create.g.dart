// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserCreate extends UserCreate {
  @override
  final String userId;
  @override
  final String password;
  @override
  final String email;
  @override
  final int? employeeId;
  @override
  final bool? administrator;
  @override
  final bool? disabled;

  factory _$UserCreate([void Function(UserCreateBuilder)? updates]) =>
      (UserCreateBuilder()..update(updates))._build();

  _$UserCreate._(
      {required this.userId,
      required this.password,
      required this.email,
      this.employeeId,
      this.administrator,
      this.disabled})
      : super._();
  @override
  UserCreate rebuild(void Function(UserCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserCreateBuilder toBuilder() => UserCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserCreate &&
        userId == other.userId &&
        password == other.password &&
        email == other.email &&
        employeeId == other.employeeId &&
        administrator == other.administrator &&
        disabled == other.disabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, employeeId.hashCode);
    _$hash = $jc(_$hash, administrator.hashCode);
    _$hash = $jc(_$hash, disabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserCreate')
          ..add('userId', userId)
          ..add('password', password)
          ..add('email', email)
          ..add('employeeId', employeeId)
          ..add('administrator', administrator)
          ..add('disabled', disabled))
        .toString();
  }
}

class UserCreateBuilder implements Builder<UserCreate, UserCreateBuilder> {
  _$UserCreate? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

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

  UserCreateBuilder() {
    UserCreate._defaults(this);
  }

  UserCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _password = $v.password;
      _email = $v.email;
      _employeeId = $v.employeeId;
      _administrator = $v.administrator;
      _disabled = $v.disabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserCreate other) {
    _$v = other as _$UserCreate;
  }

  @override
  void update(void Function(UserCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserCreate build() => _build();

  _$UserCreate _build() {
    final _$result = _$v ??
        _$UserCreate._(
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'UserCreate', 'userId'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'UserCreate', 'password'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'UserCreate', 'email'),
          employeeId: employeeId,
          administrator: administrator,
          disabled: disabled,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
