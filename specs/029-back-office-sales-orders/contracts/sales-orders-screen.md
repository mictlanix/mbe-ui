# Contract: Sales Orders Screens

**Feature**: `029-back-office-sales-orders`

Two screens. Neither invents a layout primitive — both are assembled from
`core/widgets/` components already used by every catalog.

---

## 1. `/sales/orders` — the list

### 1.1 Structure

```
CatalogFilterBar
├── actions:  [ FilledButton.icon  "New order" ]        ← FR-015, gated (routes §5)
├── search:   CatalogSearchBar                          ← FR-007
└── filters:  Badge.count( IconButton.outlined(Icons.tune) )   ← FR-008/FR-011
CatalogListStateView<OpenSale>
└── DataTableView<OpenSale>
CatalogPagination
```

Every facet lives behind the drawer (constitution §VI rule (a)). No inline chips,
no inline date pickers, no form above the list (rule (b)).

### 1.2 Columns (FR-005)

| Column | Size | Value |
|---|---|---|
| Reference | S | `serial ?? id` — the folio once assigned, the id before |
| Date | S | `fmt.display.dateTime(sale.date)` |
| Customer | L | `posSaleCustomerLabel(sale)` |
| Status | S | `PosSaleStatusChip` (existing) |
| Total | S | `fmt.display.currency(sale.total)` |
| Balance | S | `fmt.display.currency(sale.balance)` |
| — | XS | row action: Edit (drafts only) |

The whole row opens the order; Edit is the single direct row action
(constitution §VI). No print action — there is nothing to print (spec A5).

### 1.3 Filter drawer

`showCatalogFilterSheet` with, in order: date range, status, and — for an
administrator only — salesperson and facility. Both admin facets are
`CatalogEntityPicker`s seeded from `employeeDisplayNameProvider` /
`facilityDisplayNameProvider`, so a facet arriving in the URL as a bare id still
shows a name. `cash_sessions_screen.dart:475-535` is the working precedent to
copy.

`onClearAll` clears `date-from`, `date-to`, `status`, `salesperson`, `facility`
and resets to page 0 — returning the date range to the **current month**, never to
unbounded (FR-009).

### 1.4 States

| State | Treatment |
|---|---|
| loading | `CatalogListStateView`'s spinner |
| error | shared error view + Retry, which invalidates the page provider |
| empty, unfiltered | "no orders yet" message |
| empty, filtered | the shared over-filtered message + Clear filters (FR-013) |
| no facility configured | full-screen explanatory notice; **no request is issued** |

`isFiltered` is true when the range is not the default month, or any facet or
search term is set.

---

## 2. `/sales/orders/new` and `/sales/orders/:orderId` — the order

### 2.1 Structure

```
Scaffold
├── AppBar( title: "Pedido" · reference · status chip )     ← actions: EMPTY (§VI)
└── body
    ├── ErrorBanner                              ← any refused mutation (FR-028)
    ├── OrderHeaderPanel                         ← §2.2, ResponsiveFormGrid
    ├── CustomerBar(sale:)                       ← REUSED unchanged
    ├── ProductSearchField                       ← REUSED unchanged
    ├── SaleLineRow / SaleLineCard (showComment: true)  ← REUSED, one new flag
    ├── SaleTotalsBar                            ← REUSED unchanged
    └── RecordFormActions [ Cancel order ] [ Confirm ]
```

The screen is wrapped in a nested `ProviderScope` overriding `saleEditorProvider`
with `orderEditorController(orderId)` (data-model §6.2). That override is the
whole isolation mechanism for FR-030.

### 2.2 Header fields (FR-016, FR-017)

Laid out with `ResponsiveFormGrid` — two columns on wide, one on compact, matching
the legacy screen's left/right split.

| Field | Control | Editable |
|---|---|---|
| Reference (id, folio) | text | never |
| Status | chip | never |
| Date | text | never |
| Due date | text | **never** — server-derived (FR-017) |
| Exchange rate | text | never |
| Promise date | date picker | draft only |
| Payment terms | dropdown | draft only *(also on `CustomerBar`; the header shows it read-only to avoid two live controls for one field — see §2.5)* |
| Currency | dropdown | draft only |
| Priority | dropdown | **draft *and* completed** (FR-026) |
| Salesperson | `CatalogEntityPicker<EmployeeListItem>` (`salesPerson: true`) | draft only |
| Contact | `CustomerContactPicker` (existing) | draft only |
| Ship-to | `CustomerAddressPicker` (existing) | draft only |
| Fiscal recipient (RFC) | `CatalogEntityPicker` over taxpayer recipients; shows `recipientName` beneath | draft only |
| Comment | multiline text | draft only |

Every edit is one `updateHeader` call; the returned `Sale` replaces state
wholesale. Nothing is batched into a "Save" button — the surface is live, like the
register's.

### 2.3 Lines

Identical behaviour to the register's capture step, plus the per-line comment:

- price is **read-only** (spec 020 FR-038c; legacy agrees — research R9.1);
- quantity, discount, tax rate, warehouse and comment are editable while draft;
- per-line stock availability is shown for the chosen warehouse (FR-022);
- a refused edit restores the last accepted values and keeps the row usable.

### 2.4 Confirm and cancel

- **Confirm** is disabled until `lineCount > 0` (FR-023). On refusal, the server's
  message — with every offending line named — renders in the banner and the order
  stays a draft (FR-024). On success the folio appears and the screen flips to
  read-only (FR-025).
- **Cancel** requires a confirmation dialog, lives only here (never on a row), and
  renders its refusal in the same banner (FR-026).

### 2.5 Read-only mode

`!sale.isEditable` puts every control into its read-only face — the same
`enabled:` flag the capture widgets already accept. **Priority alone ignores it.**
Add-line, remove-line, confirm and cancel affordances are absent, not disabled.

**Terms appear twice** — on `CustomerBar` (reused, live) and in the header grid.
The header copy is read-only text; only the `CustomerBar` control writes. Two live
controls for one field would race each other through `updateHeader`.

### 2.6 No register configured (FR-014)

The list and the order screen both still work. Only creation is withheld: the
"New order" action is replaced by an inline notice naming the missing setting
(`user_settings.point_sale`) and who can set it. This is
`pos_gate_screen.dart`'s treatment narrowed to one action — the user is told
*before* capturing an order, never by a 422 afterwards.

---

## 3. Localization

Every string in both `.arb` files, `es-MX` authored first, keys prefixed
`salesOrders*` / `order*`. Reuse existing keys where one already says the same
thing (`filtersButton`, `clearAllFilters`, `applyFilters`, `retryButton`,
`clearFiltersButton`, the four status labels, the terms labels). New label sets
needed: the four priority values, the header field labels, the cancel
confirmation, and the no-register notice.

## 4. Formatting

Every date, money and percentage goes through `formattersProvider` (spec 028).
No `DateFormat`, no `toStringAsFixed`, no hand-built `"16.00 %"` anywhere in the
new code.
