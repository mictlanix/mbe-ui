# Phase 1 Data Model: Cross-Screen UX Consistency & Filtering Backfill

**Feature**: `017-ui-consistency-filters` | **Date**: 2026-07-25 | **Plan**: [plan.md](./plan.md)

This feature introduces **no business entity** and changes **no** mapping between a
generated DTO and a domain entity. Everything modeled here is view state and UI
contract. Three concepts are added; four existing domain repository interfaces gain
a parameter.

---

## 1. `ListQuery` — the addressable state of a list view

`lib/core/navigation/list_query.dart`. A `freezed` value decoded from a route's
`Uri` and passed into a list screen, replacing the mutable `XFilterController`
notifiers.

| Field | Type | Default | Notes |
|---|---|---|---|
| `search` | `String` | `''` | Free-text term. Empty means absent from the URL. |
| `pageIndex` | `int` | `0` | **Zero-based internally, one-based in the URL** (`page=3` → index 2). Page 1 is never written to the URL. |
| `facets` | `Map<String, List<String>>` | `{}` | Raw per-facet values, keyed by the facet's URL parameter name. A list so multi-valued facets (product labels) need no special case. |

**Derived**

- `bool get isFiltered` — `search.isNotEmpty || facets.isNotEmpty`. This is what
  distinguishes an empty catalog from an over-filtered one (FR-028) without any new
  state.
- `bool get isDefault` — `isFiltered == false && pageIndex == 0`; a default query
  produces a bare path with no query string (FR-020).

**Invariants**

- Decoding is **total**: no input `Uri` throws. Unparseable page numbers, unknown
  facet keys, and unparseable facet values are dropped (FR-021).
- `ListQuery.fromUri(q.toUri(base)) == q` for every query reachable through the UI —
  the round-trip property the unit test asserts.
- `ListQuery` is the **only** carrier of list view state. No notifier duplicates it.

Encoding rules, per-screen facet keys, and value formats: [contracts/list-query.md](./contracts/list-query.md).

---

## 2. Per-entity filter values — derived, not stored

Each entity keeps its existing `XFilter` `freezed` value (e.g. `WarehouseFilter`),
with three changes:

1. It gains `pageIndex`, so one value fully describes what to fetch.
2. It loses its display-text companion fields (`facilityDisplayText` and friends) —
   those are resolved for presentation, not carried as filter state (§4 below).
3. It gains `XFilter.fromQuery(ListQuery)` and `ListQuery toQuery()`.

Its `XFilterController` notifier is **deleted**. The value becomes the family
argument of the list controller:

```text
before:  XFilterController (mutable Notifier)  →  XListController.build()
after:   ListQuery (from route)  →  XFilter.fromQuery  →  XListController.build(XFilter)
```

The `activeFilterCount` / `hasActiveFilters` extensions used for the filter-button
badge move onto the filter value unchanged.

**Why this and not a notifier**: research §4. One direction of flow, so FR-019 ("the
address is the authority") is an invariant rather than a convention 18 screens must
each remember to honor.

---

## 3. `RecordFormActionsState` — the record's action set

`lib/core/widgets/record_form_actions.dart`. Not persisted; a description of what a
record screen may currently offer.

| Concept | Values | Source |
|---|---|---|
| Mode | `create` \| `view` \| `edit` | The screen: `create` when no id, `view` when read-only, `edit` otherwise. |
| `canEdit` | `bool` | `can(object, update) && mode == view && id != null` |
| `canSave` | `bool` | `mode == create ? can(object, create) : can(object, update)`, and never in `view` |
| `canDelete` | `bool` | `can(object, delete) && mode == edit` |
| `isSubmitting` | `bool` | The form controller's in-flight flag |

**Rendering rule** — fixed left-to-right, right-aligned, content-sized:

| Mode | Rendered |
|---|---|
| `create` | `[ Save ]` |
| `view` | `[ Edit ]` (omitted entirely without update privilege) |
| `edit` | `[ Delete ] [ Save ]` (Delete omitted entirely without delete privilege) |

An action the user lacks the privilege for is **absent**, never disabled — preserving
today's behavior exactly (FR-007, FR-038). Full contract:
[contracts/record-form-actions.md](./contracts/record-form-actions.md).

---

## 4. FK facet label resolution — presentation state, deliberately not filter state

A URL carries `facility=9`, not "Main Store". On a **cold** load (shared link,
bookmark, refresh) the picker would otherwise render blank while the results are
correctly filtered — failing FR-018.

| Aspect | Decision |
|---|---|
| Where it lives | Presentation-only, alongside the picker. Never part of `ListQuery` or `XFilter`. |
| How it resolves | The facet's own repository `get(id)` — all 14 catalog repositories already expose one. |
| While resolving | The picker shows a neutral placeholder, not a spinner-blocked control; results are already correct. |
| On failure | Fall back to displaying the raw id. Never block the list, never surface an error (FR-021's posture). |
| Warm navigation | No resolve — the label came from the picker selection that produced the URL. |

Affected facets: facility (warehouses, cash drawers, points of sale, payment method
options), warehouse (points of sale), price list + salesperson (customers), employee
(vehicle operators), supplier (products — new), labels (products — multi-valued),
currency base/target (exchange rates).

---

## 5. `ListPresentationState` — which feedback a list is showing

Not a stored type; the discrimination the shared views make (FR-027, FR-028).

| State | Condition | Recovery offered |
|---|---|---|
| `loading` | `AsyncValue.isLoading` with no previous data | none |
| `populated` | items present | n/a |
| `empty` | items empty **and** `!query.isFiltered` | "Create the first record" — only with the create privilege (FR-029) |
| `filteredEmpty` | items empty **and** `query.isFiltered` | "Clear filters" → navigate to the bare list path (FR-030) |
| `failed` | `AsyncValue.hasError` | "Retry" → re-fetch the same query unchanged (FR-032) |

`failed` renders the mapped `AppError` through `ErrorBanner`; the raw error object
never reaches a string (FR-031). Repositories already map `DioException` → `AppError`
via `_toAppError`, so the value carried by `AsyncValue.error` is already correct;
anything else degrades to `ServerError`.

---

## 6. Domain repository deltas

Four interfaces gain one parameter each. All four are **already accepted by the
generated client** — no backend dependency (research §5).

| Interface | Change |
|---|---|
| `VehicleRepository.list` | `+ EntityStatus? status` |
| `VehicleOperatorRepository.list` | `+ EntityStatus? status` |
| `UserRepository.list` | `+ EntityStatus? status` |
| `ProductRepository.list` | `+ int? supplier` |

All are **additive optional named parameters**, so no existing caller breaks — the
same additive posture spec 015 used when extending `TaxpayerIssuerRepository`. Their
`data/` implementations forward the value to the generated client and nothing else
changes; no DTO, no mapping, no entity is touched.

Per-screen facet matrix and the exact generated-client parameter each maps to:
[contracts/filter-backfill.md](./contracts/filter-backfill.md).

---

## 7. What is explicitly *not* modeled

- **No new entity, DTO, or generated-client change.** (FR-034)
- **No new `SystemObject`**; no RBAC model change. (FR-038)
- **No persistence of any kind** — no `shared_preferences`-backed sticky filters,
  no cache. URL state is address-bar state (constitution §VII).
- **No change to the `?view=true` record convention** — list state is added
  alongside it, using the same decode-in-the-route-builder shape (FR-023).
