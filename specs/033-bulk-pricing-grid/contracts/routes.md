# Contract: Routes & Navigation

**Feature**: `033-bulk-pricing-grid`

## 1. Navigation — unchanged

The Pricing destination in `kNavigationTree`
(`lib/core/navigation/nav_destinations.dart:231`) keeps its id, label, icon,
`branchIndex` and `PrivilegeGate(SystemObject.pricing, AccessRight.read)`. Only
what `/pricing` renders changes.

## 2. Routes

| Route | Before | After | Gate |
|---|---|---|---|
| `/pricing` | `PricingScreen(standalone: false)` — product picker + per-list table | **`PricingGridScreen`** | `PrivilegeGate(pricing, read)` — unchanged (`app_router.dart:701`) |
| `/products/:productId/pricing` | `PricingScreen(standalone: true)` | **unchanged** (spec CL-002, FR-028a) | `PrivilegeGate(pricing, read)` — unchanged (`app_router.dart:692`) |

`PricingScreen` loses its `standalone` parameter and its picker branch: it is now
only ever the pushed per-product screen (research R1). `initialProductId` becomes
required.

## 3. URL state

The grid follows the shared list-query contract (spec 017) so its address is
shareable and back/forward works:

```text
/pricing?search=clavo&status=active&salable=true&supplier=12&label=3&label=7&page=2
```

- `search`, `page` and every facet are read through `ListQuery.fromUri` and written
  by `context.go(query.toUri('/pricing'))`, exactly as the products list does.
- **Shown columns are not in the URL** — a view preference, not a narrowing
  (research R9).
- The worklist chip, when it ships with mbe-api#184, is one more facet
  (`missing=<priceListId>`), so it participates in the same back/forward and
  clear-all behaviour as everything else.

## 4. Clear-all

`onClearAll: () => context.go('/pricing')` — the same one-liner every catalog
screen uses. It clears filters and the worklist, and does **not** reset the shown
columns (they are not filters).
