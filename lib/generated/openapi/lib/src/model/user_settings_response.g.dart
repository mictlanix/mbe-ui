// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserSettingsResponse extends UserSettingsResponse {
  @override
  final int? storeId;
  @override
  final int? pointSaleId;
  @override
  final int? cashDrawerId;

  factory _$UserSettingsResponse(
          [void Function(UserSettingsResponseBuilder)? updates]) =>
      (UserSettingsResponseBuilder()..update(updates))._build();

  _$UserSettingsResponse._({this.storeId, this.pointSaleId, this.cashDrawerId})
      : super._();
  @override
  UserSettingsResponse rebuild(
          void Function(UserSettingsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserSettingsResponseBuilder toBuilder() =>
      UserSettingsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserSettingsResponse &&
        storeId == other.storeId &&
        pointSaleId == other.pointSaleId &&
        cashDrawerId == other.cashDrawerId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, storeId.hashCode);
    _$hash = $jc(_$hash, pointSaleId.hashCode);
    _$hash = $jc(_$hash, cashDrawerId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserSettingsResponse')
          ..add('storeId', storeId)
          ..add('pointSaleId', pointSaleId)
          ..add('cashDrawerId', cashDrawerId))
        .toString();
  }
}

class UserSettingsResponseBuilder
    implements Builder<UserSettingsResponse, UserSettingsResponseBuilder> {
  _$UserSettingsResponse? _$v;

  int? _storeId;
  int? get storeId => _$this._storeId;
  set storeId(int? storeId) => _$this._storeId = storeId;

  int? _pointSaleId;
  int? get pointSaleId => _$this._pointSaleId;
  set pointSaleId(int? pointSaleId) => _$this._pointSaleId = pointSaleId;

  int? _cashDrawerId;
  int? get cashDrawerId => _$this._cashDrawerId;
  set cashDrawerId(int? cashDrawerId) => _$this._cashDrawerId = cashDrawerId;

  UserSettingsResponseBuilder() {
    UserSettingsResponse._defaults(this);
  }

  UserSettingsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _storeId = $v.storeId;
      _pointSaleId = $v.pointSaleId;
      _cashDrawerId = $v.cashDrawerId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserSettingsResponse other) {
    _$v = other as _$UserSettingsResponse;
  }

  @override
  void update(void Function(UserSettingsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserSettingsResponse build() => _build();

  _$UserSettingsResponse _build() {
    final _$result = _$v ??
        _$UserSettingsResponse._(
          storeId: storeId,
          pointSaleId: pointSaleId,
          cashDrawerId: cashDrawerId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
