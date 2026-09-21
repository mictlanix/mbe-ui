# Contract: The Origin Facet

**Feature**: `041-fix-list-origin-refresh` | **Date**: 2026-09-20

> **SUPERSEDED, 2026-09-20 — read §0 first.** This document describes a
> user-facing facet and a per-row column that were both removed after review.
> §0 states the contract as built; everything from §1 onward is the
> pre-correction design, kept for its reasoning rather than rewritten.

---

## 0. The contract as built

Neither list offers an origin control, and neither renders an origin column.
Each list is permanently scoped, by a different mechanism:

| | POS sales list | Back-office "Pedidos" list |
|---|---|---|
| Repository arg | `origin: SaleOrigin.pointOfSale` | `excludeOrigin: SaleOrigin.pointOfSale` |
| Wire query | `?origin=0` | `?exclude_origin=0` |
| Rows kept | `pointOfSale` **only** | `backOffice` + unrecorded |
| Rows removed | `backOffice` **and unrecorded** | `pointOfSale` |
| User control | none — fixed | none — fixed |

The asymmetry is deliberate. The register's list is inclusive, so a sale
that recorded no origin (every sale predating mbe-api#209) does not appear
there; the back-office list is exclusive, so those same orders remain
visible there. That makes "Pedidos" the one place pre-#209 history is
reachable, and it is why the back-office side must **not** be switched to an
inclusive `origin=backOffice` filter.

The one rule that survives unchanged from §1: `listSales` sends only
`origin`, `listOrders` sends only `exclude_origin`. Neither method sends
both, and neither list's scoping is reachable from the URL.

**Removed by this correction**: the `hide-back-office` / `hide-point-of-sale`
URL facets, both filter-drawer chips, the `SaleOriginChip` widget, the origin
column on both tables, the nine `saleOrigin*`/`*ColumnOrigin`/`*OriginFilter*`
l10n keys, and `OpenSale.origin` (which nothing reads once the column is
gone).

---

## 1. The guarantee *(pre-correction design — see §0)*

> Neither list's origin control may hide an order whose origin was never
> recorded, in any state of the control.

This is the contract's whole point (FR-005, SC-003). It is honoured structurally
rather than by a check: the only server parameter this feature ever sends is
`exclude_origin`, which names the workflow to *remove*. An order with no
recorded origin matches no workflow and is therefore never removed. Sending
`origin=` instead would silently break the guarantee, so **`origin` must not be
passed by any code path added here**.

---

## 2. Per-screen binding

| | POS sales list | Back-office "Pedidos" list |
|---|---|---|
| Screen | `pos_sales_list_screen.dart` | `orders/sales_orders_list_screen.dart` |
| Filter field | `PosSalesFilter.hideBackOffice` | `SalesOrdersFilter.hidePointOfSale` |
| Default | `false` | `false` |
| URL facet key | `hide-back-office` | `hide-point-of-sale` |
| Facet value when on | `"true"` | `"true"` |
| Facet when off | absent (cleared with `withFacet(key, null)`) | absent |
| Domain value sent | `SaleOrigin.backOffice` | `SaleOrigin.pointOfSale` |
| Repository arg | `excludeOrigin:` on `listSales` | `excludeOrigin:` on `listOrders` |
| Wire query | `?exclude_origin=1` | `?exclude_origin=0` |
| Rows kept | `pointOfSale` + unrecorded | `backOffice` + unrecorded |
| Rows removed | `backOffice` | `pointOfSale` |

The wire values follow `api.OrderOrigin` (`number0` → `0` = point of sale,
`number1` → `1` = back office), applied via the existing `SaleOrigin.toApi()`.

**Off state**: when the field is `false`, `excludeOrigin` is `null`, the
generated client omits the parameter, and the request is identical to the one
the screen sends today (FR-012, SC-005).

---

## 3. Registration checklist — all four points, both screens

A facet that lands in only some of these is the predictable defect. Each list's
implementation must touch all four:

1. **Decode** — `fromQuery` reads the facet into the filter field.
   `PosSalesFilter.fromQuery` (`pos_sales_list_controller.dart:26-64`);
   `SalesOrdersFilter.fromQuery` (`sales_orders_list_controller.dart:34-75`).
2. **Badge count** — `activeFilterCount(...)` in the `…FilterBadge` extension
   adds 1 when the field is set (`pos_sales_list_controller.dart:118-121`;
   `sales_orders_list_controller.dart:116-122`). Drives the `Badge.count` on the
   drawer's `IconButton.outlined(Icons.tune)`.
3. **Clear all** — the screen's `onClearAll` clears the facet explicitly
   (`pos_sales_list_screen.dart:147-153`;
   `sales_orders_list_screen.dart:172-180`).
4. **Empty-state predicate** — the `isFiltered` expression that decides between
   "no results" and "nothing here yet" (`pos_sales_list_screen.dart:172-175`
   longhand; `sales_orders_list_screen.dart:197-198` via `hasActiveFilters`).

**Two invariants inherited from the status facet**, non-negotiable:

- Clear by writing `null`: `query.withFacet(key, null)`, never `"false"`.
- Every facet change carries `.copyWith(pageIndex: 0)`. Narrowing a result set
  without resetting the page can strand the user past the end of it.

---

## 4. Control presentation

- Lives **inside the existing filter drawer** (`showCatalogFilterSheet`), never
  inline in the filter row — constitution VI, v1.11.0 rule (a). Both screens
  already open that drawer, so no structural change is needed.
- Placement: after the status `Wrap`, separated by `SizedBox(height: 12)`, with
  its own `titleSmall` label — matching the existing label/`Wrap` rhythm. On the
  orders screen it precedes the `if (isAdministrator)` block
  (`sales_orders_list_screen.dart:360-423`).
- A single `FilterChip` (on/off), not a `ChoiceChip` group and not tri-state —
  see research R3 for why the project's tri-state preference does not apply.
- Keys follow the existing convention for testability:
  `pos_sales_filter_hide_back_office`, `sales_orders_filter_hide_point_of_sale`.
- Navigation on change is the established
  `context.go(updated.toUri(path).toString())`.

---

## 5. Per-row indicator (FR-006)

`SaleOriginChip` — new, in `lib/features/sales/presentation/widgets/`, a thin
wrapper over the shared `StatusChip<T>` (`core/widgets/status_chip.dart:14-42`)
built exactly like its sibling `PosSaleStatusChip`
(`widgets/pos_sale_status_chip.dart:24-49`). Domain colour mapping lives in the
wrapper; the shared chip owns the rendering.

| `OpenSale.origin` | Label (es) | Notes |
|---|---|---|
| `SaleOrigin.pointOfSale` | "Punto de venta" | Settled vocabulary — `app_es.arb:881-882` |
| `SaleOrigin.backOffice` | new string | No existing label to inherit |
| `null` | new string | Must read as *unrecorded*, never as a default workflow |

Rendered in its own column immediately after Status, on both lists, using
`DataTableColumn`'s `fixedWidth` (`data_table_view.dart:60-73`). Neither table
passes `minWidth`, so it shrinks to fit rather than scrolling — which makes the
7th column a width risk that **must be proven, not assumed**:

> A widget test asserts no overflow at a representative desktop width **and** at
> the largest of the four text-size levels (constitution V).

Documented fallback if that cannot pass at a sane width: an icon-only chip
(`Icons.point_of_sale_outlined` for the register side, per research R7) with a
tooltip carrying the label, in the same column. All three states stay
distinguishable either way.

---

## 6. Strings

Added to `lib/l10n/app_en.arb` (with `"@key": {}` stubs) and `lib/l10n/app_es.arb`
(values only), then regenerated. Naming follows the area convention —
`posSales*` for the POS list, `salesOrders*`/`salesOrder*` for the back-office
side, `<prefix>Column<Name>` for headers, `<prefix>…FilterLabel` for facets:

| Purpose | Suggested key |
|---|---|
| POS drawer facet label | `posSalesOriginFilterLabel` |
| POS chip ("hide back-office orders") | `posSalesOriginFilterHideBackOffice` |
| Orders drawer facet label | `salesOrdersOriginFilterLabel` |
| Orders chip ("hide point-of-sale sales") | `salesOrdersOriginFilterHidePointOfSale` |
| Column header | `posSalesColumnOrigin` / `salesOrdersColumnOrigin` |
| Row label: point of sale | `saleOriginPointOfSale` |
| Row label: back office | `saleOriginBackOffice` |
| Row label: unrecorded | `saleOriginUnrecorded` |

The three row labels are shared by both screens and so are unprefixed.

---

## 7. What this contract does not cover

- Backfilling origin on pre-#209 orders — out of scope, and deliberately so
  (spec OS-2 / research R1).
- Any use of the inclusive `origin` parameter — forbidden here (§1).
- `listOpen(...)` (`sales_order_repository.dart:133-139`), which backs the
  register's resume flow rather than a user-facing list, and is unchanged.
