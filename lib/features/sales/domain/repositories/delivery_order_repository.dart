import 'package:mbe_ui/features/sales/domain/entities/destination.dart';

/// One line's share of a destination being created — the client-side half of
/// `DeliveryOrderLineRequest`.
class DestinationLineRequest {
  const DestinationLineRequest({
    required this.salesOrderDetail,
    required this.quantity,
  });

  final int salesOrderDetail;
  final String quantity;
}

/// Delivery destinations for a sale (contracts/mbe-api-pos.md §2).
abstract class DeliveryOrderRepository {
  /// Creates one destination, complete, in a single call.
  ///
  /// [lines] omitted claims **everything the sale still owes** — which is how
  /// the counter-pickup remainder is recorded (FR-036). Supplied, it claims
  /// exactly that named subset (mbe-api#138).
  Future<Destination> create({
    required int salesOrder,
    required FulfillmentType fulfillmentType,
    int? shipTo,
    int? contact,
    DateTime? date,
    String? comment,
    List<DestinationLineRequest>? lines,
  });

  /// `GET /delivery-orders?sales_order=<id>` — the destinations already
  /// recorded against a sale, for the resume case.
  Future<List<Destination>> listForSale({required int salesOrder});

  /// `PUT /delivery-orders/{id}` — post-creation header edits only.
  Future<Destination> updateHeader({
    required int destinationId,
    int? shipTo,
    int? contact,
    DateTime? date,
    String? comment,
  });

  /// `PUT /delivery-orders/{id}/lines/{lineId}` — adjust an already-created
  /// destination's line.
  Future<Destination> updateLine({
    required int destinationId,
    required int lineId,
    required String quantity,
  });

  /// `DELETE /delivery-orders/{id}/lines/{lineId}`.
  Future<Destination> removeLine({required int destinationId, required int lineId});

  /// `POST /delivery-orders/{id}/cancel` — used to undo a destination, and
  /// internally by [create] to roll back a half-formed one.
  Future<void> cancel({required int destinationId, required String reason});
}
