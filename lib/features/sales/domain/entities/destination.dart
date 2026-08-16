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
/// `number1`/`number2` with no preserved member names, the same gap
/// `PaymentTerms` and `CurrencyCode` hit (see `sale.dart`).
///
/// **Renumbered by mbe-api#171**, a breaking change: `0`/`1` used to mean
/// delivery/counter-pickup and now mean the reverse, on a scale unified with
/// `sales_order.fulfillment_intent` (`FulfillmentMode`, `fulfillment_mode.dart`)
/// — pickup leads because it is the ordinary counter sale, 92.5% of all sales
/// orders. The server's own member is renamed `PICKUP`; this enum keeps
/// `counterPickup` as its Dart identifier rather than chasing the rename,
/// since nothing here reads the wire value as a name.
///
/// `number2` (`MIXED`) never reaches this type: a delivery order is one kind
/// of shipment or the other, and mbe-api's own `create_from_sales_order`
/// refuses to raise one carrying it (mixed is a *sale*-level concept, not a
/// shipment-level one). [fromApi]'s fallback exists only so an unexpected
/// value degrades to the safer of the two rather than throwing.
enum FulfillmentType {
  counterPickup(0),
  delivery(1);

  const FulfillmentType(this.value);

  final int value;

  static FulfillmentType fromApi(api.FulfillmentType value) =>
      switch (value.name) {
        'number0' => FulfillmentType.counterPickup,
        _ => FulfillmentType.delivery,
      };

  api.FulfillmentType toApi() => switch (this) {
    FulfillmentType.counterPickup => api.FulfillmentType.number0,
    FulfillmentType.delivery => api.FulfillmentType.number1,
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
