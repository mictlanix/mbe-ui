// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_certificate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TaxpayerCertificate {
  String get taxpayerCertificateId => throw _privateConstructorUsedError;
  String get taxpayer => throw _privateConstructorUsedError;
  DateTime get validFrom => throw _privateConstructorUsedError;
  DateTime get validTo => throw _privateConstructorUsedError;
  EntityStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of TaxpayerCertificate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaxpayerCertificateCopyWith<TaxpayerCertificate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxpayerCertificateCopyWith<$Res> {
  factory $TaxpayerCertificateCopyWith(
    TaxpayerCertificate value,
    $Res Function(TaxpayerCertificate) then,
  ) = _$TaxpayerCertificateCopyWithImpl<$Res, TaxpayerCertificate>;
  @useResult
  $Res call({
    String taxpayerCertificateId,
    String taxpayer,
    DateTime validFrom,
    DateTime validTo,
    EntityStatus status,
  });
}

/// @nodoc
class _$TaxpayerCertificateCopyWithImpl<$Res, $Val extends TaxpayerCertificate>
    implements $TaxpayerCertificateCopyWith<$Res> {
  _$TaxpayerCertificateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaxpayerCertificate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taxpayerCertificateId = null,
    Object? taxpayer = null,
    Object? validFrom = null,
    Object? validTo = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            taxpayerCertificateId: null == taxpayerCertificateId
                ? _value.taxpayerCertificateId
                : taxpayerCertificateId // ignore: cast_nullable_to_non_nullable
                      as String,
            taxpayer: null == taxpayer
                ? _value.taxpayer
                : taxpayer // ignore: cast_nullable_to_non_nullable
                      as String,
            validFrom: null == validFrom
                ? _value.validFrom
                : validFrom // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            validTo: null == validTo
                ? _value.validTo
                : validTo // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EntityStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaxpayerCertificateImplCopyWith<$Res>
    implements $TaxpayerCertificateCopyWith<$Res> {
  factory _$$TaxpayerCertificateImplCopyWith(
    _$TaxpayerCertificateImpl value,
    $Res Function(_$TaxpayerCertificateImpl) then,
  ) = __$$TaxpayerCertificateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String taxpayerCertificateId,
    String taxpayer,
    DateTime validFrom,
    DateTime validTo,
    EntityStatus status,
  });
}

/// @nodoc
class __$$TaxpayerCertificateImplCopyWithImpl<$Res>
    extends _$TaxpayerCertificateCopyWithImpl<$Res, _$TaxpayerCertificateImpl>
    implements _$$TaxpayerCertificateImplCopyWith<$Res> {
  __$$TaxpayerCertificateImplCopyWithImpl(
    _$TaxpayerCertificateImpl _value,
    $Res Function(_$TaxpayerCertificateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaxpayerCertificate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taxpayerCertificateId = null,
    Object? taxpayer = null,
    Object? validFrom = null,
    Object? validTo = null,
    Object? status = null,
  }) {
    return _then(
      _$TaxpayerCertificateImpl(
        taxpayerCertificateId: null == taxpayerCertificateId
            ? _value.taxpayerCertificateId
            : taxpayerCertificateId // ignore: cast_nullable_to_non_nullable
                  as String,
        taxpayer: null == taxpayer
            ? _value.taxpayer
            : taxpayer // ignore: cast_nullable_to_non_nullable
                  as String,
        validFrom: null == validFrom
            ? _value.validFrom
            : validFrom // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        validTo: null == validTo
            ? _value.validTo
            : validTo // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus,
      ),
    );
  }
}

/// @nodoc

class _$TaxpayerCertificateImpl implements _TaxpayerCertificate {
  const _$TaxpayerCertificateImpl({
    required this.taxpayerCertificateId,
    required this.taxpayer,
    required this.validFrom,
    required this.validTo,
    required this.status,
  });

  @override
  final String taxpayerCertificateId;
  @override
  final String taxpayer;
  @override
  final DateTime validFrom;
  @override
  final DateTime validTo;
  @override
  final EntityStatus status;

  @override
  String toString() {
    return 'TaxpayerCertificate(taxpayerCertificateId: $taxpayerCertificateId, taxpayer: $taxpayer, validFrom: $validFrom, validTo: $validTo, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaxpayerCertificateImpl &&
            (identical(other.taxpayerCertificateId, taxpayerCertificateId) ||
                other.taxpayerCertificateId == taxpayerCertificateId) &&
            (identical(other.taxpayer, taxpayer) ||
                other.taxpayer == taxpayer) &&
            (identical(other.validFrom, validFrom) ||
                other.validFrom == validFrom) &&
            (identical(other.validTo, validTo) || other.validTo == validTo) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    taxpayerCertificateId,
    taxpayer,
    validFrom,
    validTo,
    status,
  );

  /// Create a copy of TaxpayerCertificate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaxpayerCertificateImplCopyWith<_$TaxpayerCertificateImpl> get copyWith =>
      __$$TaxpayerCertificateImplCopyWithImpl<_$TaxpayerCertificateImpl>(
        this,
        _$identity,
      );
}

abstract class _TaxpayerCertificate implements TaxpayerCertificate {
  const factory _TaxpayerCertificate({
    required final String taxpayerCertificateId,
    required final String taxpayer,
    required final DateTime validFrom,
    required final DateTime validTo,
    required final EntityStatus status,
  }) = _$TaxpayerCertificateImpl;

  @override
  String get taxpayerCertificateId;
  @override
  String get taxpayer;
  @override
  DateTime get validFrom;
  @override
  DateTime get validTo;
  @override
  EntityStatus get status;

  /// Create a copy of TaxpayerCertificate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaxpayerCertificateImplCopyWith<_$TaxpayerCertificateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CertificateUpload {
  String get taxpayer => throw _privateConstructorUsedError;
  List<int>? get certificateBytes => throw _privateConstructorUsedError;
  String? get certificateFileName => throw _privateConstructorUsedError;
  List<int>? get keyBytes => throw _privateConstructorUsedError;
  String? get keyFileName => throw _privateConstructorUsedError;
  String get keyPassword => throw _privateConstructorUsedError;

  /// Create a copy of CertificateUpload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CertificateUploadCopyWith<CertificateUpload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CertificateUploadCopyWith<$Res> {
  factory $CertificateUploadCopyWith(
    CertificateUpload value,
    $Res Function(CertificateUpload) then,
  ) = _$CertificateUploadCopyWithImpl<$Res, CertificateUpload>;
  @useResult
  $Res call({
    String taxpayer,
    List<int>? certificateBytes,
    String? certificateFileName,
    List<int>? keyBytes,
    String? keyFileName,
    String keyPassword,
  });
}

/// @nodoc
class _$CertificateUploadCopyWithImpl<$Res, $Val extends CertificateUpload>
    implements $CertificateUploadCopyWith<$Res> {
  _$CertificateUploadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CertificateUpload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taxpayer = null,
    Object? certificateBytes = freezed,
    Object? certificateFileName = freezed,
    Object? keyBytes = freezed,
    Object? keyFileName = freezed,
    Object? keyPassword = null,
  }) {
    return _then(
      _value.copyWith(
            taxpayer: null == taxpayer
                ? _value.taxpayer
                : taxpayer // ignore: cast_nullable_to_non_nullable
                      as String,
            certificateBytes: freezed == certificateBytes
                ? _value.certificateBytes
                : certificateBytes // ignore: cast_nullable_to_non_nullable
                      as List<int>?,
            certificateFileName: freezed == certificateFileName
                ? _value.certificateFileName
                : certificateFileName // ignore: cast_nullable_to_non_nullable
                      as String?,
            keyBytes: freezed == keyBytes
                ? _value.keyBytes
                : keyBytes // ignore: cast_nullable_to_non_nullable
                      as List<int>?,
            keyFileName: freezed == keyFileName
                ? _value.keyFileName
                : keyFileName // ignore: cast_nullable_to_non_nullable
                      as String?,
            keyPassword: null == keyPassword
                ? _value.keyPassword
                : keyPassword // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CertificateUploadImplCopyWith<$Res>
    implements $CertificateUploadCopyWith<$Res> {
  factory _$$CertificateUploadImplCopyWith(
    _$CertificateUploadImpl value,
    $Res Function(_$CertificateUploadImpl) then,
  ) = __$$CertificateUploadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String taxpayer,
    List<int>? certificateBytes,
    String? certificateFileName,
    List<int>? keyBytes,
    String? keyFileName,
    String keyPassword,
  });
}

/// @nodoc
class __$$CertificateUploadImplCopyWithImpl<$Res>
    extends _$CertificateUploadCopyWithImpl<$Res, _$CertificateUploadImpl>
    implements _$$CertificateUploadImplCopyWith<$Res> {
  __$$CertificateUploadImplCopyWithImpl(
    _$CertificateUploadImpl _value,
    $Res Function(_$CertificateUploadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CertificateUpload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taxpayer = null,
    Object? certificateBytes = freezed,
    Object? certificateFileName = freezed,
    Object? keyBytes = freezed,
    Object? keyFileName = freezed,
    Object? keyPassword = null,
  }) {
    return _then(
      _$CertificateUploadImpl(
        taxpayer: null == taxpayer
            ? _value.taxpayer
            : taxpayer // ignore: cast_nullable_to_non_nullable
                  as String,
        certificateBytes: freezed == certificateBytes
            ? _value._certificateBytes
            : certificateBytes // ignore: cast_nullable_to_non_nullable
                  as List<int>?,
        certificateFileName: freezed == certificateFileName
            ? _value.certificateFileName
            : certificateFileName // ignore: cast_nullable_to_non_nullable
                  as String?,
        keyBytes: freezed == keyBytes
            ? _value._keyBytes
            : keyBytes // ignore: cast_nullable_to_non_nullable
                  as List<int>?,
        keyFileName: freezed == keyFileName
            ? _value.keyFileName
            : keyFileName // ignore: cast_nullable_to_non_nullable
                  as String?,
        keyPassword: null == keyPassword
            ? _value.keyPassword
            : keyPassword // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$CertificateUploadImpl implements _CertificateUpload {
  const _$CertificateUploadImpl({
    required this.taxpayer,
    final List<int>? certificateBytes,
    this.certificateFileName,
    final List<int>? keyBytes,
    this.keyFileName,
    this.keyPassword = '',
  }) : _certificateBytes = certificateBytes,
       _keyBytes = keyBytes;

  @override
  final String taxpayer;
  final List<int>? _certificateBytes;
  @override
  List<int>? get certificateBytes {
    final value = _certificateBytes;
    if (value == null) return null;
    if (_certificateBytes is EqualUnmodifiableListView)
      return _certificateBytes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? certificateFileName;
  final List<int>? _keyBytes;
  @override
  List<int>? get keyBytes {
    final value = _keyBytes;
    if (value == null) return null;
    if (_keyBytes is EqualUnmodifiableListView) return _keyBytes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? keyFileName;
  @override
  @JsonKey()
  final String keyPassword;

  @override
  String toString() {
    return 'CertificateUpload(taxpayer: $taxpayer, certificateBytes: $certificateBytes, certificateFileName: $certificateFileName, keyBytes: $keyBytes, keyFileName: $keyFileName, keyPassword: $keyPassword)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CertificateUploadImpl &&
            (identical(other.taxpayer, taxpayer) ||
                other.taxpayer == taxpayer) &&
            const DeepCollectionEquality().equals(
              other._certificateBytes,
              _certificateBytes,
            ) &&
            (identical(other.certificateFileName, certificateFileName) ||
                other.certificateFileName == certificateFileName) &&
            const DeepCollectionEquality().equals(other._keyBytes, _keyBytes) &&
            (identical(other.keyFileName, keyFileName) ||
                other.keyFileName == keyFileName) &&
            (identical(other.keyPassword, keyPassword) ||
                other.keyPassword == keyPassword));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    taxpayer,
    const DeepCollectionEquality().hash(_certificateBytes),
    certificateFileName,
    const DeepCollectionEquality().hash(_keyBytes),
    keyFileName,
    keyPassword,
  );

  /// Create a copy of CertificateUpload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CertificateUploadImplCopyWith<_$CertificateUploadImpl> get copyWith =>
      __$$CertificateUploadImplCopyWithImpl<_$CertificateUploadImpl>(
        this,
        _$identity,
      );
}

abstract class _CertificateUpload implements CertificateUpload {
  const factory _CertificateUpload({
    required final String taxpayer,
    final List<int>? certificateBytes,
    final String? certificateFileName,
    final List<int>? keyBytes,
    final String? keyFileName,
    final String keyPassword,
  }) = _$CertificateUploadImpl;

  @override
  String get taxpayer;
  @override
  List<int>? get certificateBytes;
  @override
  String? get certificateFileName;
  @override
  List<int>? get keyBytes;
  @override
  String? get keyFileName;
  @override
  String get keyPassword;

  /// Create a copy of CertificateUpload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CertificateUploadImplCopyWith<_$CertificateUploadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
