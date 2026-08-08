import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_line.dart';

/// `Sale`/`SaleLine` DTO-to-entity mapping (data-model.md §1, §2). Built
/// through the generated serializers rather than hand-constructed DTOs, so
/// the wire names are exercised too — a renamed field fails here, not only
/// in production.
api.SalesOrderResponse _saleResponse({
  int salesOrderId = 42,
  int? serial,
  String status = 'draft',
  int currency = 0,
  int paymentTerms = 0,
  List<Map<String, Object?>> lines = const [],
}) {
  final json = <String, Object?>{
    'sales_order_id': salesOrderId,
    'serial': serial,
    'facility': 9,
    'point_sale': 3,
    'salesperson': 100,
    'customer': 7,
    'customer_name': 'Público en general',
    'payment_terms': paymentTerms,
    'date': '2026-08-05T00:00:00.000Z',
    'due_date': '2026-08-05T00:00:00.000Z',
    'priority': 1,
    'currency': currency,
    'exchange_rate': '1',
    'ship_to': null,
    'promise_date': '2026-08-05T00:00:00.000Z',
    'status': status,
    'lines': lines,
    'subtotal': '100.00',
    'tax_total': '16.00',
    'total': '116.00',
    'balance': '116.00',
  };
  return api.standardSerializers.deserializeWith(
    api.SalesOrderResponse.serializer,
    json,
  )!;
}

Map<String, Object?> _lineJson({
  int salesOrderDetailId = 5,
  String quantity = '2',
  String taxRate = '0.16',
  int? warehouse = 3,
  Object? unit = _noUnit,
}) => {
  'unit_of_measurement': unit == _noUnit
      ? {'id': 'H87', 'name': 'Pieza', 'symbol': 'Pza'}
      : unit,
  'sales_order_detail_id': salesOrderDetailId,
  'product': 11,
  'product_code': 'P-11',
  'product_name': 'Widget',
  'quantity': quantity,
  'cost': '40.00',
  'price': '50.00',
  'discount_rate': '0',
  'tax_rate': taxRate,
  'tax_included': false,
  'currency': 0,
  'exchange_rate': '1',
  'warehouse': warehouse,
  'comment': null,
  'subtotal': '100.00',
  'tax_total': '16.00',
  'total': '116.00',
};

const _noUnit = Object();

void main() {
  group('Sale.fromResponse', () {
    test('maps the header, totals and the customer name', () {
      final sale = Sale.fromResponse(_saleResponse());

      expect(sale.id, 42);
      expect(sale.facility, 9);
      expect(sale.pointSale, 3);
      expect(sale.customer, 7);
      expect(sale.customerName, 'Público en general');
      expect(sale.subtotal, '100.00');
      expect(sale.taxTotal, '16.00');
      expect(sale.total, '116.00');
      expect(sale.balance, '116.00');
    });

    test('a sale with no lines maps to an empty list, not null', () {
      expect(Sale.fromResponse(_saleResponse()).lines, isEmpty);
      expect(Sale.fromResponse(_saleResponse()).lineCount, 0);
    });

    test('maps every line', () {
      final sale = Sale.fromResponse(
        _saleResponse(
          lines: [_lineJson(), _lineJson(salesOrderDetailId: 6)],
        ),
      );
      expect(sale.lineCount, 2);
      expect(sale.lines.map((l) => l.id), [5, 6]);
    });

    group('status', () {
      test('draft is editable and not paid', () {
        final sale = Sale.fromResponse(_saleResponse());
        expect(sale.status, SaleStatus.draft);
        expect(sale.isEditable, isTrue);
        expect(sale.isPaid, isFalse);
      });

      test('completed is no longer editable (FR-041)', () {
        final sale = Sale.fromResponse(_saleResponse(status: 'completed'));
        expect(sale.status, SaleStatus.completed);
        expect(sale.isEditable, isFalse);
      });

      test('paid is paid and not editable', () {
        final sale = Sale.fromResponse(_saleResponse(status: 'paid'));
        expect(sale.status, SaleStatus.paid);
        expect(sale.isPaid, isTrue);
        expect(sale.isEditable, isFalse);
      });

      test('cancelled maps through', () {
        expect(
          Sale.fromResponse(_saleResponse(status: 'cancelled')).status,
          SaleStatus.cancelled,
        );
      });
    });

    group('the generated enums with no preserved member names', () {
      test('currency 0/1/2 map to mxn/usd/eur', () {
        expect(Sale.fromResponse(_saleResponse(currency: 0)).currency, Currency.mxn);
        expect(Sale.fromResponse(_saleResponse(currency: 1)).currency, Currency.usd);
        expect(Sale.fromResponse(_saleResponse(currency: 2)).currency, Currency.eur);
      });

      test('payment terms 0/1 map to immediate/netD', () {
        expect(
          Sale.fromResponse(_saleResponse(paymentTerms: 0)).paymentTerms,
          PaymentTerms.immediate,
        );
        expect(
          Sale.fromResponse(_saleResponse(paymentTerms: 1)).paymentTerms,
          PaymentTerms.netD,
        );
      });
    });

    group('provisionalReference (FR-040)', () {
      test('an unconfirmed sale has no serial — callers fall back to the id', () {
        final sale = Sale.fromResponse(_saleResponse());
        expect(sale.serial, isNull);
        expect(sale.provisionalReference, 42);
      });

      test('a confirmed sale carries the assigned folio', () {
        expect(Sale.fromResponse(_saleResponse(serial: 282127)).serial, 282127);
      });
    });
  });

  group('SaleLine.fromResponse', () {
    test('maps the product, amounts and the editable tax rate (FR-023)', () {
      final line = SaleLine.fromResponse(
        api.standardSerializers.deserializeWith(
          api.SalesOrderLineResponse.serializer,
          _lineJson(),
        )!,
      );

      expect(line.id, 5);
      expect(line.product, 11);
      expect(line.productCode, 'P-11');
      expect(line.productName, 'Widget');
      expect(line.quantity, '2');
      expect(line.price, '50.00');
      expect(line.taxRate, '0.16');
      expect(line.taxIncluded, isFalse);
      expect(line.warehouse, 3);
      expect(line.total, '116.00');
    });

    test('availability is never mapped from the wire — it is joined at the '
        'display edge, not stored on the line (data-model.md §2)', () {
      final line = SaleLine.fromResponse(
        api.standardSerializers.deserializeWith(
          api.SalesOrderLineResponse.serializer,
          _lineJson(),
        )!,
      );
      expect(line.availability, isNull);
    });

    test('maps the unit\'s symbol in preference to its name (mbe-api#145)', () {
      final line = SaleLine.fromResponse(
        api.standardSerializers.deserializeWith(
          api.SalesOrderLineResponse.serializer,
          _lineJson(),
        )!,
      );
      expect(line.unit, 'Pza');
    });

    test('falls back to the unit name when it has no symbol', () {
      final line = SaleLine.fromResponse(
        api.standardSerializers.deserializeWith(
          api.SalesOrderLineResponse.serializer,
          _lineJson(unit: {'id': 'XBX', 'name': 'Caja'}),
        )!,
      );
      expect(line.unit, 'Caja');
    });

    test('a product with no unit on file maps to null, not a placeholder', () {
      final line = SaleLine.fromResponse(
        api.standardSerializers.deserializeWith(
          api.SalesOrderLineResponse.serializer,
          _lineJson(unit: null),
        )!,
      );
      expect(line.unit, isNull);
    });

    test('a line with no warehouse maps to null rather than a sentinel', () {
      final line = SaleLine.fromResponse(
        api.standardSerializers.deserializeWith(
          api.SalesOrderLineResponse.serializer,
          _lineJson(warehouse: null),
        )!,
      );
      expect(line.warehouse, isNull);
    });
  });
}
