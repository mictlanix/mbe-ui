import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';
import 'package:mbe_ui/features/sales/presentation/capture/stock_gate.dart';

import '../../../widget/features/sales/pos_test_harness.dart';

SaleLine _line(int id, {int product = 11, int? warehouse = 3, String qty = '2'}) =>
    testLine(id: id, quantity: qty, warehouse: warehouse).copyWith(product: product);

ProductStock _stock(Map<int, String> availableByWarehouse, {bool required = true}) =>
    ProductStock(
      stockRequired: required,
      warehouses: [
        for (final e in availableByWarehouse.entries)
          WarehouseStock(warehouse: e.key, onHand: e.value, available: e.value),
      ],
    );

void main() {
  test('a single short line blocks; an exact fit does not', () {
    final cache = {11: _stock({3: '5'})};
    final short = evaluateStock(testSale(lines: [_line(1, qty: '6')]), cache);
    expect(short.shortLineIds, {1});
    expect(short.blocks, isTrue);
    final fit = evaluateStock(testSale(lines: [_line(1, qty: '5')]), cache);
    expect(fit.shortLineIds, isEmpty);
    expect(fit.blocks, isFalse);
  });

  test('available <= 0 is short', () {
    final gate = evaluateStock(testSale(lines: [_line(1)]), {11: _stock({3: '0'})});
    expect(gate.shortLineIds, {1});
  });

  test('two lines of the same product and warehouse are short together', () {
    final gate = evaluateStock(
      testSale(lines: [_line(1, qty: '3'), _line(2, qty: '3')]),
      {11: _stock({3: '5'})},
    );
    expect(gate.shortLineIds, {1, 2});
  });

  test('the same product in two warehouses is judged separately', () {
    final gate = evaluateStock(
      testSale(lines: [_line(1, qty: '3'), _line(2, qty: '3', warehouse: 4)]),
      {11: _stock({3: '5', 4: '5'})},
    );
    expect(gate.shortLineIds, isEmpty);
    expect(gate.blocks, isFalse);
  });

  test('a product that is not checked is never short', () {
    final gate = evaluateStock(
      testSale(lines: [_line(1, qty: '99')]),
      {11: _stock({3: '1'}, required: false)},
    );
    expect(gate.shortLineIds, isEmpty);
    expect(gate.unknownLineIds, isEmpty);
    expect(gate.blocks, isFalse);
  });

  test('no cache entry, or no row for the warehouse, is unknown and never blocks', () {
    final noEntry = evaluateStock(testSale(lines: [_line(1)]), const {});
    expect(noEntry.unknownLineIds, {1});
    expect(noEntry.blocks, isFalse);
    final noRow = evaluateStock(testSale(lines: [_line(1)]), {11: _stock({4: '1'})});
    expect(noRow.unknownLineIds, {1});
    expect(noRow.blocks, isFalse);
  });

  test('a non-draft sale never blocks', () {
    final gate = evaluateStock(
      testSale(status: SaleStatus.completed, lines: [_line(1, qty: '9')]),
      {11: _stock({3: '1'})},
    );
    expect(gate.shortLineIds, {1});
    expect(gate.blocks, isFalse);
  });
}
