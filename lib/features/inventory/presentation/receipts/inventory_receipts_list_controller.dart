import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_filter.dart';

part 'inventory_receipts_list_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds the "Entradas de almacén" page (spec 067 FR-002,
/// research R9): server paging, filtered by the URL facets. The server
/// orders newest first and applies the user's scope, so the request carries
/// no sort and no scope parameter.
@riverpod
class InventoryReceiptsListController
    extends _$InventoryReceiptsListController {
  @override
  Future<InventoryReceiptPage> build(InventoryReceiptsFilter filter) =>
      fetchClampedPage(
        pageIndex: filter.pageIndex,
        pageSize: _pageSize,
        fetch: (pageIndex) => _fetch(filter, pageIndex),
      );

  Future<InventoryReceiptPage> _fetch(
    InventoryReceiptsFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(inventoryReceiptRepositoryProvider)
        .list(
          status: filter.status,
          warehouseId: filter.warehouseId,
          skip: pageIndex * _pageSize,
          limit: _pageSize,
        );
    return CatalogPage(
      items: result.items,
      total: result.total,
      pageIndex: pageIndex,
      pageSize: _pageSize,
    );
  }
}
