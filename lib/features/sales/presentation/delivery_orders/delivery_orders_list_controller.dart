import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_filter.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';

part 'delivery_orders_list_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds the "Órdenes de entrega" page (spec 061 FR-003, FR-004,
/// research R3): server paging, newest first, filtered by the URL facets.
///
/// **The facility is dropped here too.** The request carries one only for a
/// user who [seesEveryFacilitysDeliveryOrders], whatever [DeliveryOrdersFilter]
/// holds. mbe-api checks it too since mbe-api#314; the client drops stay as
/// defence in depth. [DeliveryOrdersFilter.fromQuery] already drops it; this
/// second drop reads the access on its own, so a filter built any other way
/// still can't widen the list. Never merge the two sites into one.
///
/// A user with no facility gets an empty page and no request, administrators
/// included, as in Pedidos.
@riverpod
class DeliveryOrdersListController extends _$DeliveryOrdersListController {
  @override
  Future<CatalogPage<DeliveryOrderSummary>> build(DeliveryOrdersFilter filter) {
    final seesEveryFacility = seesEveryFacilitysDeliveryOrders(
      ref.watch(accessControlProvider),
    );
    final facilityId = ref.watch(userFacilityIdProvider);
    if (facilityId == null) {
      return Future.value(
        const CatalogPage(
          items: [],
          total: 0,
          pageIndex: 0,
          pageSize: _pageSize,
        ),
      );
    }
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter, seesEveryFacility, pageIndex),
    );
  }

  Future<CatalogPage<DeliveryOrderSummary>> _fetch(
    DeliveryOrdersFilter filter,
    bool seesEveryFacility,
    int pageIndex,
  ) async {
    final result = await ref
        .read(deliveryOrderAdminRepositoryProvider)
        .list(
          statuses: filter.requestStatuses,
          type: filter.type,
          dateFrom: filter.dateFrom,
          dateTo: filter.dateTo,
          customer: filter.customerId,
          salesOrder: filter.salesOrderId,
          facility: seesEveryFacility ? filter.facilityId : null,
          search: filter.search,
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
