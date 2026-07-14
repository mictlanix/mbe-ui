# Feature Specification: Faceted Label Filtering

**Feature Branch**: `009-label-filter-facets`

**Created**: 2026-07-12

**Status**: Implemented and verified (T001–T021 complete). T019's live integration test and T020's manual quickstart validation both ran against a real mbe-api instance with #78 deployed: `test/integration/product_label_facets_flow_test.dart` passed 3/3 discovering a real co-occurring label pair and cross-checking facet counts against `list()`'s narrowed results; a manual browser walkthrough selecting "PLOMERIA" in the products filter drawer showed "ROTOPLAS" — the one label the live facets endpoint reported as co-occurring — remain enabled while every other label (AKSI, BOSCH, MAKITA, TRUPER, …) rendered disabled, matching the API-level result exactly.

**Input**: User description: "Enhance products' filtering by label. Enable/disable labels on the product filters drawer accordingly after filtering is done. Ex. selecting a label named 'Trupper' should update each label's enabled state based on which other labels can still be applied afterwards."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Narrow products by combining labels (Priority: P1)

A catalog user opens the products list filter drawer and picks a label (e.g. "Trupper"). The list narrows to products carrying that label. When the user picks a second label, the list narrows further to only the products that carry **both** labels — combining labels tightens the result set instead of widening it.

**Why this priority**: This narrowing behavior is what the drawer's enable/disable feedback in Story 2 computes against. AND ("match all selected labels") is already implemented server-side (mbe-api since 2026-07-05) and mbe-ui already sends every selected label, so end-to-end filtering is already AND — this story confirms and hardens that behavior (including correcting mbe-ui's stale "OR" docstrings) rather than introducing it. It delivers standalone value: precise multi-label drill-down.

**Independent Test**: With a catalog where product P1 has labels {A, B} and product P2 has labels {A}, select label A → both P1 and P2 appear; then also select label B → only P1 appears.

**Acceptance Scenarios**:

1. **Given** the products list with no filters, **When** the user selects one label, **Then** only products carrying that label are listed.
2. **Given** one label already selected, **When** the user selects a second label, **Then** only products carrying both selected labels are listed (the result set is a subset of, or equal to, the single-label result).
3. **Given** two labels selected, **When** the user deselects one, **Then** the list broadens back to products carrying the remaining selected label.

---

### User Story 2 - See which labels still narrow the results (Priority: P2)

After each change to the filter (selecting/deselecting a label, editing the search text, or toggling an attribute filter), every label chip in the drawer updates its enabled state: a label stays enabled only if at least one product in the *current* filtered result set also carries it; otherwise the chip is shown disabled/greyed. This guides the user toward only the labels that would further narrow what they are already looking at, and prevents them from reaching an empty result by combining incompatible labels.

**Why this priority**: This is the requested UX enhancement. It builds directly on Story 1's narrowing semantics and turns the drawer into a guided, dead-end-free faceted filter. High value, but depends on Story 1 being in place.

**Independent Test**: With product P1 = {Trupper, DeWalt} and product P2 = {Trupper}, and no other products, select "Trupper" → the "DeWalt" chip remains enabled (P1 has both) while any label carried by no Trupper product (e.g. "Makita") is disabled. Selecting "DeWalt" leaves only P1; labels not on P1 are now disabled.

**Acceptance Scenarios**:

1. **Given** a label is selected, **When** the drawer re-renders, **Then** labels carried by at least one product in the current result set are enabled and all other labels are disabled.
2. **Given** the current filter yields a set of products, **When** the user selects an **enabled** label, **Then** the resulting list is non-empty (selecting an enabled label never produces zero results).
3. **Given** the user edits the search box or toggles an attribute filter, **When** the result set changes, **Then** the label chips' enabled states recompute to match the new result set.
4. **Given** an already-selected label, **When** the drawer re-renders, **Then** that label remains interactive so it can be deselected, regardless of the availability of the remaining labels.

---

### User Story 3 - Recover and reset the label selection (Priority: P3)

The user can always undo their way back out of a narrow filter: deselecting a label broadens the results and re-enables the labels that become applicable again, and "Clear all" removes every label selection (alongside the other facet filters) and restores the full, all-labels-enabled drawer.

**Why this priority**: Safety/recoverability. The primary flows work without it, but users need a friction-free way to widen again after over-narrowing.

**Independent Test**: Select two labels down to a single product, deselect one → previously-disabled labels that now co-occur become enabled again; press "Clear all" → all label selections clear and every label that appears on any product in the (otherwise-filtered) catalog is enabled.

**Acceptance Scenarios**:

1. **Given** several labels selected, **When** the user deselects one, **Then** labels that co-occur with the remaining selection become enabled again.
2. **Given** any label selection, **When** the user presses "Clear all", **Then** all selected labels are cleared and the drawer returns to its default all-enabled state (subject to any remaining search/attribute filters).

---

### Edge Cases

- **No labels in the catalog**: the label section is absent (unchanged from today); the feature adds nothing to render.
- **First open, no filters applied**: every label that appears on at least one product (within any active search/attribute filter) is enabled; labels carried by no matching product are disabled.
- **Availability data unavailable/slow** (backend facet lookup fails or is in flight): the drawer MUST fail open — labels remain selectable rather than becoming stuck-disabled — so a lookup failure never blocks filtering. The applied filter itself still works.
- **Selected label with no further co-occurring labels**: the selected label stays selected and interactive; all other labels are disabled because no product narrows further. The list still shows the current result.
- **Search/attribute filters combined with labels**: label availability is computed against the full current filter (search + attributes + already-selected labels), not against the whole catalog.
- **Pagination**: availability reflects the entire filtered result set, not just the current page of results.
- **Stale/removed label**: a label that no longer applies to any matching product is disabled, never shown as a dead-end enabled chip.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The products list label filter MUST use AND semantics — a product matches only if it carries **all** selected labels. This is already the server's behavior (mbe-api implemented "contains all" semantics on 2026-07-05) and mbe-ui already sends every selected label; this feature confirms/relies on it and MUST correct mbe-ui's stale "OR" docstrings/comments so the documented behavior matches reality. No backend change is required for the AND semantics.
- **FR-002**: Selecting an additional label MUST narrow the result set to the intersection; the resulting list MUST be a subset of (or equal to) the pre-selection list.
- **FR-003**: After every filter change (label select/deselect, search text change, or attribute-filter toggle), each label chip's enabled state MUST reflect whether at least one product in the current filtered result set also carries that label.
- **FR-004**: A label carried by no product in the current filtered result set MUST be rendered disabled and MUST NOT be selectable.
- **FR-005**: Selecting any enabled label MUST always yield a non-empty result set (no dead-end selections).
- **FR-006**: Already-selected labels MUST remain interactive so the user can deselect them, independent of the remaining labels' availability.
- **FR-007**: Deselecting a label MUST broaden the result set and MUST recompute label availability accordingly.
- **FR-008**: The existing "Clear all" action MUST clear all selected labels and restore the drawer's default all-labels-enabled state (subject to any remaining search/attribute filters).
- **FR-009**: Label availability MUST be computed against the entire filtered result set across all pages, not only the products visible on the current page.
- **FR-010**: If the label-availability data cannot be obtained (lookup failure or still loading), the drawer MUST fail open — all labels remain selectable — so filtering is never blocked.
- **FR-011**: The active-filter count/badge and other existing drawer behaviors (search box, attribute chips, responsive bottom-sheet/side-sheet presentation) MUST continue to work unchanged; each selected label continues to count individually.
- **FR-012**: Access to the products list and its filter drawer MUST remain gated by the same RBAC privilege as today; this feature adds no new privilege and no new screen.

### Key Entities *(include if feature involves data)*

- **Label availability**: for the current filter selection (search + attribute filters + already-selected labels), the set of label identifiers that appear on at least one matching product, with the count of matching products per label. Drives which chips are enabled and (optionally) any count shown. Recomputed whenever the filter changes.
- **Product label filter selection**: the set of labels the user has chosen, interpreted with AND semantics. Part of the existing products-list filter state.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After any filter change, 100% of labels that would return zero products when added are shown disabled and cannot be selected.
- **SC-002**: Selecting any enabled label never produces an empty result set (0 dead-end selections in testing across representative catalogs).
- **SC-003**: Combining N labels returns exactly the products that carry all N labels, verified against known fixture data.
- **SC-004**: The drawer's label enabled/disabled states refresh within 1 second of a filter change for a typical catalog.
- **SC-005**: A user can always broaden again — deselecting a label or pressing "Clear all" re-enables the labels that become applicable — in a single interaction.
- **SC-006**: A failure to load availability data never leaves the user unable to apply or change a label filter (filtering degrades gracefully to all-enabled).

## Assumptions

- **AND semantics already in place**: the products-list label filter already matches products carrying *all* selected labels — mbe-api implemented "contains all" semantics on 2026-07-05 and mbe-ui already sends every selected label. FR-001 therefore confirms existing behavior and corrects mbe-ui's stale "OR" docstrings; it is **not** a new behavior change and needs no backend work.
- **Scope is the products list filter drawer only** — no other catalog/list screen's filtering is changed by this feature.
- **External backend dependency (mbe-api)**: the client cannot compute cross-page label co-occurrence because it only holds the current page of results. This feature depends on **one** mbe-api change, filed as [mictlanix/mbe-api#78](https://github.com/mictlanix/mbe-api/issues/78) and tracked as an external dependency in the plan (per the repo-boundary rule): a dedicated, lightweight label-facets lookup (`GET /api/v1/products/labels/facets`) that, given the same filter parameters as the products list, returns the label identifiers (with per-label match counts) present in the matching products. mbe-ui consumes it once it ships upstream and the client is regenerated.
- **Reuses existing building blocks**: the existing label lookup, the filter drawer, the label chip control, and the products-list filter state are extended rather than replaced.
- **Localization & design**: all new/changed copy is added to the existing `es-MX` (default) and `en` resources; the drawer stays Material 3 and keeps its current responsive presentation.
- **Online-only**: availability data is fetched live from mbe-api; nothing is cached or persisted locally.
