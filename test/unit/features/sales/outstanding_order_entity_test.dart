import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/network/api_serializers.dart';
import 'package:mbe_ui/features/sales/domain/entities/outstanding_order.dart';

api.OutstandingOrderResponse _row({int? serial = 812, int currency = 0}) =>
    appSerializers.deserializeWith(api.OutstandingOrderResponse.serializer, {
      'sales_order_id': 1047,
      'serial': serial,
      'customer': 77,
      'customer_name': null,
      'customer_display_name': 'Ferretería López',
      'date': '2026-11-10T09:30:00',
      'due_date': '2026-11-25T00:00:00',
      'currency': currency,
      'total': '2400.00',
      'balance': '1800.00',
    })!;

void main() {
  test('maps the order number, folio, dates, currency and amounts', () {
    final order = OutstandingOrder.fromResponse(_row());

    expect(order.id, 1047);
    expect(order.serial, 812);
    expect(order.date, DateTime(2026, 11, 10, 9, 30));
    expect(order.dueDate, DateTime(2026, 11, 25));
    expect(order.currency, Currency.mxn);
    expect(order.total, '2400.00');
    expect(order.balance, '1800.00');
  });

  test('an order with no folio keeps a null serial', () {
    expect(OutstandingOrder.fromResponse(_row(serial: null)).serial, isNull);
  });

  test('a page keeps its items and the total that match', () {
    final page = OutstandingOrderPage(
      items: [OutstandingOrder.fromResponse(_row())],
      total: 41,
    );

    expect(page.items, hasLength(1));
    expect(page.total, 41);
  });
}
