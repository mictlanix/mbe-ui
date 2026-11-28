import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';

/// The lines whose unit price is exactly zero, in line order (spec 080
/// research R10). A zero price will not update the product's cost. The
/// function is blind to the order's state; the screen decides when to show it.
List<PurchaseOrderLine> zeroPriceLines(List<PurchaseOrderLine> lines) => [
  for (final line in lines)
    if (line.price == Decimal.zero) line,
];
