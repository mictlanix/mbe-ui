import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';

/// A purchase-order line received beyond what was ordered (spec FR-015).
class OverReceipt {
  const OverReceipt({
    required this.productCode,
    required this.received,
    required this.ordered,
    required this.excess,
  });

  /// Falls back to the product id as text.
  final String productCode;
  final Decimal received;
  final Decimal ordered;
  final Decimal excess;
}

/// The over-receipts among [lines]: linked lines grouped by purchase-order
/// line (first-seen order), each group's received quantity being what other
/// receipts took plus this receipt's sum.
List<OverReceipt> computeOverReceipts(List<InventoryReceiptLine> lines) {
  final groups = <int, List<InventoryReceiptLine>>{};
  for (final line in lines) {
    final key = line.purchaseOrderLineId;
    if (key != null) (groups[key] ??= []).add(line);
  }
  final result = <OverReceipt>[];
  for (final group in groups.values) {
    final first = group.first;
    final sum = group.fold(Decimal.zero, (acc, l) => acc + l.quantity);
    final received = (first.quantityReceivedElsewhere ?? Decimal.zero) + sum;
    final ordered = first.quantityOrdered;
    if (received > ordered) {
      result.add(
        OverReceipt(
          productCode: first.productCode ?? '${first.productId}',
          received: received,
          ordered: ordered,
          excess: received - ordered,
        ),
      );
    }
  }
  return result;
}
