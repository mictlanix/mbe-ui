# Phase 1 Data Model: Catalog UI/Layout Improvements

This feature introduces **no persisted entities and no API DTOs**. It reuses existing
in-memory UI state. This document records the only state-shape change: a derived projection
on the existing `ProductFilter`.

## Reused state (unchanged shape)

### ProductFilter (existing — `products_list_controller.dart`)

Existing freezed value object, unchanged fields:

| Field | Type | Default | Meaning |
|---|---|---|---|
| `search` | `String` | `''` | Free-text search (own visible box; not a badge facet) |
| `deactivated` | `bool?` | `null` | `null` = include inactive; `false` = active only |
| `stockable` | `bool?` | `null` | Tri-state facet |
| `salable` | `bool?` | `null` | Tri-state facet |
| `purchasable` | `bool?` | `null` | Tri-state facet |
| `label` | `int?` | `null` | Selected label id, or none |

### ProductFormState (existing — `product_form_controller.dart`)

Unchanged. The responsive grid and photo-row are pure layout over the existing fields; no
form-state fields are added, removed, or retyped.

## New derived projection (no new stored state)

Added to `ProductFilter` as pure getters (computed from existing fields):

| Member | Type | Definition |
|---|---|---|
| `activeFilterCount` | `int` | Count of facets in a **non-default / narrowing** state. |
| `hasActiveFilters` | `bool` | `activeFilterCount > 0` |

**`activeFilterCount` definition** (each contributes 1 when true):

- `deactivated == false` → user narrowed to *active only* (the "Show inactive" toggle is
  **off**). At the app default `deactivated == null` (inactive included) this contributes 0,
  so a freshly-loaded list shows **no badge**.
- `stockable != null`
- `salable != null`
- `purchasable != null`
- `label != null`

`search` is deliberately excluded (it has its own always-visible field).

> Rationale for the `deactivated` rule: the current default `ProductFilter()` has
> `deactivated == null` ("show inactive included"). To avoid a badge that is lit at defaults,
> the facet counts as active only when the user has *changed it away from the default* by
> switching to active-only (`false`). This keeps SC-002 ("tell at a glance whether filters
> are active") truthful: no badge at rest, badge when the user has narrowed results.

## New reset behavior (composed from existing mutators)

A **Clear all** action resets every facet to default. Implemented either as:

- a single `ProductFilterController.reset()` that sets
  `state = ProductFilter(search: state.search)` (preserves the search text, clears facets), or
- successive calls to the existing per-facet mutators.

Preferred: a small `reset()` that preserves `search` — clearing facets only, since the search
box stays visible and is not part of the panel. This is a thin composition over `copyWith`,
not new state (FR-014-compliant).

## UI-only ephemeral state (not modeled in Riverpod)

- **Filter sheet open/closed**: a `Navigator` route (`showModalBottomSheet` /
  `showGeneralDialog`), transient, not application state.
- **Responsive column count / current tier**: derived per-frame from
  `LayoutBreakpoints.tierOf(width)` inside `LayoutBuilder`; not stored.

## Breakpoint model change (`core/layout/breakpoints.dart`)

`LayoutTier` enum gains a `large` member; `LayoutBreakpoints` gains `large = 1200`. Purely a
threshold/type extension — no data flows through it beyond the existing width→tier mapping.

| Tier | Width range | Grid columns (max) | Product form columns |
|---|---|---|---|
| `compact` | `< 600` | 1 | 1 |
| `medium` | `600 – 839` | 2 | 2 |
| `expanded` | `840 – 1199` | 2 | 2 |
| `large` | `>= 1200` | 3 | 2 (capped via `maxColumns: 2`) |

The shared `ResponsiveFormGrid` still derives up to three columns at the `large` tier for
any future consumer, but the **product detail form** passes `maxColumns: 2` so it never
exceeds two columns (paired fields read better than three narrow ones). See FR-009.
