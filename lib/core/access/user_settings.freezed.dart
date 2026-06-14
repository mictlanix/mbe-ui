// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserSettings {
  int? get storeId => throw _privateConstructorUsedError;
  int? get pointSaleId => throw _privateConstructorUsedError;
  int? get cashDrawerId => throw _privateConstructorUsedError;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSettingsCopyWith<UserSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSettingsCopyWith<$Res> {
  factory $UserSettingsCopyWith(
    UserSettings value,
    $Res Function(UserSettings) then,
  ) = _$UserSettingsCopyWithImpl<$Res, UserSettings>;
  @useResult
  $Res call({int? storeId, int? pointSaleId, int? cashDrawerId});
}

/// @nodoc
class _$UserSettingsCopyWithImpl<$Res, $Val extends UserSettings>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storeId = freezed,
    Object? pointSaleId = freezed,
    Object? cashDrawerId = freezed,
  }) {
    return _then(
      _value.copyWith(
            storeId: freezed == storeId
                ? _value.storeId
                : storeId // ignore: cast_nullable_to_non_nullable
                      as int?,
            pointSaleId: freezed == pointSaleId
                ? _value.pointSaleId
                : pointSaleId // ignore: cast_nullable_to_non_nullable
                      as int?,
            cashDrawerId: freezed == cashDrawerId
                ? _value.cashDrawerId
                : cashDrawerId // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserSettingsImplCopyWith<$Res>
    implements $UserSettingsCopyWith<$Res> {
  factory _$$UserSettingsImplCopyWith(
    _$UserSettingsImpl value,
    $Res Function(_$UserSettingsImpl) then,
  ) = __$$UserSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? storeId, int? pointSaleId, int? cashDrawerId});
}

/// @nodoc
class __$$UserSettingsImplCopyWithImpl<$Res>
    extends _$UserSettingsCopyWithImpl<$Res, _$UserSettingsImpl>
    implements _$$UserSettingsImplCopyWith<$Res> {
  __$$UserSettingsImplCopyWithImpl(
    _$UserSettingsImpl _value,
    $Res Function(_$UserSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storeId = freezed,
    Object? pointSaleId = freezed,
    Object? cashDrawerId = freezed,
  }) {
    return _then(
      _$UserSettingsImpl(
        storeId: freezed == storeId
            ? _value.storeId
            : storeId // ignore: cast_nullable_to_non_nullable
                  as int?,
        pointSaleId: freezed == pointSaleId
            ? _value.pointSaleId
            : pointSaleId // ignore: cast_nullable_to_non_nullable
                  as int?,
        cashDrawerId: freezed == cashDrawerId
            ? _value.cashDrawerId
            : cashDrawerId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$UserSettingsImpl extends _UserSettings {
  const _$UserSettingsImpl({this.storeId, this.pointSaleId, this.cashDrawerId})
    : super._();

  @override
  final int? storeId;
  @override
  final int? pointSaleId;
  @override
  final int? cashDrawerId;

  @override
  String toString() {
    return 'UserSettings(storeId: $storeId, pointSaleId: $pointSaleId, cashDrawerId: $cashDrawerId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSettingsImpl &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.pointSaleId, pointSaleId) ||
                other.pointSaleId == pointSaleId) &&
            (identical(other.cashDrawerId, cashDrawerId) ||
                other.cashDrawerId == cashDrawerId));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, storeId, pointSaleId, cashDrawerId);

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      __$$UserSettingsImplCopyWithImpl<_$UserSettingsImpl>(this, _$identity);
}

abstract class _UserSettings extends UserSettings {
  const factory _UserSettings({
    final int? storeId,
    final int? pointSaleId,
    final int? cashDrawerId,
  }) = _$UserSettingsImpl;
  const _UserSettings._() : super._();

  @override
  int? get storeId;
  @override
  int? get pointSaleId;
  @override
  int? get cashDrawerId;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
