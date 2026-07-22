import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';

/// Point of Sale lookup and full CRUD management (data-model.md, US3,
/// contracts/mbe-api-catalogs.md §Points of Sale). [list]'s `facilityId`/
/// `warehouseId` params back the list screen's two FK filter facets
/// (FR-003). The backend validates `warehouseId ∈ facilityId` on
/// create/update (mbe-api#102) — the form's facility-scoped warehouse
/// picker (FR-022) is a UX convenience over that real invariant, not a
/// substitute for it (research.md §10).
abstract class PointSaleRepository {
  Future<PointSaleListResult> list({
    String? search,
    int? facilityId,
    int? warehouseId,
    EntityStatus? status,
    int skip = 0,
    int limit = 20,
  });

  Future<PointSale> get({required int pointSaleId});

  Future<PointSale> create({
    required int facilityId,
    required String code,
    required String name,
    required int warehouseId,
    String? comment,
    EntityStatus? status,
  });

  Future<PointSale> update({
    required int pointSaleId,
    int? facilityId,
    String? code,
    String? name,
    int? warehouseId,
    String? comment,
    EntityStatus? status,
  });

  Future<void> delete({required int pointSaleId});
}

class PointSaleListResult {
  const PointSaleListResult({required this.items, required this.total});
  final List<PointSale> items;
  final int total;
}
