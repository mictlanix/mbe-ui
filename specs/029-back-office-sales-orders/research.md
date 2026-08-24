# Phase 0 Research: Back-Office Sales Orders

**Feature**: `029-back-office-sales-orders` | **Date**: 2026-08-19

Everything below was verified against the working tree and the sibling
`mbe-api` / `mbe` checkouts on 2026-08-19. Line references are to that state.

---

## R1. The reuse refactor — how the capture surface is shared

**Question**: FR-029/FR-030/FR-031 require the back-office order screen to use
the *same* capture surface as the register, without the two screens sharing one
sale and without the register's behaviour changing. `PosSaleController` is a
singleton `@riverpod` notifier holding exactly one `Sale`.

**Finding — two seams, not one.** Re-checked against the working tree on
2026-08-23, **after** specs 030 and 031 landed (see §R12). Every read of
POS-specific state inside `presentation/capture/`:

| File | Reads | What |
|---|---|---|
| `capture_step.dart` | 2 | `posSaleController` (`addLine`, `confirm`) |
| `capture_step.dart` | 2 | `posStepController`, `registerPointSaleProvider` |
| `capture_step.dart` | 2 | `unconfirmedEditsProvider(posWritesScope)`, `pendingWritesProvider(posWritesScope)` |
| `fulfillment_mode_selector.dart` | 4 | `posStepController` ×3 + `posSaleController` |
| `customer_bar.dart` | 1 | `posSaleController.updateHeader` |
| `product_lookup_controller.dart` | 1 | `posSaleController.ensureOpen` |
| `sale_line_editing.dart` | 4 | `posSaleController` (`updateLine` ×3, `removeLine`) |
| `sale_line_editing.dart` | 3 | `pendingWritesProvider(posWritesScope)` ×1, `unconfirmedEditsProvider(posWritesScope)` ×2 |

Two of those files are **not shared**: `capture_step.dart` is the POS *step* (its
confirm advances to `cobro`) and `fulfillment_mode_selector.dart` drives the
delivery step, which is out of scope (OS-3). The back-office screen composes the
pieces itself and offers a plain ship-to picker.

That leaves **three shared files** and **two distinct kinds of coupling**:

1. **The sale itself** — six reads of `posSaleControllerProvider`
   (`customer_bar` 1, `product_lookup_controller` 1, `sale_line_editing` 4).
2. **The write scope** — three reads that hard-code `posWritesScope`
   (`sale_line_editing`). This is the seam that did not exist when this feature
   was first planned, and the one that matters most: left alone, the back-office
   order would register its writes in the *register's* scope, so the cashier's
   "Continuar al cobro" would be held shut by a back-office edit and vice versa —
   a direct FR-030/FR-038 violation, and one that no compiler catches.

**Decision**: introduce a `SaleEditor` interface plus **two** provider
indirections — one for the sale, one for the write scope — each **defaulting to
the register**, and swap the nine shared reads to them.

```dart
// presentation/sale_editor.dart
abstract interface class SaleEditor {
  Future<Sale> ensureOpen();
  Future<void> updateHeader({...});
  Future<void> addLine({...});
  Future<void> updateLine({...});
  Future<void> removeLine(int lineId);
  Future<void> confirm();
}

// Two defaults, both the register. Nothing on the POS side changes.
@riverpod
SaleEditor saleEditor(Ref ref) => ref.watch(posSaleControllerProvider.notifier);

@riverpod
String saleWritesScope(Ref ref) => posWritesScope;
```

The **scope provider is the second half of the seam** and is overridden in the
same nested `ProviderScope` as the editor. `sale_line_editing.dart`'s three
hard-coded `posWritesScope` references become `ref.read(saleWritesScopeProvider)`.
The back-office scope is a new constant, `salesOrderWritesScope`
(`'back-office-sale'`) — one screen, one scope, exactly as the register's own
comment describes its own.

The back-office route wraps its screen in a nested `ProviderScope` overriding
**both** providers with its own controller and scope. Providers that are *not* overridden
still resolve in the root container, so the repository, formatters, settings and
caches stay shared; only the editor differs.

**Why the defaults matter**: they are what keeps SC-007 honest. The POS widget tests
override `salesOrderRepositoryProvider` and drive `posSaleControllerProvider`
straight off the container (`pos_test_harness.dart:294`); with the default in
place, not one of them needs an edit.

**Shared mutation logic**: `PosSaleController` is a thin façade over
`SalesOrderRepository` — every method is "call the repository, replace `state`
with the response", now wrapped in `pendingWrites.track(...)` (spec 031). Rather
than copy it, extract those bodies into a `SaleEditing` mixin on
`AsyncNotifier<Sale?>` with an abstract `String get writesScope`;
`PosSaleController` returns `posWritesScope`, the back-office controller returns
`salesOrderWritesScope`. `PosSaleController` keeps its own `startNew()`; the
back-office controller keeps its own `load()` semantics and its family key. Both
keep spec 031's rule that a controller **resets** its scope's counter when it
swaps which order it holds, and spec 031's ordering rule that new state is
published *before* `track`'s decrement runs.

**Alternatives rejected**:

- *Turn `PosSaleController` into a family keyed by scope.* Touches 7 POS call
  sites plus `pos_workspace_screen.dart` and every test that reads the provider —
  maximum churn against the one thing (SC-007) the feature must not break.
- *Copy the capture widgets.* Explicitly forbidden by FR-029; guarantees the two
  surfaces drift.
- *Reuse the singleton on both screens.* Violates FR-030 outright: a back-office
  order would evict the cashier's in-progress sale from view.
- *Thread an editor object down as a widget parameter.* Works for the widgets but
  not for `product_lookup_controller`, which is a provider — it would need a
  family parameter carrying the editor, which is worse than a provider override.

## R2. What a back-office order needs that `Sale` does not carry

**Finding**: `Sale` (domain entity) exposes id, serial, facility, pointSale,
salesperson, customer, customerName, paymentTerms, currency, exchangeRate,
shipTo, fulfillmentIntent, promiseDate, status, lines and totals. The generated
`SalesOrderResponse` additionally carries **`date`, `dueDate`, `contact`,
`recipient`, `recipientName`, `priority`, `comment`, `salesQuote`** — all of them
already on the wire, none of them mapped.

**Decision**: extend `Sale` with `date`, `dueDate`, `contact`, `recipient`,
`recipientName`, `priority` and `comment`, and map them in `Sale.fromResponse`.
`salesQuote` is left out (OS-5). A new `Priority` domain enum is needed: the
generator emits `Priority.number0/1/2` with no names, the same gap
`PaymentTerms` and `CurrencyCode` already work around in `sale.dart` — follow
that hand-mapping convention exactly.

**Consequence for POS**: purely additive. Every new field is optional or has a
server-supplied value; no POS code reads them.

**`SalesOrderRepository.updateHeader` and `SalesOrderCreate`** likewise need the
extra optional parameters (`promiseDate`, `priority`, `comment`, `salesperson`,
`recipient`). Additive; POS callers pass none of them.

## R3. Listing — no new endpoint, no codegen

**Finding**: `listSalesOrdersApiV1SalesOrdersGet` already accepts `mine`,
`customer`, `salesperson`, `status`, `dateFrom`, `dateTo`, `facility`,
`pointSale`, `search`, `skip`, `limit`. `SalesOrderSummary` returns
sales_order_id, serial, customer, customer_name, customer_display_name,
salesperson, date, due_date, currency, status, total, balance.

**Decision**: add one method to `SalesOrderRepository`:

```dart
Future<OpenSalePage> listOrders({
  bool mine = false,
  int? facility,
  int? salesperson,
  SaleStatus? status,
  DateTime? dateFrom,
  DateTime? dateTo,
  String? search,
  int skip = 0,
  int limit = 20,
});
```

and reuse the existing `OpenSale` row entity and `OpenSalePage`, which already
map `SalesOrderSummary` in full and already resolve the customer label
(`posSaleCustomerLabel`, mbe-api#172/#173). `listOpen`/`listSales` stay untouched.

**Alternative rejected**: a separate `SalesOrderListItem` entity. It would be
field-for-field identical to `OpenSale`; the only gain is a better name, at the
cost of a second mapping to keep in sync. Noted as a naming wart, not a defect.

**Server-side quirk carried over**: `status` is not exclusive — mbe-api's
`completed` filter answers with `paid` rows too (documented on `listOpen`). A
caller needing an exact match must narrow the page itself. The status facet
inherits this; the status chip on each row is what tells the truth.

## R4. Scoping — `mine`, facility, and where it is enforced

**Finding** (`sales_order_service.list_orders:603`): the facility predicate is
unconditional — `SalesOrder.facility == (facility if facility is not None else
current.facility_id)`. There is no cross-facility listing, ever.

**Finding** (`:605`): `mine=true` narrows to `creator == me OR updater == me OR
salesperson == me`, guarded by `current.employee_id is not None`. Per
`app/core/deps.py:26`, `employee_id` is a non-optional `int` — "NOT NULL since
migration 012 (#127), so every authenticated user has one". The guard can never
fail, so `mine=true` never silently degrades to "everything". This is what makes
FR-006 safe to build on.

**Decision**: the list controller sets `mine` from `access.isAdministrator`, not
from any URL state — an ordinary user's request carries `mine: true`
unconditionally, and the salesperson/facility facets are decoded only for an
administrator. This is what satisfies the "hand-edited address" edge case: the
facets are ignored at the *controller* level, not merely hidden in the drawer.

**Recorded honestly**: mbe-api enforces none of this (any caller with
`SALES_ORDERS` read may pass any `facility` and omit `mine`). Spec Assumption A2
says so; nothing in this plan claims a security boundary.

## R5. Default date range

**Finding**: spec 023 R6 measured an unfiltered `GET /sales-orders` at **19,277
rows** for a single register. The POS list therefore defaults to *today*.

**Decision**: the back-office list defaults to the **current calendar month**
(first day → last day of the month containing today). A back-office order is
often captured days before it is confirmed, so "today" would hide the work this
screen exists to manage; a month is bounded, cheap, and matches how a salesperson
talks about their pipeline. Encoded as `date-from`/`date-to` facets in
`yyyy-MM-dd`, exactly like `PosSalesFilter`, and *absent from the URL* when it
equals the default (`ListQuery.isDefault` convention).

**Carried-over trap** (`pos_sales_list_controller.dart:41-52`): the "today"
anchor MUST be truncated to a calendar date before it enters the freezed filter.
A raw `DateTime.now()` makes every rebuild construct a filter unequal to the last,
so the `@riverpod` family never reuses an instance and the list spins forever.
The same normalization applies here to the month bounds.

## R6. Facets — every one has a working precedent

| Facet | Precedent to copy |
|---|---|
| date range | `pos_sales_list_screen.dart` + `DateRangeFilterChip` |
| status | `pos_sales_list_screen.dart` `_PosSalesFiltersPanel` |
| salesperson (admin) | `customers_list_screen.dart:191` — `CatalogEntityPicker<EmployeeListItem>` + `employeeDisplayNameProvider` |
| facility (admin) | same picker shape over `facilityRepositoryProvider` + `facilityDisplayNameProvider` |

`cash_sessions_screen.dart:475-535` already puts two entity pickers *inside* the
filter drawer and seeds each from a `*DisplayNameProvider` so a facet arriving in
the URL as a bare id still renders a name. That is the exact pattern for FR-011;
nothing new is invented.

`EmployeeRepository.list(salesPerson: true)` already exists and is what the
salesperson picker queries.

## R7. Routes

**Finding**: the established shape (spec 023 research R1) is *list inside the
shell branch, record screen at top level* — `/sales/pos` is a `StatefulShellBranch`
while `/sales/pos/new` and `/sales/pos/:saleId` are top-level routes rendering
full-screen. Every catalog detail route (`/products/:productId`, …) is top-level
too.

**Decision**: `/sales/orders` (branch, `NavBranch.salesOrders = 20`, appended —
never renumbered), `/sales/orders/new` and `/sales/orders/:orderId` (top level).

**Guard**: `_gateFor` matches on `startsWith`. `'/sales/orders'` does not collide
with `'/sales/pos'` or `'/sales/cash-sessions'`. The new guard returns
`PrivilegeGate(SystemObject.salesOrders, AccessRight.read)` — deliberately **not**
`SystemObject.pos`, so a back-office salesperson with no register privilege gets
in and a cashier without sales-order rights does not (FR-002).

**Note on the existing POS gate**: `/sales/pos` is gated on `pos(44)` while every
mbe-api sales-order endpoint requires `SALES_ORDERS(7)`. That mismatch is
pre-existing and out of scope; this feature does not touch it.

## R8. Creation preconditions

**Finding** (`sales_order_service._point_sale:173`): `sales_order.point_sale` is
NOT NULL, so `POST /sales-orders` takes the register from the request or from
`user_settings.point_sale`, and raises **422** when neither exists.
`_facility:184` does the same for the facility.

**Decision**: `registerPointSaleProvider` (already exists, reads
`user.settings.pointSaleId`) gates the "New order" action. With no register
configured, the list still renders and orders still open read-write; only
creation is withheld, with an explanatory message — the `pos_gate_screen.dart`
treatment for a missing cash drawer, narrowed to one action (FR-014).

A missing *facility* is the harsher case: the list has nothing to scope to.
Same class of blocked state, whole screen.

## R9. Two spec corrections found while planning

1. **FR-020 lists "unit price" as editable. It must not be.** The shared capture
   surface makes price read-only by design (spec 020 FR-038c,
   `sale_line_editing.dart:37` — "a line's price comes from the customer's price
   list and is never typed over here"). Legacy "Pedidos" agrees: in the attached
   screenshot only Cantidad, Descuento, Impuesto and Comentario carry the dashed
   editable underline; Precio does not. Editing price here would either fork the
   shared widget (violating FR-029) or change POS behaviour (violating FR-031).
   **The spec should drop price from FR-020.**

2. **The per-line comment is new UI on a shared widget.** `SaleLine.comment`
   exists in the domain entity and `updateLine` accepts it, but nothing in
   `capture/` renders it. Adding it unconditionally would change the register's
   line layout, which FR-031 forbids.
   **Decision**: add it as an opt-in `showComment` parameter on the line
   row/card, defaulting to `false`. POS passes nothing and is untouched; the
   back-office screen passes `true`.

## R10. Testing

**Finding**: `test/unit/features/sales/`, `test/widget/features/sales/` and
`test/integration/` are all established, with `pos_test_harness.dart` providing
`pumpPos`/`pumpPosRoute` plus repository-override helpers, and
`test/integration/pos_sales_list_flow_test.dart` as the live-backend precedent
for a list screen.

**Decision**:

- **Unit**: filter encode/decode (mirroring `pos_sales_filter_test.dart`), the
  `mine`/facility scoping rule, the extended `Sale` mapping (extending
  `sale_mapping_test.dart`), and the new repository method against a mocked
  client.
- **Widget**: the list (columns, facets, empty/filtered-empty/error states,
  admin-vs-ordinary facet visibility), the order screen (draft editable,
  confirmed read-only except priority, cancel confirmation, no-register blocked
  state), and a **regression test asserting the two screens hold independent
  sales** — the direct expression of FR-030.
- **Integration**: one live golden path — create, add line, confirm, find it in
  the list — following `pos_counter_sale_flow_test.dart`.
- **Gating**: that confirm is unavailable while a write is outstanding (including
  a stepped quantity's coalescing window), and that the keep / discard /
  keep-editing decision behaves as the register's does — with the back-office
  screen's own scope, proven by a test that holds one screen's gate and asserts
  the other's is free (FR-038).
- **The POS suite is the guard for SC-007**: it must pass unmodified — now
  including spec 030's and 031's own tests (`pos_write_gating_test.dart`,
  `unconfirmed_changes_test.dart`, `sale_line_discount_test.dart`,
  `quantity_stepper_widget_test.dart`). Any test file under
  `test/*/features/sales/` that has to change is a signal the refactor went
  further than intended.

## R11. What is deliberately *not* researched

Payment collection, delivery planning, quotation conversion, printing, and any
mbe-api change — all out of scope per the spec (OS-1 … OS-7). No mbe-api issue is
filed by this feature; nothing it needs is missing.

## R12. What specs 030 and 031 changed under this feature

Both shipped after this feature's spec was written and are already merged into
this branch. Neither is out of scope to *ignore* — the back-office screen reuses
the very widgets they rewrote.

**Spec 030 — sale & delivery refinements** (merged, PR #165):

- The sale line's quantity is no longer a plain text field. It is
  `QuantityStepperController` / `QuantityStepper`
  (`presentation/widgets/quantity_stepper.dart`), shared with the delivery
  destination card: debounced (~400 ms coalescing), floored at **one** unit, and
  uncapped — stock is a non-blocking warning, never a bound. A line is removed
  with `removeLine`, never stepped to zero.
- Writes for one line are serialized through a queue, so two never fly together —
  the reason `_busy` no longer inerts the whole line on a quantity edit.

**Consequence here**: the back-office line rows inherit all of it for free.
FR-020's wording was corrected to match (quantity is stepped, floored at one).

**Spec 031 — write gating & field discard** (merged, PR #166):

- `lib/core/async/critical_action_guard.dart` — a **generic, feature-agnostic**
  mechanism: `pendingWritesProvider(scope)` counting outstanding writes
  (including a debounce window held open via `begin`/`end` tokens before any
  `Future` exists) and `unconfirmedEditsProvider(scope)` registering fields
  holding typed, unconfirmed text. `keepAlive: true` on the former is load-bearing.
- `lib/core/widgets/confirmable_text_field.dart` — `ConfirmableFieldController` /
  `ConfirmableTextField`: Enter confirms, focus loss / unparseable text / a server
  refusal **discards visibly** (cross-fade plus a colour pulse, with a
  reduced-motion path).
- `presentation/widgets/unconfirmed_changes_dialog.dart` — the keep / discard /
  keep-editing decision, and `capture_step.dart._onContinuePressed`, which reads
  the registry once at press time and resolves it before confirming.
- `posWritesScope` (`presentation/pos_write_scope.dart`) is the register's opaque
  scope string; spec 031 §FR-011 says explicitly that the mechanism must be
  adoptable outside point of sale, with the register as its *first* adopter.

**Four consequences for this feature**, all now first-class in the spec:

1. **The scope seam** (§R1 above) — without it the two screens share one gate.
2. **The order screen's confirm is a critical action** and must gate on its own
   `pendingWrites` count (FR-035) — this feature is spec 031's second adopter,
   which is what that spec was built for.
3. **The unconfirmed-edits decision must be reused, not re-implemented.**
   `_onContinuePressed` is currently private to `capture_step.dart`. Extract it as
   a shared helper — `Future<bool> resolveUnconfirmedEdits(BuildContext, WidgetRef,
   String scope)` — and have both the register's continue action and the
   back-office confirm call it. This is the one edit this feature makes to a
   POS-only file; spec 031's own tests (`pos_write_gating_test.dart`,
   `unconfirmed_changes_test.dart`) are the guard that it stayed behaviour-neutral.
4. **The order screen's own text fields** (discount is already handled by the
   shared line widget; the order-level comment and any new typed field) must use
   `ConfirmableTextField` rather than a bare `TextField`, so FR-037 holds
   everywhere and not only on the reused parts.

**The regression gate grew.** SC-007's suite now includes
`pos_write_gating_test.dart`, `unconfirmed_changes_test.dart`,
`sale_line_discount_test.dart` and `quantity_stepper_widget_test.dart`. All four
must pass unmodified.

**Not adopted**: spec 030's destination-card edit button and expandable
counter row are delivery-step work (OS-3).
