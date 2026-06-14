// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserListItem extends UserListItem {
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

  factory _$UserListItem([void Function(UserListItemBuilder)? updates]) =>
      (UserListItemBuilder()..update(updates))._build();

  _$UserListItem._(
      {required this.userId,
      required this.email,
      this.employeeId,
      required this.administrator,
      required this.disabled})
      : super._();
  @override
  UserListItem rebuild(void Function(UserListItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserListItemBuilder toBuilder() => UserListItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserListItem &&
        userId == other.userId &&
        email == other.email &&
        employeeId == other.employeeId &&
        administrator == other.administrator &&
        disabled == other.disabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, employeeId.hashCode);
    _$hash = $jc(_$hash, administrator.hashCode);
    _$hash = $jc(_$hash, disabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserListItem')
          ..add('userId', userId)
          ..add('email', email)
          ..add('employeeId', employeeId)
          ..add('administrator', administrator)
          ..add('disabled', disabled))
        .toString();
  }
}

class UserListItemBuilder
    implements Builder<UserListItem, UserListItemBuilder> {
  _$UserListItem? _$v;

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

  UserListItemBuilder() {
    UserListItem._defaults(this);
  }

  UserListItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _email = $v.email;
      _employeeId = $v.employeeId;
      _administrator = $v.administrator;
      _disabled = $v.disabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserListItem other) {
    _$v = other as _$UserListItem;
  }

  @override
  void update(void Function(UserListItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserListItem build() => _build();

  _$UserListItem _build() {
    final _$result = _$v ??
        _$UserListItem._(
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'UserListItem', 'userId'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'UserListItem', 'email'),
          employeeId: employeeId,
          administrator: BuiltValueNullFieldError.checkNotNull(
              administrator, r'UserListItem', 'administrator'),
          disabled: BuiltValueNullFieldError.checkNotNull(
              disabled, r'UserListItem', 'disabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
