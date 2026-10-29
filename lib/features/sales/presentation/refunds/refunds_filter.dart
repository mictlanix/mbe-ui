import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';

part 'refunds_filter.freezed.dart';

/// The "Devoluciones" list's addressable view state (spec 057 data-model).
/// Every field lives in the URL, so Back from a refund returns to the same
/// page and filters.
///
/// There is no search box: `GET /customer-refunds` has no free-text
/// parameter, so the status, customer and order facets are the whole filter.
@freezed
abstract class RefundsFilter with _$RefundsFilter {
  const RefundsFilter._();

  const factory RefundsFilter({
    RefundStatus? status,
    int? customerId,
    int? salesOrderId,
    @Default(0) int pageIndex,
  }) = _RefundsFilter;

  factory RefundsFilter.fromQuery(ListQuery query) {
    final status = query.facet('status');
    final customer = query.facet('customer');
    final order = query.facet('order');
    return RefundsFilter(
      status: RefundStatus.values
          .where((s) => s.wireName == status)
          .firstOrNull,
      customerId: customer == null ? null : int.tryParse(customer),
      salesOrderId: order == null ? null : int.tryParse(order),
      pageIndex: query.pageIndex,
    );
  }

  /// What the drawer badge counts: one per facet in use.
  int get activeFilterCount =>
      (status != null ? 1 : 0) +
      (customerId != null ? 1 : 0) +
      (salesOrderId != null ? 1 : 0);

  bool get isNarrowed => activeFilterCount > 0;
}
