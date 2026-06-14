// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_recovery_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfirmRecoveryRequest extends ConfirmRecoveryRequest {
  @override
  final String recoveryToken;
  @override
  final String newPassword;

  factory _$ConfirmRecoveryRequest(
          [void Function(ConfirmRecoveryRequestBuilder)? updates]) =>
      (ConfirmRecoveryRequestBuilder()..update(updates))._build();

  _$ConfirmRecoveryRequest._(
      {required this.recoveryToken, required this.newPassword})
      : super._();
  @override
  ConfirmRecoveryRequest rebuild(
          void Function(ConfirmRecoveryRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConfirmRecoveryRequestBuilder toBuilder() =>
      ConfirmRecoveryRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfirmRecoveryRequest &&
        recoveryToken == other.recoveryToken &&
        newPassword == other.newPassword;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, recoveryToken.hashCode);
    _$hash = $jc(_$hash, newPassword.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConfirmRecoveryRequest')
          ..add('recoveryToken', recoveryToken)
          ..add('newPassword', newPassword))
        .toString();
  }
}

class ConfirmRecoveryRequestBuilder
    implements Builder<ConfirmRecoveryRequest, ConfirmRecoveryRequestBuilder> {
  _$ConfirmRecoveryRequest? _$v;

  String? _recoveryToken;
  String? get recoveryToken => _$this._recoveryToken;
  set recoveryToken(String? recoveryToken) =>
      _$this._recoveryToken = recoveryToken;

  String? _newPassword;
  String? get newPassword => _$this._newPassword;
  set newPassword(String? newPassword) => _$this._newPassword = newPassword;

  ConfirmRecoveryRequestBuilder() {
    ConfirmRecoveryRequest._defaults(this);
  }

  ConfirmRecoveryRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _recoveryToken = $v.recoveryToken;
      _newPassword = $v.newPassword;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConfirmRecoveryRequest other) {
    _$v = other as _$ConfirmRecoveryRequest;
  }

  @override
  void update(void Function(ConfirmRecoveryRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfirmRecoveryRequest build() => _build();

  _$ConfirmRecoveryRequest _build() {
    final _$result = _$v ??
        _$ConfirmRecoveryRequest._(
          recoveryToken: BuiltValueNullFieldError.checkNotNull(
              recoveryToken, r'ConfirmRecoveryRequest', 'recoveryToken'),
          newPassword: BuiltValueNullFieldError.checkNotNull(
              newPassword, r'ConfirmRecoveryRequest', 'newPassword'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
