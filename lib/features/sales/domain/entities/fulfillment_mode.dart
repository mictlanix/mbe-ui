import 'package:mbe_api_client/mbe_api_client.dart' as api;

/// How this sale's goods reach the customer (data-model.md §4).
///
/// Was pure client-side state, encoded into `Sale.shipTo` because nothing on
/// `sales_order` could hold a third value — until mbe-api#170/#171 added
/// `sales_order.fulfillment_intent`, a real field on the same unified scale as
/// `delivery_order.fulfillment_type` (`FulfillmentType`, `destination.dart`).
/// [fromApi]/[toApi] are that mapping; [FulfillmentModeEncoding] is kept as
/// the fallback for a `null` intent — every sale predating the migration, and
/// any raised by a client that does not set it.
enum FulfillmentMode {
  counterPickup,
  delivery,
  mixed;

  /// `null` maps to `null` — "not recorded" survives the round trip rather
  /// than being read as a guess (mbe-api#171: the field means exactly this,
  /// and a client that turned `null` into a mode would be reintroducing the
  /// same wrong-answer risk the field was added to avoid).
  static FulfillmentMode? fromApi(api.FulfillmentType? value) => switch (value?.name) {
    'number0' => FulfillmentMode.counterPickup,
    'number1' => FulfillmentMode.delivery,
    'number2' => FulfillmentMode.mixed,
    _ => null,
  };

  api.FulfillmentType toApi() => switch (this) {
    FulfillmentMode.counterPickup => api.FulfillmentType.number0,
    FulfillmentMode.delivery => api.FulfillmentType.number1,
    FulfillmentMode.mixed => api.FulfillmentType.number2,
  };
}

/// Encodes/decodes [FulfillmentMode] against `Sale.shipTo` (research.md §4)
/// — the fallback for a sale whose `fulfillmentIntent` is `null`, since the
/// address is the only thing such a sale has ever recorded.
///
/// Two-valued only: an unrecorded sale's `ship_to` cannot distinguish `mixed`
/// from `delivery`, which is the exact gap `fulfillment_intent` closes for
/// every sale captured after mbe-api#171. `resumeTargetFor` tries the real
/// field first and falls back to this.
abstract final class FulfillmentModeEncoding {
  /// `shipTo == facilityAddressId` ⇒ counter pickup — no delivery step is
  /// owed. Anything else (including `null`, before a mode is chosen) means
  /// a delivery step is owed once the sale reaches Entrega.
  static bool impliesDelivery({
    required int? shipTo,
    required int facilityAddressId,
  }) => shipTo != null && shipTo != facilityAddressId;
}
