import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle.dart';

/// Vehicle lookup and full CRUD management (data-model.md §2,
/// contracts/mbe-api-catalogs.md §2). No external picker/filter consumer, so
/// a single `list` projection covers the catalog's own list screen
/// (research.md §3).
abstract class VehicleRepository {
  Future<VehicleListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  });

  Future<Vehicle> get({required int vehicleId});

  Future<Vehicle> create({
    required String licensePlate,
    required String name,
    required String nickname,
    required int tonsCapacity,
    EntityStatus? status,
  });

  Future<Vehicle> update({
    required int vehicleId,
    String? licensePlate,
    String? name,
    String? nickname,
    int? tonsCapacity,
    EntityStatus? status,
  });

  Future<void> delete({required int vehicleId});
}

class VehicleListResult {
  const VehicleListResult({required this.items, required this.total});
  final List<Vehicle> items;
  final int total;
}
