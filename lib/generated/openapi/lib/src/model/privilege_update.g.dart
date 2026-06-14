// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privilege_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrivilegeUpdate extends PrivilegeUpdate {
  @override
  final int systemObject;
  @override
  final int privileges;

  factory _$PrivilegeUpdate([void Function(PrivilegeUpdateBuilder)? updates]) =>
      (PrivilegeUpdateBuilder()..update(updates))._build();

  _$PrivilegeUpdate._({required this.systemObject, required this.privileges})
      : super._();
  @override
  PrivilegeUpdate rebuild(void Function(PrivilegeUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrivilegeUpdateBuilder toBuilder() => PrivilegeUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrivilegeUpdate &&
        systemObject == other.systemObject &&
        privileges == other.privileges;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, systemObject.hashCode);
    _$hash = $jc(_$hash, privileges.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrivilegeUpdate')
          ..add('systemObject', systemObject)
          ..add('privileges', privileges))
        .toString();
  }
}

class PrivilegeUpdateBuilder
    implements Builder<PrivilegeUpdate, PrivilegeUpdateBuilder> {
  _$PrivilegeUpdate? _$v;

  int? _systemObject;
  int? get systemObject => _$this._systemObject;
  set systemObject(int? systemObject) => _$this._systemObject = systemObject;

  int? _privileges;
  int? get privileges => _$this._privileges;
  set privileges(int? privileges) => _$this._privileges = privileges;

  PrivilegeUpdateBuilder() {
    PrivilegeUpdate._defaults(this);
  }

  PrivilegeUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _systemObject = $v.systemObject;
      _privileges = $v.privileges;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrivilegeUpdate other) {
    _$v = other as _$PrivilegeUpdate;
  }

  @override
  void update(void Function(PrivilegeUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrivilegeUpdate build() => _build();

  _$PrivilegeUpdate _build() {
    final _$result = _$v ??
        _$PrivilegeUpdate._(
          systemObject: BuiltValueNullFieldError.checkNotNull(
              systemObject, r'PrivilegeUpdate', 'systemObject'),
          privileges: BuiltValueNullFieldError.checkNotNull(
              privileges, r'PrivilegeUpdate', 'privileges'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
