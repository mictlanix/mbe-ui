import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/purchases/domain/below_minimum.dart';

import 'purchase_request_fixtures.dart';

void main() {
  test('a line with no minimum never warns', () {
    expect(belowMinimum([aRequestLine(quantity: '1')]), isEmpty);
  });

  test('a minimum of 0 never warns', () {
    expect(
      belowMinimum([aRequestLine(quantity: '1', minOrderQty: 0)]),
      isEmpty,
    );
  });

  test('a minimum of 1 never warns', () {
    expect(
      belowMinimum([aRequestLine(quantity: '0.5', minOrderQty: 1)]),
      isEmpty,
    );
  });

  test('exactly at the minimum does not warn', () {
    expect(
      belowMinimum([aRequestLine(quantity: '6', minOrderQty: 6)]),
      isEmpty,
    );
  });

  test('below the minimum warns with the code, quantity and minimum', () {
    final result = belowMinimum([
      aRequestLine(quantity: '5.5', minOrderQty: 6),
    ]);
    expect(result, hasLength(1));
    expect(result.single.productCode, 'A-100');
    expect(result.single.quantity, Decimal.parse('5.5'));
    expect(result.single.minimum, 6);
  });

  test('two lines of one product warn once each', () {
    final result = belowMinimum([
      aRequestLine(id: 1, quantity: '2', minOrderQty: 6),
      aRequestLine(id: 2, quantity: '3', minOrderQty: 6),
    ]);
    expect(result.map((w) => w.quantity), [
      Decimal.fromInt(2),
      Decimal.fromInt(3),
    ]);
  });
}
