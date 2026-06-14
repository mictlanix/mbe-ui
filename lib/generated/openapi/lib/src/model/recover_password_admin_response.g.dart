// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recover_password_admin_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecoverPasswordAdminResponse extends RecoverPasswordAdminResponse {
  @override
  final String recoveryToken;
  @override
  final String expiresAt;

  factory _$RecoverPasswordAdminResponse(
          [void Function(RecoverPasswordAdminResponseBuilder)? updates]) =>
      (RecoverPasswordAdminResponseBuilder()..update(updates))._build();

  _$RecoverPasswordAdminResponse._(
      {required this.recoveryToken, required this.expiresAt})
      : super._();
  @override
  RecoverPasswordAdminResponse rebuild(
          void Function(RecoverPasswordAdminResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecoverPasswordAdminResponseBuilder toBuilder() =>
      RecoverPasswordAdminResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecoverPasswordAdminResponse &&
        recoveryToken == other.recoveryToken &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, recoveryToken.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecoverPasswordAdminResponse')
          ..add('recoveryToken', recoveryToken)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class RecoverPasswordAdminResponseBuilder
    implements
        Builder<RecoverPasswordAdminResponse,
            RecoverPasswordAdminResponseBuilder> {
  _$RecoverPasswordAdminResponse? _$v;

  String? _recoveryToken;
  String? get recoveryToken => _$this._recoveryToken;
  set recoveryToken(String? recoveryToken) =>
      _$this._recoveryToken = recoveryToken;

  String? _expiresAt;
  String? get expiresAt => _$this._expiresAt;
  set expiresAt(String? expiresAt) => _$this._expiresAt = expiresAt;

  RecoverPasswordAdminResponseBuilder() {
    RecoverPasswordAdminResponse._defaults(this);
  }

  RecoverPasswordAdminResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _recoveryToken = $v.recoveryToken;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecoverPasswordAdminResponse other) {
    _$v = other as _$RecoverPasswordAdminResponse;
  }

  @override
  void update(void Function(RecoverPasswordAdminResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecoverPasswordAdminResponse build() => _build();

  _$RecoverPasswordAdminResponse _build() {
    final _$result = _$v ??
        _$RecoverPasswordAdminResponse._(
          recoveryToken: BuiltValueNullFieldError.checkNotNull(
              recoveryToken, r'RecoverPasswordAdminResponse', 'recoveryToken'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'RecoverPasswordAdminResponse', 'expiresAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
