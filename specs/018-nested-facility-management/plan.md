# Implementation Plan: Nested Facility Management

**Branch**: `018-nested-facility-management` | **Date**: 2026-07-26 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/018-nested-facility-management/spec.md`

## Summary

Four sibling catalogs — Facilities, Warehouses, Cash Drawers, Points of Sale —
collapse into one. Facilities keeps its navigation entry; the other three lose
theirs and their list screens, and are managed from inside an expandable
facility card that shows each site's full shape.

No backend change, no codegen, no new dependency. The work is shaped by four
findings in [research.md](./research.md), two of which contradict a naive reading
of the spec:

1. **One family provider, and a non-lazy list** (research §1). The existing
   `facilitiesListControllerProvider(filter)` is untouched — search, status facet,
   pagination and page-clamping all carry over from spec 017 for free. A new
   `facilityChildrenControllerProvider(facilityId)` family holds each card's
   children, so a save invalidates exactly one card instead of refetching the
   page. Eager loading (FR-017) then falls out of rendering the cards
   **non-lazily**: a `ListView.builder` would leave off-screen cards unwatched and
   their counts would pop in during scroll. That detail is load-bearing, not
   stylistic.

2. **FR-018 is partly wrong and FR-011 wins** (research §2). mbe-api does not
   enforce that production sites have no points of sale or cash drawers — no
   validation exists in `point_sale_service.py` or `cash_drawer_service.py`, and
   this catalog is populated by a migration from the legacy C# monolith. So "don't
   request child types that cannot exist for this facility type" would make
   FR-011's escape hatch unimplementable. All three types are requested for every
   facility; a production site's extra sections render only when non-empty.

3. **The cross-facility POS badge is a legacy-data affordance** (research §3).
   `point_sale_service.py:71` rejects a warehouse belonging to a facility other
   than the point of sale's, on create *and* update. The badge the mock shows can
   only ever appear on rows migrated from the monolith. It is kept — the mock's own
   sample data proves such rows exist, and the check is a set lookup — but nothing
   in the layout should be optimized for it.

4. **Three route guards must survive the deletion** (research §4). The guards in
   `_gateFor` match on `startsWith('/warehouses')` and therefore gate
   `/warehouses/:warehouseId` as well as `/warehouses`. Deleting them alongside the
   list screens is the intuitive move and would silently strip route-level RBAC
   from every surviving child record screen — with no crash and no failing test.
   This is the highest-risk edit in the feature.

Two smaller consequences the spec did not anticipate and this plan absorbs:

- **Moving a record between facilities needs an `originalFacilityId`** (research
  §6). Without it, a warehouse moved from A to B refreshes B's card and stays
  visibly rendered under A.
- **The three removed menu labels are reused, not orphaned** (research §8). Their
  l10n keys become the child-section headers — the mock's section titles are
  already exactly those strings.

Net: 4 new files, 6 deleted (plus generated companions), and edits to the router,
nav tree, four form controllers, three detail screens, both `.arb` files and the
Facilities screen itself.

## Technical Context

**Language/Version**: Dart 3.x / Flutter (stable)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_generator`, `go_router`,
`freezed`, `dio` via the generated `mbe_api_client`, `flutter_localizations`/`intl`.
**No new dependency.**

**Storage**: N/A — online-only, all reads and writes go to mbe-api (constitution §VII)

**Testing**: `flutter_test` (unit + widget), `integration_test` against a live
mbe-api

**Target Platform**: Web (Chrome) primary, macOS/desktop; compact tier at < 600 px

**Project Type**: Single Flutter application, feature-first layering

**Performance Goals**: Expanding a card is instantaneous (children already
resident). First paint of a facilities page issues 1 + 3 × pageSize requests —
up to 61 at pageSize 20.

**Constraints**: mbe-api caps every list request at 100 records
(`limit: Query(20, ge=1, le=100)`); no backend change is in scope; the
`NavBranch` ↔ router build-order invariant has no compile-time enforcement.

**Scale/Scope**: 1 screen rewritten, 3 screens deleted, 3 detail screens extended,
4 form controllers edited, 20 facilities per page.

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1 design. Both passes
below.*

| Principle | Assessment |
|---|---|
| **I. Feature-First Layered Architecture** | PASS. `FacilityChildren` is a freezed entity in `domain/entities/`; the controller sits in `presentation/`; the three new widgets in `presentation/widgets/`, matching the existing `merge_*.dart` convention. `presentation` reaches `data` only through existing repository providers, as every sibling screen does. |
| **II. Riverpod for State & DI** | PASS. New state is a `@riverpod` family exposing `AsyncValue`. Expansion state is view-local `State` in a `StatefulWidget` — deliberately not a provider (data-model §4): it must not survive a reload and has no consumer outside the screen. Constitution §II names form state and selections as local UI state, which this is. |
| **III. Contract-Driven API Integration** | PASS. No codegen, no new DTO, no hand-written model, no mbe-api edit. All access goes through existing repositories and their existing `facilityId` filters. Errors continue to surface as domain error types through `ErrorBanner`. |
| **IV. Deny-by-Default RBAC** | PASS, with the feature's main risk. Every action is gated per `SystemObject` and hidden rather than disabled (contracts/ui-contracts.md §4); an unreadable section is absent and contributes no count. The risk is the §5 guard deletion in contracts/routes.md, which this plan mitigates with an explicit test asserting `/warehouses/5` redirects for a user without `warehouses:read`. |
| **V. Material 3, White-Labeled** | PASS. All color/elevation/typography from `Theme.of(context)`; no hex from the mock reaches Dart (FR-030). Every new string localized in both `.arb` files, `es-MX` authored first. |
| **VI. Desktop/Web-First, Compact-Ready** | PASS, with one deliberate divergence, below. |
| **VII. Online-Only** | PASS. No caching layer beyond Riverpod's ordinary provider lifetime; no offline storage; no client-side document rendering. |

### §VI in detail

| Rule | How this feature satisfies it |
|---|---|
| Breakpoints centralized in `core/` | Uses `LayoutBreakpoints.isCompact`; no new breakpoint constant. |
| Shared widgets in `core/widgets/` | Reuses `CatalogFilterBar`, `CatalogSearchBar`, `CatalogListStateView`, `EntityStatusCell`, `CatalogAction` icons, pagination, `RecordFormActions`. |
| Mandatory pagination | Facilities stay paginated. Child sections are exempt under the "provably bounded" clause — bounded by one facility's children, and loaded to completion (FR-019). |
| Mandatory filtering | Search box and status facet retained unchanged. |
| Edit is the primary row action, from shared iconography | Each card header and child row exposes exactly one action, `CatalogAction.edit`. |
| At most two row icons | Every row has exactly one. No overflow menu is introduced. |
| Row click opens read-only | Card headers and child rows both push `?view=true`. |
| Create is toolbar-only; Delete lives on the detail screen | Facility create is in the toolbar (FAB on compact). Child create is a **section-level** action, not a row action — see divergence. Delete appears nowhere in the tree. |
| No horizontal scroll; tooltip on truncation; never truncate critical info | Contracts §6: wrap or ellipsize-with-tooltip; code, name and status never truncated. |
| `AppBar.actions` empty on detail screens | Unchanged — this feature adds no app-bar action. |

**Deliberate divergence — "Create remains a toolbar-only action".** Constitution
§VI bans Create as a *row* action, to keep a per-row control set of at most two
icons. This feature places a create action in each child **section header**
("+ Almacén"), which is neither a row nor the screen toolbar. It is recorded in
Complexity Tracking rather than waved through.

### Post-Phase-1 re-evaluation

Re-checked after data-model.md and the two contracts were written. No new
violation. Two choices decided during Phase 1 are worth restating:

- Requesting all three child types for every facility (research §2) increases
  request volume beyond what FR-018 envisaged. It touches no principle — §VII
  concerns caching, not request count — and the alternative was an unimplementable
  requirement.
- `FacilityChildren` carries three `*Readable` booleans so a widget can tell "none
  exist" from "you may not see them" without re-reading access control. This keeps
  RBAC resolution at the data-composition boundary rather than scattering
  `can(...)` calls through the widget tree, which serves §IV rather than bending it.

## Project Structure

### Documentation (this feature)

```text
specs/018-nested-facility-management/
├── plan.md              # This file
├── spec.md
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/
│   ├── routes.md        # Nav destinations, branch renumbering, guards
│   └── ui-contracts.md  # Widget tree, keys, RBAC, l10n
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 — created by /speckit-tasks, not here
```

### Source code

```text
lib/
├── app/router/
│   └── app_router.dart                          # M  −3 branches, +?facility= parsing, guards KEPT
├── core/navigation/
│   └── nav_destinations.dart                    # M  −3 destinations, NavBranch renumbered
├── features/catalog/
│   ├── domain/entities/
│   │   └── facility_children.dart               # +  freezed aggregate
│   └── presentation/
│       ├── facilities_list_screen.dart          # M  rewritten as the hierarchy
│       ├── facility_children_controller.dart    # +  family keyed by facilityId
│       ├── warehouses_list_screen.dart          # −
│       ├── warehouses_list_controller.dart      # −  (+ .freezed.dart, .g.dart)
│       ├── cash_drawers_list_screen.dart        # −
│       ├── cash_drawers_list_controller.dart    # −  (+ generated)
│       ├── points_of_sale_list_screen.dart      # −
│       ├── points_of_sale_list_controller.dart  # −  (+ generated)
│       ├── warehouse_form_controller.dart       # M  originalFacilityId, invalidation
│       ├── cash_drawer_form_controller.dart     # M  same
│       ├── point_sale_form_controller.dart      # M  same
│       ├── facility_form_controller.dart        # M  also invalidate that facility's children
│       ├── warehouse_detail_screen.dart         # M  facilityId prefill
│       ├── cash_drawer_detail_screen.dart       # M  same
│       ├── point_sale_detail_screen.dart        # M  same
│       └── widgets/
│           ├── facility_card.dart               # +
│           ├── facility_child_section.dart      # +
│           └── facility_child_row.dart          # +
└── l10n/
    ├── app_en.arb                               # M  +11 keys
    └── app_es.arb                               # M  +11 keys

test/
├── unit/app/router/app_router_test.dart         # M  renumbering + guard-survival assertions
├── widget/core/widgets/app_navigation_test.dart # M  three fewer destinations
├── widget/features/catalog/
│   ├── facilities_list_screen_test.dart         # M  rewritten
│   ├── warehouses_list_screen_test.dart         # −
│   ├── cash_drawers_list_screen_test.dart       # −
│   ├── points_of_sale_list_screen_test.dart     # −
│   └── *_detail_screen_test.dart                # M  prefill coverage
└── integration/
    ├── facility_catalogs_flow_test.dart         # M  drives the tree, not the lists
    └── navigation_shell_flow_test.dart          # M  branch indices
```

**Structure Decision**: Existing feature-first layout under
`lib/features/catalog/`, unchanged. New widgets go in the already-established
`presentation/widgets/` subfolder. Nothing new is added to `core/` — the facility
hierarchy is domain-specific and has exactly one consumer, so promoting it to a
shared widget would be speculative.

## Implementation Phases

Ordered so every intermediate state is shippable, and so the destructive step
lands only after the replacement is complete. This maps to the spec's user-story
priorities.

**Phase 1 — data foundation (no user-visible change).** `FacilityChildren` entity
and `facilityChildrenControllerProvider`, including the complete-the-collection
loop (FR-019) and the `*Readable` flags. Unit-tested against a fake repository.
*Verify*: new unit tests pass; app unchanged.

**Phase 2 — the hierarchy view (US1).** Rewrite `facilities_list_screen.dart` and
add the three widgets. Wide tier only, read-only: no create/edit wiring yet.
*Verify*: quickstart Gate 1, including the scroll check for eager loading.

**Phase 3 — wiring CRUD (US2).** `?facility=` parsing, the three detail-screen
prefills, `originalFacilityId` on three form states, repointed
`_invalidateCaches`. *Verify*: quickstart Gate 2, especially the
move-between-facilities case.

**Phase 4 — navigation consolidation (US3).** Delete the three list screens,
controllers and branches; renumber `NavBranch`; **keep the three guards**; update
router and navigation tests. *Verify*: quickstart Gate 3, both assertions.

**Phase 5 — compact tier (US4).** Density branching and the FAB.
*Verify*: quickstart Gate 4.

Phases 1–2 deliver the spec's P1 story on their own. Phase 4 is deliberately last:
until it lands, the old screens remain as a fallback.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| Create action in a child **section header**, where constitution §VI says "Create remains a toolbar-only action" | The screen manages four entity types at once. A single toolbar Create cannot express *which* child type, under *which* facility — the parent context is the entire value of the feature (FR-022, SC-001). The section header is the only place carrying both. | *One toolbar Create with a type+facility chooser*: reintroduces the facility re-selection this feature exists to remove. *A create icon on each row*: genuinely violates the row-action rule and attaches "create" to the wrong scope. The rule's purpose — bounding per-row icon count — is untouched: rows still carry exactly one icon. |
| Up to 61 requests on first paint of a facilities page | FR-006/FR-017 require accurate counts on collapsed cards, and the facilities projection carries no counts. Eager per-page loading was chosen by the requester over lazy loading. | *Lazy on expand*: cannot show collapsed counts at all. *Child counts on the facilities projection*: the correct end state, but needs an mbe-api change, which is out of scope. The mitigation lever if it hurts in practice is a smaller facilities page size, not a switch to lazy. |
| All three child types requested even for production sites, contradicting FR-018's first clause | mbe-api does not enforce the type rule (research §2), so a production site with points of sale is representable data. Not requesting them makes FR-011 unimplementable. | *Trust the type as an invariant*: it is a UI convention over legacy data, not a constraint — a migrated violating row would silently vanish from the only screen that can reach it. *Probe with `limit: 1` first*: two round-trips instead of one, to save a request that returns `total: 0`. |
