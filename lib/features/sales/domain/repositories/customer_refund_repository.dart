import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';

/// Reading and writing customer refunds (spec 057 contracts C2). Every write
/// returns the whole refund as the server now holds it.
abstract interface class CustomerRefundRepository {
  /// `GET /customer-refunds` — one page, in the server's order.
  Future<RefundListResult> list({
    RefundStatus? status,
    int? customerId,
    int? salesOrderId,
    required int skip,
    required int limit,
  });

  Future<CustomerRefund> getById(int id);

  /// `POST /customer-refunds` — opens a draft refund for [salesOrderId].
  Future<CustomerRefund> open(int salesOrderId);

  /// `PUT /customer-refunds/{id}/lines/{lineId}`.
  Future<CustomerRefund> updateLine(
    int refundId,
    int lineId, {
    String? quantity,
    int? warehouseId,
  });

  Future<CustomerRefund> confirm(int refundId, RefundPayout payout);

  Future<CustomerRefund> cancel(int refundId);
}

/// One page of [CustomerRefundSummary]s and the total across all pages.
class RefundListResult {
  const RefundListResult({required this.items, required this.total});
  final List<CustomerRefundSummary> items;
  final int total;
}
