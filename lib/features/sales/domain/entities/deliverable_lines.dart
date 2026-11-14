import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';

/// One sale line that still has quantity left to deliver, as "Agregar línea"
/// offers it (spec 061 data-model §1, research R8).
class DeliverableLine {
  const DeliverableLine({
    required this.salesOrderId,
    required this.salesOrderDetailId,
    required this.productCode,
    required this.productName,
    required this.ordered,
    required this.remaining,
  });

  final int salesOrderId;
  final int salesOrderDetailId;
  final String productCode;
  final String productName;

  /// The sale line's quantity.
  final Decimal ordered;

  /// [ordered] minus what the sale's non-cancelled delivery orders already
  /// hold of this line.
  final Decimal remaining;
}

/// The lines of [sale] that can still go on a delivery order: each line's
/// quantity minus the sum of that line's quantity over [ordersOfSale] that
/// aren't cancelled, which mirrors the server's `_covered_quantities`.
///
/// Lines with nothing left, and lines whose sale-line id is in
/// [excludeDetailIds] (already on the order being edited), are dropped.
///
/// simplified: computed on the client from one sale's orders; when
/// mbe-api#313 ships a `deliverable-lines` query, read it from there and
/// delete this.
List<DeliverableLine> deliverableLines(
  Sale sale,
  List<DeliveryOrder> ordersOfSale, {
  required Set<int> excludeDetailIds,
}) {
  final covered = <int, Decimal>{};
  for (final order in ordersOfSale) {
    if (order.status == DeliveryOrderStatus.cancelled) continue;
    for (final line in order.lines) {
      final detailId = line.salesOrderDetailId;
      if (detailId == null) continue;
      covered[detailId] = (covered[detailId] ?? Decimal.zero) + line.quantity;
    }
  }

  return [
    for (final line in sale.lines)
      if (!excludeDetailIds.contains(line.id))
        if (Decimal.tryParse(line.quantity) case final ordered?)
          if (ordered - (covered[line.id] ?? Decimal.zero) case final remaining
              when remaining > Decimal.zero)
            DeliverableLine(
              salesOrderId: sale.id,
              salesOrderDetailId: line.id,
              productCode: line.productCode,
              productName: line.productName,
              ordered: ordered,
              remaining: remaining,
            ),
  ];
}
