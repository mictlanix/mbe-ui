// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxpayer_certificate_upload_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TaxpayerCertificateUploadState {
  String get taxpayer => throw _privateConstructorUsedError;
  List<int>? get certificateBytes => throw _privateConstructorUsedError;
  String get certificateFileName => throw _privateConstructorUsedError;
  List<int>? get keyBytes => throw _privateConstructorUsedError;
  String get keyFileName => throw _privateConstructorUsedError;
  String get keyPassword => throw _privateConstructorUsedError;
  bool get submitting => throw _privateConstructorUsedError;
  TaxpayerCertificate? get uploaded => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get errorDetail => throw _privateConstructorUsedError;
  Map<String, String> get fieldErrors => throw _privateConstructorUsedError;

  /// Create a copy of TaxpayerCertificateUploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaxpayerCertificateUploadStateCopyWith<TaxpayerCertificateUploadState>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxpayerCertificateUploadStateCopyWith<$Res> {
  factory $TaxpayerCertificateUploadStateCopyWith(
    TaxpayerCertificateUploadState value,
    $Res Function(TaxpayerCertificateUploadState) then,
  ) =
      _$TaxpayerCertificateUploadStateCopyWithImpl<
        $Res,
        TaxpayerCertificateUploadState
      >;
  @useResult
  $Res call({
    String taxpayer,
    List<int>? certificateBytes,
    String certificateFileName,
    List<int>? keyBytes,
    String keyFileName,
    String keyPassword,
    bool submitting,
    TaxpayerCertificate? uploaded,
    String? error,
    String? errorDetail,
    Map<String, String> fieldErrors,
  });

  $TaxpayerCertificateCopyWith<$Res>? get uploaded;
}

/// @nodoc
class _$TaxpayerCertificateUploadStateCopyWithImpl<
  $Res,
  $Val extends TaxpayerCertificateUploadState
>
    implements $TaxpayerCertificateUploadStateCopyWith<$Res> {
  _$TaxpayerCertificateUploadStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaxpayerCertificateUploadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taxpayer = null,
    Object? certificateBytes = freezed,
    Object? certificateFileName = null,
    Object? keyBytes = freezed,
    Object? keyFileName = null,
    Object? keyPassword = null,
    Object? submitting = null,
    Object? uploaded = freezed,
    Object? error = freezed,
    Object? errorDetail = freezed,
    Object? fieldErrors = null,
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
            certificateFileName: null == certificateFileName
                ? _value.certificateFileName
                : certificateFileName // ignore: cast_nullable_to_non_nullable
                      as String,
            keyBytes: freezed == keyBytes
                ? _value.keyBytes
                : keyBytes // ignore: cast_nullable_to_non_nullable
                      as List<int>?,
            keyFileName: null == keyFileName
                ? _value.keyFileName
                : keyFileName // ignore: cast_nullable_to_non_nullable
                      as String,
            keyPassword: null == keyPassword
                ? _value.keyPassword
                : keyPassword // ignore: cast_nullable_to_non_nullable
                      as String,
            submitting: null == submitting
                ? _value.submitting
                : submitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            uploaded: freezed == uploaded
                ? _value.uploaded
                : uploaded // ignore: cast_nullable_to_non_nullable
                      as TaxpayerCertificate?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorDetail: freezed == errorDetail
                ? _value.errorDetail
                : errorDetail // ignore: cast_nullable_to_non_nullable
                      as String?,
            fieldErrors: null == fieldErrors
                ? _value.fieldErrors
                : fieldErrors // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
          )
          as $Val,
    );
  }

  /// Create a copy of TaxpayerCertificateUploadState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TaxpayerCertificateCopyWith<$Res>? get uploaded {
    if (_value.uploaded == null) {
      return null;
    }

    return $TaxpayerCertificateCopyWith<$Res>(_value.uploaded!, (value) {
      return _then(_value.copyWith(uploaded: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TaxpayerCertificateUploadStateImplCopyWith<$Res>
    implements $TaxpayerCertificateUploadStateCopyWith<$Res> {
  factory _$$TaxpayerCertificateUploadStateImplCopyWith(
    _$TaxpayerCertificateUploadStateImpl value,
    $Res Function(_$TaxpayerCertificateUploadStateImpl) then,
  ) = __$$TaxpayerCertificateUploadStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String taxpayer,
    List<int>? certificateBytes,
    String certificateFileName,
    List<int>? keyBytes,
    String keyFileName,
    String keyPassword,
    bool submitting,
    TaxpayerCertificate? uploaded,
    String? error,
    String? errorDetail,
    Map<String, String> fieldErrors,
  });

  @override
  $TaxpayerCertificateCopyWith<$Res>? get uploaded;
}

/// @nodoc
class __$$TaxpayerCertificateUploadStateImplCopyWithImpl<$Res>
    extends
        _$TaxpayerCertificateUploadStateCopyWithImpl<
          $Res,
          _$TaxpayerCertificateUploadStateImpl
        >
    implements _$$TaxpayerCertificateUploadStateImplCopyWith<$Res> {
  __$$TaxpayerCertificateUploadStateImplCopyWithImpl(
    _$TaxpayerCertificateUploadStateImpl _value,
    $Res Function(_$TaxpayerCertificateUploadStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaxpayerCertificateUploadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taxpayer = null,
    Object? certificateBytes = freezed,
    Object? certificateFileName = null,
    Object? keyBytes = freezed,
    Object? keyFileName = null,
    Object? keyPassword = null,
    Object? submitting = null,
    Object? uploaded = freezed,
    Object? error = freezed,
    Object? errorDetail = freezed,
    Object? fieldErrors = null,
  }) {
    return _then(
      _$TaxpayerCertificateUploadStateImpl(
        taxpayer: null == taxpayer
            ? _value.taxpayer
            : taxpayer // ignore: cast_nullable_to_non_nullable
                  as String,
        certificateBytes: freezed == certificateBytes
            ? _value._certificateBytes
            : certificateBytes // ignore: cast_nullable_to_non_nullable
                  as List<int>?,
        certificateFileName: null == certificateFileName
            ? _value.certificateFileName
            : certificateFileName // ignore: cast_nullable_to_non_nullable
                  as String,
        keyBytes: freezed == keyBytes
            ? _value._keyBytes
            : keyBytes // ignore: cast_nullable_to_non_nullable
                  as List<int>?,
        keyFileName: null == keyFileName
            ? _value.keyFileName
            : keyFileName // ignore: cast_nullable_to_non_nullable
                  as String,
        keyPassword: null == keyPassword
            ? _value.keyPassword
            : keyPassword // ignore: cast_nullable_to_non_nullable
                  as String,
        submitting: null == submitting
            ? _value.submitting
            : submitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        uploaded: freezed == uploaded
            ? _value.uploaded
            : uploaded // ignore: cast_nullable_to_non_nullable
                  as TaxpayerCertificate?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorDetail: freezed == errorDetail
            ? _value.errorDetail
            : errorDetail // ignore: cast_nullable_to_non_nullable
                  as String?,
        fieldErrors: null == fieldErrors
            ? _value._fieldErrors
            : fieldErrors // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
      ),
    );
  }
}

/// @nodoc

class _$TaxpayerCertificateUploadStateImpl
    implements _TaxpayerCertificateUploadState {
  const _$TaxpayerCertificateUploadStateImpl({
    required this.taxpayer,
    final List<int>? certificateBytes,
    this.certificateFileName = '',
    final List<int>? keyBytes,
    this.keyFileName = '',
    this.keyPassword = '',
    this.submitting = false,
    this.uploaded,
    this.error,
    this.errorDetail,
    final Map<String, String> fieldErrors = const <String, String>{},
  }) : _certificateBytes = certificateBytes,
       _keyBytes = keyBytes,
       _fieldErrors = fieldErrors;

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
  @JsonKey()
  final String certificateFileName;
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
  @JsonKey()
  final String keyFileName;
  @override
  @JsonKey()
  final String keyPassword;
  @override
  @JsonKey()
  final bool submitting;
  @override
  final TaxpayerCertificate? uploaded;
  @override
  final String? error;
  @override
  final String? errorDetail;
  final Map<String, String> _fieldErrors;
  @override
  @JsonKey()
  Map<String, String> get fieldErrors {
    if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_fieldErrors);
  }

  @override
  String toString() {
    return 'TaxpayerCertificateUploadState(taxpayer: $taxpayer, certificateBytes: $certificateBytes, certificateFileName: $certificateFileName, keyBytes: $keyBytes, keyFileName: $keyFileName, keyPassword: $keyPassword, submitting: $submitting, uploaded: $uploaded, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaxpayerCertificateUploadStateImpl &&
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
                other.keyPassword == keyPassword) &&
            (identical(other.submitting, submitting) ||
                other.submitting == submitting) &&
            (identical(other.uploaded, uploaded) ||
                other.uploaded == uploaded) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.errorDetail, errorDetail) ||
                other.errorDetail == errorDetail) &&
            const DeepCollectionEquality().equals(
              other._fieldErrors,
              _fieldErrors,
            ));
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
    submitting,
    uploaded,
    error,
    errorDetail,
    const DeepCollectionEquality().hash(_fieldErrors),
  );

  /// Create a copy of TaxpayerCertificateUploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaxpayerCertificateUploadStateImplCopyWith<
    _$TaxpayerCertificateUploadStateImpl
  >
  get copyWith =>
      __$$TaxpayerCertificateUploadStateImplCopyWithImpl<
        _$TaxpayerCertificateUploadStateImpl
      >(this, _$identity);
}

abstract class _TaxpayerCertificateUploadState
    implements TaxpayerCertificateUploadState {
  const factory _TaxpayerCertificateUploadState({
    required final String taxpayer,
    final List<int>? certificateBytes,
    final String certificateFileName,
    final List<int>? keyBytes,
    final String keyFileName,
    final String keyPassword,
    final bool submitting,
    final TaxpayerCertificate? uploaded,
    final String? error,
    final String? errorDetail,
    final Map<String, String> fieldErrors,
  }) = _$TaxpayerCertificateUploadStateImpl;

  @override
  String get taxpayer;
  @override
  List<int>? get certificateBytes;
  @override
  String get certificateFileName;
  @override
  List<int>? get keyBytes;
  @override
  String get keyFileName;
  @override
  String get keyPassword;
  @override
  bool get submitting;
  @override
  TaxpayerCertificate? get uploaded;
  @override
  String? get error;
  @override
  String? get errorDetail;
  @override
  Map<String, String> get fieldErrors;

  /// Create a copy of TaxpayerCertificateUploadState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaxpayerCertificateUploadStateImplCopyWith<
    _$TaxpayerCertificateUploadStateImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
