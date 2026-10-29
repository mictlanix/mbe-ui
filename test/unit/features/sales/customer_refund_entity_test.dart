import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';

api.CustomerRefundLineResponse _line({
  String quantity = '0',
  String refundable = '5.000000',
  int? warehouse = 3,
}) => api.CustomerRefundLineResponse(
  (b) => b
    ..customerRefundDetailId = 11
    ..salesOrderDetail = 511
    ..product = 711
    ..productCode = 'TOR-08'
    ..productName = 'Tornillo'
    ..quantity = quantity
    ..price = '2.5000'
    ..discount = '0.000000'
    ..taxRate = '0.160000'
    ..taxIncluded = false
    ..currency = api.CurrencyCode.number0
    ..warehouse = warehouse
    ..refundableQuantity = refundable
    ..subtotal = '25.0000'
    ..taxTotal = '4.0000'
    ..total = '29.0000',
);

api.CustomerRefundResponse _response({
  api.DocumentStatus status = api.DocumentStatus.draft,
  int? customer = 7,
  int? serial,
  List<api.CustomerRefundLineResponse>? lines,
}) => api.CustomerRefundResponse(
  (b) => b
    ..customerRefundId = 9
    ..salesOrder = 42
    ..customer = customer
    ..salesPerson = 100
    ..facility = 8
    ..serial = serial
    ..date = serial == null ? null : DateTime(2026, 10, 28, 9, 30)
    ..currency = api.CurrencyCode.number0
    ..exchangeRate = '1.000000'
    ..status = status
    ..lines.replace(lines ?? [_line()])
    ..subtotal = '25.0000'
    ..taxTotal = '4.0000'
    ..total = '29.0000',
);

void main() {
  test('fromResponse carries totals and quantities exactly as sent', () {
    final refund = CustomerRefund.fromResponse(
      _response(lines: [_line(quantity: '10.000000')]),
    );

    expect(refund.id, 9);
    expect(refund.salesOrderId, 42);
    expect(refund.facilityId, 8);
    expect(refund.subtotal, '25.0000');
    expect(refund.taxTotal, '4.0000');
    expect(refund.total, '29.0000');
    final line = refund.lines.single;
    expect(line.id, 11);
    expect(line.quantity, '10.000000');
    expect(line.refundableQuantity, '5.000000');
    expect(line.price, '2.5000');
    expect(line.warehouseId, 3);
    expect(line.total, '29.0000');
  });

  test('paid maps to completed, the rest map one to one', () {
    RefundStatus map(api.DocumentStatus s) =>
        CustomerRefund.fromResponse(_response(status: s)).status;

    expect(map(api.DocumentStatus.paid), RefundStatus.completed);
    expect(map(api.DocumentStatus.completed), RefundStatus.completed);
    expect(map(api.DocumentStatus.draft), RefundStatus.draft);
    expect(map(api.DocumentStatus.cancelled), RefundStatus.cancelled);
  });

  test('isDraft follows the status', () {
    expect(CustomerRefund.fromResponse(_response()).isDraft, isTrue);
    expect(
      CustomerRefund.fromResponse(
        _response(status: api.DocumentStatus.completed),
      ).isDraft,
      isFalse,
    );
  });

  group('hasReturn', () {
    bool has(List<String> quantities) => CustomerRefund.fromResponse(
      _response(lines: [for (final q in quantities) _line(quantity: q)]),
    ).hasReturn;

    test('is false for "0" and "0.000000"', () {
      expect(has(['0']), isFalse);
      expect(has(['0.000000', '0']), isFalse);
    });

    test('is true once any line is above zero', () {
      expect(has(['0', '0.000001']), isTrue);
      expect(has(['3']), isTrue);
    });
  });

  test('a null customer, serial, date and warehouse survive the mapping', () {
    final refund = CustomerRefund.fromResponse(
      _response(customer: null, lines: [_line(warehouse: null)]),
    );

    expect(refund.customerId, isNull);
    expect(refund.serial, isNull);
    expect(refund.date, isNull);
    expect(refund.lines.single.warehouseId, isNull);
  });

  test('a confirmed refund keeps its serial and date', () {
    final refund = CustomerRefund.fromResponse(
      _response(status: api.DocumentStatus.completed, serial: 412),
    );

    expect(refund.serial, 412);
    expect(refund.date, DateTime(2026, 10, 28, 9, 30));
  });

  test('CustomerRefundSummary maps a list row', () {
    final row = CustomerRefundSummary.fromResponse(
      api.CustomerRefundSummary(
        (b) => b
          ..customerRefundId = 9
          ..salesOrder = 42
          ..customer = null
          ..serial = null
          ..date = null
          ..currency = api.CurrencyCode.number0
          ..status = api.DocumentStatus.paid
          ..total = '120.0000',
      ),
    );

    expect(row.id, 9);
    expect(row.salesOrderId, 42);
    expect(row.customerId, isNull);
    expect(row.serial, isNull);
    expect(row.status, RefundStatus.completed);
    expect(row.total, '120.0000');
  });
}
