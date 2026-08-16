/// The walk-in customer every new sale starts on — "PÚBLICO EN GENERAL" on a
/// typical deployment.
///
/// **This mirrors a server-side setting the API does not expose.** mbe-api
/// resolves the customer for a sale raised without one from its own
/// `settings.default_customer_id` (`app/core/config.py`, default `1`; applied
/// in `sales_order_service.create_order`). No endpoint publishes that value —
/// there is no settings endpoint, `PointSaleResponse` carries no customer, and
/// `UserSettings` carries only facility/point-sale/cash-drawer — so a client
/// cannot learn it before a sale exists.
///
/// The capture step needs it *before* that point: it renders the customer band
/// from the moment the step opens, rather than letting the band appear from
/// nowhere once the first scan creates the sale. Reading it from a build-time
/// define is the only option available today.
///
/// **Drift is the known cost.** A deployment that changes mbe-api's
/// `default_customer_id` must pass a matching
/// `--dart-define=POS_DEFAULT_CUSTOMER_ID=<id>` here, or the band names the
/// wrong customer until the first real action opens the sale and the server's
/// own answer replaces it. Nothing is ever *written* from this value — it is
/// display-only until a sale exists, and the sale's own `customer` takes over
/// the moment there is one — so the worst case is a briefly wrong label, never
/// a sale raised against the wrong customer.
///
/// Delete this once mbe-api exposes the default customer (mictlanix/mbe-api
/// issue filed alongside #172).
const posDefaultCustomerId = int.fromEnvironment(
  'POS_DEFAULT_CUSTOMER_ID',
  defaultValue: 1,
);
