import 'package:decimal/decimal.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';

/// One sale line that still has quantity left to deliver, as "Agregar línea"
/// offers it (spec 061 data-model §1), read from
/// `GET /delivery-orders/deliverable-lines` (mbe-api#313).
class DeliverableLine {
  const DeliverableLine({
    required this.salesOrderId,
    required this.salesOrderDetailId,
    required this.productCode,
    required this.productName,
    required this.ordered,
    required this.remaining,
  });

  /// An unreadable quantity is a server fault, never a zero.
  factory DeliverableLine.fromResponse(api.DeliverableLineResponse r) {
    final ordered = Decimal.tryParse(r.quantity);
    final remaining = Decimal.tryParse(r.remaining);
    if (ordered == null || remaining == null) throw const AppError.server();
    return DeliverableLine(
      salesOrderId: r.salesOrder,
      salesOrderDetailId: r.salesOrderDetail,
      productCode: r.productCode,
      productName: r.productName,
      ordered: ordered,
      remaining: remaining,
    );
  }

  final int salesOrderId;
  final int salesOrderDetailId;
  final String productCode;
  final String productName;

  /// The sale line's quantity.
  final Decimal ordered;

  /// [ordered] minus what the sale's non-cancelled delivery orders already
  /// hold of this line, as the server counts it.
  final Decimal remaining;
}
