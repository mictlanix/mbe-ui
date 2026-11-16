import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/invoice_amounts.dart';

Decimal d(String s) => Decimal.parse(s);

InvoiceLine line({
  required String q,
  required String p,
  String disc = '0',
  String tax = '0.16',
  bool included = false,
}) => InvoiceLine(
  id: 1,
  productName: 'X',
  quantity: d(q),
  price: d(p),
  discountRate: d(disc),
  taxRate: d(tax),
  taxIncluded: included,
);

void expectAmounts(
  LineAmounts a, {
  required String subtotal,
  required String discount,
  required String total,
  required String taxes,
}) {
  expect(a.subtotal, d(subtotal), reason: 'subtotal');
  expect(a.discount, d(discount), reason: 'discount');
  expect(a.total, d(total), reason: 'total');
  expect(a.taxes, d(taxes), reason: 'taxes');
}

void main() {
  // Expected values are worked out by hand from mbe-api's line_amounts
  // (spec 066 research R11), not from the implementation.
  group('lineAmounts', () {
    test('tax excluded: 2 x 100 at 16 %', () {
      expectAmounts(
        lineAmounts(line(q: '2', p: '100')),
        subtotal: '200',
        discount: '0',
        total: '232',
        taxes: '32',
      );
    });

    test('tax included: 116 holds 100 + 16', () {
      expectAmounts(
        lineAmounts(line(q: '1', p: '116', included: true)),
        subtotal: '100',
        discount: '0',
        total: '116',
        taxes: '16',
      );
    });

    test('0 % and exempt carry no tax', () {
      for (final t in ['0', '-1']) {
        expectAmounts(
          lineAmounts(line(q: '3', p: '10.5', tax: t)),
          subtotal: '31.5',
          discount: '0',
          total: '31.5',
          taxes: '0',
        );
      }
    });

    test('a 10 % discount, tax excluded', () {
      final a = lineAmounts(line(q: '1', p: '100', disc: '0.1'));
      expectAmounts(
        a,
        subtotal: '100',
        discount: '10',
        total: '104.4',
        taxes: '14.4',
      );
      expect(a.net, d('90'));
    });

    test('a 50 % discount, tax included', () {
      expectAmounts(
        lineAmounts(line(q: '1', p: '116', disc: '0.5', included: true)),
        subtotal: '100',
        discount: '50',
        total: '58',
        taxes: '8',
      );
    });

    test('half a cent rounds away from zero', () {
      expectAmounts(
        lineAmounts(line(q: '1', p: '0.105', tax: '0')),
        subtotal: '0.11',
        discount: '0',
        total: '0.11',
        taxes: '0',
      );
    });
  });

  test('invoiceAmounts sums the lines', () {
    final a = invoiceAmounts([
      line(q: '2', p: '100'),
      line(q: '1', p: '100', disc: '0.1'),
    ]);
    expect(a.subtotal, d('300'));
    expect(a.discount, d('10'));
    expect(a.taxes, d('46.4'));
    expect(a.total, d('336.4'));
  });

  test('no lines is zero', () {
    expect(invoiceAmounts(const []).total, Decimal.zero);
  });
}
