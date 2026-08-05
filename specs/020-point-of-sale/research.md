# Phase 0 Research: Point of Sale — Sale Capture

**Feature**: `020-point-of-sale` | **Date**: 2026-08-03, revised 2026-08-05 |
**Spec**: [spec.md](./spec.md)

Everything below was verified against the checked-in generated client
(`lib/generated/openapi`), the mbe-api sources in the sibling checkout, and the
existing mbe-ui code — not inferred from the spec.

**Status as of 2026-08-05**: all 8 backend gaps this document originally found
(§9–§12, §17, plus two more discovered while filing) have **shipped** in
mbe-api and the client has been regenerated — verified directly against
mbe-api's `git log` (PR #139 "020-pos-api-gaps") and the current generated
`lib/generated/openapi`, not assumed from the issues being closed. Every
former "GAP" section below is marked **RESOLVED** with the shipped shape, and
every stopgap it drove is removed rather than left in place unused. Separately,
spec 021 (cash sessions) shipped a real implementation in
`lib/features/sales/`, the same module this feature was already going to own —
§14 catalogs what that leaves ready to reuse, and §18 is a new finding: this
feature now hard-depends on 021, reversing 021's own "no coupling" decision by
explicit product direction (spec.md D-006).

| # | Was | Now |
|---|---|---|
| [mbe-api#131](https://github.com/mictlanix/mbe-api/issues/131) | Customer change never re-priced lines (§17) | **Shipped** — unconditional reprice |
| [mbe-api#132](https://github.com/mictlanix/mbe-api/issues/132) | No customer address access (§9) | **Shipped** — embedded on `CustomerResponse` |
| [mbe-api#133](https://github.com/mictlanix/mbe-api/issues/133) | No contacts API (§10) | **Shipped** — `/api/v1/contacts` + embedded on `CustomerResponse` |
| [mbe-api#134](https://github.com/mictlanix/mbe-api/issues/134) | A sale's payments unlistable (§11) | **Shipped** — `GET /sales-orders/{id}/payments` |
| [mbe-api#135](https://github.com/mictlanix/mbe-api/issues/135) | Line tax rate read-only (§12) | **Shipped** — writable on add/update |
| [mbe-api#136](https://github.com/mictlanix/mbe-api/issues/136) | No `point_sale` filter (§5) | **Shipped** |
| [mbe-api#137](https://github.com/mictlanix/mbe-api/issues/137) | No `requires_reference` flag (§6) | **Shipped** — computed on `PaymentMethodOptionResponse` |
| [mbe-api#138](https://github.com/mictlanix/mbe-api/issues/138) | Delivery create claims everything uncovered (§3) | **Shipped** — accepts a named line subset |

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
| Screen opened, no sale selected | `GET /cash-sessions/current` first (§18) | Gate — no open session, no sale |
| — sale then opened | `POST /sales-orders` with an empty body | Server fills point of sale, facility, salesperson, default customer, currency, terms (`SalesOrderCreate` — every field optional) |
| Customer / terms / currency / ship-to changed | `PUT /sales-orders/{id}` | Draft only. Customer change re-prices every line server-side (§17) |
| Product added | `POST /sales-orders/{id}/lines` | `price` omitted ⇒ resolved from the customer's price list; `tax_rate` omitted ⇒ the product's own (§12) |
| Line edited | `PUT /sales-orders/{id}/lines/{lineId}` | quantity, price, discount_rate, tax_rate, warehouse, comment |
| Line removed | `DELETE /sales-orders/{id}/lines/{lineId}` | |
| "Continuar al cobro" | `POST /sales-orders/{id}/confirm` | Assigns `serial`, commits stock, freezes the order |
| Payment added | `POST /customer-payments` then `POST /customer-payments/{id}/applications` | Two calls, always in that order |
| Destination added (delivery step) | `POST /delivery-orders` with `{sales_order, fulfillment_type, lines: [{sales_order_detail, quantity}, ...]}` | **One call per destination** (§3) — no trim step |
| Sale closed, mixed remainder | `POST /delivery-orders` with `fulfillment_type=COUNTER_PICKUP`, omitting `lines` | Omitted `lines` still means "everything left" |

**Rationale**: two preconditions in mbe-api fix this order and cannot be worked
around from the client: `customer_payment_service.assert_order_payable` rejects
a payment against an unconfirmed order ("Only a completed order can be paid;
confirm it first"), and `delivery_order_service.create_from_sales_order`
rejects a delivery for an order that is not completed. Confirming therefore
sits between capture and payment, and delivery — per the spec's step order —
sits after both, where both preconditions are satisfied. A third precondition
was added by product decision rather than found in the API: no sale opens at
all without a current cash session (§18).

**Alternatives considered**: confirming at the very end and staging everything
in the client (rejected by the requester in favour of live recording, and it
would make a mid-sequence failure leave a half-written sale).

---

## 3. Splitting across destinations is one call per destination — RESOLVED (was create-then-trim)

**Original finding (2026-08-03)**: `POST /delivery-orders` always claimed
*everything not yet covered* by another delivery order for the sale, with no
way to ask for a named subset. Splitting one sale across destinations meant
create (claims everything), then `PUT`/`DELETE` its lines down to the
cashier's numbers, then create the next against whatever was left —
correct, but it forced every destination's writes to serialize (destination
*n+1* could not be created until *n* was trimmed) and put the arithmetic that
must sum exactly to the ordered amount in the client. Filed as
[mbe-api#138](https://github.com/mictlanix/mbe-api/issues/138); this was the
highest-risk client logic in the whole feature.

**Shipped, verified 2026-08-05** (`mbe-api` commit `5ae4f8c`,
`git show 5ae4f8c -- app/schemas/delivery_order.py app/services/delivery_order_service.py`):
`DeliveryOrderCreate` gained `lines: list[DeliveryOrderLineRequest] | None`,
each entry `{sales_order_detail, quantity}`. **Omitting it keeps the original
"claim everything uncovered" behaviour** — the counter-pickup remainder create
at close (§2) relies on exactly this, passing no `lines` on purpose.
`narrow_to_requested` (pure function, `delivery_order_service.py`) validates
the request against the same `_covered_quantities` figure the default path
uses — over-claiming a line, naming one twice, or naming a line of another
sale are each refused with `422` naming the line and the shortfall.

**Decision (revised)**: Each destination is now **one call**:
`POST /delivery-orders` with `{sales_order, fulfillment_type: DELIVERY, lines:
[{sales_order_detail, quantity}, ...]}`. No trim step, no serialization
constraint, no `destination_split.dart` orchestrator — the whole finding this
section used to document is deleted along with the client-side workaround it
justified. The client still needs to compute *which* lines and quantities to
request (the distribution — data-model.md §6), but no longer needs to create,
then discover what it over-claimed, then correct it.

**What survives**: the counter-pickup sweep is still its own create, still
last, still with `lines` omitted — that part of the original design was never
the workaround, and still holds. `fulfillment_type` is still immutable after
creation (absent from `DeliveryOrderUpdate`).

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

## 5. The open-sales selector — `point_sale` filter now available

**Decision**: `GET /sales-orders?point_sale=<id>&status=draft` for the count
and list, plus a second call with `status=completed` to catch
confirmed-but-unpaid sales, plus a **third call with `status=paid`** to catch a
delivery/mixed sale that is paid but whose distribution is not yet complete
(client-filtered to an incomplete `LineDistribution`, data-model.md §6 — no
server-side way to filter on that). `mine=true` is dropped in favour of
`point_sale`, now that one exists.

**Revised 2026-08-05**: the original two-call decision used
`facility` + `mine=true` as an approximation of "sales at this register,"
because no `point_sale` filter existed. [mbe-api#136](https://github.com/mictlanix/mbe-api/issues/136)
shipped one (`mbe-api` commit `b42a8ee`,
`git show b42a8ee -- app/api/v1/endpoints/sales_orders.py`) — verified present
in the regenerated client (`sales_orders_api.dart`, `pointSale` parameter on
`SalesOrdersGet`). The selector now scopes to the actual register, not every
sale this employee has touched at the facility — closer to what the mock's
"4 abiertos hoy" chip was always meant to mean. A three-call `status=paid`
addition (analysis finding C1, kept from the prior revision) is unaffected by
this change and still needed — see spec.md FR-058.

**Rationale**: `list_sales_orders` filters on `point_sale`, `mine`, `status`,
`date_from`, `date_to`, `customer`, `salesperson`, `search` and `facility`.
`point_sale` is exactly the register a cashier is standing at
(`UserSettings.pointSaleId`), a tighter and more correct scope than
"everything this employee has touched at the facility."

**Alternatives considered**: filtering client-side over an unfiltered page
(rejected: unbounded); `facility` + `mine=true` (superseded now that
`point_sale` exists — kept as a documented fallback only if a cashier's
`UserSettings.pointSaleId` is somehow null, which A-007 treats as
unreachable in practice).

---

## 6. The payment method grid — `requires_reference` now server-computed, reuse the shared `PaymentMethod`

**Decision**: The grid is built from **payment method options** for the
cashier's facility (`PaymentMethodOption`: `name`, `payment_method`,
`commission`, `number_of_payments`, `display_on_ticket`, now also
`requires_reference`), which mbe-ui already has an entity and repository for.
When a facility has none configured, fall back to a fixed list built from the
shared `PaymentMethod` enum (`lib/core/domain/payment_method.dart`, promoted
by 021-cash-sessions — see §14). **No client-side reference-required table is
built** — `payment_method_rules.dart`, planned in the original revision of
this document, is deleted from the plan entirely.

**Revised 2026-08-05**: [mbe-api#137](https://github.com/mictlanix/mbe-api/issues/137)
shipped (`mbe-api` commit `a9ec601`) `PaymentMethodOptionResponse.requires_reference`,
a `@computed_field` derived from the SAT payment-method code
(`PaymentMethod.requires_reference(code)` in `app/enums.py`) — confirmed
present in the regenerated client (`payment_method_option_response.dart`,
`bool get requiresReference`). Card, transfer, cheque, electronic purse,
electronic money, food vouchers, debit and service-card methods require one;
cash and the in-kind settlements do not; **an unrecognized SAT code defaults
to not requiring one** (deliberate — an unclassified code must not stop a
cashier taking money). The rule now lives in exactly one place, and it is not
this feature's client code.

**Rationale**: `payment_method_option` is per-facility and carries the display
name the store actually uses, and `CustomerPaymentCreate.payment_charge` takes
a `payment_method_option_id` — so the option *is* the thing being selected, and
selecting it fills both `method` and `payment_charge`, and now
`requiresReference` besides.

**Alternatives considered**: hardcoding the eight methods from the mock
(rejected: ignores per-facility configuration that already exists); a
client-side reference-required table (superseded — see above).

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

## 8. Money stays a string; arithmetic uses the `decimal` package — already added

**Decision**: Monetary values stay `String` in domain entities, exactly as spec
011 established — the generated DTOs already type every `Decimal` field as
`String`. Where the POS must *compute* (outstanding balance, quick amounts,
change, per-line distribution, the paid == total gate), use the `decimal`
package and convert at the edges.

**Revised 2026-08-05**: the `decimal` package this section originally proposed
adding is **already a dependency** — 021-cash-sessions added it
(`pubspec.yaml: decimal: ^3.2.6`), for the identical reason (a counted-total /
expected-cash / difference computation that `double` cannot be trusted for).
**No new dependency is needed.** More usefully, 021 already built the exact
kind of helper file this feature needs:
`lib/features/sales/domain/money.dart` — `parseAmount`, `formatAmount`,
`countedTotal`, `difference`, all wrapping `Decimal` so it never escapes the
file. That file's own arithmetic (`countedTotal`, `expectedCash`) is
cash-session-specific and stays as-is; this feature **extends the same file**
with the generic helpers it needs (`add`, `subtract`, `compare`, `isZero`)
rather than creating a second money-arithmetic file in the same module — see
§14.

**Rationale**: the POS is the first *sales* screen that does arithmetic on
money rather than displaying it, but it is not the first screen in this
codebase to need this, and the file already exists in the exact module this
feature already targets.

**Alternatives considered**: scaled `int` helpers in the domain layer (viable,
rejected as a bug farm); `double` with epsilon comparison (rejected outright);
a second, POS-only decimal helper file (rejected — see §14, this would
duplicate `money.dart`'s own stated purpose of being "the one file in the
feature that imports `package:decimal`").

---

## 9. RESOLVED — a customer's addresses are now reachable

**Original finding (2026-08-03)**: `customer_address` existed as a junction
table with no endpoint. `CustomerResponse` carried no addresses, `GET
/addresses` had no `customer` filter, and there was no link/unlink route.
Filed as [mbe-api#132](https://github.com/mictlanix/mbe-api/issues/132).

**Shipped, verified 2026-08-05** (`mbe-api` commit `3d1d9eb`,
`git show 3d1d9eb -- app/schemas/customer.py`): `CustomerResponse` now carries
`addresses: list[AddressResponse]` and `contacts: list[ContactResponse]`,
**embedded on the detail response only** — `CustomerListItem` is untouched, so
a page of customers costs no extra queries. `CustomerCreate`/`CustomerUpdate`
take `addresses: list[int] | None` / `contacts: list[int] | None` to link
existing rows — **replace-all semantics, but only for a collection actually
sent**: omitted leaves links alone, `[]` unlinks everything. The rows
themselves are still created through their own endpoints (`/addresses`,
`/contacts`), not through the customer endpoint — embedding matches the
existing `product`↔`label` house pattern.

**Decision (revised)**: The delivery-destination address picker (FR-031,
FR-056) reads `Customer.addresses` directly — the customer detail fetch
already needed for the customer bar now also carries this — with
`showAddressInlineCreateDialog` still available to create a new one, which is
then linked via `CustomerRepository.update(addresses: [...existing, newId])`.
No more global-search stopgap. This requires the shared catalog `Customer`
entity and `CustomerRepository` to map the new field — not yet done as of
2026-08-05 (the domain layer predates this backend change) — tracked as a
task in this feature's plan rather than a separate spec, since constitution §I
makes `catalog` the correct owner and no other feature needs it yet.

---

## 10. RESOLVED — a contacts API now exists

**Original finding (2026-08-03)**: `Contact` and `customer_contact` existed in
the model with no API. `SalesOrderCreate.contact`/`DeliveryOrderUpdate.contact`
took an id nothing could produce. Filed as
[mbe-api#133](https://github.com/mictlanix/mbe-api/issues/133); the stopgap
wrote contact name/phone into the delivery order's free-text `comment`.

**Shipped, verified 2026-08-05** (`mbe-api` commit `3d1d9eb`,
`git show 3d1d9eb -- app/api/v1/endpoints/contacts.py`): full CRUD at
`/api/v1/contacts`, gated by the `Contacts` (12) privilege that already
existed for it (unused until now). `mobile` defaults to `''` rather than
`null`, matching a `NOT NULL DEFAULT ''` column. No `status` column exists on
`contact`, so the only list filter is `search`. Confirmed present in the
regenerated client: `lib/generated/openapi/lib/src/api/contacts_api.dart`.
`Customer.contacts` (§9) is the same embed/link pattern as addresses.

**Decision (revised)**: The destination editor (FR-029, FR-031) creates and
picks real `Contact` records — `contact` on both `SalesOrderUpdate` and
`DeliveryOrderUpdate` is now a genuinely reachable id, not a dead field. **The
comment-stuffing stopgap is deleted entirely**, not merely deprioritized: the
delivery order's `comment` field goes back to being free-text for genuine
delivery instructions, which is what FR-029's "delivery instructions" field
(distinct from contact) was always supposed to hold. This needs a small new
catalog-layer `ContactRepository` (mirroring `AddressRepository`) and an
inline-create dialog mirroring `showAddressInlineCreateDialog` — new shared
catalog code, same rationale as §9.

---

## 11. RESOLVED — a sale's payments can now be listed back

**Original finding (2026-08-03)**: Applications were readable only per
payment. Nothing listed the payments applied to a given sales order. Filed as
[mbe-api#134](https://github.com/mictlanix/mbe-api/issues/134); the stopgap
showed only the current session's payments on resume, with an explanatory note
in place of the earlier ones.

**Shipped, verified 2026-08-05** (`mbe-api` commit `b42a8ee`,
`git show b42a8ee -- app/api/v1/endpoints/sales_orders.py app/schemas/customer_payment.py`):
`GET /sales-orders/{id}/payments` returns `list[OrderApplicationResponse]` —
each application row with its payment's `method`, `currency`, `reference`,
`payment_date`, `payment_type` and `verifier` flattened onto it by a join, so
rendering the applied-payments panel costs one call, not one per row.
Cancelled applications are included, same as the payment-side listing, so a
reversal stays visible. Gated by `CustomerPayments` (8) — payment data,
answering to the payments privilege rather than the order's own. Confirmed in
the regenerated client:
`SalesOrdersApi.listSalesOrderPaymentsApiV1SalesOrdersSalesOrderIdPaymentsGet`.

**Decision (revised)**: The applied-payments panel is rebuilt from this call
on every load — resumed or not. **The session-scoped fallback and its
explanatory note are deleted.** SC-004's "every captured line, payment and
destination intact" — walked back in the prior revision specifically because
this gap existed — is restored to its original, full promise: see spec.md
SC-004.

---

## 12. RESOLVED — a line's tax rate is now writable

**Original finding (2026-08-03)**: `SalesOrderLineCreate`/`Update` carried no
`tax_rate`; a line's rate was copied from `product.tax_rate` at add time and
fixed forever after. Filed as [mbe-api#135](https://github.com/mictlanix/mbe-api/issues/135)
as a question, since a product-level single source of truth might have been
intentional. FR-023 was amended to render the field read-only.

**Shipped, verified 2026-08-05** (`mbe-api` commit `8f908fd`,
`git show 8f908fd -- app/schemas/sales_order.py`): both `SalesOrderLineCreate`
and `SalesOrderLineUpdate` gained `tax_rate: Decimal | None`, bounded `0–1`
(it is a rate, the column is `Numeric(5, 4)` — `16` would mean 1600%).
Omitted on create ⇒ the product's own rate, exactly as before; supplied,
overrides for that line only. `tax_included` stays derived — not part of this
change. Confirmed in the regenerated client
(`sales_order_line_create.dart`/`sales_order_line_update.dart`, `taxRate`
field).

**Decision (revised)**: FR-023's read-only amendment is **reverted**. The
line's tax rate is editable in place exactly as the original mock showed it,
alongside quantity, price, discount and warehouse — no amendment needed, no
Complexity Tracking deviation for this field anymore.

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

## 14. Reuse, not reinvention — revised: `lib/features/sales/` is no longer empty

**Original decision (2026-08-03)**: The feature builds on what exists in
`features/catalog/` rather than adding parallel machinery.

**Revised 2026-08-05**: spec 021 (cash sessions) shipped a complete
implementation *in the exact module this feature already planned to own* —
`lib/features/sales/`. This is not a naming collision to work around; it is
more of the "reuse, not reinvention" this section already argues for, one
level closer than expected. Verified by reading the actual files, not
assuming from the spec:

| Need | Existing asset | Source |
|---|---|---|
| Customer, Product, Warehouse, Address, PriceList entities and repositories | `features/catalog/domain` + `features/catalog/data` | pre-existing (constitution §I) |
| Customer's addresses/contacts (§9, §10) | `Customer` entity + `CustomerRepository` — **need extending**, don't exist yet | pre-existing, gap noted |
| Create an address without leaving the screen | `showAddressInlineCreateDialog` | pre-existing |
| Create a contact without leaving the screen | **new — no equivalent exists**, build mirroring the address dialog | new, this feature |
| Create a customer without leaving the screen | `customer_form_controller.dart`, reused behind a dialog | pre-existing |
| Payment method options, incl. `requiresReference` (§6) | `payment_method_option_repository.dart` + entity — **needs a field added** for `requiresReference` | pre-existing, extend |
| The shared `PaymentMethod` enum + localized label | `lib/core/domain/payment_method.dart`, `paymentMethodLabel()` | **021-cash-sessions** — reuse directly, do not redefine |
| Cashier's default facility / point of sale / cash drawer | `core/access/user_settings.dart` | pre-existing |
| Money and date/time formatting | `lib/core/widgets/money_formatters.dart` (`MoneyFormatters`) | **021-cash-sessions** — already promoted from `pricing_formatters.dart`; this feature's own planned promotion is unnecessary, already done |
| Decimal arithmetic helpers | `lib/features/sales/domain/money.dart` | **021-cash-sessions** — extend with generic `add`/`subtract`/`compare`/`isZero`, don't create a second file (§8) |
| Current/open cash session read | `lib/features/sales/domain/repositories/cash_session_repository.dart`, `presentation/current_session_controller.dart` | **021-cash-sessions** — reuse directly for the hard gate (§18) |
| The screen-level `SystemObject.pos` (44) privilege | `lib/core/access/system_object.dart` — legacy `mbe/docs/constants.md`: "44 | POS | Sales | Point of sale terminal (POS module)" | pre-existing; **021 already set the precedent** of gating a POS-adjacent screen's read/create on `pos`, not `salesOrders` — this feature's own route/open-a-sale gate should follow the same precedent (revises plan.md's original RBAC table, which used `salesOrders` for both) |
| Breakpoints, error banner, form grid, entity picker | `core/layout/breakpoints.dart`, `core/widgets/*` | pre-existing |

**Rationale**: constitution §I names `catalog` as the shared master-data
module and — by the same logic — a feature module a sibling spec already
populated is not a namespace to avoid, it is prior art to build on. Two
consequences: this feature adds fewer new files than originally planned (money
arithmetic and formatting are both already done), and it must **not**
duplicate `PaymentMethod`/`payment_method_rules.dart` the way the original
revision of this document planned to — that plan predates both 021's reuse
opportunity and mbe-api#137 making the client-side rule unnecessary in the
first place (§6).

**Consequence for file planning**: `lib/core/widgets/number_pad.dart` is still
new (021 built no numeric keypad — its denomination-count entry is a
different UI shape). `lib/features/sales/domain/money.dart` is edited, not
created. No `payment_method_rules.dart` is created at all.

---

## 15. Verify codegen parity before writing code — done

**Decision**: Regenerate the client against a running mbe-api and diff before
implementation starts.

**Status 2026-08-05**: done, not merely planned. The client was regenerated
against mbe-api after PR #139 merged; every field/parameter this document
cites (`taxRate`, `requiresReference`, `lines` on `DeliveryOrderCreate`,
`addresses`/`contacts` on `Customer*`, `pointSale` on `SalesOrdersGet`,
`listSalesOrderPaymentsApiV1SalesOrdersSalesOrderIdPaymentsGet`,
`contacts_api.dart`) was confirmed present directly in
`lib/generated/openapi`, not assumed from mbe-api's source alone.

**Rationale**: constitution §III requires regeneration whenever the spec
changes, and this repo has been bitten twice by mid-feature backend churn
before (the `active`/`disabled` → `status` migration during spec 013) — a
third time, mid-*this* feature's planning, is exactly why this section existed
in the first place.

---

## 16. Testing approach — simplified

**Decision**:

- **Unit** — the decimal helpers (§8, extending `money.dart`); the
  mode-durability encoding (§4); DTO → entity mapping for `Sale`, `SaleLine`,
  `Destination`, `Payment`; the cash-session gate's state resolution (§18).
- **Widget** — the line row's edit affordances (now including a genuinely
  writable tax rate, §12) and shortfall warning; the payment step's confirm
  gate (FR-049); the step indicator's 2-vs-3 shape; the cash-session gate
  screen; compact layout at 390 px.
- **Integration** — the golden path against a live mbe-api, discovering its
  fixtures at runtime (a real product with stock, a real customer, a real open
  cash session) rather than hardcoding ids, following the pattern proven in
  spec 009.

**Revised 2026-08-05**: the prior revision's highest-priority unit test — the
destination-split invariant against a fake repository — **no longer applies**.
Splitting is now a single, server-validated call (§3); the client-side
arithmetic that test protected does not exist anymore. What replaces it is
smaller: a pure function computing the *requested* `lines` payload from a
`Sale` and the cashier's per-destination entries (data-model.md §6), tested
for the same "sums exactly to the ordered amount" property, but with no
server-interaction sequencing to get right.

**Rationale**: the money gate is still where a defect costs real money and is
still pure logic testable without a server. The integration test remains the
only way to prove the §2 sequence end to end, because its preconditions —
including, now, an open cash session — live in the server.

---

## 17. RESOLVED — a customer change now re-prices existing lines, unconditionally

**Original finding (2026-08-03)**: `update_order`'s customer branch was
`order.customer = customer.customer_id` and nothing else — no line was
touched. mbe-ui's own team reported the legacy system did reprice; whether
dropping that was deliberate or an oversight wasn't answerable from the code.
Filed as [mbe-api#131](https://github.com/mictlanix/mbe-api/issues/131) as a
**blocking** dependency (spec.md D-005) — FR-015 was written against the
*intended* behaviour ahead of the backend shipping it, an accepted interim
risk while it was outstanding.

**Shipped, verified 2026-08-05** (`mbe-api` commit `8f908fd`,
`git show 8f908fd -- app/services/sales_order_service.py`): `update_order`
now calls `_reprice_lines` whenever `customer.customer_id != order.customer`
— **only on an actual change**, not on every `PUT` (a client editing just the
`comment` does not silently reprice the order). One query for the whole
order's lines against `ProductPrice` filtered to the new customer's
`price_list`, not one query per line. **Repricing is unconditional** — the
open question this feature's own filed issue raised (should a manually-typed
price be exempted?) was considered and explicitly rejected: `sales_order_detail`
stores no marker distinguishing a hand-entered price from a listed one, so
"preserve the override" could only ever have been a guess at what the
*previous* customer's list would have charged, which is worse than a
consistent rule. A product absent from the new price list prices at `0`,
caught by confirmation's existing zero-price gate rather than by this call.
`tax_rate` and `cost` are untouched — tax follows the product, cost follows
the cost price list, neither depends on which customer is buying.

**Decision (revised)**: FR-015 needs no further change — it already described
exactly this outcome. What's removed is the **interim-risk framing**: D-005's
"until #131 ships, switching customers leaves lines stale with no indication"
warning no longer applies, because #131 has shipped. The blocking-dependency
status is resolved, not merely mitigated.

---

## 18. NEW — a cash session is now a hard precondition for opening a sale

**Decision**: Entering `/sales/pos` first resolves
`currentSessionControllerProvider` (`lib/features/sales/presentation/current_session_controller.dart`,
already built by 021). `state == none` ⇒ the screen renders a blocking
explanation and a link into 021's own `/sales/cash-sessions` open flow;
**no sale is opened, `POST /sales-orders` is never called**. `state == open`
or `state == stale` ⇒ proceed exactly as before — a stale session is still an
*open* session server-side (no end time), still accepts payments, and 021's
own FR-003 forbids the system from auto-closing it. A stale session shows a
non-blocking banner ("this shift was opened on an earlier day") rather than
blocking the sale; only `none` blocks.

**Why this reverses 021's own D-002**: spec 021 explicitly decided *against*
this — its Aug-4 clarification says "This feature MUST NOT edit or depend on
spec 020's Point of Sale screen... Wiring POS to the session state is a
deliberate follow-up," recorded because 021 had to ship independently of a
POS screen that did not exist yet (020 was `ready-to-implement` but
unstarted). That constraint was about *021's* delivery order, not a permanent
architectural decision — now that 021 has shipped a real, working
`currentSessionControllerProvider`, the dependency direction reverses
cleanly: 020 depends on 021 (already done), not the other way around. This is
a deliberate, explicit product decision (spec.md D-006), not a rediscovery of
something 021 missed — 021's own text already names this exact wiring as a
"deliberate follow-up," which this feature now is.

**Rationale for a hard gate over a soft one**: a real cash register cannot
take money with the drawer closed — every payment this feature records is
implicitly a movement of physical cash or its equivalent through a drawer, and
`customer_payment.cash_session` (attached server-side "when one exists", per
the *original* A-005) being nullable was a schema affordance, not a workflow
recommendation. A soft gate (show the state, don't block) would let a cashier
ring up and collect payment against no shift at all, producing exactly the
"permanently unattributed" payments 021's own D-007 warns about.

**Mechanics reused, not rebuilt**: `CurrentSession`, `SessionState`,
`currentSessionControllerProvider` and the repository behind them are 021's;
this feature adds zero new cash-session read/write code, only the gate
widget and the routing decision at screen entry.

**Consequence for RBAC**: opening a sale now implicitly requires whatever 021
requires to *have* a session (`pos:create` to open one, `pos:read` to see the
current state) in addition to `salesOrders:create` for the sales order itself
— not a new privilege, just a precondition that was already true in practice
(a cashier without a drawer cannot meaningfully use a register) made explicit.
