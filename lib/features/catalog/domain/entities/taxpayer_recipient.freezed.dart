// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_recipient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TaxpayerRecipient {
  String get taxpayerRecipientId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  SatCatalogItem? get postalCode => throw _privateConstructorUsedError;
  SatCatalogItem? get regime => throw _privateConstructorUsedError;

  /// Create a copy of TaxpayerRecipient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaxpayerRecipientCopyWith<TaxpayerRecipient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxpayerRecipientCopyWith<$Res> {
  factory $TaxpayerRecipientCopyWith(
    TaxpayerRecipient value,
    $Res Function(TaxpayerRecipient) then,
  ) = _$TaxpayerRecipientCopyWithImpl<$Res, TaxpayerRecipient>;
  @useResult
  $Res call({
    String taxpayerRecipientId,
    String name,
    String email,
    SatCatalogItem? postalCode,
    SatCatalogItem? regime,
  });

  $SatCatalogItemCopyWith<$Res>? get postalCode;
  $SatCatalogItemCopyWith<$Res>? get regime;
}

/// @nodoc
class _$TaxpayerRecipientCopyWithImpl<$Res, $Val extends TaxpayerRecipient>
    implements $TaxpayerRecipientCopyWith<$Res> {
  _$TaxpayerRecipientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaxpayerRecipient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taxpayerRecipientId = null,
    Object? name = null,
    Object? email = null,
    Object? postalCode = freezed,
    Object? regime = freezed,
  }) {
    return _then(
      _value.copyWith(
            taxpayerRecipientId: null == taxpayerRecipientId
                ? _value.taxpayerRecipientId
                : taxpayerRecipientId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            postalCode: freezed == postalCode
                ? _value.postalCode
                : postalCode // ignore: cast_nullable_to_non_nullable
                      as SatCatalogItem?,
            regime: freezed == regime
                ? _value.regime
                : regime // ignore: cast_nullable_to_non_nullable
                      as SatCatalogItem?,
          )
          as $Val,
    );
  }

  /// Create a copy of TaxpayerRecipient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SatCatalogItemCopyWith<$Res>? get postalCode {
    if (_value.postalCode == null) {
      return null;
    }

    return $SatCatalogItemCopyWith<$Res>(_value.postalCode!, (value) {
      return _then(_value.copyWith(postalCode: value) as $Val);
    });
  }

  /// Create a copy of TaxpayerRecipient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SatCatalogItemCopyWith<$Res>? get regime {
    if (_value.regime == null) {
      return null;
    }

    return $SatCatalogItemCopyWith<$Res>(_value.regime!, (value) {
      return _then(_value.copyWith(regime: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TaxpayerRecipientImplCopyWith<$Res>
    implements $TaxpayerRecipientCopyWith<$Res> {
  factory _$$TaxpayerRecipientImplCopyWith(
    _$TaxpayerRecipientImpl value,
    $Res Function(_$TaxpayerRecipientImpl) then,
  ) = __$$TaxpayerRecipientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String taxpayerRecipientId,
    String name,
    String email,
    SatCatalogItem? postalCode,
    SatCatalogItem? regime,
  });

  @override
  $SatCatalogItemCopyWith<$Res>? get postalCode;
  @override
  $SatCatalogItemCopyWith<$Res>? get regime;
}

/// @nodoc
class __$$TaxpayerRecipientImplCopyWithImpl<$Res>
    extends _$TaxpayerRecipientCopyWithImpl<$Res, _$TaxpayerRecipientImpl>
    implements _$$TaxpayerRecipientImplCopyWith<$Res> {
  __$$TaxpayerRecipientImplCopyWithImpl(
    _$TaxpayerRecipientImpl _value,
    $Res Function(_$TaxpayerRecipientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaxpayerRecipient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taxpayerRecipientId = null,
    Object? name = null,
    Object? email = null,
    Object? postalCode = freezed,
    Object? regime = freezed,
  }) {
    return _then(
      _$TaxpayerRecipientImpl(
        taxpayerRecipientId: null == taxpayerRecipientId
            ? _value.taxpayerRecipientId
            : taxpayerRecipientId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        postalCode: freezed == postalCode
            ? _value.postalCode
            : postalCode // ignore: cast_nullable_to_non_nullable
                  as SatCatalogItem?,
        regime: freezed == regime
            ? _value.regime
            : regime // ignore: cast_nullable_to_non_nullable
                  as SatCatalogItem?,
      ),
    );
  }
}

/// @nodoc

class _$TaxpayerRecipientImpl implements _TaxpayerRecipient {
  const _$TaxpayerRecipientImpl({
    required this.taxpayerRecipientId,
    required this.name,
    required this.email,
    this.postalCode,
    this.regime,
  });

  @override
  final String taxpayerRecipientId;
  @override
  final String name;
  @override
  final String email;
  @override
  final SatCatalogItem? postalCode;
  @override
  final SatCatalogItem? regime;

  @override
  String toString() {
    return 'TaxpayerRecipient(taxpayerRecipientId: $taxpayerRecipientId, name: $name, email: $email, postalCode: $postalCode, regime: $regime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaxpayerRecipientImpl &&
            (identical(other.taxpayerRecipientId, taxpayerRecipientId) ||
                other.taxpayerRecipientId == taxpayerRecipientId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.regime, regime) || other.regime == regime));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    taxpayerRecipientId,
    name,
    email,
    postalCode,
    regime,
  );

  /// Create a copy of TaxpayerRecipient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaxpayerRecipientImplCopyWith<_$TaxpayerRecipientImpl> get copyWith =>
      __$$TaxpayerRecipientImplCopyWithImpl<_$TaxpayerRecipientImpl>(
        this,
        _$identity,
      );
}

abstract class _TaxpayerRecipient implements TaxpayerRecipient {
  const factory _TaxpayerRecipient({
    required final String taxpayerRecipientId,
    required final String name,
    required final String email,
    final SatCatalogItem? postalCode,
    final SatCatalogItem? regime,
  }) = _$TaxpayerRecipientImpl;

  @override
  String get taxpayerRecipientId;
  @override
  String get name;
  @override
  String get email;
  @override
  SatCatalogItem? get postalCode;
  @override
  SatCatalogItem? get regime;

  /// Create a copy of TaxpayerRecipient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaxpayerRecipientImplCopyWith<_$TaxpayerRecipientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
