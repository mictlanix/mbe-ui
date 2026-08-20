# Phase 1 Data Model: Back-Office Sales Orders

**Feature**: `029-back-office-sales-orders` | **Date**: 2026-08-19

Domain entities and view state. Nothing here is a new wire format — every field
already exists on `SalesOrderResponse` / `SalesOrderSummary`
([research.md](./research.md) §R2, §R3).

---

## 1. `Sale` — extended (`domain/entities/sale.dart`)

Existing fields are unchanged. Added, all mapped in `Sale.fromResponse` from
fields the generated DTO already carries:

| Field | Type | Source | Notes |
|---|---|---|---|
| `date` | `DateTime` | `r.date` | The order date. Server-set at creation; not editable (mbe-api accepts `date` only on create, and this screen does not send one). |
| `dueDate` | `DateTime` | `r.dueDate` | **Display only** (FR-017). Derived server-side by `derive_due_date(date, terms, credit_days)`; absent from `SalesOrderUpdate`. |
| `contact` | `int?` | `r.contact` | FK → contact. Editable while draft. |
| `recipient` | `String?` | `r.recipient` | The fiscal recipient's RFC (≤ 13 chars) — a client-supplied string key, not an int FK. Editable while draft. |
| `recipientName` | `String?` | `r.recipientName` | **Display only** — server-filled from the recipient. |
| `priority` | `Priority` | `r.priority` | Editable while draft **and after completion** (the one exception, FR-026). |
| `comment` | `String?` | `r.comment` | Order-level notes. Editable while draft. |

### 1.1 `Priority` — new hand-mapped enum

```dart
enum Priority { low(0), normal(1), high(2), critical(3); … }
```

Verified against `mbe-api/app/enums.py:115` — `LOW=0, NORMAL=1, HIGH=2,
CRITICAL=3`. **Four members, not three**: legacy's data dictionary documents only
"1=Normal, 2=High" and its form offers Baja/Media/Alta, so `critical` is an
mbe-api addition with no legacy label. It is mapped (a value that exists on the
wire must decode) and gets its own localized label.

The generator emits `Priority.number0`…`number3` with no preserved member names —
the identical gap `PaymentTerms` and `CurrencyCode` already work around in this
same file. Follow that convention exactly: a `fromApi` switching on `value.name`
with a safe fallback to `normal`, and a `toApi`. `normal` (not `low`) is the
default for a new order, matching `SalesOrderCreate.priority`'s own default.

### 1.2 Derived members (existing, unchanged semantics)

- `isEditable` → `status == draft`. This is what puts the whole order screen in
  read-only mode (FR-026); **priority is the single control that ignores it**.
- `isPaid`, `lineCount`, `provisionalReference` — untouched.

### 1.3 What is deliberately not mapped

`salesQuote` (OS-5), `partialDeliveries` and `delivered` (OS-3), `customerShipto`
(free-text override with no UI in scope).

---

## 2. `SaleLine` — unchanged

`comment` is already an entity field and already round-trips through
`updateLine`. Only its *rendering* is new, and that is a widget parameter
(§6.3), not a model change.

---

## 3. `OpenSale` — reused as the list row

Already maps `SalesOrderSummary` completely: `id`, `serial`, `customerName`
(the per-document override), `customerDisplayName` (joined by mbe-api #173),
`total`, `balance`, `status`, `date`. `posSaleCustomerLabel(sale)` already
resolves the display rule (override wins, then joined name, then a dash).

**Decision**: reuse it rather than introduce a field-identical
`SalesOrderListItem`. The name is POS-flavoured for what is really "a row of
`GET /sales-orders`"; a rename would touch the register's list and selector for
no functional gain and is not attempted here. Recorded in R3 as a known wart.

**Not on the summary, therefore not on a row**: the point of sale, the creating
user, and the payment terms (spec A1, A4). The salesperson *is* on the summary
but is not shown — FR-005 does not ask for the column and resolving a name per
row costs a request each.

---

## 4. `SalesOrdersFilter` — the list's addressable view state

A `@freezed` value keyed by the same shape as `PosSalesFilter`, decoded by
`SalesOrdersFilter.fromQuery(ListQuery, {required DateTime today, required bool isAdministrator})`.

| Field | Type | Facet key | Default |
|---|---|---|---|
| `from` | `DateTime` | `date-from` | first day of the month containing `today` |
| `to` | `DateTime` | `date-to` | last day of that month |
| `status` | `SaleStatus?` | `status` | null (every status) |
| `salesperson` | `int?` | `salesperson` | null — **decoded only when `isAdministrator`** |
| `facility` | `int?` | `facility` | null → the caller's own — **decoded only when `isAdministrator`** |
| `search` | `String` | (reserved `search`) | `''` |
| `pageIndex` | `int` | (reserved `page`) | `0` |

### 4.1 Rules

- **`fromQuery` is total** — an unparseable date, status, salesperson or facility
  degrades to its default and never throws (the `ListQuery` convention).
- **`today` is a parameter, truncated to a calendar date before use.** Reading
  `DateTime.now()` inside would make every rebuild construct a filter unequal to
  the previous one, so the `@riverpod` family keyed on this value never reuses an
  instance: each watch starts a fetch whose completion triggers the rebuild that
  starts the next one. `pos_sales_list_controller.dart:41-52` documents this as a
  confirmed, observed hang. The month bounds inherit the same requirement.
- **`isAdministrator` is a decode-time input, not a field.** A non-administrator's
  filter simply has no `salesperson`/`facility`, whatever the URL says — the
  hand-edited-address edge case is closed here, in the decoder, not in the drawer.
- `isDefaultRange(today)` → the month; clearing the date chip returns to the
  month, **never to unbounded** (FR-009).
- `activeFilterCount(today)` → date-range (if not the default month) + status +
  salesperson + facility. `search` is excluded — it has its own visible control,
  matching every other catalog's badge convention.

---

## 5. Controllers

### 5.1 `salesOrdersListController(SalesOrdersFilter filter)` → `AsyncValue<OpenSalePage>`

A `@riverpod` family. Builds the request as:

```
mine:        !isAdministrator          // never from URL state (R4)
facility:    isAdministrator ? filter.facility : null   // null ⇒ caller's own
salesperson: isAdministrator ? filter.salesperson : null
status/dateFrom/dateTo/search/skip/limit: from the filter
```

`limit` is 20; `skip` is `pageIndex * 20`. Page clamping follows the existing
`CatalogPagination` convention (an out-of-range page shows the last one).

### 5.2 `orderEditorController(int? orderId)` → `AsyncValue<Sale?>`

A `@riverpod` autoDispose family, `implements SaleEditor`.

| Key | Meaning | `build` |
|---|---|---|
| `null` | a brand-new order | `null` — **nothing is written** until the first mutation (FR-015, SC-005) |
| an id | an existing order | `getById(saleId: id)` |

State transitions are the same "replace wholesale with the server's response"
rule the register already follows: every mutation awaits its repository call and
assigns `AsyncValue.data(response)`. A **rejected** mutation leaves `state` at its
last accepted value and rethrows, so the screen renders the error inline instead
of blanking the order (FR-028).

`autoDispose` is deliberate: a back-office user opens many orders in a session
and each one's state should die with its route, unlike the register's long-lived
singleton.

---

## 6. The shared-editor seam

### 6.1 `SaleEditor` (interface, `presentation/sale_editor.dart`)

```dart
abstract interface class SaleEditor {
  Future<Sale> ensureOpen();
  Future<void> updateHeader({ …all header fields… });
  Future<void> addLine({ … });
  Future<void> updateLine({ … });
  Future<void> removeLine(int lineId);
  Future<void> confirm();
}
```

Both `PosSaleController` and `OrderEditorController` implement it. The interface
is intentionally the union of what the *shared* widgets call — not the union of
what both controllers do (`startNew`, `load`, `refresh` stay off it).

### 6.2 `saleEditorProvider`

```dart
@riverpod
SaleEditor saleEditor(Ref ref) => ref.watch(posSaleControllerProvider.notifier);
```

**The default is the register.** The back-office route overrides it inside a
nested `ProviderScope`; every other provider still resolves in the root
container, so repository, formatters, settings and the stock/tax caches remain
shared. This default is the reason no POS test changes (SC-007).

### 6.3 Widget parameters that change

| Widget | Change | Default |
|---|---|---|
| `SaleLineRow` / `SaleLineCard` | `bool showComment` | `false` — the register is untouched |

`CustomerBar`, `ProductSearchField` and `SaleTotalsBar` need **no** new
parameters; they already take the `Sale` (or its parts) and now route their
mutations through `saleEditorProvider`.

---

## 7. Validation and state rules (all server-owned)

The client enforces **nothing** it would have to duplicate. It reads:

| Rule | Owner | Client behaviour |
|---|---|---|
| minimum order quantity | server | pre-fills quantity, floored at 1 (a scan means "one") |
| price from the customer's price list | server | price is **read-only** on the surface (R9.1) |
| profit-margin band | server | refusal rendered inline |
| credit allowed for `netD` | server | refusal rendered against the terms control |
| zero-priced lines / stock shortfall on confirm | server | every named line surfaced in one banner (FR-024) |
| cancel refused when money stands against the order | server | refusal rendered on the order screen |
| what is editable after completion | server (`update_order`: everything but `priority` is refused) | mirrored by `Sale.isEditable`, so the UI does not *offer* the refusal |

The one rule the client owns outright is the scoping rule (§5.1), because there
is no server-side equivalent to read (spec A2).
