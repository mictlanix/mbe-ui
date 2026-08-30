/// The price list holding cost rather than sale price — `Costo` on a typical
/// deployment, which sits at id **0** there.
///
/// **This mirrors a server-side setting the API does not expose.** mbe-api
/// reads it from its own `settings.cost_price_list_id`
/// (`app/core/config.py`, default `0`), which is where a sales-order line
/// takes its cost snapshot from. No endpoint publishes the value — there is
/// no settings endpoint and no price list is flagged as the cost one — so a
/// client cannot learn which list it is, only be told.
///
/// The pricing grid needs it for one thing: the column menu's "copy from the
/// cost list" action (spec 033 FR-013). Everywhere else the cost list is an
/// ordinary column, hideable and editable like any other (spec CL-001), so
/// nothing else here depends on getting this right.
///
/// ⚠️ **`0` is a real id, and it is the default.** Any check for "is a cost
/// list configured?" must compare against the price lists that exist, never
/// test this value for truthiness — `if (costPriceListId)` is false for the
/// very list it usually names (spec FR-019a).
///
/// **Drift is the known cost.** A deployment that changes mbe-api's
/// `cost_price_list_id` must pass a matching
/// `--dart-define=COST_PRICE_LIST_ID=<id>` here. The failure is contained:
/// copy-from-cost would read the wrong column, so the action is offered only
/// when this id matches a price list that actually exists, and it writes
/// nothing the user cannot see and undo.
///
/// Delete this if mbe-api ever exposes the cost list.
const costPriceListId = int.fromEnvironment(
  'COST_PRICE_LIST_ID',
  defaultValue: 0,
);
