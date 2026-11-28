import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/domain/zero_price.dart';

import 'purchase_order_fixtures.dart';

/// Spec 080 research R10: the price-0 warning's rule.
void main() {
  test('no lines, none flagged', () {
    expect(zeroPriceLines(const []), isEmpty);
    expect(zeroPriceLines([anOrderLine()]), isEmpty);
  });

  test('one zero-priced line is flagged', () {
    final free = anOrderLine(id: 2, price: '0');
    expect(zeroPriceLines([anOrderLine(), free]), [free]);
  });

  test('several are flagged in line order, however the zero is written', () {
    final a = anOrderLine(id: 1, price: '0');
    final b = anOrderLine(id: 3, price: '0.0000000');
    expect(zeroPriceLines([a, anOrderLine(id: 2), b]), [a, b]);
  });

  test('a tiny non-zero price is not flagged', () {
    expect(zeroPriceLines([anOrderLine(price: '0.0000001')]), isEmpty);
  });

  test('a cancelled order\'s lines are still flagged: the function is '
      'state-blind', () {
    final order = anOrder(
      status: InventoryDocumentStatus.cancelled,
      lines: [anOrderLine(price: '0')],
    );
    expect(zeroPriceLines(order.lines), hasLength(1));
  });
}
