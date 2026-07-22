// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facility_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FacilityFormState {
  int? get facilityId => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  FacilityType get type => throw _privateConstructorUsedError;
  String? get locationId => throw _privateConstructorUsedError;
  String get locationDisplayText => throw _privateConstructorUsedError;
  int? get addressId => throw _privateConstructorUsedError;
  String get addressDisplayText => throw _privateConstructorUsedError;

  /// The stored issuer RFC (FR-034). Empty until a taxpayer is picked (or
  /// typed, in the read-denied fallback).
  String get taxpayerRfc => throw _privateConstructorUsedError;

  /// The issuer display name resolved on load (FR-034b); the taxpayer field
  /// shows `taxpayerDisplayText`, which the detail screen prefers over the
  /// bare [taxpayerRfc].
  String get taxpayerDisplayText => throw _privateConstructorUsedError;
  String get logo => throw _privateConstructorUsedError;
  String get receiptMessage => throw _privateConstructorUsedError;
  String get defaultBatch => throw _privateConstructorUsedError;
  EntityStatus get status => throw _privateConstructorUsedError;
  bool get loading => throw _privateConstructorUsedError;
  bool get submitting => throw _privateConstructorUsedError;
  bool get saved => throw _privateConstructorUsedError;
  bool get deleted => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get errorDetail => throw _privateConstructorUsedError;
  Map<String, String> get fieldErrors => throw _privateConstructorUsedError;

  /// Create a copy of FacilityFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FacilityFormStateCopyWith<FacilityFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FacilityFormStateCopyWith<$Res> {
  factory $FacilityFormStateCopyWith(
    FacilityFormState value,
    $Res Function(FacilityFormState) then,
  ) = _$FacilityFormStateCopyWithImpl<$Res, FacilityFormState>;
  @useResult
  $Res call({
    int? facilityId,
    String code,
    String name,
    FacilityType type,
    String? locationId,
    String locationDisplayText,
    int? addressId,
    String addressDisplayText,
    String taxpayerRfc,
    String taxpayerDisplayText,
    String logo,
    String receiptMessage,
    String defaultBatch,
    EntityStatus status,
    bool loading,
    bool submitting,
    bool saved,
    bool deleted,
    String? error,
    String? errorDetail,
    Map<String, String> fieldErrors,
  });
}

/// @nodoc
class _$FacilityFormStateCopyWithImpl<$Res, $Val extends FacilityFormState>
    implements $FacilityFormStateCopyWith<$Res> {
  _$FacilityFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FacilityFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? facilityId = freezed,
    Object? code = null,
    Object? name = null,
    Object? type = null,
    Object? locationId = freezed,
    Object? locationDisplayText = null,
    Object? addressId = freezed,
    Object? addressDisplayText = null,
    Object? taxpayerRfc = null,
    Object? taxpayerDisplayText = null,
    Object? logo = null,
    Object? receiptMessage = null,
    Object? defaultBatch = null,
    Object? status = null,
    Object? loading = null,
    Object? submitting = null,
    Object? saved = null,
    Object? deleted = null,
    Object? error = freezed,
    Object? errorDetail = freezed,
    Object? fieldErrors = null,
  }) {
    return _then(
      _value.copyWith(
            facilityId: freezed == facilityId
                ? _value.facilityId
                : facilityId // ignore: cast_nullable_to_non_nullable
                      as int?,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as FacilityType,
            locationId: freezed == locationId
                ? _value.locationId
                : locationId // ignore: cast_nullable_to_non_nullable
                      as String?,
            locationDisplayText: null == locationDisplayText
                ? _value.locationDisplayText
                : locationDisplayText // ignore: cast_nullable_to_non_nullable
                      as String,
            addressId: freezed == addressId
                ? _value.addressId
                : addressId // ignore: cast_nullable_to_non_nullable
                      as int?,
            addressDisplayText: null == addressDisplayText
                ? _value.addressDisplayText
                : addressDisplayText // ignore: cast_nullable_to_non_nullable
                      as String,
            taxpayerRfc: null == taxpayerRfc
                ? _value.taxpayerRfc
                : taxpayerRfc // ignore: cast_nullable_to_non_nullable
                      as String,
            taxpayerDisplayText: null == taxpayerDisplayText
                ? _value.taxpayerDisplayText
                : taxpayerDisplayText // ignore: cast_nullable_to_non_nullable
                      as String,
            logo: null == logo
                ? _value.logo
                : logo // ignore: cast_nullable_to_non_nullable
                      as String,
            receiptMessage: null == receiptMessage
                ? _value.receiptMessage
                : receiptMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultBatch: null == defaultBatch
                ? _value.defaultBatch
                : defaultBatch // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as EntityStatus,
            loading: null == loading
                ? _value.loading
                : loading // ignore: cast_nullable_to_non_nullable
                      as bool,
            submitting: null == submitting
                ? _value.submitting
                : submitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            saved: null == saved
                ? _value.saved
                : saved // ignore: cast_nullable_to_non_nullable
                      as bool,
            deleted: null == deleted
                ? _value.deleted
                : deleted // ignore: cast_nullable_to_non_nullable
                      as bool,
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
}

/// @nodoc
abstract class _$$FacilityFormStateImplCopyWith<$Res>
    implements $FacilityFormStateCopyWith<$Res> {
  factory _$$FacilityFormStateImplCopyWith(
    _$FacilityFormStateImpl value,
    $Res Function(_$FacilityFormStateImpl) then,
  ) = __$$FacilityFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? facilityId,
    String code,
    String name,
    FacilityType type,
    String? locationId,
    String locationDisplayText,
    int? addressId,
    String addressDisplayText,
    String taxpayerRfc,
    String taxpayerDisplayText,
    String logo,
    String receiptMessage,
    String defaultBatch,
    EntityStatus status,
    bool loading,
    bool submitting,
    bool saved,
    bool deleted,
    String? error,
    String? errorDetail,
    Map<String, String> fieldErrors,
  });
}

/// @nodoc
class __$$FacilityFormStateImplCopyWithImpl<$Res>
    extends _$FacilityFormStateCopyWithImpl<$Res, _$FacilityFormStateImpl>
    implements _$$FacilityFormStateImplCopyWith<$Res> {
  __$$FacilityFormStateImplCopyWithImpl(
    _$FacilityFormStateImpl _value,
    $Res Function(_$FacilityFormStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FacilityFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? facilityId = freezed,
    Object? code = null,
    Object? name = null,
    Object? type = null,
    Object? locationId = freezed,
    Object? locationDisplayText = null,
    Object? addressId = freezed,
    Object? addressDisplayText = null,
    Object? taxpayerRfc = null,
    Object? taxpayerDisplayText = null,
    Object? logo = null,
    Object? receiptMessage = null,
    Object? defaultBatch = null,
    Object? status = null,
    Object? loading = null,
    Object? submitting = null,
    Object? saved = null,
    Object? deleted = null,
    Object? error = freezed,
    Object? errorDetail = freezed,
    Object? fieldErrors = null,
  }) {
    return _then(
      _$FacilityFormStateImpl(
        facilityId: freezed == facilityId
            ? _value.facilityId
            : facilityId // ignore: cast_nullable_to_non_nullable
                  as int?,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as FacilityType,
        locationId: freezed == locationId
            ? _value.locationId
            : locationId // ignore: cast_nullable_to_non_nullable
                  as String?,
        locationDisplayText: null == locationDisplayText
            ? _value.locationDisplayText
            : locationDisplayText // ignore: cast_nullable_to_non_nullable
                  as String,
        addressId: freezed == addressId
            ? _value.addressId
            : addressId // ignore: cast_nullable_to_non_nullable
                  as int?,
        addressDisplayText: null == addressDisplayText
            ? _value.addressDisplayText
            : addressDisplayText // ignore: cast_nullable_to_non_nullable
                  as String,
        taxpayerRfc: null == taxpayerRfc
            ? _value.taxpayerRfc
            : taxpayerRfc // ignore: cast_nullable_to_non_nullable
                  as String,
        taxpayerDisplayText: null == taxpayerDisplayText
            ? _value.taxpayerDisplayText
            : taxpayerDisplayText // ignore: cast_nullable_to_non_nullable
                  as String,
        logo: null == logo
            ? _value.logo
            : logo // ignore: cast_nullable_to_non_nullable
                  as String,
        receiptMessage: null == receiptMessage
            ? _value.receiptMessage
            : receiptMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultBatch: null == defaultBatch
            ? _value.defaultBatch
            : defaultBatch // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus,
        loading: null == loading
            ? _value.loading
            : loading // ignore: cast_nullable_to_non_nullable
                  as bool,
        submitting: null == submitting
            ? _value.submitting
            : submitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        saved: null == saved
            ? _value.saved
            : saved // ignore: cast_nullable_to_non_nullable
                  as bool,
        deleted: null == deleted
            ? _value.deleted
            : deleted // ignore: cast_nullable_to_non_nullable
                  as bool,
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

class _$FacilityFormStateImpl implements _FacilityFormState {
  const _$FacilityFormStateImpl({
    this.facilityId,
    this.code = '',
    this.name = '',
    this.type = FacilityType.store,
    this.locationId,
    this.locationDisplayText = '',
    this.addressId,
    this.addressDisplayText = '',
    this.taxpayerRfc = '',
    this.taxpayerDisplayText = '',
    this.logo = '',
    this.receiptMessage = '',
    this.defaultBatch = '',
    this.status = EntityStatus.active,
    this.loading = false,
    this.submitting = false,
    this.saved = false,
    this.deleted = false,
    this.error,
    this.errorDetail,
    final Map<String, String> fieldErrors = const <String, String>{},
  }) : _fieldErrors = fieldErrors;

  @override
  final int? facilityId;
  @override
  @JsonKey()
  final String code;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final FacilityType type;
  @override
  final String? locationId;
  @override
  @JsonKey()
  final String locationDisplayText;
  @override
  final int? addressId;
  @override
  @JsonKey()
  final String addressDisplayText;

  /// The stored issuer RFC (FR-034). Empty until a taxpayer is picked (or
  /// typed, in the read-denied fallback).
  @override
  @JsonKey()
  final String taxpayerRfc;

  /// The issuer display name resolved on load (FR-034b); the taxpayer field
  /// shows `taxpayerDisplayText`, which the detail screen prefers over the
  /// bare [taxpayerRfc].
  @override
  @JsonKey()
  final String taxpayerDisplayText;
  @override
  @JsonKey()
  final String logo;
  @override
  @JsonKey()
  final String receiptMessage;
  @override
  @JsonKey()
  final String defaultBatch;
  @override
  @JsonKey()
  final EntityStatus status;
  @override
  @JsonKey()
  final bool loading;
  @override
  @JsonKey()
  final bool submitting;
  @override
  @JsonKey()
  final bool saved;
  @override
  @JsonKey()
  final bool deleted;
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
    return 'FacilityFormState(facilityId: $facilityId, code: $code, name: $name, type: $type, locationId: $locationId, locationDisplayText: $locationDisplayText, addressId: $addressId, addressDisplayText: $addressDisplayText, taxpayerRfc: $taxpayerRfc, taxpayerDisplayText: $taxpayerDisplayText, logo: $logo, receiptMessage: $receiptMessage, defaultBatch: $defaultBatch, status: $status, loading: $loading, submitting: $submitting, saved: $saved, deleted: $deleted, error: $error, errorDetail: $errorDetail, fieldErrors: $fieldErrors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FacilityFormStateImpl &&
            (identical(other.facilityId, facilityId) ||
                other.facilityId == facilityId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.locationDisplayText, locationDisplayText) ||
                other.locationDisplayText == locationDisplayText) &&
            (identical(other.addressId, addressId) ||
                other.addressId == addressId) &&
            (identical(other.addressDisplayText, addressDisplayText) ||
                other.addressDisplayText == addressDisplayText) &&
            (identical(other.taxpayerRfc, taxpayerRfc) ||
                other.taxpayerRfc == taxpayerRfc) &&
            (identical(other.taxpayerDisplayText, taxpayerDisplayText) ||
                other.taxpayerDisplayText == taxpayerDisplayText) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.receiptMessage, receiptMessage) ||
                other.receiptMessage == receiptMessage) &&
            (identical(other.defaultBatch, defaultBatch) ||
                other.defaultBatch == defaultBatch) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.submitting, submitting) ||
                other.submitting == submitting) &&
            (identical(other.saved, saved) || other.saved == saved) &&
            (identical(other.deleted, deleted) || other.deleted == deleted) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.errorDetail, errorDetail) ||
                other.errorDetail == errorDetail) &&
            const DeepCollectionEquality().equals(
              other._fieldErrors,
              _fieldErrors,
            ));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    facilityId,
    code,
    name,
    type,
    locationId,
    locationDisplayText,
    addressId,
    addressDisplayText,
    taxpayerRfc,
    taxpayerDisplayText,
    logo,
    receiptMessage,
    defaultBatch,
    status,
    loading,
    submitting,
    saved,
    deleted,
    error,
    errorDetail,
    const DeepCollectionEquality().hash(_fieldErrors),
  ]);

  /// Create a copy of FacilityFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FacilityFormStateImplCopyWith<_$FacilityFormStateImpl> get copyWith =>
      __$$FacilityFormStateImplCopyWithImpl<_$FacilityFormStateImpl>(
        this,
        _$identity,
      );
}

abstract class _FacilityFormState implements FacilityFormState {
  const factory _FacilityFormState({
    final int? facilityId,
    final String code,
    final String name,
    final FacilityType type,
    final String? locationId,
    final String locationDisplayText,
    final int? addressId,
    final String addressDisplayText,
    final String taxpayerRfc,
    final String taxpayerDisplayText,
    final String logo,
    final String receiptMessage,
    final String defaultBatch,
    final EntityStatus status,
    final bool loading,
    final bool submitting,
    final bool saved,
    final bool deleted,
    final String? error,
    final String? errorDetail,
    final Map<String, String> fieldErrors,
  }) = _$FacilityFormStateImpl;

  @override
  int? get facilityId;
  @override
  String get code;
  @override
  String get name;
  @override
  FacilityType get type;
  @override
  String? get locationId;
  @override
  String get locationDisplayText;
  @override
  int? get addressId;
  @override
  String get addressDisplayText;

  /// The stored issuer RFC (FR-034). Empty until a taxpayer is picked (or
  /// typed, in the read-denied fallback).
  @override
  String get taxpayerRfc;

  /// The issuer display name resolved on load (FR-034b); the taxpayer field
  /// shows `taxpayerDisplayText`, which the detail screen prefers over the
  /// bare [taxpayerRfc].
  @override
  String get taxpayerDisplayText;
  @override
  String get logo;
  @override
  String get receiptMessage;
  @override
  String get defaultBatch;
  @override
  EntityStatus get status;
  @override
  bool get loading;
  @override
  bool get submitting;
  @override
  bool get saved;
  @override
  bool get deleted;
  @override
  String? get error;
  @override
  String? get errorDetail;
  @override
  Map<String, String> get fieldErrors;

  /// Create a copy of FacilityFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FacilityFormStateImplCopyWith<_$FacilityFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
