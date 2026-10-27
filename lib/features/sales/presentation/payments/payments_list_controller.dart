import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';

part 'payments_list_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds the Pagos list's page (spec 054 FR-004).
///
/// **The facility is never a facet.** mbe-api honours whatever `facility` it
/// is sent (mbe-api#271), so the only thing that keeps a user inside their
/// own facility is that this controller always sends the user's own and
/// nothing in the URL can change it (FR-009, research R4). Don't "simplify"
/// this to omit the argument: the server's default would still be right, but
/// the guarantee would then rest on a default nobody reads.
///
/// A user with no facility has nothing to scope to, so no request is made and
/// the page is empty — the same posture the Sales Orders list takes.
///
/// The all-facilities scope (US3) is the one way to cross facilities. It is
/// honoured only for a user who can read the Payments Editor, and that is
/// re-asserted here rather than trusted to [PaymentsFilter.fromQuery]: both
/// drop it, so removing either leaves the other holding (the same two-site
/// shape as the Sales Orders scoping).
@riverpod
class PaymentsListController extends _$PaymentsListController {
  @override
  Future<CatalogPage<CustomerPayment>> build(PaymentsFilter filter) {
    final canSearchAll = ref
        .watch(accessControlProvider)
        .can(SystemObject.paymentsEditor, AccessRight.read);
    if (filter.scope == PaymentsScope.allFacilities && canSearchAll) {
      return fetchClampedPage(
        pageIndex: filter.pageIndex,
        pageSize: _pageSize,
        fetch: (pageIndex) => _search(filter, pageIndex),
      );
    }
    final facilityId = ref.watch(userFacilityIdProvider);
    if (facilityId == null) {
      return Future.value(
        CatalogPage(
          items: const [],
          total: 0,
          pageIndex: 0,
          pageSize: _pageSize,
        ),
      );
    }
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(facilityId, filter, pageIndex),
    );
  }

  Future<CatalogPage<CustomerPayment>> _fetch(
    int facilityId,
    PaymentsFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(customerPaymentRepositoryProvider)
        .list(
          facilityId: facilityId,
          customerId: filter.customerId,
          cashSessionId: filter.cashSessionId,
          dateFrom: filter.dateFrom,
          dateTo: filter.dateTo,
          methodCode: filter.methodCode,
          verified: filter.verified,
          search: filter.customerSearch,
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

  Future<CatalogPage<CustomerPayment>> _search(
    PaymentsFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(customerPaymentRepositoryProvider)
        .searchAcrossFacilities(
          customerId: filter.customerId,
          reference: filter.reference,
          dateFrom: filter.dateFrom,
          dateTo: filter.dateTo,
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
