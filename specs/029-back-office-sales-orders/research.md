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

**Finding — the coupling is smaller than it looks.** Every read of the POS
singleton inside `presentation/capture/`:

| File | Line | Call |
|---|---|---|
| `capture_step.dart` | 61, 83 | `addLine`, `confirm` |
| `capture_step.dart` | 84 | `posStepControllerProvider.advanceToCobro()` |
| `capture_step.dart` | 101 | `registerPointSaleProvider` |
| `customer_bar.dart` | 75 | `updateHeader` |
| `fulfillment_mode_selector.dart` | 241, 271, 273, 284 | `posStepControllerProvider` + `updateHeader` |
| `product_lookup_controller.dart` | 26 | `ensureOpen` |
| `sale_line_editing.dart` | 90, 189 | `updateLine`, `removeLine` |

Two of those files are **not shared**: `capture_step.dart` is the POS *step*
(its confirm advances to `cobro`) and `fulfillment_mode_selector.dart` drives
the delivery step, which is out of scope (OS-3). The back-office screen composes
the pieces itself and offers a plain ship-to picker instead. That leaves exactly
**four call sites in three shared files**: `customer_bar.dart` (1),
`product_lookup_controller.dart` (1), `sale_line_editing.dart` (2).

**Decision**: introduce a `SaleEditor` interface + a `saleEditorProvider`
indirection whose **default resolves to the POS controller**, and swap those four
call sites to read it.

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

// default — the register. Nothing on the POS side changes.
@riverpod
SaleEditor saleEditor(Ref ref) => ref.watch(posSaleControllerProvider.notifier);
```

The back-office route wraps its screen in a nested `ProviderScope` overriding
`saleEditorProvider` with its own controller. Providers that are *not* overridden
still resolve in the root container, so the repository, formatters, settings and
caches stay shared; only the editor differs.

**Why the default matters**: it is what keeps SC-007 honest. The POS widget tests
override `salesOrderRepositoryProvider` and drive `posSaleControllerProvider`
straight off the container (`pos_test_harness.dart:294`); with the default in
place, not one of them needs an edit.

**Shared mutation logic**: `PosSaleController` (181 lines) is a thin façade over
`SalesOrderRepository` — every method is "call the repository, replace `state`
with the response". Rather than copy it, extract those bodies into a
`SaleEditing` mixin on `AsyncNotifier<Sale?>` and have both notifiers mix it in.
`PosSaleController` keeps its own `startNew()`; the back-office controller keeps
its own `load()` semantics and its family key.

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
- **The POS suite is the guard for SC-007**: it must pass unmodified. Any test
  file under `test/*/features/sales/` that has to change is a signal the refactor
  went further than intended.

## R11. What is deliberately *not* researched

Payment collection, delivery planning, quotation conversion, printing, and any
mbe-api change — all out of scope per the spec (OS-1 … OS-7). No mbe-api issue is
filed by this feature; nothing it needs is missing.
