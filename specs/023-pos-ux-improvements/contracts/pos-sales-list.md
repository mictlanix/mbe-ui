# Contract: the POS sales list screen

**Route**: `/sales/pos` (shell branch 18, unchanged) ·
**Screen**: `lib/features/sales/presentation/pos_sales_list_screen.dart` (new) ·
**Gate**: `(SystemObject.pos, AccessRight.read)` — the existing
`location.startsWith('/sales/pos')` rule covers it.

Supersedes what `/sales/pos` rendered before this feature: the capture surface
moves to `contracts/pos-workspace.md`.

---

## 1. Shape

Standard catalog list composition (constitution §VI), in this order:

```
CatalogFilterBar(
  search:  CatalogSearchBar            → ListQuery.search
  actions: [FilledButton.icon "Nueva venta"]
  filters: [DateRangeFilterChip, status FilterChip/sheet entry]
)
DataTableView<OpenSale>(
  columns:          §2
  rowActionsBuilder: §3
  onRowTap:          §3
  pagination:        CatalogPagination, page size 20
)
```

The screen is a `ConsumerWidget` taking `ListQuery query`, as every list screen
does, and derives `PosSalesFilter.fromQuery(query, today: DateTime.now())`.

## 2. Columns

| # | Column | Alignment | Truncation | Content |
|---|---|---|---|---|
| 1 | Folio / referencia | left | never | `serial ?? id`, labelled so the two are distinguishable (folio once assigned, provisional reference otherwise) |
| 2 | Fecha | left | never | `date`, `intl` short date + time in the active locale |
| 3 | Cliente | left | ellipsis + tooltip | `customerName ?? '—'` — the only truncatable column |
| 4 | Estado | centred | never | `StatusChip` with the neutral status label (data-model §7) |
| 5 | Total | right | never | `MoneyFormatters.currency(total)` |
| 6 | Saldo | right | never | `MoneyFormatters.currency(balance)` |

Columns 1, 4, 5 and 6 are covered by the constitution's "never truncate critical
info" rule (identifiers, status badges, monetary amounts).

## 3. Row affordances

Exactly one row icon, plus the whole-row click — the constitution's Edit-only /
click-to-view rule:

| | Condition | Behaviour |
|---|---|---|
| **Edit icon** | `saleIsWorkable(sale, resumableIds: …)` **and** `can(salesOrders, update)` | `context.push('/sales/pos/${sale.id}')` |
| **Edit icon** | workable but no `update` privilege | **absent** (never shown disabled — constitution §VI/IV) |
| **Edit icon** | not workable | **shown disabled**, with `posSalesEditDisabledTooltip` stating why |
| **Row click** | any row | `context.push('/sales/pos/${sale.id}')` — read-only when the sale is past draft (FR-006a) |

The one deliberate difference from other catalogs: a *state*-based refusal is
rendered as a disabled icon with a tooltip, because "this sale is finished" is
information the cashier needs; a *privilege*-based refusal is rendered as absence,
per the constitution. The two cases never coincide visually.

Built with `buildCatalogRowActions(editTooltip:, onEdit:)` — no bespoke icon.

## 4. Filters

### 4.1 Date range — the default and the floor

| | Value |
|---|---|
| Default | today → today |
| Control | `DateRangeFilterChip` (new shared widget, `core/widgets/`) → `showDateRangePicker` |
| Encoding | `?date-from=yyyy-MM-dd&date-to=yyyy-MM-dd`; omitted when both are today |
| Clearing | returns to today → today, **not** to unbounded |

Unbounded is forbidden here: spec 020 measured 19,277 rows for one register's
history, and a cleared filter that scans them is a trap, not a feature.

### 4.2 Status

Single-select facet over `SaleStatus` (`draft`, `completed`, `paid`,
`cancelled`); absent means every status. Because mbe-api's `status` filter is
**not exclusive** (spec 020, live-verified: `completed` answers with `paid` rows
too), the controller narrows each page to the requested status client-side. The
count shown is the server's total for the query; a narrowed page may therefore be
shorter than the page size. This is a known wart of the endpoint, recorded rather
than worked around.

### 4.3 Search

`?search=` passed through verbatim. What the endpoint matches is not yet
verified (research U1) — the screen therefore makes no claim in its copy about
*what* is searched, and an unmatched search shows the filtered-empty state.

## 5. Data source

`SalesOrderRepository.listSales(...)` →
`GET /api/v1/sales-orders?point_sale=&status=&date_from=&date_to=&search=&skip=&limit=`

| Parameter | From |
|---|---|
| `point_sale` | `registerPointSaleProvider` — **always sent**, never cashier-editable |
| `status` | the status facet, when set |
| `date_from` / `date_to` | `wireDate(filter.from)` / `wireDate(filter.to)` — midnight of the local date flagged UTC (data-model §4.1) |
| `search` | the search box, when non-empty |
| `skip` / `limit` | `pageIndex * 20` / `20` |

`mine`, `customer`, `salesperson` and `facility` are not sent: the register
already scopes the query, and any of them would narrow it further in ways the
screen does not offer.

## 6. States

| State | Rendering |
|---|---|
| Loading | the shared list loading view |
| Empty, default range | `posSalesEmptyToday` — "no sales on this register today", with "Nueva venta" still offered |
| Empty, filtered | `posSalesEmptyFiltered` + a clear-filters affordance (`filter.hasActiveFilters`) |
| No register configured | `posSalesNoRegister` — explains a register must be assigned; no query is issued |
| Failure | `ErrorBanner` with retry (`ref.invalidate`), the sale rows kept off screen rather than half-shown |

## 7. "Nueva venta"

| Condition | Behaviour |
|---|---|
| A cash session is open or stale | enabled → `context.push('/sales/pos/new')` |
| No cash session | **disabled**, with `posSalesNewSaleBlockedNoSession` and a link to `/sales/cash-sessions` |
| No `pos` create privilege | absent |

Nothing is written server-side by pressing it: the workspace opens with no sale
and mbe-api is only touched by the first real action, preserving spec 020's
anti-empty-draft rule (research R2).

## 8. Returning from the workspace

The list re-reads on return (FR-009). The navigation is **awaited** and the two
providers behind the screen are invalidated once it resolves:

```dart
onEdit: () async {
  await context.push('/sales/pos/${sale.id}');
  if (!context.mounted) return;
  ref.invalidate(posSalesListControllerProvider(filter));
  ref.invalidate(openSalesSelectorControllerProvider(pointSale));
},
```

`GoRouter.push` returns a `Future` that completes when the pushed route pops,
which is exactly the signal wanted. The second invalidation matters as much as the
first: `openSalesSelectorControllerProvider` is what §3 reads to decide
workability, so without it a sale finished in the workspace would come back to a
row that still offers Edit.

**Note on why this is explicit.** The other catalog list screens do *not* refresh
after a detail edit — the list controllers are keyed families invalidated only on
retry, and the list screen survives underneath a pushed top-level route (it sits
in the shell's `IndexedStack`), so nothing re-runs on its own. FR-009 is a
requirement this feature adds, so it carries its own mechanism rather than
inheriting one that does not exist.
