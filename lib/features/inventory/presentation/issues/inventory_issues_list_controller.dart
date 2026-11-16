import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/inventory/data/inventory_issue_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_documents_filter.dart';

part 'inventory_issues_list_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds the "Salidas de almacén" page (spec 068 FR-002):
/// server paging, filtered by the URL facets. The server
/// orders newest first and applies the user's scope, so the request carries
/// no sort and no scope parameter.
@riverpod
class InventoryIssuesListController extends _$InventoryIssuesListController {
  @override
  Future<InventoryIssuePage> build(InventoryDocumentsFilter filter) =>
      fetchClampedPage(
        pageIndex: filter.pageIndex,
        pageSize: _pageSize,
        fetch: (pageIndex) => _fetch(filter, pageIndex),
      );

  Future<InventoryIssuePage> _fetch(
    InventoryDocumentsFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(inventoryIssueRepositoryProvider)
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
