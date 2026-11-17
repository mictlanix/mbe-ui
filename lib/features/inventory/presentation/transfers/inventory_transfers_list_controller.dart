import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfers_filter.dart';

part 'inventory_transfers_list_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds the "Traspasos" page (spec 069 FR-002): server paging,
/// filtered by the URL facets. The server orders newest first and applies the
/// user's scope, so the request carries no sort and no scope parameter.
@riverpod
class InventoryTransfersListController
    extends _$InventoryTransfersListController {
  @override
  Future<InventoryTransferPage> build(InventoryTransfersFilter filter) =>
      fetchClampedPage(
        pageIndex: filter.pageIndex,
        pageSize: _pageSize,
        fetch: (pageIndex) => _fetch(filter, pageIndex),
      );

  Future<InventoryTransferPage> _fetch(
    InventoryTransfersFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(inventoryTransferRepositoryProvider)
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
