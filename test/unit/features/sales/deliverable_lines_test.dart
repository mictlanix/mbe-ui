import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/domain/entities/deliverable_lines.dart';

api.DeliverableLineResponse _response({
  String quantity = '15',
  String remaining = '10.5',
}) => api.DeliverableLineResponse(
  (b) => b
    ..salesOrder = 42
    ..salesOrderDetail = 103
    ..facility = 1
    ..product = 1030
    ..productCode = 'P-103'
    ..productName = 'Producto 103'
    ..warehouse = 3
    ..quantity = quantity
    ..covered = '4.5'
    ..remaining = remaining,
);

/// Spec 061 data-model §1: a deliverable line as the server counts it
/// (mbe-api#313).
void main() {
  test('maps the server row', () {
    final line = DeliverableLine.fromResponse(_response());

    expect(line.salesOrderId, 42);
    expect(line.salesOrderDetailId, 103);
    expect(line.productCode, 'P-103');
    expect(line.productName, 'Producto 103');
    expect(line.ordered, Decimal.parse('15'));
    expect(line.remaining, Decimal.parse('10.5'));
  });

  test('an unreadable quantity is a server fault, not a zero', () {
    expect(
      () => DeliverableLine.fromResponse(_response(remaining: 'x')),
      throwsA(isA<AppError>()),
    );
    expect(
      () => DeliverableLine.fromResponse(_response(quantity: '')),
      throwsA(isA<AppError>()),
    );
  });
}
