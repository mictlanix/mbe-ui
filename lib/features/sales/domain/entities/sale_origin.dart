import 'package:mbe_api_client/mbe_api_client.dart' as api;

/// Which workflow raised a sales order (`sales_order.origin`, mbe-api#209;
/// spec 039 FR-051/FR-052).
///
/// A back-office order and a register sale are otherwise identical in every
/// readable field — same table, same endpoints, and `point_sale` is populated
/// on every row from the caller's own configuration, so it cannot stand in.
/// This field is the only thing that answers "which workflow raised this",
/// and it is written once, at create, never edited.
///
/// [fromApi] is hand-written for the same reason
/// `FulfillmentMode.fromApi` is: the generator emits `number0`/`number1`
/// rather than named members.
enum SaleOrigin {
  pointOfSale,
  backOffice;

  /// `null` maps to `null`, and deliberately so: **`null` is not a member of
  /// this vocabulary**. It means the origin was never recorded — every order
  /// predating mbe-api migration 020, and any raised by a client that does
  /// not say. Nothing infers it, here or on the server: not from the
  /// register, not from the customer, not from the fulfilment intent
  /// (spec 039 A9, FR-052). What a `null` origin *does* fall back to, when
  /// this workspace has to decide whether an order is its own, is
  /// `foreign_order_guard.dart` — one deliberately one-sided test, not a
  /// guess at this value.
  static SaleOrigin? fromApi(api.OrderOrigin? value) => switch (value?.name) {
    'number0' => SaleOrigin.pointOfSale,
    'number1' => SaleOrigin.backOffice,
    _ => null,
  };

  api.OrderOrigin toApi() => switch (this) {
    SaleOrigin.pointOfSale => api.OrderOrigin.number0,
    SaleOrigin.backOffice => api.OrderOrigin.number1,
  };
}
