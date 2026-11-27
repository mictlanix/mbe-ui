import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_requests_filter.dart';

part 'purchase_requests_list_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds the "Solicitudes de compra" page (spec 079 FR-002,
/// research R9): server paging, filtered by the URL facets. The server orders
/// newest first and decides the default scope, so the request carries no
/// sort; the client only sends `all` and the filters.
@riverpod
class PurchaseRequestsListController extends _$PurchaseRequestsListController {
  @override
  Future<PurchaseRequestPage> build(PurchaseRequestsFilter filter) =>
      fetchClampedPage(
        pageIndex: filter.pageIndex,
        pageSize: _pageSize,
        fetch: (pageIndex) => _fetch(filter, pageIndex),
      );

  Future<PurchaseRequestPage> _fetch(
    PurchaseRequestsFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(purchaseRequestRepositoryProvider)
        .list(
          all: filter.all,
          status: filter.status,
          facilityId: filter.facilityId,
          warehouseId: filter.warehouseId,
          creatorId: filter.creatorId,
          serial: filter.serial,
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
