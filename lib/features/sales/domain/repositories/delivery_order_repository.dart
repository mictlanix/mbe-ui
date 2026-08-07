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
  /// Creates one destination, complete, and returns it.
  ///
  /// [lines] omitted claims **everything the sale still owes** — which is how
  /// the counter-pickup remainder is recorded (FR-036). Supplied, it claims
  /// exactly that named subset (mbe-api#138).
  ///
  /// **Two calls, not one.** `DeliveryOrderCreate` accepts only
  /// `salesOrder`/`fulfillmentType`/`lines`; the destination's own header —
  /// [shipTo], [contact], [date], [comment] — is settable only through
  /// `PUT /delivery-orders/{id}`. The spec's contract assumed otherwise;
  /// verified against mbe-api's own `create_from_sales_order`, and filed as
  /// [mbe-api#146](https://github.com/mictlanix/mbe-api/issues/146). The
  /// implementation performs the pair and, if the second call fails, cancels
  /// the order it just created rather than leaving a draft destination
  /// holding committed stock against the wrong address (FR-037).
  Future<Destination> create({
    required int salesOrder,
    required FulfillmentType fulfillmentType,
    int? shipTo,
    int? contact,
    DateTime? date,
    String? comment,
    List<DestinationLineRequest>? lines,
  });

  /// The destinations already recorded against a sale, for the resume case.
  ///
  /// Takes [customer] and [saleLineIds] as well as [salesOrder] because
  /// mbe-api cannot answer this question directly: a delivery order exposes
  /// no `sales_order` field and the list endpoint has no such filter, so the
  /// link is reconstructed from line ids
  /// ([mbe-api#147](https://github.com/mictlanix/mbe-api/issues/147)).
  /// [searchLimit] bounds how far back the customer's delivery orders are
  /// scanned; a destination older than that is not found. Both extra
  /// parameters and the bound disappear once #147 ships.
  Future<List<Destination>> listForSale({
    required int salesOrder,
    required int customer,
    required Set<int> saleLineIds,
    int searchLimit = 50,
  });

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
