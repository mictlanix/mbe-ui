import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';

/// A line ordered below its product's minimum purchase quantity (spec 079
/// FR-013).
class BelowMinimum {
  const BelowMinimum({
    required this.productCode,
    required this.quantity,
    required this.minimum,
  });

  final String productCode;
  final Decimal quantity;
  final int minimum;
}

/// One entry per line with `minOrderQty > 1` and a quantity under it, in line
/// order. This is the server's own `below_minimum_warning` rule: a minimum of
/// 0 or 1 never warns.
List<BelowMinimum> belowMinimum(List<PurchaseRequestLine> lines) => [
  for (final line in lines)
    if (line.minOrderQty != null &&
        line.minOrderQty! > 1 &&
        line.quantity < Decimal.fromInt(line.minOrderQty!))
      BelowMinimum(
        productCode: line.productCode,
        quantity: line.quantity,
        minimum: line.minOrderQty!,
      ),
];
