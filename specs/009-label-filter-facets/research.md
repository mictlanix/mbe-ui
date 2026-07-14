# Phase 0 — Research: Faceted Label Filtering

All Technical Context items are resolved; no `NEEDS CLARIFICATION` remain. Decisions below are recorded as Decision / Rationale / Alternatives.

## §1 — Source of label availability

**Decision**: Fetch availability from a new dedicated endpoint, `GET /api/v1/products/labels/facets` ([mictlanix/mbe-api#78](https://github.com/mictlanix/mbe-api/issues/78)), which takes the same filter query params as the products list (no `skip`/`limit`) and returns `[{label_id, count}]` for the labels present across the entire matching product set.

**Rationale**: The client only holds one 20-item page of `GET /api/v1/products`, so it cannot derive cross-page co-occurrence (spec FR-009). A dedicated endpoint keeps the payload minimal (≤ one row per label, not per product) and keeps the list response lean — the performance-conscious option the user asked for. One grouped query server-side (`product_label` joined against the filtered product set) answers it.

**Alternatives considered**:
- *Embed `label_facets` in the `GET /products` list response* — one round-trip, but inflates every page with a facet payload the caller doesn't always need, and couples facet freshness to pagination. Rejected on performance/coupling grounds (this was the explicit A/B decision with the user).
- *Compute client-side from the current page* — impossible; only 20 of N products are present. Rejected.

## §2 — Label filter semantics (AND)

**Decision**: Rely on the existing AND ("contains all") semantics; no code change. Correct mbe-ui's stale "OR" docstrings/comments so documentation matches reality.

**Rationale**: mbe-api's `list_products` already restricts to products carrying *all* requested labels via `.having(func.count(func.distinct(product_label.c["label"])) == len(label))` (commit `bc80335`, 2026-07-05), and `ProductRepositoryImpl.list` already forwards every selected `label`. So end-to-end filtering is already AND; the only inaccuracy is the docstring on `ProductRepository.list` (and the `activeFilterCount` note) still saying "OR". Faceted narrowing only makes sense under AND, so this is the correct and already-satisfied foundation.

**Alternatives considered**: *Introduce an AND mode toggle / keep OR* — rejected; AND is already the shipped behavior and is what the feature needs.

## §3 — Availability data model

**Decision**: Reduce the facet response to a `Set<int>` of available label ids for the drawer's enable/disable logic, while keeping the raw `{labelId, count}` in a `ProductLabelFacet` domain entity for potential future count display.

**Rationale**: The UI's v1 requirement (FR-003/FR-004) is purely enable/disable — a chip is enabled iff its id is in the available set (or already selected, see §5). A `Set<int>` gives O(1) membership per chip. Counts are carried in the entity so a later "show count on chip" enhancement needs no contract change.

**Alternatives considered**: *Map<int,int> id→count everywhere* — carries counts the v1 UI ignores; the provider still exposes the set for the picker. We keep both: entity list from the repo, set derived in the provider.

## §4 — Provider shape and lifecycle

**Decision**: Expose availability via an `@riverpod` **autodispose** `productLabelFacetsProvider` returning `AsyncValue<Set<int>>`, built by `ref.watch(productFilterControllerProvider)` → `productRepository.productLabelFacets(...)`.

**Rationale**: Watching the filter makes Riverpod refetch on every discrete filter change (label toggle, attribute toggle, submitted search) — exactly the recompute trigger in FR-003. Autodispose means the request fires **only while `_ProductFiltersPanel` is mounted** (the drawer is a separate sheet route), so closing the drawer stops facet traffic and reopening refetches for the current filter — matching the performance goal. It parallels the existing `productsListController`, which already refetches on filter change, so list + facets update together.

**Alternatives considered**:
- *Manual debounce in the provider* — unnecessary: search is applied `onSubmitted` (not per keystroke) and attribute/label toggles are discrete, so each change is already one fetch. No extra debounce added.
- *Keep-alive (non-autodispose) provider* — would keep fetching on filter changes even when the drawer is closed and the availability is unused. Rejected for wasted requests.

## §5 — Fail-open and selected-label handling

**Decision**: A chip is **enabled** iff it is already selected **or** its id is in the available set. When the provider is loading or errored (no set available), treat availability as absent and enable **all** chips.

**Rationale**: FR-006 requires selected labels to stay interactive so they can be deselected even if nothing further narrows; OR-ing "selected" into the enabled condition guarantees that. FR-010 requires the drawer to fail open — a facet lookup failure or in-flight state must never strand the user with disabled chips or block filtering; passing a `null` availability set to the picker restores today's all-enabled behavior. The applied filter (list query) is independent of the facet query, so filtering keeps working regardless.

**Alternatives considered**: *Disable chips while loading / show a spinner over the label section* — worse UX and risks the "stuck disabled" trap FR-010 forbids. Rejected.

## §6 — Shared picker extension vs. fork

**Decision**: Extend the existing `core/widgets/label_multi_picker.dart` with an optional `availableIds` (`Set<int>?`) parameter rather than creating a filter-only picker variant.

**Rationale**: `LabelMultiPicker` is shared by the products list filter drawer *and* the product form / detail screen. Adding an optional, nullable availability set is backward-compatible: callers that omit it (the product form) keep every chip enabled, while the filter drawer passes the set. Constitution §VI favors shared `core/widgets/` components over per-screen reimplementations.

**Alternatives considered**: *New `FacetedLabelPicker` widget* — duplicates the `Wrap`/`FilterChip` layout and diverges over time. Rejected.

## §7 — Localization / new copy

**Decision**: Add at most one new `.arb` key — a tooltip for disabled chips (e.g. es: "Sin productos que coincidan", en: "No matching products") — if a tooltip is used; the disabled visual state itself needs no new string.

**Rationale**: No hardcoded strings (§V). A disabled `FilterChip` is self-evident visually, but a tooltip aids discoverability of *why* it's disabled; it is optional and, if added, localized in `app_es.arb` (default) + `app_en.arb`.

**Alternatives considered**: *No tooltip* — acceptable; the greyed state communicates unavailability. Final choice deferred to implementation, but the key is reserved here so copy isn't hardcoded later.
