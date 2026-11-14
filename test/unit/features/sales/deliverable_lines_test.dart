import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/deliverable_lines.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';

SaleLine _saleLine(int id, String quantity) => SaleLine(
  id: id,
  product: id * 10,
  productCode: 'P-$id',
  productName: 'Producto $id',
  quantity: quantity,
  price: '20',
  discountRate: '0',
  taxRate: '0.16',
  taxIncluded: false,
  subtotal: '0',
  taxTotal: '0',
  total: '0',
);

Sale _sale(List<SaleLine> lines) => Sale(
  id: 42,
  facility: 1,
  salesperson: 100,
  customer: 7,
  paymentTerms: PaymentTerms.immediate,
  currency: Currency.mxn,
  exchangeRate: '1',
  status: SaleStatus.completed,
  lines: lines,
  subtotal: '0',
  taxTotal: '0',
  total: '0',
  date: DateTime(2026, 11, 14),
  dueDate: DateTime(2026, 11, 14),
);

DeliveryOrder _order(
  int id,
  Map<int, String> claims, {
  DeliveryOrderStatus status = DeliveryOrderStatus.inPreparation,
}) => DeliveryOrder(
  id: id,
  facilityId: 1,
  customerId: 7,
  priority: 0,
  status: status,
  type: FulfillmentType.delivery,
  createdAt: DateTime(2026, 11, 14),
  modifiedAt: DateTime(2026, 11, 14),
  lines: [
    for (final MapEntry(key: detail, value: quantity) in claims.entries)
      DeliveryOrderLine(
        id: id * 100 + detail,
        salesOrderDetailId: detail,
        productId: detail * 10,
        productCode: 'P-$detail',
        productName: 'Producto $detail',
        warehouseId: 3,
        quantity: Decimal.parse(quantity),
        committed: Decimal.zero,
        delivered: Decimal.zero,
        returned: Decimal.zero,
        open: Decimal.parse(quantity),
      ),
  ],
);

Map<int, String> _remaining(List<DeliverableLine> lines) => {
  for (final line in lines) line.salesOrderDetailId: line.remaining.toString(),
};

/// Spec 061 T024, data-model §1, research R8.
void main() {
  final sale = _sale([_saleLine(1, '10'), _saleLine(2, '5.5')]);

  test('with no orders, every line is offered in full', () {
    final lines = deliverableLines(sale, const [], excludeDetailIds: {});

    expect(_remaining(lines), {1: '10', 2: '5.5'});
    expect(lines.first.salesOrderId, 42);
    expect(lines.first.productCode, 'P-1');
    expect(lines.first.productName, 'Producto 1');
    expect(lines.first.ordered, Decimal.fromInt(10));
  });

  test('a cancelled order does not count', () {
    final lines = deliverableLines(sale, [
      _order(1, {1: '10'}, status: DeliveryOrderStatus.cancelled),
    ], excludeDetailIds: {});

    expect(_remaining(lines), {1: '10', 2: '5.5'});
  });

  test('several orders sum, leaving a partly covered line', () {
    final lines = deliverableLines(sale, [
      _order(1, {1: '3'}),
      _order(2, {1: '2.5', 2: '1'}, status: DeliveryOrderStatus.draft),
    ], excludeDetailIds: {});

    expect(_remaining(lines), {1: '4.5', 2: '4.5'});
  });

  test('a fully covered line is dropped', () {
    final lines = deliverableLines(sale, [
      _order(1, {2: '5.5'}),
    ], excludeDetailIds: {});

    expect(_remaining(lines), {1: '10'});
  });

  test('a line already on the order is dropped', () {
    final lines = deliverableLines(sale, const [], excludeDetailIds: {1});

    expect(_remaining(lines), {2: '5.5'});
  });
}
