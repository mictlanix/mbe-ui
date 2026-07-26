# Contract: `ListQuery` — URL encoding for list view state

**Feature**: `017-ui-consistency-filters` | Satisfies FR-017 – FR-023, FR-026

Defines how a list screen's search text, facets, and page are written to and read
from the route's query string. Defined **once** in `lib/core/navigation/list_query.dart`
and used by every list screen (FR-023).

## 1. Shape

```text
/<list-path>?search=<term>&page=<n>&<facet>=<value>[&<facet>=<value>…]
```

Consistent with the existing record convention `/<path>/<id>?view=true`
(`app_router.dart:276`): parameters are decoded **in the route builder** and passed
to the screen as constructor arguments, never read from `GoRouterState` inside the
screen.

## 2. Reserved parameter names

| Name | Meaning | Encoding |
|---|---|---|
| `search` | free-text term | percent-encoded UTF-8; omitted when empty |
| `page` | **one-based** page number | positive integer; omitted when 1 |
| `view` | reserved by the record convention | never used by a list |

Every other parameter is a facet, named per §4.

## 3. Value encoding by facet type

| Type | Encoding | Example |
|---|---|---|
| `EntityStatus` | lower-case enum name | `status=active`, `status=inactive`, `status=archived` |
| FK id (`int`) | decimal | `facility=9` |
| Multi-valued FK | repeated key | `label=3&label=7` |
| `bool` tri-state | `true` / `false`; omitted when null | `stockable=true` |
| `DateTime` (date only) | ISO-8601 date | `dateFrom=2026-07-01` |

Tri-state booleans must round-trip **all three** states — absent ≠ `false`. This
matches the tri-state filter convention already used for the product flags.

## 4. Per-screen facet keys

Keys are the API-facing concept name, not the Dart field name (so `driverId`
becomes `employee`, matching the server).

| Screen | Facet keys |
|---|---|
| Products | `status`, `stockable`, `salable`, `purchasable`, `label` (multi), **`supplier`** |
| Customers | `status`, `priceList`, `salesperson` |
| Employees | `status`, `salesPerson` |
| Warehouses, Cash Drawers, Payment Method Options | `facility`, `status` |
| Points of Sale | `facility`, `warehouse`, `status` |
| Facilities | `status` |
| Vehicle Operators | `employee`, **`status`** |
| Vehicles | **`status`** |
| Users | **`status`** |
| Exchange Rates | `dateFrom`, `dateTo`, `base`, `target` |
| Labels, Suppliers, Expenses, Price Lists, Taxpayer Recipients, Taxpayer Issuers | *(none — search only)* |

**Bold** = added by this feature (see [filter-backfill.md](./filter-backfill.md)).

## 5. Decoding rules — total, never throws (FR-021)

| Input | Result |
|---|---|
| unknown parameter name | ignored, dropped |
| unparseable value for a known facet | that facet ignored; the rest applied |
| `page` ≤ 0, non-numeric, or absent | page 1 |
| `page` beyond the result set | clamped to the last page **after** the count is known (FR-026) |
| repeated key on a single-valued facet | first value wins |
| percent-encoded / accented / reserved characters | round-trip intact via standard URI decoding |

A malformed address must still render a working list and must **not** surface an
error to the user.

## 6. Encoding rules

- **Defaults are omitted.** An unfiltered first page produces a bare path with no
  query string (FR-020).
- **Deterministic ordering**: `search`, then `page`, then facets in the order
  declared in §4 — so the same view always produces a byte-identical URL and is
  comparable in tests.

## 7. Navigation semantics

| Action | Call | Why |
|---|---|---|
| change search / facet / page | `context.go(newUri)` | `go` reports a new route to the platform, producing a browser history entry — this is what makes Back work (FR-022) |
| clear all filters | `context.go(barePath)` | FR-030 |
| open a record | `context.push(recordPath)` | unchanged; leaves the list mounted beneath (research §3) |

**Never** `context.replace` for a filter change — it overwrites history and breaks
FR-022.

No debounce is needed: `CatalogSearchBar` fires on submit, not per keystroke, so no
history entry is created per character.

## 8. Provider wiring

```text
route builder → ListQuery.fromUri(state.uri)
              → XListScreen(query:)
              → XFilter.fromQuery(query)          [includes pageIndex]
              → ref.watch(xListControllerProvider(filter))
```

The list controller is a **family keyed by the filter value**, so:

- a different URL is a different provider instance;
- `ref.invalidate(xListControllerProvider)` after a mutation re-runs `build` with the
  **same** page — which is what fixes the page-reset bug at no extra cost (FR-025,
  research §3).

Freezed value equality supplies the family key; no manual `==` is written.

## 9. Test obligations

- Round-trip: `fromUri(toUri(q)) == q` for every facet type in §3, including
  multi-valued, tri-state, and date facets.
- Default omission: a default query encodes to a bare path.
- Malformed input: each row of §5's table.
- Character safety: accented text, `&`, `#`, `+`, and spaces survive a round trip.
- Ordering: the same view always produces an identical URL string.
- **Branch preservation** (plan Phase 2 gate): `context.go` to the same
  shell-branch path with different query parameters updates the list in place
  rather than rebuilding or resetting the branch.
