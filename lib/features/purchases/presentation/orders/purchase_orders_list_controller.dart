import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_orders_filter.dart';

part 'purchase_orders_list_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds the "Órdenes de compra" page (spec 080 FR-004, research
/// R15): server paging, filtered by the URL facets. The server orders newest
/// first and decides the default scope, so the request carries no sort; the
/// client only sends `all` and the filters. No facility is ever sent
/// (FR-003).
@riverpod
class PurchaseOrdersListController extends _$PurchaseOrdersListController {
  @override
  Future<PurchaseOrderPage> build(PurchaseOrdersFilter filter) =>
      fetchClampedPage(
        pageIndex: filter.pageIndex,
        pageSize: _pageSize,
        fetch: (pageIndex) => _fetch(filter, pageIndex),
      );

  Future<PurchaseOrderPage> _fetch(
    PurchaseOrdersFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(purchaseOrderRepositoryProvider)
        .list(
          all: filter.all,
          status: filter.status,
          supplierId: filter.supplierId,
          creatorId: filter.creatorId,
          orderId: filter.orderId,
          from: filter.from,
          to: filter.to,
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
