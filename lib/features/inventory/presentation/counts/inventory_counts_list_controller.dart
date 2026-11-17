import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/inventory/data/inventory_count_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_documents_filter.dart';

part 'inventory_counts_list_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds the "Conteos físicos" page (spec 070 FR-002): server
/// paging, filtered by the URL facets. The server orders newest first and
/// applies the user's scope, so the request carries no sort and no scope
/// parameter.
@riverpod
class InventoryCountsListController extends _$InventoryCountsListController {
  @override
  Future<InventoryCountPage> build(InventoryDocumentsFilter filter) =>
      fetchClampedPage(
        pageIndex: filter.pageIndex,
        pageSize: _pageSize,
        fetch: (pageIndex) => _fetch(filter, pageIndex),
      );

  Future<InventoryCountPage> _fetch(
    InventoryDocumentsFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(inventoryCountRepositoryProvider)
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
