import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/domain/over_receipt.dart';

InventoryReceiptLine _line({
  int id = 1,
  String quantity = '1',
  int? orderLine,
  String ordered = '0',
  String? elsewhere,
}) => InventoryReceiptLine(
  id: id,
  productId: 7,
  productCode: 'A-100',
  quantity: Decimal.parse(quantity),
  purchaseOrderLineId: orderLine,
  quantityOrdered: Decimal.parse(ordered),
  quantityReceivedElsewhere: elsewhere == null
      ? null
      : Decimal.parse(elsewhere),
);

void main() {
  test('no linked lines gives no warnings', () {
    expect(computeOverReceipts([_line(quantity: '99')]), isEmpty);
  });

  test('exactly at ordered gives none', () {
    final lines = [_line(quantity: '10', orderLine: 5, ordered: '10')];
    expect(computeOverReceipts(lines), isEmpty);
  });

  test('above ordered gives one, with the excess', () {
    final lines = [_line(quantity: '13', orderLine: 5, ordered: '10')];
    final result = computeOverReceipts(lines);
    expect(result, hasLength(1));
    expect(result.single.productCode, 'A-100');
    expect(result.single.received, Decimal.parse('13'));
    expect(result.single.ordered, Decimal.parse('10'));
    expect(result.single.excess, Decimal.parse('3'));
  });

  test('two lines on the same order line are summed', () {
    final lines = [
      _line(id: 1, quantity: '6', orderLine: 5, ordered: '10'),
      _line(id: 2, quantity: '6', orderLine: 5, ordered: '10'),
    ];
    final result = computeOverReceipts(lines);
    expect(result, hasLength(1));
    expect(result.single.excess, Decimal.parse('2'));
  });

  test('quantities received elsewhere are counted', () {
    final lines = [
      _line(quantity: '8', orderLine: 5, ordered: '10', elsewhere: '5'),
    ];
    expect(computeOverReceipts(lines).single.excess, Decimal.parse('3'));
  });

  test('a null elsewhere counts as 0', () {
    final lines = [_line(quantity: '8', orderLine: 5, ordered: '10')];
    expect(computeOverReceipts(lines), isEmpty);
  });
}
