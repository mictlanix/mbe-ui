import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/features/sales/domain/entities/destination.dart';

part 'delivery_order.freezed.dart';

/// One row of the back-office delivery orders list (spec 061 data-model §1).
///
/// The POS keeps its own, narrower `Destination`; this is the full record the
/// logistics screens read. [status] and [type] reuse the enums in
/// `destination.dart`.
@freezed
abstract class DeliveryOrderSummary with _$DeliveryOrderSummary {
  const factory DeliveryOrderSummary({
    required int id,
    required int facilityId,

    /// Null on a draft — the server assigns it on confirmation.
    int? serial,
    required int customerId,
    @Default(<int>[]) List<int> salesOrderIds,
    int? shipToId,
    DateTime? date,
    required int priority,
    required DeliveryOrderStatus status,
    required FulfillmentType type,
    int? parentId,

    /// Server-joined names (mbe-api#324, #325). Null when the row is gone;
    /// [shipToLabel] is also null for a counter pickup. The name cells fall
    /// back to a per-id lookup when one is null.
    String? customerName,
    String? shipToLabel,
    String? facilityName,
  }) = _DeliveryOrderSummary;

  factory DeliveryOrderSummary.fromResponse(api.DeliveryOrderSummary r) =>
      DeliveryOrderSummary(
        id: r.deliveryOrderId,
        facilityId: r.facility,
        serial: r.serial,
        customerId: r.customer,
        salesOrderIds: r.salesOrders?.toList() ?? const <int>[],
        shipToId: r.shipTo,
        date: r.date,
        priority: r.priority,
        status: DeliveryOrderStatus.fromApi(r.status),
        type: FulfillmentType.fromApi(r.fulfillmentType),
        parentId: r.parentDeliveryOrder,
        customerName: r.customerDisplayName,
        shipToLabel: r.shipToLabel,
        facilityName: r.facilityName,
      );
}

/// A delivery order in full: the summary's fields plus contact, comment,
/// rejection reason, proof, timestamps and lines.
@freezed
abstract class DeliveryOrder with _$DeliveryOrder {
  const DeliveryOrder._();

  const factory DeliveryOrder({
    required int id,
    required int facilityId,
    int? serial,
    required int customerId,
    @Default(<int>[]) List<int> salesOrderIds,
    int? shipToId,
    DateTime? date,
    required int priority,
    required DeliveryOrderStatus status,
    required FulfillmentType type,
    int? parentId,

    /// Server-joined names (mbe-api#324, #325). Null when the row is gone;
    /// [shipToLabel] is also null for a counter pickup. The name cells fall
    /// back to a per-id lookup when one is null.
    String? customerName,
    String? shipToLabel,
    String? facilityName,
    int? contactId,
    String? comment,
    String? rejectionReason,
    int? proofId,
    required DateTime createdAt,
    required DateTime modifiedAt,
    @Default(<DeliveryOrderLine>[]) List<DeliveryOrderLine> lines,
  }) = _DeliveryOrder;

  factory DeliveryOrder.fromResponse(api.DeliveryOrderResponse r) =>
      DeliveryOrder(
        id: r.deliveryOrderId,
        facilityId: r.facility,
        serial: r.serial,
        customerId: r.customer,
        salesOrderIds: r.salesOrders?.toList() ?? const <int>[],
        shipToId: r.shipTo,
        date: r.date,
        priority: r.priority,
        status: DeliveryOrderStatus.fromApi(r.status),
        type: FulfillmentType.fromApi(r.fulfillmentType),
        parentId: r.parentDeliveryOrder,
        customerName: r.customerDisplayName,
        shipToLabel: r.shipToLabel,
        facilityName: r.facilityName,
        contactId: r.contact,
        comment: r.comment,
        rejectionReason: r.rejectionReason,
        proofId: r.proofOfDelivery,
        createdAt: r.creationTime,
        modifiedAt: r.modificationTime,
        lines: (r.lines ?? const <api.DeliveryOrderLineResponse>[])
            .map(DeliveryOrderLine.fromResponse)
            .toList(),
      );

  bool get isDraft => status == DeliveryOrderStatus.draft;

  bool get isPickup => type == FulfillmentType.counterPickup;

  /// Nothing more happens to the order once it reaches one of these.
  bool get isTerminal => switch (status) {
    DeliveryOrderStatus.pickedUp ||
    DeliveryOrderStatus.delivered ||
    DeliveryOrderStatus.partiallyDelivered ||
    DeliveryOrderStatus.cancelled => true,
    _ => false,
  };

  bool get hasProof => proofId != null;
}

/// One line of a [DeliveryOrder]. Quantities arrive as decimal strings and
/// are held as [Decimal], never `double`.
@freezed
abstract class DeliveryOrderLine with _$DeliveryOrderLine {
  const factory DeliveryOrderLine({
    required int id,
    int? salesOrderDetailId,
    required int productId,
    required String productCode,
    required String productName,
    required int warehouseId,
    required Decimal quantity,
    required Decimal committed,
    required Decimal delivered,
    required Decimal returned,
    required Decimal open,
  }) = _DeliveryOrderLine;

  factory DeliveryOrderLine.fromResponse(api.DeliveryOrderLineResponse r) =>
      DeliveryOrderLine(
        id: r.deliveryOrderDetailId,
        salesOrderDetailId: r.salesOrderDetail,
        productId: r.product,
        productCode: r.productCode,
        productName: r.productName,
        warehouseId: r.warehouse,
        quantity: Decimal.parse(r.quantity),
        committed: Decimal.parse(r.committedQuantity),
        delivered: Decimal.parse(r.deliveredQuantity),
        returned: Decimal.parse(r.returnedQuantity),
        open: Decimal.parse(r.openQuantity),
      );
}

/// One status transition in an order's history.
@freezed
abstract class DeliveryOrderEvent with _$DeliveryOrderEvent {
  const factory DeliveryOrderEvent({
    required int id,

    /// Null on the creation event.
    DeliveryOrderStatus? from,
    required DeliveryOrderStatus to,
    required int employeeId,
    required DateTime at,
    String? reason,
  }) = _DeliveryOrderEvent;

  factory DeliveryOrderEvent.fromResponse(api.DeliveryOrderEventResponse r) =>
      DeliveryOrderEvent(
        id: r.deliveryOrderEventId,
        from: r.fromStatus == null
            ? null
            : DeliveryOrderStatus.fromApi(r.fromStatus!),
        to: DeliveryOrderStatus.fromApi(r.toStatus),
        employeeId: r.employee,
        at: r.eventTime,
        reason: r.reason,
      );
}

/// Who took delivery. The image is fetched separately, as bytes.
@freezed
abstract class ProofOfDelivery with _$ProofOfDelivery {
  const factory ProofOfDelivery({
    required String receiverName,

    /// Free text: whatever ID the receiver showed.
    required String receiverIdShown,
    required DateTime capturedAt,
    required int capturedBy,
  }) = _ProofOfDelivery;

  factory ProofOfDelivery.fromResponse(api.ProofOfDeliveryResponse r) =>
      ProofOfDelivery(
        receiverName: r.receiverName,
        receiverIdShown: r.receiverIdShown,
        capturedAt: r.capturedTime,
        capturedBy: r.capturedBy,
      );
}
