import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/customer_refund_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refunds_filter.dart';

part 'refunds_list_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds the "Devoluciones" page (spec 057 FR-013, research R8):
/// server paging, filtered by status, customer and order.
///
/// A user without customer-refunds read gets an empty page and no request; the
/// route and the navigation are what actually keep them out.
@riverpod
class RefundsListController extends _$RefundsListController {
  @override
  Future<CatalogPage<CustomerRefundSummary>> build(RefundsFilter filter) {
    final canRead = ref
        .watch(accessControlProvider)
        .can(SystemObject.customerRefunds, AccessRight.read);
    if (!canRead) {
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
      fetch: (pageIndex) => _fetch(filter, pageIndex),
    );
  }

  Future<CatalogPage<CustomerRefundSummary>> _fetch(
    RefundsFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(customerRefundRepositoryProvider)
        .list(
          status: filter.status,
          customerId: filter.customerId,
          salesOrderId: filter.salesOrderId,
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
