// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserSettingsUpdate extends UserSettingsUpdate {
  @override
  final int? storeId;
  @override
  final int? pointSaleId;
  @override
  final int? cashDrawerId;

  factory _$UserSettingsUpdate(
          [void Function(UserSettingsUpdateBuilder)? updates]) =>
      (UserSettingsUpdateBuilder()..update(updates))._build();

  _$UserSettingsUpdate._({this.storeId, this.pointSaleId, this.cashDrawerId})
      : super._();
  @override
  UserSettingsUpdate rebuild(
          void Function(UserSettingsUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserSettingsUpdateBuilder toBuilder() =>
      UserSettingsUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserSettingsUpdate &&
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
    return (newBuiltValueToStringHelper(r'UserSettingsUpdate')
          ..add('storeId', storeId)
          ..add('pointSaleId', pointSaleId)
          ..add('cashDrawerId', cashDrawerId))
        .toString();
  }
}

class UserSettingsUpdateBuilder
    implements Builder<UserSettingsUpdate, UserSettingsUpdateBuilder> {
  _$UserSettingsUpdate? _$v;

  int? _storeId;
  int? get storeId => _$this._storeId;
  set storeId(int? storeId) => _$this._storeId = storeId;

  int? _pointSaleId;
  int? get pointSaleId => _$this._pointSaleId;
  set pointSaleId(int? pointSaleId) => _$this._pointSaleId = pointSaleId;

  int? _cashDrawerId;
  int? get cashDrawerId => _$this._cashDrawerId;
  set cashDrawerId(int? cashDrawerId) => _$this._cashDrawerId = cashDrawerId;

  UserSettingsUpdateBuilder() {
    UserSettingsUpdate._defaults(this);
  }

  UserSettingsUpdateBuilder get _$this {
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
  void replace(UserSettingsUpdate other) {
    _$v = other as _$UserSettingsUpdate;
  }

  @override
  void update(void Function(UserSettingsUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserSettingsUpdate build() => _build();

  _$UserSettingsUpdate _build() {
    final _$result = _$v ??
        _$UserSettingsUpdate._(
          storeId: storeId,
          pointSaleId: pointSaleId,
          cashDrawerId: cashDrawerId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
