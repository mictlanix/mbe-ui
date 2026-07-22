import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';

/// CashDrawer lookup and full CRUD management (data-model.md, US2,
/// contracts/mbe-api-catalogs.md §CashDrawers). [list]'s `facilityId` param
/// backs the list screen's facility filter facet (FR-003) — the same shape
/// as [WarehouseRepository], with no Points of Sale dependency (research.md §3).
abstract class CashDrawerRepository {
  Future<CashDrawerListResult> list({
    String? search,
    int? facilityId,
    EntityStatus? status,
    int skip = 0,
    int limit = 20,
  });

  Future<CashDrawer> get({required int cashDrawerId});

  Future<CashDrawer> create({
    required int facilityId,
    required String code,
    required String name,
    String? comment,
    EntityStatus? status,
  });

  Future<CashDrawer> update({
    required int cashDrawerId,
    int? facilityId,
    String? code,
    String? name,
    String? comment,
    EntityStatus? status,
  });

  Future<void> delete({required int cashDrawerId});
}

class CashDrawerListResult {
  const CashDrawerListResult({required this.items, required this.total});
  final List<CashDrawer> items;
  final int total;
}
