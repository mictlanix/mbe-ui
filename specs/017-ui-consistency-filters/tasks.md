---
description: "Task list for 017-ui-consistency-filters"
---

# Tasks: Cross-Screen UX Consistency & Filtering Backfill

**Input**: Design documents from `/specs/017-ui-consistency-filters/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/)

**Tests**: Included — FR-037 makes test updates a requirement, and every affected
screen already has a widget test file (research §9). Test tasks are not optional here.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1–US5 from [spec.md](./spec.md)
- Exact file paths in every description

## ⚠️ Read before starting

This feature **modifies 36 existing screens**; it barely creates anything new. Three
things follow from that:

1. **Never batch test fixes.** Each screen conversion updates that screen's test in
   the *same commit*. A suite that is red across a 36-screen conversion stops being
   a signal (research §9).
2. **Execution order ≠ priority order.** US2 is P1 by value but is scheduled after
   US3, because 4 of US2's screens are among the 18 US3 converts — doing US2 first
   means building notifier-based filters and immediately rewriting them. See
   [Dependencies](#dependencies--execution-order).
3. **T008 is a hard gate.** If it fails, stop and revisit research §4 before
   converting anything else.

---

## Phase 1: Setup

**Purpose**: Establish a known-green baseline so later failures are attributable.

- [X] T001 Verify baseline is green: run `flutter analyze` and `flutter test` at repo root, record the pass count in the PR description
- [X] T002 Verify codegen is current: run `dart run build_runner build --delete-conflicting-outputs` and confirm no `lib/**/*.g.dart` or `*.freezed.dart` file changes
- [X] T003 [P] Add an l10n key-parity check to `test/unit/core/l10n_parity_test.dart` asserting `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` have identical key sets (701 each as of the `main` merge — assert set equality, not this literal count) — this guards FR-036 for every later task

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The shared pieces US2–US5 all build on, plus the one risk that could
invalidate the approach.

**⚠️ CRITICAL**: US2, US3, US4, and US5 cannot start until T008 passes.
**US1 is independent of this phase** and may run in parallel with it.

- [X] T004 [P] Create `ListQuery` freezed value (`search`, `pageIndex`, `facets`) with `isFiltered` / `isDefault` derived getters in `lib/core/navigation/list_query.dart` per [data-model.md](./data-model.md) §1
- [X] T005 Implement `ListQuery.fromUri` / `toUri` encoding in `lib/core/navigation/list_query.dart` per [contracts/list-query.md](./contracts/list-query.md) §2–§6 — one-based `page`, omitted defaults, deterministic ordering, total (never-throwing) decode
- [X] T006 [P] Write `ListQuery` round-trip and malformed-input unit tests in `test/unit/core/navigation/list_query_test.dart` covering every row of [contracts/list-query.md](./contracts/list-query.md) §5 and §9 (accents, `&`, `#`, `+`, spaces, multi-valued, tri-state, ISO dates, `page<=0`, unknown keys)
- [X] T007 Localize `ErrorBanner`: move the five hard-coded English messages out of `lib/core/widgets/error_banner.dart` into `errorValidationGeneric` / `errorAuthGeneric` / `errorNotFoundGeneric` / `errorServerGeneric` / `errorNetworkGeneric` in both `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, reading them via `AppLocalizations.of(context)` — see [contracts/list-state-views.md](./contracts/list-state-views.md) §0
- [X] T008 **RISK GATE** — convert only `/vehicles` to URL-driven filters in `lib/app/router/app_router.dart` + `lib/features/catalog/presentation/vehicles_list_screen.dart` + `vehicles_list_controller.dart`, and prove in `test/widget/features/catalog/vehicles_list_screen_test.dart` that `context.go` to the same shell-branch path with different query parameters updates the list **in place** without rebuilding or resetting the `StatefulShellRoute` branch
- [X] T009 [P] Write the `ErrorBanner` localization widget test in `test/widget/core/widgets/error_banner_test.dart` asserting localized output in both `en` and `es`

**Checkpoint**: `ListQuery` exists and is proven against the real router shape. If
T008 failed, **stop** — do not proceed to US3/US4.

---

## Phase 3: User Story 1 — Act on a record from one consistent place (Priority: P1) 🎯 MVP

**Goal**: Edit, Save, and Delete live in one shared, consistently placed action area
on all 18 record screens; `AppBar.actions` is empty.

**Independent Test**: Open any record read-only → no app-bar icons, an outlined Edit
at the end of the form; click it → the same area shows Delete + Save. Repeat on a
record in another module and observe identical placement, order, and styling.

**Independent of Phase 2** — can start immediately and in parallel.

### Shared component

- [X] T010 [P] [US1] Create `RecordFormActions` + `RecordFormMode` + `RecordDeleteConfirmation` in `lib/core/widgets/record_form_actions.dart` per [contracts/record-form-actions.md](./contracts/record-form-actions.md) §1–§5 — right-aligned `Wrap`, order `[Delete] [Edit-or-Save]`, null callback ⇒ action absent, caller-supplied labels and keys
- [X] T011 [US1] Write the `RecordFormActions` widget test matrix in `test/widget/core/widgets/record_form_actions_test.dart` covering every mode × RBAC combination from [contracts/record-form-actions.md](./contracts/record-form-actions.md) §7 — absent actions must be `findsNothing`, not found-but-disabled

### Governance (FR-005) — lands with the first converted screen

- [X] T012 [US1] Amend `DESIGN.md` §4.2/§4.3 to describe the record action area and the emptied record app bar, per [research.md](./research.md) §7
- [X] T013 [US1] Amend `.specify/memory/constitution.md` §VI — replace the v1.8.0 `AppBar.actions` paragraph with the new rule, retain the app-bar-delete allowance verbatim, add a Sync Impact Report entry, and bump **Version: 1.9.0 → 1.10.0** and **Last Amended** to 2026-07-25

### Screen conversions — each task converts the screen **and** updates its test in the same commit

- [X] T014 [US1] Convert `lib/features/catalog/presentation/expense_detail_screen.dart` to `RecordFormActions` (remove the app-bar `IconButton`, the two `FormGridSpan.full` buttons, and `_confirmDelete`) and update `test/widget/features/catalog/expense_detail_screen_test.dart` — do this one first as the reference conversion, alongside T012/T013
- [X] T015 [P] [US1] Convert `lib/features/catalog/presentation/label_detail_screen.dart` and update `test/widget/features/catalog/label_detail_screen_test.dart`
- [X] T016 [P] [US1] Convert `lib/features/catalog/presentation/supplier_detail_screen.dart` and update `test/widget/features/catalog/supplier_detail_screen_test.dart`
- [X] T017 [P] [US1] Convert `lib/features/catalog/presentation/vehicle_detail_screen.dart` and update `test/widget/features/catalog/vehicle_detail_screen_test.dart`
- [X] T018 [P] [US1] Convert `lib/features/catalog/presentation/vehicle_operator_detail_screen.dart` and update `test/widget/features/catalog/vehicle_operator_detail_screen_test.dart`
- [X] T019 [P] [US1] Convert `lib/features/catalog/presentation/cash_drawer_detail_screen.dart` and update `test/widget/features/catalog/cash_drawer_detail_screen_test.dart`
- [X] T020 [P] [US1] Convert `lib/features/catalog/presentation/warehouse_detail_screen.dart` and update `test/widget/features/catalog/warehouse_detail_screen_test.dart`
- [X] T021 [P] [US1] Convert `lib/features/catalog/presentation/facility_detail_screen.dart` and update `test/widget/features/catalog/facility_detail_screen_test.dart`
- [X] T022 [P] [US1] Convert `lib/features/catalog/presentation/customer_detail_screen.dart` and update `test/widget/features/catalog/customer_detail_screen_test.dart`
- [X] T023 [P] [US1] Convert `lib/features/catalog/presentation/employee_detail_screen.dart` and update `test/widget/features/catalog/employee_detail_screen_test.dart`
- [X] T024 [P] [US1] Convert `lib/features/catalog/presentation/product_detail_screen.dart` and update `test/widget/features/catalog/product_detail_screen_test.dart`
- [X] T025 [P] [US1] Convert `lib/features/catalog/presentation/point_sale_detail_screen.dart` and add the missing edit-affordance assertion to `test/widget/features/catalog/point_sale_detail_screen_test.dart`
- [X] T026 [P] [US1] Convert `lib/features/catalog/presentation/payment_method_option_detail_screen.dart` and update `test/widget/features/catalog/payment_method_option_detail_screen_test.dart`
- [X] T027 [P] [US1] Convert `lib/features/catalog/presentation/taxpayer_recipient_detail_screen.dart` and update `test/widget/features/catalog/taxpayer_recipient_detail_screen_test.dart`
- [X] T028 [P] [US1] Convert `lib/features/catalog/presentation/taxpayer_issuer_detail_screen.dart` and update `test/widget/features/catalog/taxpayer_issuer_detail_screen_test.dart` — leave the certificates sub-section's own actions untouched (they are not record actions)
- [X] T029 [P] [US1] Convert `lib/features/pricing/presentation/exchange_rate_detail_screen.dart` and add the missing edit-affordance assertion to `test/widget/features/pricing/exchange_rate_detail_screen_test.dart`
- [X] T030 [P] [US1] Convert `lib/features/pricing/presentation/price_list_detail_screen.dart` and add the missing edit-affordance assertion to `test/widget/features/pricing/price_list_detail_screen_test.dart`
- [X] T031 [P] [US1] Convert `lib/features/auth/presentation/admin/user_detail_screen.dart` and update `test/widget/features/auth/user_detail_screen_test.dart`
- [X] T032 [US1] Assert the invariant repo-wide in `test/widget/features/record_app_bar_actions_test.dart`: no record detail screen renders a non-empty `AppBar.actions` (SC-001). **Do not touch** `pricing_screen_test.dart`'s `edit_price_button_1` — it is a pricing-table row action, not a record toggle

**Checkpoint**: US1 is independently shippable. `grep -rn "actions: \[" lib/features/**/*_detail_screen.dart` returns nothing.

---

## Phase 4: User Story 3 — Share, bookmark, and refresh a filtered list (Priority: P2)

**Goal**: Every list screen's search, facets, and page live in the URL and restore
from it.

**Independent Test**: Filter + page any list, copy the address, open it in a fresh
session → same view, with the values visible in the filter controls.

**Scheduled before US2** — see [Dependencies](#dependencies--execution-order).

### Router + picker groundwork

- [X] T033 [US3] Add `ListQuery.fromUri(state.uri)` decoding to every list route builder in `lib/app/router/app_router.dart`, passing the result to each screen as a constructor argument — mirroring the existing `forceReadOnly` convention at `app_router.dart:276`
- [X] T034 [P] [US3] Add cold-load id→label resolution support to `lib/core/widgets/catalog_entity_picker.dart` per [data-model.md](./data-model.md) §4 — placeholder while resolving, raw-id fallback on failure, never blocks the list

### Screen conversions — each removes the screen's `XFilterController`, makes the list controller a family keyed by `XFilter` (including `pageIndex`), routes every filter/search/page change through `context.go`, and updates that screen's test

- [X] T035 [P] [US3] Convert `warehouses_list_screen.dart` + `warehouses_list_controller.dart` and update `test/widget/features/catalog/warehouses_list_screen_test.dart` — do this one first as the reference conversion for a facility+status catalog
- [X] T036 [P] [US3] Convert `cash_drawers_list_screen.dart` + `cash_drawers_list_controller.dart` and update `test/widget/features/catalog/cash_drawers_list_screen_test.dart`
- [X] T037 [P] [US3] Convert `points_of_sale_list_screen.dart` + `points_of_sale_list_controller.dart` and update `test/widget/features/catalog/points_of_sale_list_screen_test.dart`
- [X] T038 [P] [US3] Convert `facilities_list_screen.dart` + `facilities_list_controller.dart` and update `test/widget/features/catalog/facilities_list_screen_test.dart`
- [X] T039 [P] [US3] Convert `payment_method_options_list_screen.dart` + `payment_method_options_list_controller.dart` and update `test/widget/features/catalog/payment_method_options_list_screen_test.dart` — keep the pending-upstream `search` box wired as-is
- [X] T040 [P] [US3] Convert `products_list_screen.dart` + `products_list_controller.dart` and update `test/widget/features/catalog/products_list_screen_test.dart` — includes the multi-valued `label` facet
- [X] T041 [P] [US3] Convert `customers_list_screen.dart` + `customers_list_controller.dart` and update `test/widget/features/catalog/customers_list_screen_test.dart`
- [X] T042 [P] [US3] Convert `employees_list_screen.dart` + `employees_list_controller.dart` and update `test/widget/features/catalog/employees_list_screen_test.dart`
- [X] T043 [P] [US3] Convert `vehicle_operators_list_screen.dart` + `vehicle_operators_list_controller.dart` and update `test/widget/features/catalog/vehicle_operators_list_screen_test.dart`
- [X] T044 [P] [US3] Convert `labels_list_screen.dart` + `labels_list_controller.dart` and update `test/widget/features/catalog/labels_list_screen_test.dart`
- [X] T045 [P] [US3] Convert `suppliers_list_screen.dart` + `suppliers_list_controller.dart` and update `test/widget/features/catalog/suppliers_list_screen_test.dart`
- [X] T046 [P] [US3] Convert `expenses_list_screen.dart` + `expenses_list_controller.dart` and update `test/widget/features/catalog/expenses_list_screen_test.dart`
- [X] T047 [P] [US3] Convert `taxpayer_recipients_list_screen.dart` + `taxpayer_recipients_list_controller.dart` and update `test/widget/features/catalog/taxpayer_recipients_list_screen_test.dart`
- [X] T048 [P] [US3] Convert `taxpayer_issuers_list_screen.dart` + `taxpayer_issuers_list_controller.dart` and update `test/widget/features/catalog/taxpayer_issuers_list_screen_test.dart`
- [X] T049 [P] [US3] Convert `lib/features/pricing/presentation/exchange_rates_list_screen.dart` + `exchange_rates_list_controller.dart` and update `test/widget/features/pricing/exchange_rates_list_screen_test.dart` — includes the ISO date facets
- [X] T050 [P] [US3] Convert `lib/features/pricing/presentation/price_lists_list_screen.dart` + `price_lists_list_controller.dart` and update `test/widget/features/pricing/price_lists_list_screen_test.dart`
- [X] T051 [P] [US3] Convert `lib/features/auth/presentation/admin/users_list_screen.dart` + `users_controller.dart` and update `test/widget/features/auth/users_list_screen_test.dart` — preserve `UsersController.refresh()`'s current-page behavior (`users_controller.dart:133`)

*(Vehicles was already converted in T008.)*

- [X] T052 [US3] Add a shared list-URL round-trip widget test in `test/widget/features/list_url_state_test.dart` asserting, for a representative screen per facet type, that filters restore from the URL **into the controls** (FR-018) and that changing a filter updates the URL; also assert **browser Back navigation** (FR-022, spec.md US3 Acceptance Scenario 8): apply filter A, then filter B, then filter C via `context.go`, pop router history twice, and confirm the restored view matches filter A's state — not merely that `context.go` fires

**Checkpoint**: every list view is linkable, bookmarkable, and refresh-safe.

---

## Phase 5: User Story 4 — Keep your place in the list after changing a record (Priority: P2)

**Goal**: Creating, updating, or deleting a record returns the user to the page they
were on, refreshed.

**Independent Test**: Filter a >3-page catalog, page to 3, open a record, edit and
save → back on page 3 with the change visible.

**Mostly falls out of Phase 4** — page index is now part of the family key, so
`invalidate` re-fetches the same page (research §3). These tasks verify and close
the gaps.

- [X] T053 [US4] Audit all 16 `*_form_controller.dart` files under `lib/features/catalog/presentation/` and `lib/features/pricing/presentation/` for `ref.invalidate(<entity>ListControllerProvider)` and confirm each now re-fetches the same page rather than page 0; convert any that still reset
- [X] T054 [US4] Implement page clamping on load in `lib/core/navigation/list_query.dart` consumers: a `page` beyond the result set lands on the nearest valid page, never an empty view (FR-026)
- [X] T055 [P] [US4] Add a regression test in `test/widget/features/list_state_preservation_test.dart` for the path that **already works** — view a record and go back preserves search, facets, and page (FR-024) — so Phase 4's refactor cannot quietly break it
- [X] T056 [P] [US4] Add tests in `test/widget/features/list_state_preservation_test.dart` for create / update / delete returning to the same page with the change reflected (FR-025), and for deleting the last item on the last page clamping to a valid page (FR-026)

**Checkpoint**: the page-reset bug is gone and the previously-correct path is pinned.

---

## Phase 6: User Story 2 — Filter every catalog by every criterion its data supports (Priority: P1)

**Goal**: Vehicles, Vehicle Operators, and Users gain a status filter; Products gains
a supplier filter.

**Independent Test**: Filter Vehicles to Active → inactive vehicles disappear and the
result/page count reflects the filtered total; repeat for the other three.

**Scheduled after US3** so each facet is built once, directly on URL-driven filters.

### Vehicles — status (FR-009)

- [X] T057 [P] [US2] Add `EntityStatus? status` to `VehicleRepository.list` in `lib/features/catalog/domain/repositories/vehicle_repository.dart` and forward it in `lib/features/catalog/data/vehicle_repository_impl.dart`
- [X] T058 [US2] Add the first filter sheet to `lib/features/catalog/presentation/vehicles_list_screen.dart` (filter button + badge + `showCatalogFilterSheet` + `EntityStatusFilterChips`), wire the `status` facet through `ListQuery`, and **correct the stale comment at `vehicles_list_screen.dart:19-22`** which wrongly claims the endpoint has no facets beyond `search`
- [X] T059 [US2] Add the Vehicles filter-sheet title key to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, and extend `test/widget/features/catalog/vehicles_list_screen_test.dart` to assert: the repository receives the status value and it round-trips through the URL; the facet renders via `EntityStatusFilterChips` (FR-013 — no bespoke widget); and a filtered result's displayed total/page count comes from the mocked server response, not `items.length` (FR-014)

### Vehicle Operators — status (FR-010)

- [X] T060 [P] [US2] Add `EntityStatus? status` to `VehicleOperatorRepository.list` in `lib/features/catalog/domain/repositories/vehicle_operator_repository.dart` and forward it in `lib/features/catalog/data/vehicle_operator_repository_impl.dart`
- [X] T061 [US2] Add `EntityStatusFilterChips` to the existing filter sheet in `lib/features/catalog/presentation/vehicle_operators_list_screen.dart`, combinable with the operator facet, and update the badge count; extend `test/widget/features/catalog/vehicle_operators_list_screen_test.dart` to assert both facets apply together (FR-013) and that the filtered total/page count comes from the server response, not `items.length` (FR-014)

### Users — status (FR-011)

- [X] T062 [P] [US2] Add `EntityStatus? status` to `UserRepository.list` in `lib/features/auth/domain/repositories/user_repository.dart` and forward it to `listUsersApiV1UsersGet` in `lib/features/auth/data/user_repository_impl.dart`
- [X] T063 [US2] Add the first filter sheet to `lib/features/auth/presentation/admin/users_list_screen.dart` with `EntityStatusFilterChips`, add its title key to both `.arb` files, and extend `test/widget/features/auth/users_list_screen_test.dart` to assert the shared-control usage (FR-013) and that the filtered total/page count comes from the server response, not `items.length` (FR-014)

### Products — supplier (FR-012)

- [X] T064 [P] [US2] Add `int? supplier` to `ProductRepository.list` in `lib/features/catalog/domain/repositories/product_repository.dart` and forward it in `lib/features/catalog/data/product_repository_impl.dart`
- [X] T065 [US2] Add a `CatalogEntityPicker<Supplier>` supplier facet to the existing filter sheet in `lib/features/catalog/presentation/products_list_screen.dart`, fed by `SupplierRepository`, using the T034 cold-load resolution; add its label key to both `.arb` files
- [X] T066 [US2] Extend `test/widget/features/catalog/products_list_screen_test.dart` to assert the supplier facet reaches the repository, combines with label + status, round-trips through the URL including its resolved display name, uses `CatalogEntityPicker` rather than a bespoke widget (FR-013), and that a filtered result's total/page count comes from the mocked server response, not `items.length` (FR-014)

**Checkpoint**: no catalog ignores a facet its endpoint accepts.

---

## Phase 7: User Story 5 — Understand why a list is not showing results (Priority: P3)

**Goal**: All 18 lists render loading, empty, filtered-empty, and failed identically,
with no raw exception text anywhere.

**Independent Test**: Force each of the four states on any list and observe four
distinct, consistent treatments; the failed state shows a comprehensible localized
message plus Retry.

### Shared component

- [X] T067 [P] [US5] Create `CatalogListStateView` in `lib/core/widgets/list_state_views.dart` per [contracts/list-state-views.md](./contracts/list-state-views.md) §1–§3 — four states, `isFiltered` discriminates the two empty ones, `failed` renders `ErrorBanner` with the mapped `AppError`
- [X] T068 [P] [US5] Add the ~6 generic shared keys (retry, clear filters, filtered-empty title, generic load-failure title) to `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`
- [X] T069 [US5] Write the state-view widget tests in `test/widget/core/widgets/list_state_views_test.dart` per [contracts/list-state-views.md](./contracts/list-state-views.md) §5, including that the create affordance is absent without the create privilege

### Adoption — replace `loading:` / `error:` / empty rendering on every list

- [X] T070 [P] [US5] Adopt `CatalogListStateView` in the 15 catalog list screens under `lib/features/catalog/presentation/*_list_screen.dart`, removing every `Center(child: Text(l10n.<entity>LoadError(e)))` and `Center(child: Text(l10n.no<Entity>Found))`
- [X] T071 [P] [US5] Adopt `CatalogListStateView` in `lib/features/pricing/presentation/exchange_rates_list_screen.dart` and `price_lists_list_screen.dart`
- [X] T072 [P] [US5] Adopt `CatalogListStateView` in `lib/features/auth/presentation/admin/users_list_screen.dart`
- [X] T073 [P] [US5] Adopt the shared states in `lib/features/pricing/presentation/pricing_screen.dart` (replacing `pricing_screen.dart:99-105`), keeping its screen-specific "select a product first" prompt local and **not** touching its deferred table layout issues
- [X] T074 [US5] Add a repo-wide assertion in `test/widget/features/list_error_rendering_test.dart` that no list screen renders a raw exception — `grep -rn "LoadError(e)" lib/features` must return nothing (SC-008)

**Checkpoint**: every list reports emptiness and failure the same way, localized.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [X] T075 [P] Write the standing repository-parameter audit test in `test/unit/features/repository_list_params_audit_test.dart` per [contracts/filter-backfill.md](./contracts/filter-backfill.md) §5 — every list repository's declared parameters vs a checked-in expected set, with a commented reason for each deliberate omission (FR-015)
- [X] T076 [P] Write the end-to-end integration flow in `test/integration/list_state_and_actions_flow_test.dart`: filter a list → page → open a record → edit → save → confirm same page and filters, with the change visible
- [X] T077 [P] Remove the now-unused per-entity `<entity>LoadError` keys from `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` once nothing references them
- [ ] T078 Run the full [quickstart.md](./quickstart.md) acceptance walkthrough on `flutter run -d chrome` (US1–US5 sections) and record results
- [X] T079 Final gate: `flutter analyze` clean, `flutter test` green, l10n parity test passing, and every Definition-of-Done box in [quickstart.md](./quickstart.md) checked

---

## Dependencies & Execution Order

```text
Phase 1 (Setup)
   │
   ├─────────────────────────────► Phase 3 (US1) ──────────────► shippable alone
   │                                  T010,T011 → T012,T013,T014 → T015…T031 → T032
   │
   └─► Phase 2 (Foundational)
          T004 → T005 → T006
          T007 → T009
          T008 ◄── HARD GATE
             │
             ├─► Phase 4 (US3)  T033,T034 → T035…T051 → T052
             │        │
             │        ├─► Phase 5 (US4)  T053,T054 → T055,T056
             │        │
             │        ├─► Phase 6 (US2)  T057…T066
             │        │
             │        └─► Phase 7 (US5)  T067,T068,T069 → T070…T073 → T074
             │
             └─────────────────────────► Phase 8 (Polish)  T075…T079
```

### Why US3 (P2) runs before US2 (P1)

US2's four screens — Vehicles, Vehicle Operators, Users, Products — are all among
the 18 that US3 converts from notifier-backed to URL-backed filters. Building the
new facets first means writing them against the notifier pattern and rewriting them
days later; two of the four (Vehicles, Users) would need their *first ever* filter
sheet built twice. Priority still reflects user value — US2 is the missing
capability — but the cheapest correct order is US3 → US2. If US2 must ship first
for external reasons, it can, at the cost of reworking four screens.

### Story independence

| Story | Depends on | Independently demoable? |
|---|---|---|
| US1 | nothing (Phase 1 only) | ✅ Yes — full MVP on its own |
| US3 | T008 gate | ✅ Yes |
| US4 | US3 | ✅ Yes (its own acceptance walkthrough) |
| US2 | US3 (for cost, not correctness) | ✅ Yes |
| US5 | T004/T007 (`isFiltered`, localized `ErrorBanner`) | ✅ Yes |

---

## Parallel Execution Opportunities

- **T004 ‖ T007 ‖ T010** — three independent files (`list_query.dart`,
  `error_banner.dart`, `record_form_actions.dart`) at the very start.
- **US1 ‖ Phase 2** — US1 touches no list screen and no routing; it can run
  start-to-finish alongside the foundational work.
- **T015–T031 (17 detail screens)** — all `[P]`, one file pair each. The single
  ordering constraint is T014 first, as the reference conversion that T012/T013's
  amendment ships with.
- **T035–T051 (17 list screens)** — all `[P]` after T033/T034. Convert T035
  (Warehouses) first as the reference for a facility+status catalog.
- **T057 ‖ T060 ‖ T062 ‖ T064** — the four repository interface deltas are in four
  separate files.
- **T070 ‖ T071 ‖ T072 ‖ T073** — state-view adoption per module.

---

## Implementation Strategy

**MVP = Phase 1 + Phase 3 (US1).** That alone delivers the change the user asked for
— the edit affordance moved to an outlined button beside Save/Delete on all 18
record screens — plus the shared component that makes the next such change one edit
instead of eighteen. It ships without touching a single list screen.

**Increment 2 = Phase 2 + Phase 4 (US3).** The riskiest work, gated at T008.

**Increment 3 = Phases 5–7 (US4, US2, US5).** Each independently demoable, in that
order for cost.

**Increment 4 = Phase 8.** The standing audit test is the piece that stops this
feature's findings from silently recurring — do not drop it under time pressure.

**Total: 79 tasks** — 3 setup, 6 foundational, 23 US1, 20 US3, 4 US4, 10 US2, 8 US5,
5 polish.
