# Phase 0 Research: Point of Sale — Sale Capture

**Feature**: `020-point-of-sale` | **Date**: 2026-08-03 | **Spec**: [spec.md](./spec.md)

Everything below was verified against the checked-in generated client
(`lib/generated/openapi`), the mbe-api sources in the sibling checkout, and the
existing mbe-ui code — not inferred from the spec. Findings §9 through §11 are
gaps: capabilities the feature needs that the backend does not have today.

---

## 1. Every write returns the whole order — so one notifier owns the sale

**Decision**: A single `AsyncNotifier` holds the current sale as one immutable
`Sale` entity. Every mutation calls its endpoint and replaces state wholesale
with the mapped response. No local recomputation of totals, no optimistic
patching of the line list.

**Rationale**: `POST /sales-orders/{id}/lines`, `PUT .../lines/{lineId}`,
`DELETE .../lines/{lineId}`, `PUT /sales-orders/{id}` and
`POST /sales-orders/{id}/confirm` all return the full `SalesOrderResponse`,
lines included, with `subtotal`, `tax_total`, `total` and `balance` computed
server-side (`sales_order.py:SalesOrderResponse`; the derived three are
documented as "never stored"). FR-008 asks for exactly this: show what the
server returns. The naive alternative — a line-list notifier plus a totals
notifier — has to reconcile two sources that the API already delivers as one.

**Alternatives considered**: optimistic local edit with reconciliation
(rejected: FR-008 forbids displaying locally-computed money, and the reconcile
path is where drift bugs live); one provider per line (rejected: every write
already invalidates the whole order, so the family would refetch itself).

---

## 2. The API call behind every step transition

**Decision**: The flow maps to this exact sequence. Nothing else writes.

| Moment | Call | Notes |
|---|---|---|
| Screen opened, no sale selected | `POST /sales-orders` with an empty body | Server fills point of sale, facility, salesperson, default customer, currency, terms (`SalesOrderCreate` — every field optional) |
| Customer / terms / currency / ship-to changed | `PUT /sales-orders/{id}` | Draft only |
| Product added | `POST /sales-orders/{id}/lines` | `price` omitted ⇒ resolved from the customer's price list |
| Line edited | `PUT /sales-orders/{id}/lines/{lineId}` | quantity, price, discount_rate, warehouse, comment |
| Line removed | `DELETE /sales-orders/{id}/lines/{lineId}` | |
| "Continuar al cobro" | `POST /sales-orders/{id}/confirm` | Assigns `serial`, commits stock, freezes the order |
| Payment added | `POST /customer-payments` then `POST /customer-payments/{id}/applications` | Two calls, always in that order |
| Destination added (delivery step) | `POST /delivery-orders` + `PUT`/`DELETE` on its lines + `PUT /delivery-orders/{id}` | See §3 |
| Sale closed, mixed remainder | `POST /delivery-orders` with `fulfillment_type=COUNTER_PICKUP` | Sweeps whatever is left |

**Rationale**: two preconditions in mbe-api fix this order and cannot be worked
around from the client: `customer_payment_service.assert_order_payable` rejects
a payment against an unconfirmed order ("Only a completed order can be paid;
confirm it first"), and `delivery_order_service.create_from_sales_order`
rejects a delivery for an order that is not completed. Confirming therefore
sits between capture and payment, and delivery — per the spec's step order —
sits after both, where both preconditions are satisfied.

**Alternatives considered**: confirming at the very end and staging everything
in the client (rejected by the requester in favour of live recording, and it
would make a mid-sequence failure leave a half-written sale).

---

## 3. Splitting across destinations is create-then-trim, and the order matters

**Decision**: Each destination is created by `POST /delivery-orders`
`{sales_order, fulfillment_type: DELIVERY}`, which claims **everything not yet
covered**; the screen then trims it to the cashier's per-line numbers with
`PUT /delivery-orders/{id}/lines/{lineId}` (quantity) and
`DELETE .../lines/{lineId}` (lines this destination takes none of), and sets
address, date and comment with `PUT /delivery-orders/{id}`. The counter-pickup
remainder is created **last**, at close, so it sweeps exactly what is left.

**Rationale**: `_covered_quantities` sums the lines of every non-cancelled
delivery order for the sale and subtracts them, so "uncovered" is exactly the
undistributed remainder — creating a destination after trimming the previous
one yields the right lines with no quantity arithmetic sent by the client. A
delivery order stays editable while `status == DRAFT`
(`delivery_order_service.assert_editable`), which every freshly created one is.
`fulfillment_type` is immutable after creation (it is absent from
`DeliveryOrderUpdate`), which is why it must be right in the `POST` and why the
counter-pickup sweep is its own create rather than an edit of an existing one.

**Consequence for the UI**: destination *n+1* cannot be created until
destination *n* has been trimmed. The step must serialize its writes per
destination, and the "add destination" affordance is disabled while a trim is
in flight.

**Alternatives considered**: creating all destinations first and trimming after
(rejected: the first create takes everything, so every later create fails with
"already fully delivered"); one delivery per line (rejected: an address would
get one document per product).

---

## 4. What makes the fulfilment mode survive a reload

**Decision**: The sale's `ship_to` carries the mode. Counter pickup writes the
**facility's own address**; delivery and mixed write the customer's chosen
address (FR-056). On resume, `ship_to == facility.address` ⇒ no delivery step;
anything else ⇒ delivery step owed. Mixed is **not** separately encoded: on a
resumed sale the screen shows the undistributed remainder and asks the cashier
to either assign it or leave it at the counter, which is the only decision the
mixed/delivery distinction actually gates.

**Rationale**: nothing else on the sale is both writable before confirmation and
readable after it. `FacilityResponse.address` exists and is already mapped in
`features/catalog/domain/entities/facility.dart`, and mbe-api's own
`_is_facility_address` uses exactly this test to detect counter pickup when
`fulfillment_type` is omitted — so the client's encoding and the server's
detection agree by construction. Mixed-vs-delivery is a *closing* rule
(FR-035), not a data attribute, and a resumed sale can ask rather than guess.

**Alternatives considered**: a marker in the order's `comment` (rejected:
`comment` is user-visible free text and would surface on documents); inferring
the mode from the existence of delivery orders (rejected: it is false for a
delivery sale that has not reached the delivery step yet, which is precisely
the resume case that matters).

---

## 5. The open-sales selector

**Decision**: `GET /sales-orders?mine=true&status=draft&date_from=<today 00:00>`
for the count and the list, plus a second call with `status=completed` to catch
confirmed-but-unpaid sales, plus a **third call with `status=paid`** to catch a
delivery/mixed sale that is paid but whose distribution is not yet complete.
Facility scoping is automatic.

**Correction (post-planning, analysis finding C1)**: the first draft of this
decision stopped at two calls. That silently made a paid-but-undistributed
delivery/mixed sale unreachable from the selector — exactly the sale FR-058 and
US3 Acceptance Scenario 5 require to stay reachable, and exactly the case
`contracts/pos-screen.md` §5 already documented as resumable. mbe-api has no
way to filter "paid AND undistributed" server-side, so the third call fetches
every `paid` sale for this cashier and the client filters to those whose
distribution (data-model.md §6) is incomplete — cheap, since a paid sale that
*is* fully distributed is rare and short-lived (it only exists between the
close action and the delivery step's own completion).

**Rationale**: `list_sales_orders` filters on `mine`, `status`, `date_from`,
`date_to`, `customer`, `salesperson`, `search` and `facility`, and defaults
`facility` to the caller's own (`sales_order_service.list_orders:508`). `mine`
matches creator, updater **or** salesperson (`:510-517`), which is the right
net for "sales I have been working on". There is **no `point_sale` filter** —
facility plus `mine` is the closest available approximation, and it is the one
the mock's "4 abiertos hoy" chip needs.

**Alternatives considered**: filtering client-side over an unfiltered page
(rejected: unbounded); asking mbe-api for a `point_sale` filter (deferred — the
facility+mine approximation is adequate and this is a nice-to-have, not a gap).

---

## 6. The payment method grid comes from configured options, not the raw enum

**Decision**: The grid is built from **payment method options** for the
cashier's facility (`PaymentMethodOption`: `name`, `payment_method`,
`commission`, `number_of_payments`, `display_on_ticket`), which mbe-ui already
has an entity and repository for. When a facility has none configured, fall
back to a fixed list of `PaymentMethod` enum values. Which methods demand a
reference is a **client-side rule** keyed on `PaymentMethod`: card, transfer
and cheque require one; cash and purse do not.

**Rationale**: `payment_method_option` is per-facility and carries the display
name the store actually uses, and `CustomerPaymentCreate.payment_charge` takes
a `payment_method_option_id` — so the option *is* the thing being selected, and
selecting it fills both `method` and `payment_charge`. Nothing in the schema
marks a method as requiring a reference or terminal validation, so the mock's
"Requiere validación / Requiere referencia" captions have no server source and
must be a client-side table.

**Alternatives considered**: hardcoding the eight methods from the mock
(rejected: ignores per-facility configuration that already exists); asking
mbe-api to add a `requires_reference` flag (worth filing eventually; not a
blocker, since the rule is stable and small).

---

## 7. Barcode scanning needs no package

**Decision**: A single text field that keeps focus, submits on Enter, and clears
after a successful add. A scan that resolves to exactly one product adds it
directly; anything else opens the results list.

**Rationale**: store scanners are keyboard-wedge devices — they type the code and
send Enter. `GET /sales-orders/product-lookup?pattern=&customer=&warehouse=`
already searches code, name, brand, SKU and barcode in one call and returns
per-warehouse `on_hand`/`available`, so one endpoint serves both the scan and
the search path. Adding a camera-scanner package would serve a use case the
spec does not have.

---

## 8. Money stays a string; arithmetic gets a real decimal type

**Decision**: Monetary values stay `String` in domain entities, exactly as spec
011 established (`features/pricing/domain/entities/product_price.dart`,
`PricingFormatters`) — the generated DTOs already type every `Decimal` field as
`String`. Where the POS must *compute* (outstanding balance, quick amounts,
change, per-line distribution, the paid == total gate), add the pure-Dart
`decimal` package and convert at the edges.

**Rationale**: the POS is the first screen that does arithmetic on money rather
than displaying it. `double` is disqualified for a paid/not-paid gate. The
alternative — hand-rolled scaled integers — is a small amount of code and a
large amount of risk in exactly the place the feature can lose money.

**Alternatives considered**: scaled `int` helpers in the domain layer (viable,
rejected as a bug farm); `double` with epsilon comparison (rejected outright).

**Note**: this is the feature's only new dependency and is recorded as such in
plan.md's Technical Context.

---

## 9. GAP — a customer's addresses are not reachable

**Finding**: The `customer_address` junction table exists
(`app/models/customer.py:10`), but **no endpoint exposes it**: `CustomerResponse`
carries no addresses, `GET /addresses` has no `customer` filter (only `search`,
`type`, `status`), and there is no link/unlink route.

**Impact**: FR-031 and FR-056 ("pick one of the customer's existing addresses")
cannot be satisfied as written. P1 is unaffected — a counter sale needs no
address beyond the facility's own.

**Decision**: File an mbe-api issue for `GET /customers/{id}/addresses` and a
link route. Until it ships, the address picker searches the global address list
(`GET /addresses?search=`) and a newly created address is used directly as
`ship_to` without being linked to the customer. The sales order and delivery
order both accept any address id, so the flow works — it is the *filtering* that
degrades.

---

## 10. GAP — there is no contacts API

**Finding**: `customer_contact` exists in the model; there is no
`contacts.py` endpoint module and no contact route anywhere in the v1 API.
`SalesOrderCreate.contact` and `DeliveryOrderUpdate.contact` take an id the
client has no way to obtain or create.

**Impact**: the per-destination contact name and phone the mock shows (and
FR-029/FR-031 require) have nowhere structured to live.

**Decision**: Capture contact name and phone in the destination card and write
them into the delivery order's `comment` in a fixed format, so the information
reaches whoever prepares and delivers the order. Leave `contact` null. File an
mbe-api issue for a contacts API and replace the stopgap when it ships.

---

## 11. GAP — a sale's payments cannot be listed back

**Finding**: Applications are readable only per payment
(`GET /customer-payments/{id}/applications`). Nothing lists the payments applied
to a given sales order, and `GET /customer-payments` filters by customer or cash
session, not by order.

**Impact**: on resume of a partially paid sale, the applied-payments panel
cannot be rebuilt. The **balance** is always correct (it comes from the order),
so the gate in FR-049 is never wrong — only the itemisation is missing.

**Decision**: Show payments captured in the current session from the controller's
own state; on a resumed sale show the balance with an explicit note that earlier
payments were taken in another session, rather than an empty list that reads as
"no payments". File an mbe-api issue for `GET /sales-orders/{id}/payments`.

---

## 12. GAP (minor) — a line's tax rate is not editable

**Finding**: `SalesOrderLineCreate` and `SalesOrderLineUpdate` carry no
`tax_rate`; the line's rate is copied from `product.tax_rate` at add time.

**Impact**: the mock's per-line IVA dropdown cannot write anything. FR-023 lists
"tax treatment" among the in-place editable fields.

**Decision**: Render the line's tax rate **read-only**. File an mbe-api issue if
the business genuinely needs per-line tax override; do not build a control that
cannot save. FR-023 is amended accordingly (noted in plan.md's Complexity
Tracking).

---

## 13. The stepper and open-sales selector go in a screen header band

**Decision**: Both render in a header band at the top of the screen body,
directly under the shell's app bar — not inside `AppBar.actions`.

**Rationale**: `AppShell` owns the only app bar and, per spec 010 FR-009 and its
navigation-shell contract, carries "exactly one trailing control — the
`UserMenuButton`". Constitution §VI likewise requires screen-level controls to
live in the body. Injecting screen-owned widgets into the shared app bar means
either a global provider that leaks one screen's state into shared navigation,
or a route-keyed slot in `AppShell` — a change to the shell every other screen
depends on, for one screen's benefit. A header band immediately below the app
bar reads as one header, keeps both controls exactly where the mock puts them
relative to the content, and touches no shared code.

**Alternatives considered**: extending `AppShell` with an app-bar slot
(rejected as above — but it is a contained change if the requester wants the
controls literally inside the app bar); a second `AppBar` inside the screen
(rejected: two stacked app bars).

---

## 14. Reuse, not reinvention

**Decision**: The feature builds on what exists rather than adding parallel
machinery:

| Need | Existing asset |
|---|---|
| Customer, Product, Warehouse, Address, PriceList entities and repositories | `features/catalog/domain` + `features/catalog/data` — the shared master-data module named in constitution §I |
| Create an address without leaving the screen | `showAddressInlineCreateDialog` (`features/catalog/presentation/address_inline_create.dart`) |
| Create a customer without leaving the screen | `customer_form_controller.dart`, reused behind a dialog |
| Payment method options | `payment_method_option_repository.dart` + entity |
| Cashier's default facility / point of sale / cash drawer | `core/access/user_settings.dart` |
| Money and percent formatting | `features/pricing/presentation/pricing_formatters.dart` — promote to `core/` |
| Breakpoints, error banner, form grid, entity picker | `core/layout/breakpoints.dart`, `core/widgets/*` |

**Rationale**: constitution §I names `catalog` as the shared master-data module
for entities used across features, so a `sales` feature importing
`features/catalog/domain` is the sanctioned arrangement, not a layering breach.

---

## 15. Verify codegen parity before writing code

**Decision**: Before implementation starts, regenerate the client against a
running mbe-api and diff. Ship nothing on the assumption that the checked-in
client is current.

**Rationale**: constitution §III requires regeneration whenever the spec
changes, and this repo has been bitten twice by mid-feature backend churn (the
`active`/`disabled` → `status` migration during spec 013). The checked-in client
does already carry every endpoint this feature needs — `sales_orders_api.dart`,
`delivery_orders_api.dart` and `customer_payments_api.dart` were all verified to
expose the calls in §2 — so this is a parity check, not an expected regeneration.

---

## 16. Testing approach

**Decision**:

- **Unit** — the destination split algorithm (§3) against a fake repository; the
  decimal helpers (§8); the reference-required rule (§6); the mode-durability
  encoding (§4); DTO → entity mapping for `Sale`, `SaleLine`, `Destination`,
  `Payment`.
- **Widget** — the line row's edit affordances and shortfall warning; the
  payment step's confirm gate (FR-049); the step indicator's 2-vs-3 shape;
  compact layout at 390 px.
- **Integration** — the golden path against a live mbe-api, discovering its
  fixtures at runtime (a real product with stock, a real customer) rather than
  hardcoding ids, following the pattern proven in spec 009.

**Rationale**: the split algorithm and the money gate are where a defect costs
real money, and both are pure logic that can be tested without a server. The
integration test is the only way to prove the §2 sequence end to end, because
its preconditions live in the server.
