import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';

part 'delivery_order_approval_queue_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds a page of the delivery order approval queue (spec 062
/// R3).
///
/// **There is no facility guard here, on purpose.** The server scopes
/// `GET /delivery-orders/approval` to the caller's own facility and offers no
/// `facility` parameter, so there is nothing for the client to drop or to
/// forward (R1, R12). Don't copy the guard from the delivery orders list:
/// that endpoint honours a `facility` it is sent, this one can't be asked for
/// another. The no-facility notice is the screen's job, so a user with no
/// facility never reaches this controller.
///
/// A page left empty by an approval or rejection on its last row steps back
/// to the last page that has rows ([fetchClampedPage]).
@riverpod
class DeliveryOrderApprovalQueueController
    extends _$DeliveryOrderApprovalQueueController {
  @override
  Future<CatalogPage<DeliveryOrderSummary>> build(int pageIndex) {
    return fetchClampedPage(
      pageIndex: pageIndex,
      pageSize: _pageSize,
      fetch: _fetch,
    );
  }

  Future<CatalogPage<DeliveryOrderSummary>> _fetch(int pageIndex) async {
    final result = await ref
        .read(deliveryOrderAdminRepositoryProvider)
        .approvalQueue(skip: pageIndex * _pageSize, limit: _pageSize);
    return CatalogPage(
      items: result.items,
      total: result.total,
      pageIndex: pageIndex,
      pageSize: _pageSize,
    );
  }
}
