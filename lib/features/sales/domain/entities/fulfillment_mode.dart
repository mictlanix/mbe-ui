/// How this sale's goods reach the customer (data-model.md §4). A pure
/// client-side concept — mbe-api records only two fulfilment types
/// (`DELIVERY`/`COUNTER_PICKUP`) on the *delivery order*, not on the sale.
/// `mixed` exists only here, as the third choice the capture step offers.
enum FulfillmentMode { counterPickup, delivery, mixed }

/// Encodes/decodes [FulfillmentMode] against `Sale.shipTo` (research.md §4)
/// — the only field that is both writable before confirmation and readable
/// after it, so it is what a resumed sale reads to know whether a delivery
/// step is owed.
///
/// `mixed` is deliberately **not** distinguishable from `delivery` once
/// resumed: the distinction only gates whether an undistributed remainder
/// blocks closing (spec FR-035), which the delivery step itself asks about
/// rather than inferring.
abstract final class FulfillmentModeEncoding {
  /// `shipTo == facilityAddressId` ⇒ counter pickup — no delivery step is
  /// owed. Anything else (including `null`, before a mode is chosen) means
  /// a delivery step is owed once the sale reaches Entrega.
  static bool impliesDelivery({
    required int? shipTo,
    required int facilityAddressId,
  }) => shipTo != null && shipTo != facilityAddressId;
}
