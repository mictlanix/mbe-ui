# Contract: mbe-api Usage

**Feature**: `029-back-office-sales-orders` | **Verified**: 2026-08-19

Every endpoint below already exists and is already in the generated client
(`lib/generated/openapi/lib/src/api/sales_orders_api.dart`). **No codegen, no
mbe-api issue, no backend dependency.**

---

## 1. `GET /api/v1/sales-orders` — the list

Generated: `listSalesOrdersApiV1SalesOrdersGet({mine, customer, salesperson,
status, dateFrom, dateTo, facility, pointSale, search, skip, limit})`

New repository method:

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

`customer` and `pointSale` are deliberately not exposed — nothing in scope filters
by them.

**Server behaviour that the client must respect** (`sales_order_service.list_orders`):

| Behaviour | Consequence here |
|---|---|
| `facility` defaults to `current.facility_id`, and the predicate is unconditional | one facility per request, always; omit the param for "my facility" |
| `mine=true` ⇒ `creator == me OR updater == me OR salesperson == me` | this *is* FR-006's definition of "my orders" |
| `mine` is guarded by `employee_id is not None`, and `employee_id` is NOT NULL since migration 012 | the narrowing can never silently degrade to "everything" |
| `status=completed` also returns `paid` rows | the facet is a narrowing hint, not an exact match; the row's own status chip is the truth |
| numeric `search` matches id **or** serial; text `search` matches the customer's name or the document override | matches FR-007 exactly; nothing extra to implement |
| ordering is `sales_order_id DESC` | "newest first" comes free |
| `limit` is capped at 100 | page size 20 |
| no filter by creating user, and no register on the response | FR-011a, spec A4 |
| **the server does not check that the caller may see the `facility` they ask for** | the client's non-administrator drop is the *only* guard — see the note below |

**Live-verified 2026-08-24 — `facility` is not authorization-checked.** Probed
directly against a running backend with two real tokens:

| Token | Request | `total` |
|---|---|---|
| `spec029user` — non-administrator, `SALES_ORDERS` CRU, **facility 51**, employee 2 | `mine=true`, month range | `0` |
| the same token | `?facility=51` added by hand, month range | **`130`** |

That second row is the whole problem: `spec029user` is a fully legitimate,
correctly-configured ordinary user of *its own* facility, and it reads 130 orders
belonging to **another employee** purely by editing the address. (The same probe
against a non-administrator with *no* facility configured behaves identically —
`0` without the facet, the full count with it — so the hole is not an artefact of
how the account is set up.)

So a non-administrator who hand-edits `facility=<id>` into the address reaches
every order in a facility that is not theirs — *if the client passes the facet
through*. It does not: `SalesOrdersFilter.fromQuery` drops `facility` and
`salesperson` unless `isAdministrator`, and `SalesOrdersListController._fetch`
drops them again on its own terms (`sales_orders_list_controller.dart:69-70`,
`:164-165`), locked by `sales_orders_scoping_test.dart`. That double drop is what
SC-009 is about, and this measurement is why it is defence-in-depth rather than
belt-and-braces: **remove either one and the exposure is real.**

`salesperson=<other employee>` from the same token answered `0`, so that facet is
not a comparable hole on this dataset — but it is not demonstrably checked
either, and should not be assumed safe.

> **Recommended backend hardening (out of scope for this feature, client-side
> only):** `list_orders` should reject — or silently narrow — a `facility` the
> caller has no claim to, rather than trusting the client to omit it.

## 2. `POST /api/v1/sales-orders` — create

An **empty body** opens a draft on the caller's configuration. Called lazily by
`ensureOpen()`, never from `build` (FR-015, SC-005).

**422 when the caller has no point of sale** (`_point_sale`) or no facility
(`_facility`). The screen must prevent the first case up front (FR-014) rather
than let it surface after capture.

Server-filled on create: facility (from the caller — **never** the request),
point of sale, salesperson, default customer, currency, exchange rate, terms
(`netD` if the customer has credit and is not the default customer, else
`immediate`), date, promise date (`date + max_days_to_deliver_stockables`) and
due date.

**Consequence for FR-011/US5 scenario 4**: an administrator viewing another
facility still creates in *their own*, because the facility comes from the token,
not the body. The screen says so before they begin.

## 3. `PUT /api/v1/sales-orders/{id}` — header

`SalesOrderUpdate` accepts: `customer`, `salesperson`, `payment_terms`,
`currency`, `promise_date`, `contact`, `ship_to`, `recipient`, `customer_name`,
`priority`, `comment`, `fulfillment_intent`.

`SalesOrderRepository.updateHeader` gains the optional parameters it lacks
(`promiseDate`, `salesperson`, `priority`, `comment`, `recipient`). Additive —
existing POS callers pass none of them.

**Server rules to render, not re-implement**:

- changing `customer` **reprices every existing line** (the returned `Sale`
  already carries the new totals);
- changing `payment_terms` recomputes `due_date`;
- changing `currency` re-expresses every line;
- `netD` on a customer without credit is refused;
- once `completed` or `cancelled`, **every field but `priority` is refused** —
  which is why the UI does not offer them (`Sale.isEditable`).

`due_date` is **not** in the schema. It is derived. Do not send one.

## 4. Lines

`POST /{id}/lines`, `PUT /{id}/lines/{lineId}`, `DELETE /{id}/lines/{lineId}` —
all already on `SalesOrderRepository`, all already accept `comment`. Nothing
changes here; only the line widget's rendering does.

## 5. `POST /{id}/confirm` and `POST /{id}/cancel`

Unchanged from the register's use. Confirm assigns the folio, commits stock and
freezes the document; it refuses zero-priced lines, stock shortfalls and lines
needing stock with no warehouse, naming each offender. Cancel refuses an already
cancelled order, a paid one, and one with live payment applications.

The repository already flattens the server's `{"message", "lines"}` refusal into
the banner text — reuse that path verbatim (FR-024).

## 6. `GET /sales-orders/product-lookup`

Unchanged. Prices against the order's customer, so it stays one of the actions
that lazily opens the order.

## 7. Supporting catalogs

| Need | Endpoint / provider (all existing) |
|---|---|
| salesperson facet + header picker | `employeeRepositoryProvider.list(salesPerson: true)`, `employeeDisplayNameProvider` |
| facility facet | `facilityRepositoryProvider.list(...)`, `facilityDisplayNameProvider` |
| contact / ship-to pickers | `CustomerContactPicker`, `CustomerAddressPicker` |
| fiscal recipient picker | `taxpayerRecipientRepositoryProvider.list(search:)` — RFC is the key |
| per-line warehouses | `facilityWarehousesController` (existing) |

## 8. Explicitly not used

`GET /{id}/payments` (OS-2), anything under delivery orders (OS-3), quotations
(OS-5). No endpoint in this feature needs a change, so no mbe-api issue is filed
(constitution §III).
