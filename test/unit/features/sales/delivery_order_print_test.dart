import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_order_print.dart';

import '../../core/documents/document_fakes.dart';

void main() {
  group('canPrintDeliveryOrder (spec 064 FR-003, FR-004)', () {
    const printable = {
      DeliveryOrderStatus.approved,
      DeliveryOrderStatus.readyForPickup,
      DeliveryOrderStatus.pickedUp,
      DeliveryOrderStatus.inPreparation,
      DeliveryOrderStatus.inTransit,
      DeliveryOrderStatus.delivered,
      DeliveryOrderStatus.partiallyDelivered,
      DeliveryOrderStatus.failed,
      DeliveryOrderStatus.cancelled,
    };

    for (final status in DeliveryOrderStatus.values) {
      final expected = printable.contains(status);

      test('${status.name} is ${expected ? '' : 'not '}printable '
          'for a delivery orders reader', () {
        expect(
          canPrintDeliveryOrder(accessFor(deliveryOrdersReader), status),
          expected,
        );
      });

      test('${status.name} is never printable without the right', () {
        expect(canPrintDeliveryOrder(accessFor(noPrivileges), status), isFalse);
        expect(
          canPrintDeliveryOrder(accessFor(salesOrdersReader), status),
          isFalse,
        );
      });

      test('${status.name} follows the status for an administrator', () {
        expect(
          canPrintDeliveryOrder(accessFor(administrator), status),
          expected,
        );
      });
    }

    test('exactly the nine post-approval statuses print', () {
      expect(
        DeliveryOrderStatus.values
            .where(
              (s) => canPrintDeliveryOrder(accessFor(deliveryOrdersReader), s),
            )
            .toSet(),
        printable,
      );
    });
  });

  group('distinctWarehouses (spec 064 data-model)', () {
    DeliveryOrderLine line(int id, int warehouse) => DeliveryOrderLine(
      id: id,
      productId: id,
      productCode: 'P-$id',
      productName: 'Producto $id',
      warehouseId: warehouse,
      quantity: Decimal.one,
      committed: Decimal.zero,
      delivered: Decimal.zero,
      returned: Decimal.zero,
      open: Decimal.one,
    );

    test('keeps first-appearance order', () {
      expect(distinctWarehouses([line(1, 5), line(2, 3), line(3, 4)]), [
        5,
        3,
        4,
      ]);
    });

    test('drops repeats', () {
      expect(distinctWarehouses([line(1, 3), line(2, 5), line(3, 3)]), [3, 5]);
    });

    test('one warehouse across every line is one entry', () {
      expect(distinctWarehouses([line(1, 3), line(2, 3)]), [3]);
    });

    test('no lines is empty', () {
      expect(distinctWarehouses(const []), isEmpty);
    });
  });
}
