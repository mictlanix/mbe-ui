import 'package:mbe_api_client/mbe_api_client.dart' as api;

/// The six date ranges the server splits the pending-deliveries queue into
/// (spec 063 data-model §1). Declaration order is display order; [key] is the
/// server's bucket key and the `period` URL facet value.
enum PendingDeliveryPeriod {
  earlier('earlier'),
  yesterday('yesterday'),
  today('today'),
  tomorrow('tomorrow'),
  dayAfter('day_after'),
  later('later');

  const PendingDeliveryPeriod(this.key);

  final String key;

  /// A missing or unknown [key] is Hoy, the default period (spec Edge Cases).
  static PendingDeliveryPeriod fromKey(String? key) =>
      values.where((p) => p.key == key).firstOrNull ?? today;
}

/// One delivery-order line still waiting to be loaded (data-model §2).
///
/// Customer, ship-to and warehouse arrive as ids only; names are looked up
/// by the screen.
class PendingDeliveryLine {
  const PendingDeliveryLine({
    required this.deliveryOrderId,
    required this.lineId,
    this.serial,
    required this.customerId,
    this.shipToId,
    this.scheduledDate,
    required this.priority,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.warehouseId,
    required this.openQuantity,
  });

  factory PendingDeliveryLine.fromResponse(api.PendingDeliveryLine r) =>
      PendingDeliveryLine(
        deliveryOrderId: r.deliveryOrder,
        lineId: r.deliveryOrderDetail,
        serial: r.serial,
        customerId: r.customer,
        shipToId: r.shipTo,
        scheduledDate: r.date,
        priority: r.priority,
        productId: r.product,
        productCode: r.productCode,
        productName: r.productName,
        warehouseId: r.warehouse,
        openQuantity: r.openQuantity,
      );

  final int deliveryOrderId;
  final int lineId;
  final int? serial;
  final int customerId;
  final int? shipToId;
  final DateTime? scheduledDate;
  final int priority;
  final int productId;
  final String productCode;
  final String productName;
  final int warehouseId;

  /// The server's decimal string; format it with `display.quantity`.
  final String openQuantity;
}

/// One bucket of the response: its date (single-day periods only), its total
/// line count and the requested page of its lines.
typedef PendingDeliveryBucket = ({
  DateTime? date,
  int total,
  List<PendingDeliveryLine> items,
});

/// The whole response, keyed by period. A bucket key the client doesn't know
/// is dropped when mapping.
typedef PendingDeliveriesResult =
    Map<PendingDeliveryPeriod, PendingDeliveryBucket>;
