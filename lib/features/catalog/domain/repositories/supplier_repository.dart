import 'package:mbe_ui/features/catalog/domain/entities/supplier.dart';
import 'package:mbe_ui/features/catalog/domain/entities/supplier_list_item.dart';

/// Supplier lookup and full CRUD management (data-model.md "SupplierRepository",
/// contracts/mbe-api-master-data-pickers.md, contracts/mbe-api-catalogs.md §1).
/// `list` is also consumed by the product form's read-only supplier picker
/// (specs/005) — unaffected by the CRUD additions below (spec 012).
abstract class SupplierRepository {
  Future<SupplierListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  });

  /// Full-detail listing for the Suppliers catalog screen itself (spec 012
  /// FR-001), as opposed to [list]'s lightweight `SupplierListItem` used by
  /// the product form's picker. Both hit the same `GET /suppliers` endpoint
  /// (which already returns the full `SupplierResponse` per row) — this is a
  /// different client-side projection of the same response, not a different
  /// endpoint.
  Future<SupplierPage> listDetailed({
    String? search,
    int skip = 0,
    int limit = 20,
  });

  Future<Supplier> get({required int supplierId});

  Future<Supplier> create({
    required String code,
    required String name,
    String? zone,
    String? creditLimit,
    int? creditDays,
    String? comment,
  });

  Future<Supplier> update({
    required int supplierId,
    String? code,
    String? name,
    String? zone,
    String? creditLimit,
    int? creditDays,
    String? comment,
  });

  Future<void> delete({required int supplierId});
}

class SupplierListResult {
  const SupplierListResult({required this.items, required this.total});
  final List<SupplierListItem> items;
  final int total;
}

class SupplierPage {
  const SupplierPage({required this.items, required this.total});
  final List<Supplier> items;
  final int total;
}
