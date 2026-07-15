# Contract: Routes, Navigation & RBAC Gating

**Feature**: `011-product-pricing` | **Date**: 2026-07-14

## Routes

Added to `lib/app/router/app_router.dart`. The three list routes are
`StatefulShellRoute` branches (persistent nav); detail/form routes sit outside
the shell, matching the existing `/products` + `/products/:productId` pattern.

| Route | Screen | Shell branch? | Gate (`routeSystemObject`) |
|---|---|---|---|
| `/price-lists` | `PriceListsListScreen` | ✅ branch | `priceLists` + `read` |
| `/price-lists/new` | `PriceListDetailScreen` (create) | ❌ | `priceLists` + `create` |
| `/price-lists/:priceListId` | `PriceListDetailScreen` (view/edit) | ❌ | `priceLists` + `read` |
| `/pricing` | `PricingScreen` | ✅ branch | `pricing` + `read` |
| `/exchange-rates` | `ExchangeRatesListScreen` | ✅ branch | `exchangeRates` + `read` |
| `/exchange-rates/new` | `ExchangeRateDetailScreen` (create) | ❌ | `exchangeRates` + `create` |
| `/exchange-rates/:exchangeRateId` | `ExchangeRateDetailScreen` (view/edit) | ❌ | `exchangeRates` + `read` |

`/pricing` has **no** detail route — product selection is in-screen state, not
a URL segment. (A future `/pricing?product=:id` deep link is a possible
enhancement; not in scope.)

## Navigation

`lib/core/navigation/nav_destinations.dart` — three `NavDestination` entries
appended to the existing `catalogs` `NavGroup`, and three new `NavBranch`
indices.

```text
NavBranch: home(0), users(1), products(2),
           priceLists(3), pricing(4), exchangeRates(5)   ← new
```

> ⚠️ `NavBranch` indices **MUST** match the branch order in `app_router.dart`
> (per the existing comment in `nav_destinations.dart:10-11`). Adding branches
> means adding them in the same order in both files.

| Destination id | Label (l10n key) | Icon | Route | Gate |
|---|---|---|---|---|
| `price-lists` | `priceListsMenuTitle` | `Icons.sell_outlined` / `Icons.sell` | `/price-lists` | `priceLists` + `read` |
| `pricing` | `pricingMenuTitle` | `Icons.price_change_outlined` / `Icons.price_change` | `/pricing` | `pricing` + `read` |
| `exchange-rates` | `exchangeRatesMenuTitle` | `Icons.currency_exchange_outlined` / `Icons.currency_exchange` | `/exchange-rates` | `exchangeRates` + `read` |

Visibility is resolved by `navDestinationsProvider`'s access filter — the
`AppNavigation` widget never calls `can(...)` (spec 010 contract). A user with
none of the three privileges sees no new entries; the `catalogs` group itself
is dropped only if *all* its children are filtered out.

## RBAC gating

All three `SystemObject` values **already exist** in
`lib/core/access/system_object.dart` — this feature adds **no** RBAC plumbing.

| Surface | SystemObject | Value | Rights used |
|---|---|---|---|
| Price-lists catalog | `SystemObject.priceLists` | `5` | `read`, `create`, `update`, `delete` |
| Pricing tool | `SystemObject.pricing` | `106` | `read`, `update` |
| Exchange rates | `SystemObject.exchangeRates` | `43` | `read`, `create`, `update`, `delete` |

**Why pricing is gated by `pricing` (106), not `priceLists` (5) or `products`
(0)**: per `mbe/docs/constants.md`, `106 | Pricing` is the "Price management /
pricing tool" object, distinct from `5 | PriceLists` (the list catalog) and
`0 | Products`. A user may therefore price products without being able to edit
list definitions or products themselves. Confirmed with the product owner
2026-07-14.

**Create/update on the pricing screen**: spec FR-009 (create a missing price
row) and FR-010 (update an existing one) are both user-visible as "set the
price", one control. Both are gated by `pricing` + **`update`** — the
create/update split is an API artifact (research.md §5), not a privilege
distinction the user should feel. A user with `update` but not `create` on
object 106 can still set a first price.

## Per-constitution §VI list-screen conventions

The two catalog screens (`/price-lists`, `/exchange-rates`) MUST follow the
shared contract already implemented by `/products`:

- Shared `DataTableView` (`core/widgets/data_table_view.dart`) — row hover,
  borders, header alignment (text left, numeric/currency **right**, actions
  centered).
- Mandatory `CatalogPagination` (`core/widgets/catalog_pagination.dart`).
- Mandatory filtering via `CatalogFilterBar` / `CatalogSearchBar`.
- Exactly **one** row action — Edit — from `catalog_action_icons.dart`; hidden
  (not disabled) without `update`.
- Whole-row click → **read-only** detail view; Create is toolbar-only; Delete
  lives in the detail form body as a warning-styled button (feature 007's
  FR-014/FR-015 pattern).
- Detail forms use `ResponsiveFormGrid` (`core/widgets/responsive_form_grid.dart`).

`/pricing` is a **tool**, not a catalog list, so the row-action/row-click
conventions do not apply to its price rows (each row is an inline-editable
price, not a navigable record). It still uses `DataTableView` for the price
table and the shared product picker
(`core/widgets/catalog_entity_picker.dart`) for selection, and its numeric
columns are right-aligned per §VI.
