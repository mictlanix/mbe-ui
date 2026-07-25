# Implementation Plan: Cross-Screen UX Consistency & Filtering Backfill

**Branch**: `017-ui-consistency-filters` | **Date**: 2026-07-25 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/017-ui-consistency-filters/spec.md`

## Summary

A remediation pass over the **18 list screens** and **18 record detail screens**
shipped by specs 001–015. No new entity, no new route, no new dependency. Five
verified inconsistencies are closed, and one codified design rule is deliberately
reversed.

The work is shaped by four decisions taken in [research.md](./research.md):

1. **One shared record action area replaces 18 copies** (research §2). Every detail
   screen currently hand-copies a Save `FilledButton`, an error-filled Delete
   `FilledButton`, and a `_confirmDelete` dialog — all stretched edge-to-edge via
   `FormGridSpan.full` — plus an app-bar edit `IconButton`. A new
   `core/widgets/record_form_actions.dart` renders **Delete, then Edit-or-Save**,
   right-aligned and content-sized, and the edit affordance becomes an
   `OutlinedButton` there instead of an app-bar icon. This is what makes the
   requested move one change rather than eighteen.
2. **The URL becomes the single source of truth for list view state**
   (research §4). A shared `ListQuery` value is decoded in each list route's
   builder and passed to the screen exactly as `forceReadOnly` is today; the
   mutable `XFilterController` notifiers are **deleted**; the list controller
   becomes a family keyed by the decoded filter. One direction of data flow, so
   there is no re-entrancy guard to get wrong on 18 screens.
3. **The "page resets on Back" bug is narrower than the spec first assumed, and
   decision 2 fixes it for free** (research §3). A behavioral probe showed that
   viewing a record and going back already preserves search, facets, *and* page —
   the list stays mounted beneath the record screen. The place is lost only after a
   mutation, because every form controller calls
   `ref.invalidate(<entity>ListControllerProvider)` and every list controller's
   `build()` hard-codes `pageIndex: 0`. Once page index is part of the family key,
   `invalidate` re-fetches the same page. The spec was corrected before this plan.
4. **Four filter facets are backfilled, and a test keeps the audit honest**
   (research §5). Vehicles, Vehicle Operators, and Users gain `status`; Products
   gains `supplier`. All four are already accepted by the generated client — no
   backend dependency. A reflective unit test asserts every repository's declared
   list parameters against a checked-in expectation, so the next upstream facet
   fails a test instead of going unnoticed for two specs.

Two things surfaced during research that the spec did not anticipate and that this
plan absorbs:

- **`ErrorBanner` hard-codes its five messages in English** (research §6) — the
  very widget constitution §III designates as the shared error surface. Pointing 18
  more screens at it would multiply the bug, so localizing it is a prerequisite task
  of US5, not a follow-up.
- **Foreign-key facets lose their human-readable label on a cold URL load**
  (research §4) — a shared link carries `supplier=7`, not "Acme". Each FK facet
  resolves id → label through its own repository's existing `get(id)` on cold load.

Consequently this feature adds 4 files under `core/`, modifies every list and detail
screen, the router, both `.arb` files, `ErrorBanner`, DESIGN.md, and the
constitution. It touches **no** generated code and **no** backend.

## Technical Context

**Language/Version**: Dart `^3.10.3` (per `pubspec.yaml`), Flutter stable matching
that SDK constraint — unchanged from specs 011–015.

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation`/`riverpod_generator`,
`go_router`, `dio`, `freezed`/`freezed_annotation`, `intl` (`es-MX`), `data_table_2`.
**No new dependency is introduced** (FR-033).

**Storage**: N/A — no local database/cache (constitution §VII). List view state moves
*out* of memory and into the URL, which is not persistence.

**Testing**: `flutter_test` for unit/widget, `mocktail` for repository fakes,
`integration_test` for the end-to-end flow. See research §9 for the blast radius:
**23 existing assertions across 16 widget test files** reference
`edit_<entity>_button` and must be updated screen-by-screen, not batched.

**Target Platform**: Web, Windows, macOS, Linux — Expanded (desktop/web) tier,
Compact tier inherited from spec 010's adaptive shell. US3 is most valuable on web
but the mechanism is platform-neutral.

**Project Type**: Single Flutter project, feature-first. This feature is unusual in
that most of its weight lands in `core/` and is then adopted across three existing
feature modules, rather than creating a new one.

**Performance Goals**: Unchanged — one paginated page (`skip`/`limit`, default 20)
per fetch, all filtering server-side (FR-014), no N+1 per-row lookups. The one new
per-screen cost is at most one id → label resolve per FK facet on a **cold** URL
load, never per row and never on warm navigation.

**Constraints**: RBAC gating must be preserved exactly — actions hidden, never
disabled (FR-007, FR-038); the server stays authoritative. No generated file edited
(FR-034). No sibling-repo edit (FR-035). Both locales updated (FR-036).

**Scale/Scope**: 18 list screens + 18 detail screens converted; ~18 list controllers
refactored to family providers with their `XFilterController` notifiers removed; 4
repositories + impls extended (`vehicle`, `vehicle_operator`, `user`, `product`); 1
router file with ~18 list-route builders gaining query decoding; **4 new `core/`
files**; `ErrorBanner` localized; ~19 new l10n keys × 2 locales; DESIGN.md and
constitution amended. **No** new route, **no** new nav destination, **no** new
`SystemObject`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | ✅ PASS | New shared widgets land in `core/widgets/` and `core/navigation/` — the shared kernel, which is where cross-module UI contracts belong by §I. No feature imports another feature; `presentation` still imports only `domain`. Repository extensions stay behind their `domain` interfaces. |
| II. Riverpod for State & DI | ✅ PASS | List controllers remain `Notifier`-based exposing `AsyncValue`, gaining a family key. **Deleting the `XFilterController` notifiers moves filter state to the URL, not out of Riverpod** — the derived filter is a provider argument, which is the idiomatic Riverpod way to model route-derived state. Repositories stay provider-exposed for test overrides. |
| III. Contract-Driven API Integration | ✅ PASS | Consumes already-generated clients; no hand-written DTOs; no generated file edited. The four backfilled facets are existing client parameters. §III's "errors surfaced via the shared error-display widget" is **currently violated by all 18 list screens** — this feature is what brings them into compliance, and fixes `ErrorBanner`'s own hard-coded English on the way (research §6). No backend edit (§III repo-boundary rule); no backend change is needed. |
| IV. Deny-by-Default RBAC | ✅ PASS | No privilege check is added, removed, or relaxed. `RecordFormActions` takes `canEdit`/`canSave`/`canDelete` and **omits** absent actions rather than disabling them, preserving today's semantics exactly; FR-038 forbids weakening, and a widget test per RBAC combination enforces it. The empty-state "create first record" affordance is gated on the create privilege (FR-029). |
| V. Material 3 White-Labeled Design System | ✅ PASS | Material 3 components only; no new theming, no brand token change. **Improves** §V compliance: `ErrorBanner`'s five hard-coded English strings move into both `.arb` files. All new strings in both locales (FR-036). |
| VI. Desktop/Web-First, Compact-Ready Layout | ⚠️ **PASS ONLY VIA AMENDMENT** — see below | US1 directly contradicts §VI as written today. Resolved by amending §VI, not by claiming an exception. Every other §VI rule is upheld or strengthened. |
| VII. Online-Only, Server-Rendered Documents | ✅ PASS | No local persistence or caching introduced. URL query state is address-bar state, not client storage — and it was explicitly chosen over a `shared_preferences`-backed alternative for this reason (research §4). |

### On §VI — the one principle this feature changes

Constitution §VI v1.8.0 states: *"`AppBar.actions` MUST be reserved for the single
read-only-to-edit toggle affordance already codified above."* **US1 reverses this
rule.** That is not an exception to be justified in Complexity Tracking — a
Complexity Tracking entry would leave the constitution saying one thing while the
code does another. It is a deliberate amendment, executed through the process
§Governance prescribes: DESIGN.md §4.2/§4.3 first, then constitution §VI plus its
Sync Impact Report, **MINOR bump to v1.10.0** (research §7 — matching how the v1.5.0
and v1.8.0 rule redefinitions were classified).

FR-005 makes this a deliverable, and the plan sequences the amendment to land with
the *first* converted screen rather than after all 18, so the repository never holds
a screen that contradicts its own written rule.

Every other §VI rule is upheld, and several are strengthened:

- **Mandatory filtering on every catalog** — this feature closes the last four gaps
  and adds a test to keep them closed (research §5).
- **Shared components, not per-module reimplementation** — the record action set,
  the list state views, and the list-query codec each move from 18 copies (or 18
  ad-hoc renderings) to one shared definition.
- **No full-width single-field stretch** — the action area stops stretching
  edge-to-edge (FR-004), which the current `FormGridSpan.full` buttons violate in
  spirit.
- **Row action set, read-only row click, toolbar-only Create, detail-screen
  Delete** — all unchanged.

**Post-Phase 1 re-check**: ✅ still passing on the same terms. Phase 1 introduced no
dependency, no generated-file edit, no persistence, no new RBAC object, and no route
change beyond query-parameter decoding in existing builders. §VI remains
conditional on the amendment landing, which is tracked as FR-005 and sequenced in
Phase 3 below.

## Project Structure

### Documentation (this feature)

```text
specs/017-ui-consistency-filters/
├── plan.md                            # This file
├── spec.md                            # Feature spec (US4 corrected post-probe)
├── research.md                        # Phase 0 output (§1–§10)
├── data-model.md                      # Phase 1 output
├── quickstart.md                      # Phase 1 output
├── contracts/                         # Phase 1 output
│   ├── record-form-actions.md         # shared record action area contract
│   ├── list-query.md                  # URL encoding contract for list view state
│   ├── list-state-views.md            # loading/empty/filtered-empty/error contract
│   └── filter-backfill.md             # per-screen facet matrix + repository deltas
├── checklists/
│   └── requirements.md                # spec quality checklist (from /speckit-specify)
└── tasks.md                           # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── app/
│   └── router/
│       └── app_router.dart                    # MODIFIED: each list route builder decodes ListQuery
│                                              #   from state.uri and passes it to the screen
│                                              #   (mirrors the existing ?view=true convention)
├── core/
│   ├── navigation/
│   │   └── list_query.dart                    # NEW: ListQuery value + fromUri/toUri codec
│   └── widgets/
│       ├── record_form_actions.dart           # NEW: Delete + Edit-or-Save action area,
│       │                                      #   RBAC-aware, hosts the confirm dialog
│       ├── list_state_views.dart              # NEW: loading / empty / filtered-empty / error
│       ├── error_banner.dart                  # MODIFIED: five hard-coded English messages → l10n
│       ├── catalog_entity_picker.dart         # MODIFIED (small): cold-load id→label resolution hook
│       ├── catalog_filter_bar.dart            # unchanged (reused)
│       ├── catalog_filter_sheet.dart          # unchanged (reused)
│       └── entity_status_controls.dart        # unchanged (reused)
├── l10n/
│   └── app_{en,es}.arb                        # MODIFIED: ~19 new keys each (research §8)
└── features/
    ├── auth/
    │   ├── domain/repositories/user_repository.dart      # MODIFIED: list() gains status
    │   ├── data/user_repository_impl.dart                # MODIFIED
    │   └── presentation/admin/
    │       ├── users_controller.dart                     # MODIFIED: filter from ListQuery, family key
    │       ├── users_list_screen.dart                    # MODIFIED: first filter sheet + state views
    │       └── user_detail_screen.dart                   # MODIFIED: RecordFormActions
    ├── catalog/
    │   ├── domain/repositories/
    │   │   ├── vehicle_repository.dart                   # MODIFIED: list() gains status
    │   │   ├── vehicle_operator_repository.dart          # MODIFIED: list() gains status
    │   │   └── product_repository.dart                   # MODIFIED: list() gains supplier
    │   ├── data/*_repository_impl.dart                   # MODIFIED: the three above
    │   └── presentation/
    │       ├── *_list_controller.dart   (15)             # MODIFIED: XFilterController removed,
    │       │                                             #   list controller becomes a family
    │       ├── *_list_screen.dart       (15)             # MODIFIED: URL-driven filters + state views
    │       └── *_detail_screen.dart     (15)             # MODIFIED: RecordFormActions
    └── pricing/
        └── presentation/
            ├── {exchange_rates,price_lists}_list_*.dart  # MODIFIED: as above
            ├── {exchange_rate,price_list}_detail_*.dart  # MODIFIED: RecordFormActions
            └── pricing_screen.dart                       # MODIFIED: state views only (not a catalog list)

lib/generated/openapi/                                    # UNCHANGED — consumed, not edited

test/
├── unit/core/navigation/list_query_test.dart             # NEW: round-trip + edge cases
├── unit/features/repository_list_params_audit_test.dart  # NEW: FR-015 standing audit
├── widget/core/widgets/
│   ├── record_form_actions_test.dart                     # NEW: RBAC × mode matrix
│   └── list_state_views_test.dart                        # NEW
├── widget/features/**/*_detail_screen_test.dart          # MODIFIED: 23 assertions across 16 files
├── widget/features/**/*_list_screen_test.dart            # MODIFIED: URL-driven filter assertions
└── integration/list_state_and_actions_flow_test.dart     # NEW: filter → page → edit → save → back

DESIGN.md                                                 # MODIFIED: §4.2/§4.3 (amendment step 1)
.specify/memory/constitution.md                           # MODIFIED: §VI + Sync Impact Report, v1.10.0
```

**Structure Decision**: Unlike specs 011–015, this feature's center of gravity is
**`core/`**, not a feature module. That is deliberate and follows constitution §I
and §VI: every problem being fixed here is a cross-module consistency problem, and
§VI explicitly requires shared table/form/filter behavior to be "implemented once in
the shared `core/widgets/` component, not re-implemented per screen". Four new
shared definitions are added and then adopted across `auth`, `catalog`, and
`pricing`; no feature module gains a new sub-tree, and no entity moves.

## Implementation Phases

Sequenced per research §10, which deliberately front-loads risk. Phases 1–3 are the
uncertain part; Phase 4 is repetition.

| Phase | Work | Gate |
|---|---|---|
| **1. Shared foundations** | `ListQuery` + codec; `RecordFormActions`; `list_state_views`; localize `ErrorBanner`. Each with tests. Nothing wired up; no user-visible change. | All new unit/widget tests green; app builds unchanged. |
| **2. Retire the routing risk** | Prove on **one** screen (Vehicles) that `context.go` to the same shell-branch path with different query parameters preserves the branch and refetches. Vehicles is chosen because it needs all four changes at once and is small. | **Hard gate.** If the branch rebuilds or resets, §4's approach is revisited before it costs 18×. |
| **3. Governance** | DESIGN.md §4.2/§4.3 → constitution §VI + Sync Impact Report → v1.10.0, landing with the first converted detail screen. | Constitution and code agree at every commit. |
| **4. Fan out** | Remaining 17 list screens and 17 detail screens, module by module; each screen's own tests updated in the same commit. | Suite green per module, never red across the whole conversion. |
| **5. Filter backfill** | The four facets (research §5), on top of the now-URL-driven filters. | Each new facet filters server-side and round-trips through the URL. |
| **6. Standing audit** | The reflective repository-parameter test, once every repository is final. | Test fails if a repository ignores a client parameter. |

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| **`context.go` with new query parameters may rebuild or reset a `StatefulShellRoute` branch** rather than updating it in place. The probe in research §3 covered push/pop, not this. | The whole URL-as-source-of-truth approach (US3/US4) would need rework — after potentially touching many screens. | **Phase 2 is a hard gate**: prove it on Vehicles alone before fanning out. This is why the sequencing is risk-first rather than module-first. |
| **Deleting 18 `XFilterController` notifiers is a wide refactor** with broad test fallout. | A long-lived red suite that stops being a signal. | Convert screen-by-screen with its tests in the same commit (research §9); never batch the test fixes. Module-by-module fan-out keeps each step small. |
| **FK facet labels are lost on cold URL load** (`supplier=7` carries no name). | A shared link shows correct results with blank filter controls — FR-018 fails. | Resolve id → label via each repository's existing `get(id)` on cold load, with a placeholder while resolving and a raw-id fallback on failure (research §4). |
| **`ErrorBanner`'s hard-coded English** would be multiplied across 18 more screens. | A regression in `es-MX` UX and a §V violation at 18× the current scale. | Localizing it is a **prerequisite** task in Phase 1, not a follow-up. |
| **The constitution amendment could lag the code** if screens land first. | The repo would contain screens contradicting their own governing rule — exactly the drift §Governance exists to prevent. | Phase 3 pins the amendment to the *first* converted detail screen. FR-005 states it as a requirement. |
| **RBAC regression while moving actions between widgets.** | A user could see an action they must not have. | `RecordFormActions` omits (never disables) absent actions; a widget test covers every RBAC × mode combination; FR-038 forbids weakening. |
| **Page-index-in-URL disagreeing with a shrinking result set** (delete the last item on the last page). | An empty page with no way back. | FR-026: clamp to the nearest valid page on load; covered by the integration flow. |
| **Scope creep from the standing audit (FR-015)** — the audit may surface further upstream gaps. | Feature grows unbounded. | Gaps found are **filed upstream and recorded**, never worked around client-side (FR-016, FR-035). Only the four already-verified facets are in this feature. |

## Follow-ups (not blocking)

- **Upstream (tracked, pre-existing)**: `search` on the Payment Method Options list
  endpoint remains open from spec 015; unchanged by this feature. Its search box
  lights up automatically when it ships.
- **Deferred (explicitly out of scope)**: the pricing/price-list table
  empty-space, footer placement, and search box layout issues. This feature touches
  those screens' loading/empty/error rendering only.
- **Possible future**: column sorting and saved views become straightforward once
  list state is URL-addressable — but both are out of scope here.

## Complexity Tracking

*No unjustified constitution violations — but this section is **not** empty, because
one principle is being changed rather than merely satisfied.*

| Item | Why | Why not the simpler alternative |
|---|---|---|
| **§VI's `AppBar.actions` rule is reversed, not excepted** (v1.8.0 → v1.10.0) | The user requires the edit affordance to sit with Save/Delete in the form body. Filing this as a per-screen exception would leave 18 screens permanently deviating from a rule the project still claims to hold. | A Complexity Tracking exception was rejected: exceptions are for one-off deviations, and this is the new universal rule. The Governance process exists for exactly this case, and §VI has been amended this way twice before (v1.5.0, v1.8.0). |
| **Delete rather than adapt the 18 `XFilterController` notifiers** | Two sources of truth for filter state cannot satisfy FR-019, and a two-way sync needs a re-entrancy guard on all 18 screens. | Seeding the notifiers from the URL and writing back was rejected in research §4: it is 18 opportunities for a "filter flickers back" bug and makes the invariant unstateable. |
| **`ErrorBanner` localization pulled into this feature** | US5 points 18 screens at a widget whose messages are hard-coded English; shipping that would multiply an existing §V violation. | Deferring it was rejected: the feature would knowingly make an existing bug worse, and the fix is ~5 keys. |
