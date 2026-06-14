// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privilege_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PrivilegeResponse extends PrivilegeResponse {
  @override
  final int systemObject;
  @override
  final int privileges;
  @override
  final bool allowCreate;
  @override
  final bool allowRead;
  @override
  final bool allowUpdate;
  @override
  final bool allowDelete;

  factory _$PrivilegeResponse(
          [void Function(PrivilegeResponseBuilder)? updates]) =>
      (PrivilegeResponseBuilder()..update(updates))._build();

  _$PrivilegeResponse._(
      {required this.systemObject,
      required this.privileges,
      required this.allowCreate,
      required this.allowRead,
      required this.allowUpdate,
      required this.allowDelete})
      : super._();
  @override
  PrivilegeResponse rebuild(void Function(PrivilegeResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PrivilegeResponseBuilder toBuilder() =>
      PrivilegeResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PrivilegeResponse &&
        systemObject == other.systemObject &&
        privileges == other.privileges &&
        allowCreate == other.allowCreate &&
        allowRead == other.allowRead &&
        allowUpdate == other.allowUpdate &&
        allowDelete == other.allowDelete;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, systemObject.hashCode);
    _$hash = $jc(_$hash, privileges.hashCode);
    _$hash = $jc(_$hash, allowCreate.hashCode);
    _$hash = $jc(_$hash, allowRead.hashCode);
    _$hash = $jc(_$hash, allowUpdate.hashCode);
    _$hash = $jc(_$hash, allowDelete.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PrivilegeResponse')
          ..add('systemObject', systemObject)
          ..add('privileges', privileges)
          ..add('allowCreate', allowCreate)
          ..add('allowRead', allowRead)
          ..add('allowUpdate', allowUpdate)
          ..add('allowDelete', allowDelete))
        .toString();
  }
}

class PrivilegeResponseBuilder
    implements Builder<PrivilegeResponse, PrivilegeResponseBuilder> {
  _$PrivilegeResponse? _$v;

  int? _systemObject;
  int? get systemObject => _$this._systemObject;
  set systemObject(int? systemObject) => _$this._systemObject = systemObject;

  int? _privileges;
  int? get privileges => _$this._privileges;
  set privileges(int? privileges) => _$this._privileges = privileges;

  bool? _allowCreate;
  bool? get allowCreate => _$this._allowCreate;
  set allowCreate(bool? allowCreate) => _$this._allowCreate = allowCreate;

  bool? _allowRead;
  bool? get allowRead => _$this._allowRead;
  set allowRead(bool? allowRead) => _$this._allowRead = allowRead;

  bool? _allowUpdate;
  bool? get allowUpdate => _$this._allowUpdate;
  set allowUpdate(bool? allowUpdate) => _$this._allowUpdate = allowUpdate;

  bool? _allowDelete;
  bool? get allowDelete => _$this._allowDelete;
  set allowDelete(bool? allowDelete) => _$this._allowDelete = allowDelete;

  PrivilegeResponseBuilder() {
    PrivilegeResponse._defaults(this);
  }

  PrivilegeResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _systemObject = $v.systemObject;
      _privileges = $v.privileges;
      _allowCreate = $v.allowCreate;
      _allowRead = $v.allowRead;
      _allowUpdate = $v.allowUpdate;
      _allowDelete = $v.allowDelete;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PrivilegeResponse other) {
    _$v = other as _$PrivilegeResponse;
  }

  @override
  void update(void Function(PrivilegeResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PrivilegeResponse build() => _build();

  _$PrivilegeResponse _build() {
    final _$result = _$v ??
        _$PrivilegeResponse._(
          systemObject: BuiltValueNullFieldError.checkNotNull(
              systemObject, r'PrivilegeResponse', 'systemObject'),
          privileges: BuiltValueNullFieldError.checkNotNull(
              privileges, r'PrivilegeResponse', 'privileges'),
          allowCreate: BuiltValueNullFieldError.checkNotNull(
              allowCreate, r'PrivilegeResponse', 'allowCreate'),
          allowRead: BuiltValueNullFieldError.checkNotNull(
              allowRead, r'PrivilegeResponse', 'allowRead'),
          allowUpdate: BuiltValueNullFieldError.checkNotNull(
              allowUpdate, r'PrivilegeResponse', 'allowUpdate'),
          allowDelete: BuiltValueNullFieldError.checkNotNull(
              allowDelete, r'PrivilegeResponse', 'allowDelete'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
