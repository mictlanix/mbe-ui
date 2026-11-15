import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';

/// What the approve and reject dialogs need to name an order (spec 062
/// data-model §1).
///
/// The queue holds a [DeliveryOrderSummary] and the detail screen a
/// [DeliveryOrder]; neither is a subtype of the other, so each builds one of
/// these and the dialogs take only that.
class ApprovalTarget {
  const ApprovalTarget({
    required this.id,
    required this.serial,
    required this.customerId,
    required this.type,
    required this.date,
  });

  factory ApprovalTarget.fromSummary(DeliveryOrderSummary order) =>
      ApprovalTarget(
        id: order.id,
        serial: order.serial,
        customerId: order.customerId,
        type: order.type,
        date: order.date,
      );

  factory ApprovalTarget.fromOrder(DeliveryOrder order) => ApprovalTarget(
    id: order.id,
    serial: order.serial,
    customerId: order.customerId,
    type: order.type,
    date: order.date,
  );

  final int id;

  /// Null only in theory: an order waiting for approval was confirmed, so it
  /// has its folio. The nullable type is the source entities'.
  final int? serial;
  final int customerId;
  final FulfillmentType type;
  final DateTime? date;

  /// The folio for a sentence, `#id` in the unreachable case of no serial.
  String get folio => serial == null ? '#$id' : '$serial';
}
