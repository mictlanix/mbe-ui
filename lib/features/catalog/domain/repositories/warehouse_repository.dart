import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';

/// Warehouse lookup and full CRUD management (data-model.md, US1,
/// contracts/mbe-api-catalogs.md §Warehouses). [list]'s `facilityId` param
/// backs both the list screen's facility filter facet (FR-003) and the
/// facility-scoped warehouse picker Points of Sale reuses (FR-022).
abstract class WarehouseRepository {
  Future<WarehouseListResult> list({
    String? search,
    int? facilityId,
    EntityStatus? status,
    int skip = 0,
    int limit = 20,
  });

  Future<Warehouse> get({required int warehouseId});

  Future<Warehouse> create({
    required int facilityId,
    required String code,
    required String name,
    String? comment,
    EntityStatus? status,
  });

  Future<Warehouse> update({
    required int warehouseId,
    int? facilityId,
    String? code,
    String? name,
    String? comment,
    EntityStatus? status,
  });

  Future<void> delete({required int warehouseId});
}

class WarehouseListResult {
  const WarehouseListResult({required this.items, required this.total});
  final List<Warehouse> items;
  final int total;
}
