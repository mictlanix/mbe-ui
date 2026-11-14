import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/payment_verification_filter.dart';

part 'verification_queue_controller.g.dart';

const _pageSize = 20;

/// Fetches and holds a page of the verification queue (spec 060 R2, R3).
///
/// **There is no facility scoping here, on purpose.** Unlike
/// `PaymentsListController`, which always sends the user's own facility
/// because mbe-api honours any `facility` it is sent (mbe-api#271), this
/// queue is company-wide: verification is, on the server and in the legacy
/// screen. Who may list it is decided by the Payments Verification read right
/// the route and the server both check. Don't "fix" the missing guard by
/// copying the Pagos one: the facility filter is only an optional narrowing.
///
/// A page left empty by a verification on its last row steps back to the last
/// page that has rows ([fetchClampedPage]).
@riverpod
class VerificationQueueController extends _$VerificationQueueController {
  @override
  Future<CatalogPage<CustomerPayment>> build(PaymentVerificationFilter filter) {
    return fetchClampedPage(
      pageIndex: filter.pageIndex,
      pageSize: _pageSize,
      fetch: (pageIndex) => _fetch(filter, pageIndex),
    );
  }

  Future<CatalogPage<CustomerPayment>> _fetch(
    PaymentVerificationFilter filter,
    int pageIndex,
  ) async {
    final result = await ref
        .read(customerPaymentRepositoryProvider)
        .listUnverified(
          facilityId: filter.facilityId,
          dateFrom: filter.dateFrom,
          dateTo: filter.dateTo,
          methodCode: filter.methodCode,
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
