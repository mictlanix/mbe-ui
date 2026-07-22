import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart'
    hide EntityStatus, FacilityType;

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/features/catalog/domain/address_formatting.dart';

part 'facility.freezed.dart';

/// An operating site — the merged successor of the legacy Store and
/// Production Site concepts (data-model.md "Facility", spec 014 US4).
/// Full detail entity for the Facilities catalog's own list and detail
/// screens, mapped from `FacilityResponse`.
@freezed
class Facility with _$Facility {
  const factory Facility({
    required int facilityId,
    required String code,
    required String name,
    required FacilityType type,
    required String locationId,
    required String locationLabel,
    required int addressId,
    required String addressLabel,
    required String taxpayerRfc,

    /// Resolved issuer name — `null` from [fromResponse] (the facility
    /// response carries only the RFC, not the expanded issuer); populated by
    /// the form controller's `loadForEdit` via a single
    /// `TaxpayerIssuersApi.get(rfc)` call (FR-034b, data-model.md).
    String? taxpayerName,
    String? logo,
    String? receiptMessage,
    String? defaultBatch,
    required EntityStatus status,
  }) = _Facility;

  factory Facility.fromResponse(FacilityResponse r) => Facility(
    facilityId: r.facilityId,
    code: r.code,
    name: r.name,
    type: FacilityType.fromApi(r.type),
    locationId: r.location.id,
    locationLabel: r.location.description ?? r.location.id,
    addressId: r.address.addressId,
    addressLabel: formatAddress(r.address),
    taxpayerRfc: r.taxpayer,
    logo: r.logo,
    receiptMessage: r.receiptMessage,
    defaultBatch: r.defaultBatch,
    status: EntityStatus.fromApi(r.status),
  );
}
