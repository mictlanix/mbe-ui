import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/features/sales/domain/entities/destination_line.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';

part 'destination.freezed.dart';

/// A delivery order, in the vocabulary of the delivery step (data-model.md
/// §5) — one address the goods are going to, with the quantities it takes.
///
/// `addressSummary`/`contactName`/`contactPhone` are joined for display from
/// the customer's own addresses and contacts; the source of truth stays the
/// linked records, never a local copy (data-model.md §5).
@freezed
class Destination with _$Destination {
  const Destination._();

  const factory Destination({
    required int id,
    required FulfillmentType fulfillmentType,
    int? shipTo,
    String? addressSummary,
    int? contact,
    String? contactName,
    String? contactPhone,
    DateTime? date,
    String? comment,
    required DeliveryOrderStatus status,
    @Default(<DestinationLine>[]) List<DestinationLine> lines,
  }) = _Destination;

  factory Destination.fromResponse(api.DeliveryOrderResponse r) => Destination(
    id: r.deliveryOrderId,
    fulfillmentType: FulfillmentType.fromApi(r.fulfillmentType),
    shipTo: r.shipTo,
    contact: r.contact,
    date: r.date,
    comment: r.comment,
    status: DeliveryOrderStatus.fromApi(r.status),
    lines: (r.lines ?? const <api.DeliveryOrderLineResponse>[])
        .map(DestinationLine.fromResponse)
        .toList(),
  );

  /// FR-029's card header.
  int get lineCount => lines.length;

  String get unitCount =>
      lines.fold('0', (sum, line) => addAmounts(sum, line.quantity));

  /// The counter-pickup remainder is a destination too (FR-036), but it has
  /// no address and is not editable as one.
  bool get isCounterPickup => fulfillmentType == FulfillmentType.counterPickup;
}

/// `delivery_order.fulfillment_type` — **a type, not a status; immutable
/// after creation.** Hand-mapped because the generator emits `number0`/
/// `number1` with no preserved member names, the same gap `PaymentTerms` and
/// `CurrencyCode` hit (see `sale.dart`).
///
/// Values verified against mbe-api's own `app/enums.py`
/// (`DELIVERY = 0`, `COUNTER_PICKUP = 1`) rather than inferred — existing
/// data has both types with and without a `ship_to`, so the wire alone is
/// not conclusive.
enum FulfillmentType {
  delivery(0),
  counterPickup(1);

  const FulfillmentType(this.value);

  final int value;

  static FulfillmentType fromApi(api.FulfillmentType value) =>
      switch (value.name) {
        'number1' => FulfillmentType.counterPickup,
        _ => FulfillmentType.delivery,
      };

  api.FulfillmentType toApi() => switch (this) {
    FulfillmentType.delivery => api.FulfillmentType.number0,
    FulfillmentType.counterPickup => api.FulfillmentType.number1,
  };
}

/// `delivery_order.status` — the v2 delivery lifecycle. A destination created
/// by the POS is always [draft] while the step is open (data-model.md §5);
/// the rest of the lifecycle belongs to the logistics module, and is mapped
/// only so a resumed sale can render what it finds.
enum DeliveryOrderStatus {
  draft(0),
  pendingApproval(1),
  approved(2),
  readyForPickup(3),
  pickedUp(4),
  inPreparation(5),
  inTransit(6),
  delivered(7),
  partiallyDelivered(8),
  failed(9),
  cancelled(10);

  const DeliveryOrderStatus(this.value);

  final int value;

  static DeliveryOrderStatus fromApi(api.DeliveryOrderStatus value) {
    final code = int.tryParse(value.name.replaceFirst('number', ''));
    for (final status in DeliveryOrderStatus.values) {
      if (status.value == code) return status;
    }
    return DeliveryOrderStatus.draft;
  }
}
