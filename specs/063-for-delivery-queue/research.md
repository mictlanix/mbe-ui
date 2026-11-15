# Research: For Delivery Queue

**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-11-15

## R1. The endpoint and what it returns

**Decision**: Use the generated `DeliveryItinerariesApi.pendingDeliveriesApiV1DeliveryItinerariesDeliveriesGet(skip, limit)` (`GET /api/v1/delivery-itineraries/deliveries`).

**What it does** (mbe-api `app/api/v1/endpoints/delivery_itineraries.py`, `app/services/delivery_itinerary_service.py`):
- Gated on ForDeliver (91) read.
- Selects every line of delivery orders in `IN_PREPARATION`, fulfillment type `DELIVERY`, at an active facility, ordered by priority desc then order id desc. Lines with open quantity ≤ 0 are dropped.
- Splits them into six buckets by the order's date against the **server's** `date.today()`: `earlier`, `yesterday`, `today`, `tomorrow`, `day_after`, `later`. A null date goes to `later`.
- Returns all six buckets, always, in that order. Each has `key`, `date` (null for `earlier` and `later`), `total`, and `items[skip:skip+limit]`.
- `skip`/`limit` (limit ≤ 100) apply to **every** bucket in the same request. No search, no filters, no facility parameter.

**Line fields** (`PendingDeliveryLine`): `deliveryOrder`, `deliveryOrderDetail`, `serial?`, `customer`, `shipTo?`, `date?` (DateTime), `priority`, `product`, `productCode`, `productName`, `warehouse`, `openQuantity` (String decimal). No facility id, no names for customer, ship-to or warehouse.

**Rationale**: It's already in the generated client. No regeneration and no upstream work.

## R2. Where the repository lives

**Decision**: A new `DeliveryItineraryRepository` in `features/sales/domain/repositories/` with one method, `pendingDeliveries({skip, limit})`, and its `…Impl` in `features/sales/data/`. It maps the response to domain types (data-model §1–2).

**Rationale**: The endpoint belongs to the itineraries API. roadmap#41 will add the rest of that API to the same repository, so this is its natural home rather than `DeliveryOrderAdminRepository`. Delivery features live in `features/sales` (specs 061, 062), so this does too.

**Alternatives considered**: Adding the method to `DeliveryOrderAdminRepository` (it wraps `DeliveryOrdersApi`; mixing APIs muddles it). A new `features/logistics` module (a move #41 can decide; not worth doing for one screen).

## R3. Period filter: state and URL

**Decision**: A `PendingDeliveriesFilter` (freezed) with `period` and `pageIndex`, read from and written to `ListQuery` like `DeliveryOrdersFilter`.
- URL facet `period`, values are the server keys (`earlier`, `yesterday`, `today`, `tomorrow`, `day_after`, `later`). `today` is the default and is **not** written to the URL, so the plain route is the default view.
- An unknown or missing value parses to `today` (spec edge case).
- `activeFilterCount` is 1 when `period != today`, else 0. `cleared()` returns `today`, page 0.
- Changing the period goes to page 0 (FR-007), as `goTo` does in the delivery orders panel.

**Rationale**: Same shape as every other list's filter. The URL holds period and page (FR-007), so Back from an order restores both (FR-008).

## R4. Controller and paging

**Decision**: A `PendingDeliveriesController` `AsyncNotifier` family keyed by `(PendingDeliveryPeriod, int pageIndex)`, page size 20.
- `build` calls `fetchClampedPage`. Its `fetch` requests `skip = pageIndex * 20, limit = 20`, picks the selected period's bucket as the `CatalogPage`, and keeps every bucket's `date` and `total` from the same response.
- The state is a `PendingDeliveriesView`: the six period summaries plus the page (data-model §3).
- The panel's counts come from that state, so opening the panel costs no request.

**Why it works with the server's shared paging**: one request returns a page of every bucket, but only the selected bucket is shown. The other buckets' items are discarded; their totals feed the panel. Changing period refetches at page 0, which is one cheap request.

**Clamping**: if the selected period's page comes back empty with total > 0, `fetchClampedPage` refetches its last page (spec edge case "Page past the end"). The other summaries come from the second response.

**No facility guard**: the endpoint has no facility parameter and is cross-facility by design, as the legacy screen was. Say so in a doc comment, as spec 062's controller does, so nobody copies the delivery-orders facility guard in.

## R5. Period control in the panel (wireframe Open Question 3)

**Decision**: A `DropdownButtonFormField<PendingDeliveryPeriod>` in a `showCatalogFilterSheet` panel, labelled "Periodo", with six items and **no** "all" item. Each item reads `Hoy · 2026-11-15 (12)`; `earlier`/`later` read `Anteriores (4)`. Wrapped in `KeyedSubtree(ValueKey(period))`, as in the delivery orders panel, because a dropdown reads its initial value only once.

**Rationale**: It is the single-select facet control the existing panels use (status and type in `delivery_orders_list_screen.dart`). Using it keeps the panel consistent and adds no component.

**Date format**: `formattersProvider.display.date`, the app's date format (ISO by default, spec 028). The wireframe's "15 nov" was indicative.

**Counts survive a period change**: the panel applies live, and picking a period switches the controller to a new family key that starts in loading. If the panel read counts from the current key, every count would vanish until the new response lands. So each successful load also writes its six summaries into a small keep-alive `LastPendingDeliverySummaries` notifier, and the panel reads the counts from there. The six totals don't depend on the selected period, so the last-known set is the right one to show while the next page loads.

**Counts before the first load**: until any load has succeeded, the notifier is empty and items show labels without counts. A failed load leaves the last-known counts in place.

## R6. Reload on return (FR-008)

**Decision**: The row tap is `context.push('$deliveryOrdersPath/$id').then((_) => ref.invalidate(pendingDeliveriesControllerProvider(period, page)))`.

**Rationale**: Unlike spec 062's queue, this screen performs no writes, so nothing else invalidates it. The detail screen may cancel or requeue the order (spec 061), which changes the queue. Invalidating on return covers that and any change made by others meanwhile. Period and page change through `context.go`, which rebuilds the family key and refetches.

**No refresh button**: per the spec clarification. The error state keeps its retry.

## R7. Name cells

**Decision**:
- **Customer**: `DeliveryOrderCustomerName(customerId)` (spec 061), unchanged.
- **Ship-to**: extract the delivery branch of `DeliveryOrderShipTo` into a public `DeliveryOrderCustomerAddress(customerId, shipToId)` and have `DeliveryOrderShipTo` call it. The queue uses it directly.
- **Warehouse**: a new small cell over the existing `warehouseDisplayNameProvider(warehouseId)` (catalog), falling back to `#id`.

**Why the ship-to extraction**: `DeliveryOrderShipTo` requires a `facilityId` for its pickup branch, and the line carries none. The queue only has delivery lines (R1), so it needs only the address branch. Passing a dummy facility id would work but hide that.

**Why not `DeliveryOrderWarehouseName`**: it resolves through `facilityWarehousesControllerProvider(facilityId)`, and the line has no facility id. `warehouseDisplayNameProvider` takes the warehouse id alone. It returns `null` on any failure, including no Warehouses read, so the cell falls back to `#id`.

**Rights**: names need Customers read and Warehouses read; without them the cells show the number, as spec 061's do. No extra gate.

## R8. Row tap and rights

**Decision**: `onRowTap` is set only with `can(deliveryOrders, read)` (FR-009), as spec 062's screen does. The nav entry and route gate are `PrivilegeGate(SystemObject.forDeliver, AccessRight.read)`.

## R9. Route and navigation (wireframe Open Question 1)

**Decision**: `/sales/for-delivery`, a new `NavBranch.forDelivery = 28` appended last, and a `NavDestination` in the Logística group right after Aprobación de entregas. Icon: `Icons.local_shipping_outlined` / `Icons.local_shipping`. `_routeGate` gets a `startsWith(forDeliveryPath)` clause.

**Rationale**: Matches its siblings (`/sales/delivery-orders`, `/sales/delivery-order-approval`), whose routes stayed under `/sales/` when the nav moved to Logística. No other route starts with `/sales/for-delivery`.

## R10. Rows: per line, flat (wireframe Open Question 2)

**Decision**: One row per line, in the server's order. Lines of one order are adjacent because the server sorts by priority then order id.

**Rationale**: The totals and pagination count lines. Grouping by order would need client-side regrouping across page boundaries.

## R11. API errors

**Decision**: No new error codes. The endpoint returns only generic codes (`auth.forbidden`, `auth.not_authenticated`), which are already localized. The error state uses `CatalogListStateView` with the shared problem localization (FR-013). No TSV change.

## R12. Testing

**Decision**:
- **Unit**: `pending_deliveries_filter_test` (parse, default, unknown value, badge, cleared, toQuery round trip); `pending_deliveries_controller_test` (bucket pick, summaries, clamp, skip/limit); `delivery_itinerary_repository_impl_test` (mapping, including null date, null serial, decimal string).
- **Widget**: `pending_deliveries_screen_test` (default Hoy, columns, "Sin fecha", row tap with and without 71 read, empty with and without clear, error retry, panel items and counts, period change goes to page 0, compact cards); `delivery_order_name_cells` coverage for the extracted address cell.
- **Router/nav**: `nav_destinations_test` and `app_router_test` for the new entry and gate.
- **Live**: `integration_test/for_delivery_quickstart_test.dart`, read-only: the screen loads, the six periods appear in the panel with counts matching the API, and switching to a period with lines shows them. The local tenant has delivery orders 30240 and 30242 in En preparación from spec 062's runs, so at least one period is non-empty.

Templates: spec 062's `delivery_order_approval_queue_controller_test`, `delivery_order_approval_screen_test`, `delivery_order_approval_quickstart_test`; spec 061's `delivery_orders_filter_test`.
