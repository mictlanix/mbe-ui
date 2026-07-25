// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_issuer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TaxpayerIssuer {
  String get rfc => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  SatCatalogItem? get regime => throw _privateConstructorUsedError;
  FiscalCertificationProvider get provider =>
      throw _privateConstructorUsedError;
  SatCatalogItem? get postalCode => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;

  /// Create a copy of TaxpayerIssuer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaxpayerIssuerCopyWith<TaxpayerIssuer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxpayerIssuerCopyWith<$Res> {
  factory $TaxpayerIssuerCopyWith(
    TaxpayerIssuer value,
    $Res Function(TaxpayerIssuer) then,
  ) = _$TaxpayerIssuerCopyWithImpl<$Res, TaxpayerIssuer>;
  @useResult
  $Res call({
    String rfc,
    String name,
    SatCatalogItem? regime,
    FiscalCertificationProvider provider,
    SatCatalogItem? postalCode,
    String? comment,
  });

  $SatCatalogItemCopyWith<$Res>? get regime;
  $SatCatalogItemCopyWith<$Res>? get postalCode;
}

/// @nodoc
class _$TaxpayerIssuerCopyWithImpl<$Res, $Val extends TaxpayerIssuer>
    implements $TaxpayerIssuerCopyWith<$Res> {
  _$TaxpayerIssuerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaxpayerIssuer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rfc = null,
    Object? name = null,
    Object? regime = freezed,
    Object? provider = null,
    Object? postalCode = freezed,
    Object? comment = freezed,
  }) {
    return _then(
      _value.copyWith(
            rfc: null == rfc
                ? _value.rfc
                : rfc // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            regime: freezed == regime
                ? _value.regime
                : regime // ignore: cast_nullable_to_non_nullable
                      as SatCatalogItem?,
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as FiscalCertificationProvider,
            postalCode: freezed == postalCode
                ? _value.postalCode
                : postalCode // ignore: cast_nullable_to_non_nullable
                      as SatCatalogItem?,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of TaxpayerIssuer
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

  /// Create a copy of TaxpayerIssuer
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
}

/// @nodoc
abstract class _$$TaxpayerIssuerImplCopyWith<$Res>
    implements $TaxpayerIssuerCopyWith<$Res> {
  factory _$$TaxpayerIssuerImplCopyWith(
    _$TaxpayerIssuerImpl value,
    $Res Function(_$TaxpayerIssuerImpl) then,
  ) = __$$TaxpayerIssuerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String rfc,
    String name,
    SatCatalogItem? regime,
    FiscalCertificationProvider provider,
    SatCatalogItem? postalCode,
    String? comment,
  });

  @override
  $SatCatalogItemCopyWith<$Res>? get regime;
  @override
  $SatCatalogItemCopyWith<$Res>? get postalCode;
}

/// @nodoc
class __$$TaxpayerIssuerImplCopyWithImpl<$Res>
    extends _$TaxpayerIssuerCopyWithImpl<$Res, _$TaxpayerIssuerImpl>
    implements _$$TaxpayerIssuerImplCopyWith<$Res> {
  __$$TaxpayerIssuerImplCopyWithImpl(
    _$TaxpayerIssuerImpl _value,
    $Res Function(_$TaxpayerIssuerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaxpayerIssuer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rfc = null,
    Object? name = null,
    Object? regime = freezed,
    Object? provider = null,
    Object? postalCode = freezed,
    Object? comment = freezed,
  }) {
    return _then(
      _$TaxpayerIssuerImpl(
        rfc: null == rfc
            ? _value.rfc
            : rfc // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        regime: freezed == regime
            ? _value.regime
            : regime // ignore: cast_nullable_to_non_nullable
                  as SatCatalogItem?,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as FiscalCertificationProvider,
        postalCode: freezed == postalCode
            ? _value.postalCode
            : postalCode // ignore: cast_nullable_to_non_nullable
                  as SatCatalogItem?,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$TaxpayerIssuerImpl implements _TaxpayerIssuer {
  const _$TaxpayerIssuerImpl({
    required this.rfc,
    required this.name,
    this.regime,
    required this.provider,
    this.postalCode,
    this.comment,
  });

  @override
  final String rfc;
  @override
  final String name;
  @override
  final SatCatalogItem? regime;
  @override
  final FiscalCertificationProvider provider;
  @override
  final SatCatalogItem? postalCode;
  @override
  final String? comment;

  @override
  String toString() {
    return 'TaxpayerIssuer(rfc: $rfc, name: $name, regime: $regime, provider: $provider, postalCode: $postalCode, comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaxpayerIssuerImpl &&
            (identical(other.rfc, rfc) || other.rfc == rfc) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.regime, regime) || other.regime == regime) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.comment, comment) || other.comment == comment));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    rfc,
    name,
    regime,
    provider,
    postalCode,
    comment,
  );

  /// Create a copy of TaxpayerIssuer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaxpayerIssuerImplCopyWith<_$TaxpayerIssuerImpl> get copyWith =>
      __$$TaxpayerIssuerImplCopyWithImpl<_$TaxpayerIssuerImpl>(
        this,
        _$identity,
      );
}

abstract class _TaxpayerIssuer implements TaxpayerIssuer {
  const factory _TaxpayerIssuer({
    required final String rfc,
    required final String name,
    final SatCatalogItem? regime,
    required final FiscalCertificationProvider provider,
    final SatCatalogItem? postalCode,
    final String? comment,
  }) = _$TaxpayerIssuerImpl;

  @override
  String get rfc;
  @override
  String get name;
  @override
  SatCatalogItem? get regime;
  @override
  FiscalCertificationProvider get provider;
  @override
  SatCatalogItem? get postalCode;
  @override
  String? get comment;

  /// Create a copy of TaxpayerIssuer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaxpayerIssuerImplCopyWith<_$TaxpayerIssuerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
