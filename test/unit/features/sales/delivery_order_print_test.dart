import 'package:flutter_test/flutter_test.dart';
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
}
