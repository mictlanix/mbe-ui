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

2. **Facility type decides what is fetched, before any request** (research §2).
   Stores have warehouses, points of sale and cash drawers; production sites have
   warehouses only. This is a domain invariant, so a production site issues one
   child request instead of three and never builds the other two sections. Note
   that mbe-api does **not** enforce the invariant — no validation exists in
   `point_sale_service.py` or `cash_drawer_service.py` — so a migrated row that
   violates it would be invisible and, once the standalone lists are gone,
   unreachable. Checked against production data on 2026-07-26 and confirmed clean:
   no point of sale or cash drawer is attached to a production site (research §2).

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

Net: 5 new files, 6 deleted (plus generated companions), and edits to the router,
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
resident). First paint issues one facilities request plus three per store and one
per production site — a worst case of 61 at pageSize 20. Against the reference
tenant (14 facilities, all stores, verified 2026-07-26) it is **43 requests on a
single page**, and pagination never engages.

**Constraints**: mbe-api caps every list request at 100 records
(`limit: Query(20, ge=1, le=100)`); no backend change is in scope; the
`NavBranch` ↔ router build-order invariant has no compile-time enforcement.

**Scale/Scope**: 1 screen rewritten, 3 screens deleted, 3 detail screens extended,
4 form controllers edited, 20 facilities per page.

**Reference-tenant reality (verified 2026-07-26)**: 14 facilities, **all of type
`store`; zero production sites**. Two consequences for verification, not for
design — both paths stay implemented because a user can create a production site
from the facility form at any time, and pagination is mandated by constitution §VI:

- The production-site path (FR-011, the Warehouses-only card and its note) has no
  live data. It MUST be covered by widget tests with fabricated data; it cannot be
  signed off by clicking through the app.
- The whole catalog fits on one page, so page-preservation after a mutation
  (FR-027) is likewise not observable against live data and needs test coverage.

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
| Mandatory pagination | Facilities stay paginated. Child sections carry no pagination control — recorded in Complexity Tracking rather than asserted as a clean exemption, since the constitution's "provably bounded" example (a small fixed enum-like list) is narrower than this case; the mitigating fact is FR-019's complete-the-collection loop, so nothing is ever hidden behind an unfetched page. |
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

- Fetching by facility type (research §2) means a production site's points of sale
  and cash drawers are never requested. This touches no principle; it is the
  domain invariant expressed in the fetch path, and it lowers request volume.
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
├── unit/features/catalog/
│   └── facility_children_controller_test.dart   # +  fetch-by-type, complete-collection loop, invalidation
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
priorities. **Numbered to match tasks.md's phases exactly** — tasks.md brackets
these five with its own Phase 1 (Setup) and Phase 7 (Polish & Cross-Cutting),
which have no analog here since they involve no design decision.

**Phase 2 — data foundation (no user-visible change).** `FacilityChildren` entity
and `facilityChildrenControllerProvider`, including the complete-the-collection
loop (FR-019) and the `*Readable` flags. Unit-tested against a fake repository.
*Verify*: new unit tests pass; app unchanged.

**Phase 3 — the hierarchy view (US1).** Rewrite `facilities_list_screen.dart` and
add the three widgets. Wide tier only, read-only: no create/edit wiring yet.
*Verify*: quickstart Gate 1, including the scroll check for eager loading.

**Phase 4 — wiring CRUD (US2).** `?facility=` parsing, the three detail-screen
prefills, `originalFacilityId` on three form states, repointed
`_invalidateCaches`. *Verify*: quickstart Gate 2, especially the
move-between-facilities case.

**Phase 5 — navigation consolidation (US3).** Delete the three list screens,
controllers and branches; renumber `NavBranch`; **keep the three guards**; update
router and navigation tests. *Verify*: quickstart Gate 3, both assertions.

**Phase 6 — compact tier (US4).** Density branching and the FAB.
*Verify*: quickstart Gate 4.

Phases 2–3 deliver the spec's P1 story on their own. Phase 5 is deliberately last:
until it lands, the old screens remain as a fallback.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| Create action in a child **section header**, where constitution §VI says "Create remains a toolbar-only action" | The screen manages four entity types at once. A single toolbar Create cannot express *which* child type, under *which* facility — the parent context is the entire value of the feature (FR-022, SC-001). The section header is the only place carrying both. | *One toolbar Create with a type+facility chooser*: reintroduces the facility re-selection this feature exists to remove. *A create icon on each row*: genuinely violates the row-action rule and attaches "create" to the wrong scope. The rule's purpose — bounding per-row icon count — is untouched: rows still carry exactly one icon. |
| Up to 61 requests on first paint of a facilities page | FR-006/FR-017 require accurate counts on collapsed cards, and the facilities projection carries no counts. Eager per-page loading was chosen by the requester over lazy loading. | *Lazy on expand*: cannot show collapsed counts at all. *Child counts on the facilities projection*: the correct end state, but needs an mbe-api change, which is out of scope. The mitigation lever if it hurts in practice is a smaller facilities page size, not a switch to lazy. |
| ~~A point of sale or cash drawer attached to a production site becomes invisible~~ — **resolved, no longer a deviation** | The facility type rule is a domain invariant (research §2): production sites have warehouses only. Applying it before fetching expresses that rule directly and saves two requests per production site. | Retained for the record: the concern was that mbe-api does not enforce the invariant, so a migrated row could be stranded. Production data was queried on 2026-07-26 and returned no such row, so *fetch all three types and render whatever comes back* would have added two always-empty requests per production site to guard against data that does not exist. |
| Child sections (Warehouses/POS/Cash Drawers) carry no pagination control, where constitution §VI mandates pagination for any list "that can grow unbounded," exempting only a dataset that is "provably bounded (e.g. a small fixed enum-like list)" | A facility's children are bounded by real-world business shape, not by a small fixed set — the constitution's own example is narrower than this case. The bound here is FR-019's complete-the-collection loop: every child is always fetched to completion (up to mbe-api's 100-per-request cap, looped), so nothing is ever hidden behind an unfetched page, which is the actual harm the pagination rule guards against. | *A visible "load more" control per section*: rejected in spec.md's own edge-case reasoning (§Edge Cases, "A facility holds more children than one request returns") — a real store never approaches the 100-record cap, so a control would sit unused on every card, forever, adding UI weight for a case research confirms does not occur in the reference tenant (14 facilities, 0 with >20 children of any type). *A hard page-size cap on child sections with no loop*: would violate FR-019 outright by making some children genuinely unreachable once the standalone lists are gone. |
