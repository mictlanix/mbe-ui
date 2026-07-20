import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';

/// Vehicle Operator lookup and full CRUD management (data-model.md §3,
/// contracts/mbe-api-catalogs.md §3). No external picker/filter consumer, so
/// a single `list` projection covers the catalog's own list screen
/// (research.md §3). [driverId] maps to the endpoint's `employee` query
/// param (research.md §6).
abstract class VehicleOperatorRepository {
  Future<VehicleOperatorListResult> list({
    String? search,
    int? driverId,
    int skip = 0,
    int limit = 20,
  });

  Future<VehicleOperator> get({required int vehicleOperatorId});

  Future<VehicleOperator> create({
    required int driverId,
    required String licenseType,
    required String driverLicenseNumber,
    required DateTime issueDate,
    required DateTime expirationDate,
    required String issuingLocation,
    bool? active,
  });

  Future<VehicleOperator> update({
    required int vehicleOperatorId,
    int? driverId,
    String? licenseType,
    String? driverLicenseNumber,
    DateTime? issueDate,
    DateTime? expirationDate,
    String? issuingLocation,
    bool? active,
  });

  Future<void> delete({required int vehicleOperatorId});
}

class VehicleOperatorListResult {
  const VehicleOperatorListResult({required this.items, required this.total});
  final List<VehicleOperator> items;
  final int total;
}
