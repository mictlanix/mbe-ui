import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/domain/entity_status.dart';

part 'vehicle_operator.freezed.dart';

/// A driver's credential record linking an existing employee (the driver) to
/// their driving-license details — full detail entity for the Vehicle
/// Operators catalog (data-model.md §3), mapped from
/// `VehicleOperatorResponse`. No external picker consumer, so this single
/// entity covers both list and detail rendering (research.md §3). Audit
/// fields (`creator`/`updater`/`creationTime`/`modificationTime`) are
/// available on the response but not surfaced by any FR — omitted here.
@freezed
class VehicleOperator with _$VehicleOperator {
  const factory VehicleOperator({
    required int vehicleOperatorId,
    required int driverId,
    required String driverName,
    required String licenseType,
    required String driverLicenseNumber,
    required DateTime issueDate,
    required DateTime expirationDate,
    required String issuingLocation,
    required EntityStatus status,
    int? daysUntilExpiry,
  }) = _VehicleOperator;

  factory VehicleOperator.fromResponse(VehicleOperatorResponse response) {
    return VehicleOperator(
      vehicleOperatorId: response.vehicleOperatorId,
      driverId: response.driver.employeeId,
      driverName: '${response.driver.firstName} ${response.driver.lastName}',
      licenseType: response.licenseType,
      driverLicenseNumber: response.driverLicenseNumber,
      issueDate: response.issueDate.toDateTime(),
      expirationDate: response.expirationDate.toDateTime(),
      issuingLocation: response.issuingLocation,
      status: EntityStatus.fromApi(response.status),
      daysUntilExpiry: response.daysUntilExpiry,
    );
  }
}

/// [daysUntilExpiry] is server-computed; when the server omits it, derive a
/// client-side fallback from [VehicleOperator.expirationDate] so the
/// "days until expiry" indicator is always shown (FR-019, SC-003,
/// research.md §7).
extension VehicleOperatorExpiry on VehicleOperator {
  int get effectiveDaysUntilExpiry =>
      daysUntilExpiry ?? expirationDate.difference(DateTime.now()).inDays;
}
