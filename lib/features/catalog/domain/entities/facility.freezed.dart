// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facility.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Facility {
  int get facilityId => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  FacilityType get type => throw _privateConstructorUsedError;
  String get locationId => throw _privateConstructorUsedError;
  String get locationLabel => throw _privateConstructorUsedError;
  int get addressId => throw _privateConstructorUsedError;
  String get addressLabel => throw _privateConstructorUsedError;
  String get taxpayerRfc => throw _privateConstructorUsedError;

  /// Resolved issuer name — `null` from [fromResponse] (the facility
  /// response carries only the RFC, not the expanded issuer); populated by
  /// the form controller's `loadForEdit` via a single
  /// `TaxpayerIssuersApi.get(rfc)` call (FR-034b, data-model.md).
  String? get taxpayerName => throw _privateConstructorUsedError;
  String? get logo => throw _privateConstructorUsedError;
  String? get receiptMessage => throw _privateConstructorUsedError;
  String? get defaultBatch => throw _privateConstructorUsedError;
  EntityStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of Facility
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FacilityCopyWith<Facility> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FacilityCopyWith<$Res> {
  factory $FacilityCopyWith(Facility value, $Res Function(Facility) then) =
      _$FacilityCopyWithImpl<$Res, Facility>;
  @useResult
  $Res call({
    int facilityId,
    String code,
    String name,
    FacilityType type,
    String locationId,
    String locationLabel,
    int addressId,
    String addressLabel,
    String taxpayerRfc,
    String? taxpayerName,
    String? logo,
    String? receiptMessage,
    String? defaultBatch,
    EntityStatus status,
  });
}

/// @nodoc
class _$FacilityCopyWithImpl<$Res, $Val extends Facility>
    implements $FacilityCopyWith<$Res> {
  _$FacilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Facility
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? facilityId = null,
    Object? code = null,
    Object? name = null,
    Object? type = null,
    Object? locationId = null,
    Object? locationLabel = null,
    Object? addressId = null,
    Object? addressLabel = null,
    Object? taxpayerRfc = null,
    Object? taxpayerName = freezed,
    Object? logo = freezed,
    Object? receiptMessage = freezed,
    Object? defaultBatch = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            facilityId: null == facilityId
                ? _value.facilityId
                : facilityId // ignore: cast_nullable_to_non_nullable
                      as int,
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
            locationId: null == locationId
                ? _value.locationId
                : locationId // ignore: cast_nullable_to_non_nullable
                      as String,
            locationLabel: null == locationLabel
                ? _value.locationLabel
                : locationLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            addressId: null == addressId
                ? _value.addressId
                : addressId // ignore: cast_nullable_to_non_nullable
                      as int,
            addressLabel: null == addressLabel
                ? _value.addressLabel
                : addressLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            taxpayerRfc: null == taxpayerRfc
                ? _value.taxpayerRfc
                : taxpayerRfc // ignore: cast_nullable_to_non_nullable
                      as String,
            taxpayerName: freezed == taxpayerName
                ? _value.taxpayerName
                : taxpayerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            logo: freezed == logo
                ? _value.logo
                : logo // ignore: cast_nullable_to_non_nullable
                      as String?,
            receiptMessage: freezed == receiptMessage
                ? _value.receiptMessage
                : receiptMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultBatch: freezed == defaultBatch
                ? _value.defaultBatch
                : defaultBatch // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$FacilityImplCopyWith<$Res>
    implements $FacilityCopyWith<$Res> {
  factory _$$FacilityImplCopyWith(
    _$FacilityImpl value,
    $Res Function(_$FacilityImpl) then,
  ) = __$$FacilityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int facilityId,
    String code,
    String name,
    FacilityType type,
    String locationId,
    String locationLabel,
    int addressId,
    String addressLabel,
    String taxpayerRfc,
    String? taxpayerName,
    String? logo,
    String? receiptMessage,
    String? defaultBatch,
    EntityStatus status,
  });
}

/// @nodoc
class __$$FacilityImplCopyWithImpl<$Res>
    extends _$FacilityCopyWithImpl<$Res, _$FacilityImpl>
    implements _$$FacilityImplCopyWith<$Res> {
  __$$FacilityImplCopyWithImpl(
    _$FacilityImpl _value,
    $Res Function(_$FacilityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Facility
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? facilityId = null,
    Object? code = null,
    Object? name = null,
    Object? type = null,
    Object? locationId = null,
    Object? locationLabel = null,
    Object? addressId = null,
    Object? addressLabel = null,
    Object? taxpayerRfc = null,
    Object? taxpayerName = freezed,
    Object? logo = freezed,
    Object? receiptMessage = freezed,
    Object? defaultBatch = freezed,
    Object? status = null,
  }) {
    return _then(
      _$FacilityImpl(
        facilityId: null == facilityId
            ? _value.facilityId
            : facilityId // ignore: cast_nullable_to_non_nullable
                  as int,
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
        locationId: null == locationId
            ? _value.locationId
            : locationId // ignore: cast_nullable_to_non_nullable
                  as String,
        locationLabel: null == locationLabel
            ? _value.locationLabel
            : locationLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        addressId: null == addressId
            ? _value.addressId
            : addressId // ignore: cast_nullable_to_non_nullable
                  as int,
        addressLabel: null == addressLabel
            ? _value.addressLabel
            : addressLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        taxpayerRfc: null == taxpayerRfc
            ? _value.taxpayerRfc
            : taxpayerRfc // ignore: cast_nullable_to_non_nullable
                  as String,
        taxpayerName: freezed == taxpayerName
            ? _value.taxpayerName
            : taxpayerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        logo: freezed == logo
            ? _value.logo
            : logo // ignore: cast_nullable_to_non_nullable
                  as String?,
        receiptMessage: freezed == receiptMessage
            ? _value.receiptMessage
            : receiptMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultBatch: freezed == defaultBatch
            ? _value.defaultBatch
            : defaultBatch // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as EntityStatus,
      ),
    );
  }
}

/// @nodoc

class _$FacilityImpl implements _Facility {
  const _$FacilityImpl({
    required this.facilityId,
    required this.code,
    required this.name,
    required this.type,
    required this.locationId,
    required this.locationLabel,
    required this.addressId,
    required this.addressLabel,
    required this.taxpayerRfc,
    this.taxpayerName,
    this.logo,
    this.receiptMessage,
    this.defaultBatch,
    required this.status,
  });

  @override
  final int facilityId;
  @override
  final String code;
  @override
  final String name;
  @override
  final FacilityType type;
  @override
  final String locationId;
  @override
  final String locationLabel;
  @override
  final int addressId;
  @override
  final String addressLabel;
  @override
  final String taxpayerRfc;

  /// Resolved issuer name — `null` from [fromResponse] (the facility
  /// response carries only the RFC, not the expanded issuer); populated by
  /// the form controller's `loadForEdit` via a single
  /// `TaxpayerIssuersApi.get(rfc)` call (FR-034b, data-model.md).
  @override
  final String? taxpayerName;
  @override
  final String? logo;
  @override
  final String? receiptMessage;
  @override
  final String? defaultBatch;
  @override
  final EntityStatus status;

  @override
  String toString() {
    return 'Facility(facilityId: $facilityId, code: $code, name: $name, type: $type, locationId: $locationId, locationLabel: $locationLabel, addressId: $addressId, addressLabel: $addressLabel, taxpayerRfc: $taxpayerRfc, taxpayerName: $taxpayerName, logo: $logo, receiptMessage: $receiptMessage, defaultBatch: $defaultBatch, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FacilityImpl &&
            (identical(other.facilityId, facilityId) ||
                other.facilityId == facilityId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.locationLabel, locationLabel) ||
                other.locationLabel == locationLabel) &&
            (identical(other.addressId, addressId) ||
                other.addressId == addressId) &&
            (identical(other.addressLabel, addressLabel) ||
                other.addressLabel == addressLabel) &&
            (identical(other.taxpayerRfc, taxpayerRfc) ||
                other.taxpayerRfc == taxpayerRfc) &&
            (identical(other.taxpayerName, taxpayerName) ||
                other.taxpayerName == taxpayerName) &&
            (identical(other.logo, logo) || other.logo == logo) &&
            (identical(other.receiptMessage, receiptMessage) ||
                other.receiptMessage == receiptMessage) &&
            (identical(other.defaultBatch, defaultBatch) ||
                other.defaultBatch == defaultBatch) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    facilityId,
    code,
    name,
    type,
    locationId,
    locationLabel,
    addressId,
    addressLabel,
    taxpayerRfc,
    taxpayerName,
    logo,
    receiptMessage,
    defaultBatch,
    status,
  );

  /// Create a copy of Facility
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FacilityImplCopyWith<_$FacilityImpl> get copyWith =>
      __$$FacilityImplCopyWithImpl<_$FacilityImpl>(this, _$identity);
}

abstract class _Facility implements Facility {
  const factory _Facility({
    required final int facilityId,
    required final String code,
    required final String name,
    required final FacilityType type,
    required final String locationId,
    required final String locationLabel,
    required final int addressId,
    required final String addressLabel,
    required final String taxpayerRfc,
    final String? taxpayerName,
    final String? logo,
    final String? receiptMessage,
    final String? defaultBatch,
    required final EntityStatus status,
  }) = _$FacilityImpl;

  @override
  int get facilityId;
  @override
  String get code;
  @override
  String get name;
  @override
  FacilityType get type;
  @override
  String get locationId;
  @override
  String get locationLabel;
  @override
  int get addressId;
  @override
  String get addressLabel;
  @override
  String get taxpayerRfc;

  /// Resolved issuer name — `null` from [fromResponse] (the facility
  /// response carries only the RFC, not the expanded issuer); populated by
  /// the form controller's `loadForEdit` via a single
  /// `TaxpayerIssuersApi.get(rfc)` call (FR-034b, data-model.md).
  @override
  String? get taxpayerName;
  @override
  String? get logo;
  @override
  String? get receiptMessage;
  @override
  String? get defaultBatch;
  @override
  EntityStatus get status;

  /// Create a copy of Facility
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FacilityImplCopyWith<_$FacilityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
