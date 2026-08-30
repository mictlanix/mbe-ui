# Implementation Plan: CRUD UI Refinements

**Branch**: `035-crud-ui-refinements` | **Date**: 2026-08-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/035-crud-ui-refinements/spec.md`

## Summary

Seven cross-cutting defects observed across the built CRUD screens, fixed at the shared-component
and design-token level rather than per screen, plus the conversion of 14 simple records from a
pushed full-screen route to the app's existing responsive panel.

The technical shape of the work is lopsided in a useful way. Four of the seven items collapse to
**single edits in `core/`**: the square table corners are an unclipped `Card`, not a missing
radius, so `cardTheme.clipBehavior` fixes every table at once; the same `cardTheme.shape` gains the
hairline outline that also lands on `FacilityCard` for free. Two more are small shared additions —
a horizontal inset moved into `CatalogFilterBar` (retiring 20 ad-hoc `EdgeInsets.all(8)` literals
that already violate §VI), and a submit helper that calls the `ref.invalidate` these screens
already use for retry. The remaining item, the panel conversion, is the bulk of the work: 14
entities, 28 routes deleted, and a §VI amendment.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.44.2 (stable)

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (state), `go_router`
(navigation), `data_table_2` 2.6.0 (tables), `freezed` (value types), generated `mbe_api_client`
(OpenAPI dio client)

**Storage**: none client-side; all state is server-owned or URL-derived

**Testing**: `flutter test` — `test/unit`, `test/widget`, `test/contract`, `test/golden` (image
comparison), `test/integration` (live mbe-api, credentials in `.env`)

**Target Platform**: desktop and web first (macOS, Windows, Linux, Chrome); compact tier supported
but not the design target

**Project Type**: single Flutter application, feature-first layered architecture

**Performance Goals**: no new network calls beyond one refetch per explicit search submission;
FR-009 forbids a double fetch

**Constraints**: no mbe-api changes (§III repo boundary, and this feature carries no external
dependency by decision); server-side pagination means no client-side row filtering; the panel must
not regress the multi-column form rule

**Scale/Scope**: 20 list screens touched for the filter-bar inset, 10 for the default status
filter, 14 entities converted to panels, 28 routes deleted, ~3 files in `core/design`

## Constitution Check

*GATE: evaluated against `.specify/memory/constitution.md` v1.12.0.*

| Principle | Verdict | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | **PASS** | All shared work lands in `core/design` and `core/widgets`; feature modules only consume it. |
| II. Riverpod for State & DI | **PASS** | Reuses the existing family-keyed list controllers and `ref.invalidate`. No new state primitive. |
| III. Contract-Driven API Integration | **PASS** | No API change, no generated-client change, no sibling-repo edit. The one place this feature wanted a server change (multi-value status) was descoped rather than worked around. |
| IV. Deny-by-Default RBAC | **PASS** | The panel reuses `RecordFormActions`, which already gates Edit on update and Delete on delete. FR-028/FR-029 restate this; no new privilege surface. |
| V. Material 3 Design System | **PASS** | Outlined cards and clipped surfaces are M3-idiomatic. Every value comes from `spacing`/`shapes`/`ColorScheme`; the feature *removes* literals rather than adding them. |
| VI. Desktop/Web-First Layout | **CONFLICT — amendment required** | See below. |
| VII. Online-Only Documents | **N/A** | Untouched. |

### §VI conflict and resolution

§VI already permits a sheet-hosted form ("*it belongs on its own route, **or in a dialog/sheet
launched from a toolbar action in the filter row***"), so the conflict is narrower than the spec
assumed. Three clauses bind, and each says *screen* where it means *the record's own surface*:

1. a row click "MUST open that record's detail **screen** in read-only mode";
2. "the read-only detail **screen** MUST label itself as a 'View' screen" and offer the edit toggle;
3. "Delete/soft-delete MUST be surfaced on the record's own detail **screen**".

Each rule's *intent* survives the panel intact — a stray click stays safe, view and edit remain one
form, delete never returns to the row. Only the noun is wrong. **Resolution**: amend §VI to say
*surface* (full screen or shared panel) and name which entities use which. Constitution moves
**1.12.0 → 1.13.0** (material expansion of an existing principle). Per this project's practice, the
amendment lands with the first converted entity, not ahead of it.

No other gate fails, so nothing enters Complexity Tracking.

### Re-evaluation after Phase 1 design

Re-checked against the artifacts produced below. **Two findings worth recording:**

- The design *improves* §VI compliance in two places beyond what the spec asked. The 20
  `EdgeInsets.all(8)` wrappers being deleted are existing violations of "padding and margin values
  MUST come from the shared design tokens, never ad-hoc literals", as are the `circular(6)` /
  `circular(12)` values in the facility widgets. Both are removed as a side effect.
- FR-033 (panel wide enough for two columns) is what keeps the conversion compliant with §VI's
  multi-column form rule. `ResponsiveFormGrid` measures its *container*, not the screen
  (`responsive_form_grid.dart:47-53`), so a 360dp panel silently yields one column. Research R6
  sets the record panel to 640 to clear the 600dp two-column threshold. **If that proves too wide
  in use, the fallback is to amend the form-grid rule rather than ship one-column forms silently** —
  recorded so the decision is made deliberately, not by drift.

Gate status after design: **PASS, conditional on the §VI amendment shipping with the conversion.**

## Project Structure

### Documentation (this feature)

```text
specs/035-crud-ui-refinements/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output — R1..R9
├── data-model.md        # Phase 1 output — view-state and token changes
├── quickstart.md        # Phase 1 output — validation guide
├── contracts/
│   └── shared-widgets.md  # Phase 1 output — C1..C7 widget/route contracts
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── design/
│   │   ├── component_themes.dart      # cardTheme: clipBehavior + outlined shape (R2, R3)
│   │   └── shapes.dart                # hairline BorderSide helper (R3)
│   ├── navigation/
│   │   ├── list_query.dart            # `status=all` sentinel support (R5)
│   │   └── list_search_submit.dart    # NEW — submit helper (C4, R4)
│   └── widgets/
│       ├── catalog_filter_bar.dart    # horizontal inset + symmetric spacing (R1)
│       ├── entity_status_controls.dart# "All" writes `status=all` (R5)
│       ├── app_side_sheet.dart        # width + confirmDismiss args (C5, R6, R8)
│       ├── record_sheet.dart          # NEW — record panel host (C6)
│       └── data_table_view.dart       # unchanged (styling arrives via theme)
├── app/router/
│   └── app_router.dart                # delete 28 record routes, add redirects (C7, R7)
└── features/
    ├── catalog/presentation/          # 10 list screens, 11 detail screens → form widgets
    │   └── widgets/
    │       ├── facility_card.dart     # tokenised radii (R3)
    │       └── facility_child_row.dart# hairline + tokenised radii (R3)
    ├── pricing/presentation/          # price lists, exchange rates, pricing grid
    ├── auth/presentation/admin/       # users, user profiles (status default only)
    └── sales/presentation/            # filter-bar inset ONLY — filtering untouched (FR-007)

test/
├── widget/    # inset/alignment assertions (FR-016), default-filter, submit-once, panel behaviour
├── golden/    # regenerated for the outline, clipping and inset
└── integration/  # live-API CRUD-through-the-panel flows

.specify/memory/constitution.md        # → 1.13.0, §VI re-expressed (FR-037)
```

**Structure Decision**: The existing feature-first layout is kept unchanged. The defining choice is
that **almost nothing is added** — four of the seven items are edits to files that already exist in
`core/design` and `core/widgets`, with only two new files (`list_search_submit.dart`,
`record_sheet.dart`), each introduced because more than one module needs the identical behaviour
and §VI requires shared behaviour to be implemented once.

## Implementation Sequencing

Ordered so that user-visible value lands before the risky work, and so each stage is independently
shippable.

1. **Design-system styling** (US3, US4 — FR-013…FR-025). `cardTheme` clip + outline, the filter-bar
   inset, the 20 wrapper deletions, the facility-widget tokens. Regenerate goldens. Broadest visible
   improvement, smallest risk.
2. **Search refresh** (US2 — FR-008…FR-012). The submit helper plus 20 call sites. Verify the
   loading transition does not blank the table.
3. **Default Active filter** (US1 — FR-001…FR-006). The `status=all` sentinel, the shared decode
   helper, 10 list screens. Includes the explicit regression check that the three transactional
   lists are untouched.
4. **Panel conversion** (US5 — FR-026…FR-036). Widen the panel, add the dirty guard, convert
   entities one at a time behind the shared host, delete routes last. **Amend §VI with the first
   converted entity** (FR-037).

Stages 1–3 are independent of each other and of stage 4; stage 4 depends only on stage 1 having
settled the panel's surface styling.

## Risks

| Risk | Why it matters | Mitigation |
|---|---|---|
| `cardTheme` outline reaches **every** `Card` in the app | POS, dashboard and merge-review surfaces change appearance without being in scope | Deliberate per R3, but every remaining Card surface must be visually reviewed once before stage 1 is called done |
| Form controllers are **global singletons**, not families | A reopened panel may briefly show the previous record's values | R7 watch item — assert with a test that opening a second record starts clean; do not assume auto-dispose covers it |
| `ref.invalidate` returns the provider to `AsyncLoading` | The table could blank on every search press, which is worse than the bug being fixed | FR-012 — render previous data while refreshing; verified in stage 2, not deferred |
| 640dp panel may feel oversized | Trades one complaint for another | Fallback recorded in R6: amend the form-grid rule instead, as a deliberate decision |
| Goldens regenerated carelessly | A styling bug becomes the reference image | Quickstart requires reviewing each diff before `--update-goldens` |

## Complexity Tracking

> No constitution gate failed without resolution. The single conflict (§VI) is resolved by a
> versioned amendment that preserves every rule's intent, not by an exception.
