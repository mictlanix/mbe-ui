import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';

part 'refunds_filter.freezed.dart';

/// The "Devoluciones" list's addressable view state (spec 057 data-model).
/// Every field lives in the URL, so Back from a refund returns to the same
/// page and filters.
///
/// [query] is the search box (`ListQuery.search`): a number matches the refund
/// id, folio or source order id, text matches the customer's name
/// (mbe-api#285). It is not counted in the drawer badge.
@freezed
abstract class RefundsFilter with _$RefundsFilter {
  const RefundsFilter._();

  const factory RefundsFilter({
    RefundStatus? status,
    int? customerId,
    int? salesOrderId,
    @Default('') String query,

    /// Only refunds the caller created or last updated.
    @Default(false) bool mine,
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
      query: query.search.trim(),
      mine: query.facet('mine') == '1',
      pageIndex: query.pageIndex,
    );
  }

  /// What the drawer badge counts: one per facet in use.
  int get activeFilterCount =>
      (status != null ? 1 : 0) +
      (customerId != null ? 1 : 0) +
      (salesOrderId != null ? 1 : 0) +
      (mine ? 1 : 0);

  bool get isNarrowed => activeFilterCount > 0 || query.isNotEmpty;
}
