import 'package:mbe_ui/features/catalog/domain/entities/supplier_list_item.dart';

/// Read-only supplier lookup, consumed by the supplier picker on the product
/// form (data-model.md "SupplierRepository", contracts/mbe-api-master-data-pickers.md).
abstract class SupplierRepository {
  Future<SupplierListResult> list({
    String? search,
    int skip = 0,
    int limit = 20,
  });
}

class SupplierListResult {
  const SupplierListResult({required this.items, required this.total});
  final List<SupplierListItem> items;
  final int total;
}
