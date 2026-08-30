# Tasks: CRUD UI Refinements

**Input**: Design documents from `/specs/035-crud-ui-refinements/`
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/shared-widgets.md](./contracts/shared-widgets.md)

**Tests**: Not explicitly requested as TDD, but the spec requires alignment/behavior to be
"asserted by tests measuring real insets, not by inspection" (FR-016) and mandates specific,
checkable behaviors (exactly-one-fetch, dirty-guard, route redirects). Test tasks are therefore
included per-story, immediately after the implementation they cover, so each story stays
independently verifiable.

**Organization**: Phase 3 onward is grouped by user story (priority order from spec.md). Each
phase is independently shippable per the plan's sequencing (styling → search → default filter →
panels).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1–US5, matching spec.md
- Every description carries its exact file path

---

## Phase 1: Setup

**Purpose**: Nothing to initialize — this feature adds two new files to an existing, fully
configured project. No dependency, tool, or scaffolding changes are needed.

- [ ] T001 Confirm the working tree is clean and `flutter analyze && flutter test` pass before any
      change, as the pre-change baseline for every later regression check.

---

## Phase 2: Foundational

**Purpose**: Shared primitives multiple stories build on. **US3's theme change (T003) also
underlies US4 and is a prerequisite the panel work in US5 visually depends on being settled first**
(plan.md Implementation Sequencing) — nothing in a later story should start before this phase closes.

**⚠️ Nothing in Phase 3+ may start until this phase's checkpoint is reached.**

- [ ] T002 [P] Add a hairline `BorderSide` helper (colour `scheme.outlineVariant`, width 1) to
      `lib/core/design/shapes.dart`, alongside the existing `*Radius` getters, for both card-based
      and `Container`-based consumers to share (research.md R3).
- [ ] T003 In `lib/core/design/component_themes.dart`, set `cardTheme.clipBehavior: Clip.antiAlias`
      and add `side: <T002's helper>` to the existing `cardTheme.shape` (`RoundedRectangleBorder`).
      This is the single edit that rounds all four table corners (FR-017, FR-018, FR-020) and adds
      the hairline outline to every `Card` in the app, including `FacilityCard` (FR-019, FR-023).
- [ ] T004 [P] Add `--pageIndex`-preserving refresh support: confirm
      `lib/core/widgets/list_state_views.dart`'s `CatalogListStateView` (guard at line ~51,
      `page == null && state.isLoading`) already keeps rendering the previous page during a
      Riverpod-invalidate-triggered reload — research.md R4 predicts this already holds by
      construction. Do not change this file unless the guard is proven wrong; if it is, fix the
      guard here rather than in each story.

**Checkpoint**: `flutter test test/golden` now fails everywhere a `Card` renders — expected. Do
not regenerate goldens yet; each story regenerates only the goldens it touches, after review, in
its own phase.

---

## Phase 3: User Story 1 — Lists open showing only what is in use (Priority: P1)

**Goal**: Every catalog whose status facet is the shared entity lifecycle opens showing only
Active records, with a real, visible, clearable default that survives paging, sorting and reload.

**Independent Test**: Open Customers (or any of the ten catalogs) with a clean URL; only active
records are listed, the status facet shows Active selected, and choosing "All" reveals every
record and survives a reload.

### Implementation for User Story 1

- [ ] T005 [US1] In `lib/core/navigation/list_query.dart`, add an `all` sentinel to the status
      facet's decode contract: a helper (e.g. `EntityStatus? decodeStatusFacet(ListQuery query,
      {String key = 'status'})`) that returns `EntityStatus.active` when the `status` facet key is
      absent, `null` when it equals the literal string `all`, and the parsed `EntityStatus`
      otherwise, falling back to `EntityStatus.active` on an unrecognized value (data-model.md §1).
- [ ] T006 [US1] In `lib/core/widgets/entity_status_controls.dart`, change
      `EntityStatusFilterChips`'s "All" chip `onSelected` to call `onChanged` with a distinguishable
      "all" signal rather than `null` — since `value == null` must keep rendering "All" as selected
      per contracts/shared-widgets.md C3, thread the sentinel through the `onChanged(EntityStatus?)`
      call site's caller (T007) rather than changing this widget's own value type.
- [ ] T007 [US1] Update each of the ten status-facet list controllers to build their `ListQuery`
      facet writes and reads through T005's helper, and to default `status` to `EntityStatus.active`
      when constructing their filter type from `ListQuery.fromQuery`, in:
      `lib/features/auth/presentation/admin/user_profiles_list_screen.dart`,
      `lib/features/auth/presentation/admin/users_list_screen.dart`,
      `lib/features/catalog/presentation/employees_list_controller.dart`,
      `lib/features/catalog/presentation/facilities_list_controller.dart`,
      `lib/features/catalog/presentation/customers_list_controller.dart`,
      `lib/features/catalog/presentation/vehicle_operators_list_controller.dart` (or its screen if
      the controller has no local filter type), `lib/features/catalog/presentation/vehicles_list_controller.dart`,
      `lib/features/catalog/presentation/products_list_screen.dart`,
      `lib/features/catalog/presentation/payment_method_options_list_screen.dart`,
      `lib/features/pricing/presentation/pricing_grid_screen.dart`. Each write of the "All" chip's
      selection must now produce `status=all` in the URL, not an absent facet.
- [ ] T008 [US1] In `lib/core/navigation/list_query.dart`, confirm `ListQuery.isFiltered` counts a
      present `status=all` (or a present `status=<value>`) as filtered, and that a *default-applied*
      Active state (facet key entirely absent) is separately surfaced to the filters-badge callers
      so FR-006 holds — add a `ListQuery.hasAppliedDefault` (or equivalent) if the badge needs to
      distinguish "user chose Active" from "user chose nothing, Active applied" from "All chosen".
- [ ] T009 [US1] Confirm the POS sales, sales orders and cash sessions screens
      (`lib/features/sales/presentation/pos_sales_list_screen.dart`,
      `lib/features/sales/presentation/orders/sales_orders_list_screen.dart`,
      `lib/features/sales/presentation/cash_sessions_screen.dart`) are untouched by T005–T008 — no
      import of the new helper, no change to their existing `status == null` → "All" behavior
      (FR-007 regression guard).

### Tests for User Story 1

- [ ] T010 [P] [US1] Extend `test/unit/core/navigation/list_query_test.dart` with cases for T005's
      decode helper: absent → Active, `all` → `null`, a valid value → that value, an invalid value →
      Active.
- [ ] T011 [P] [US1] Add a widget test asserting the default-Active behavior for at least Customers
      and Vehicles (representative of the ten) in
      `test/widget/features/catalog/customers_list_screen_test.dart` and
      `test/widget/features/catalog/vehicles_list_screen_test.dart` (create if absent): a clean
      route shows only active fixtures; `status=all` shows every fixture; the status chips reflect
      the correct selection in both cases.
- [ ] T012 [P] [US1] Add a widget test confirming `pos_sales_list_screen_test.dart`,
      `sales_orders_list_screen_test.dart` and `cash_sessions_screen_test.dart` (wherever they
      already live under `test/widget/`) are unchanged — a clean route still shows every state,
      pinning FR-007 as a regression guard.

**Checkpoint**: US1 is independently shippable. `flutter test` clean for all touched files.

---

## Phase 4: User Story 2 — The search button always refreshes the list (Priority: P1)

**Goal**: Submitting the search control — with the same term or a changed one — always produces
exactly one fresh server request, without introducing per-keystroke fetching.

**Independent Test**: On any list, submit an unchanged term after the underlying data changed
elsewhere; the new data appears, with the page, sort and facets untouched.

### Implementation for User Story 2

- [ ] T013 [US2] Create `lib/core/navigation/list_search_submit.dart` implementing
      `submitCatalogSearch` per contracts/shared-widgets.md C4: navigates via `context.go` with a
      reset page index when the submitted term differs from the current one; otherwise calls the
      supplied `refresh` callback and leaves the query untouched. Must not call both paths.
- [ ] T014 [US2] Wire `CatalogSearchBar.onSubmitted` through T013's helper in all 20 screens that
      use `CatalogFilterBar` with a search box, passing each screen's own
      `ref.invalidate(<screen>ControllerProvider(filter))` as the `refresh` callback — the same
      closure each screen already passes to `CatalogListStateView.onRetry`:
      `lib/features/auth/presentation/admin/user_profiles_list_screen.dart`,
      `lib/features/auth/presentation/admin/users_list_screen.dart`,
      `lib/features/catalog/presentation/customers_list_screen.dart`,
      `lib/features/catalog/presentation/employees_list_screen.dart`,
      `lib/features/catalog/presentation/expenses_list_screen.dart`,
      `lib/features/catalog/presentation/facilities_list_screen.dart`,
      `lib/features/catalog/presentation/labels_list_screen.dart`,
      `lib/features/catalog/presentation/payment_method_options_list_screen.dart`,
      `lib/features/catalog/presentation/products_list_screen.dart`,
      `lib/features/catalog/presentation/suppliers_list_screen.dart`,
      `lib/features/catalog/presentation/taxpayer_issuers_list_screen.dart`,
      `lib/features/catalog/presentation/taxpayer_recipients_list_screen.dart`,
      `lib/features/catalog/presentation/vehicle_operators_list_screen.dart`,
      `lib/features/catalog/presentation/vehicles_list_screen.dart`,
      `lib/features/pricing/presentation/exchange_rates_list_screen.dart`,
      `lib/features/pricing/presentation/price_lists_list_screen.dart`,
      `lib/features/pricing/presentation/pricing_grid_screen.dart`,
      `lib/features/sales/presentation/cash_sessions_screen.dart`,
      `lib/features/sales/presentation/orders/sales_orders_list_screen.dart`,
      `lib/features/sales/presentation/pos_sales_list_screen.dart`.
- [ ] T015 [US2] Verify (per T004's Foundational check) that `CatalogListStateView` does not blank
      the table during the `ref.invalidate`-triggered reload; if it does, fix the guard in
      `lib/core/widgets/list_state_views.dart` here, scoped to this story (FR-012).

### Tests for User Story 2

- [ ] T016 [P] [US2] Add a unit test for `submitCatalogSearch` in
      `test/unit/core/navigation/list_search_submit_test.dart`: same term → refresh called, no
      navigation; different term → navigation called with reset page index, refresh not called;
      never both.
- [ ] T017 [P] [US2] Add a widget test on one representative screen (Labels — the simplest,
      search-only screen) in `test/widget/features/catalog/labels_list_screen_test.dart` (create if
      absent) asserting: submitting an unchanged term re-fetches and the previous rows stay visible
      during the fetch; submitting a changed term issues exactly one fetch; typing alone issues none.

**Checkpoint**: US2 is independently shippable, and independent of US1.

---

## Phase 5: User Story 3 — The list surface reads as one object (Priority: P2)

**Goal**: The filter row's content edges align with the list surface's content edges at every
width, and the list surface (already rounded and outlined by Phase 2's T002/T003) has that
correction reflected in its own component and in every screen that stopped padding it manually.

**Independent Test**: Render any list screen at each breakpoint in both themes; the search box's
left edge and the last filter control's right edge align with the table's edges; all four corners
are equally rounded; a hairline outline bounds it.

### Implementation for User Story 3

- [ ] T018 [US3] In `lib/core/widgets/catalog_filter_bar.dart`, add a horizontal inset of
      `spacing.cardPadding` (reading the tier-dependent value already used by `cardTheme.margin`) to
      both the `>= expanded` `Row` branch and the reflowed `Column`/`Wrap` branch, and replace the
      per-trailing-widget `Padding(right: 8)` with `Row`'s own `spacing:` argument so gaps sit
      between children only (research.md R1).
- [ ] T019 [US3] Remove the now-redundant `Padding(padding: const EdgeInsets.all(8))` wrapper around
      `CatalogFilterBar` from all 20 consuming screens (same list as T014, plus
      `lib/features/catalog/presentation/facilities_list_screen.dart` if not already listed) — the
      bar now insets itself.
- [ ] T020 [US3] [P] Replace the three hard-coded `BorderRadius.circular(6)` /
      `BorderRadius.circular(12)` literals in
      `lib/features/catalog/presentation/widgets/facility_card.dart` (lines ~200, ~248, ~525) with
      `shapes.smRadius` / `shapes.mdRadius` as appropriate, and add T002's hairline `BorderSide` to
      each of those `BoxDecoration`s (FR-023, FR-024). *(Card-level outline from T003 already
      applies to `FacilityCard`'s own `Card`; this task covers its inner `Container` surfaces.)*
- [ ] T021 [US3] [P] Replace the `BorderRadius.circular(6)` / `BorderRadius.circular(12)` literals
      in `lib/features/catalog/presentation/widgets/facility_child_row.dart` (lines ~29, ~161,
      ~249) with the matching `shapes` token, and add T002's hairline `BorderSide` to each
      `BoxDecoration` (FR-023, FR-024).

### Tests for User Story 3

- [ ] T022 [US3] Extend `test/widget/core/widgets/catalog_filter_bar_test.dart` with a real-inset
      assertion (per FR-016): render the bar next to a `DataTableView` at both the narrow and wide
      breakpoint and assert their left/right edges are equal, not merely that spacing tokens were
      referenced in code.
- [ ] T023 [US3] [P] Regenerate and manually review the affected goldens: `catalog_filter_bar_*`,
      `data_table_view_*`, `entity_status_controls_*` in `test/golden/goldens/`, plus any
      facility-card golden, via `flutter test test/golden --update-goldens`, confirming each diff
      shows only the intended rounding/outline/alignment change.
- [ ] T024 [US3] [P] Add a widget test in
      `test/widget/features/catalog/widgets/facility_card_test.dart` (create if absent) asserting
      the facility card and its three child-row variants render the hairline outline and that hover
      states remain visually distinguishable against it (FR-025).

**Checkpoint**: US3 is independently shippable, and independent of US1/US2. Every list screen in
the app now reads as one aligned, rounded, outlined object.

---

## Phase 6: User Story 4 — Facility cards and their child rows match the tables (Priority: P2)

**Goal**: `FacilityCard` and its warehouse/point-of-sale/cash-drawer rows are visually consistent
with the list surfaces.

**Independent Test**: Render the Facilities screen with a facility carrying all three child types;
each card/row carries the shared hairline outline and a tokenised radius.

> **Note**: T020/T021 (Phase 5) already implement this story's entire functional requirement set
> (FR-023–FR-025), because the outline/radius work for `FacilityCard` and its child rows is one
> edit shared with US3's alignment pass. This phase's remaining work is the story-specific
> end-to-end check that US3's implementation actually satisfies US4's independent test in isolation.

### Tests for User Story 4

- [ ] T025 [US4] Run the Facilities screen manually (or via the `dart` MCP driver) with a facility
      that has a warehouse, a point of sale and a cash drawer, and confirm against
      quickstart.md's "Facility cards (US4)" section: outline visible on all four surface kinds in
      both themes; hover/selection states still legible.

**Checkpoint**: US4 confirmed. No new implementation task — it rides on US3.

---

## Phase 7: User Story 5 — Simple records open beside the list, not instead of it (Priority: P3)

**Goal**: The 14 named entities are created, viewed, edited and deleted entirely from a panel over
their list, their per-record routes are removed, and the constitution is amended to make the
result compliant rather than merely tolerated.

**Independent Test**: For each of the 14 entities, create, view, edit and delete a record from its
list screen; the list's page, filters and scroll position are unchanged afterward.

**Dependency note**: This phase depends on Phase 2 (T002/T003 — panel and surface styling must
already be settled) per plan.md's sequencing. It does not depend on US1/US2/US3/US4's own
task completion, only on the Phase 2 checkpoint.

### Shared panel infrastructure for User Story 5

- [ ] T026 [US5] In `lib/core/widgets/app_side_sheet.dart`, add `width` (default `360`, clamped to
      the available viewport width less `spacing.cardPadding * 2`) and `confirmDismiss` (default
      `false`) parameters to `showAppSideSheet`; when `confirmDismiss` is true, route the barrier
      tap, the Escape key, and the close button through a caller-supplied dirty check before
      popping (contracts/shared-widgets.md C5, research.md R6/R8). Existing callers (the filter
      sheet, the shift sheet) must compile and behave unchanged, passing neither new argument.
- [ ] T027 [US5] Create `lib/core/widgets/record_sheet.dart` implementing `showRecordSheet` per
      contracts/shared-widgets.md C6: calls T026's `showAppSideSheet` at width `640`,
      `confirmDismiss: true`, wiring `isDirty` to the caller's dirty check.
- [ ] T028 [US5] Define the dirty-check pattern from data-model.md §3: for a `@riverpod` form
      controller whose state is a `freezed` class, snapshot the state once loading completes and
      compare with `!=` on dismissal. Document this as the pattern each of the 14 entity
      conversions below follows (no separate shared helper needed — freezed equality already does
      the comparison; this task is the reference implementation for the first entity, T029).

### Entity conversions for User Story 5

For each entity, the task is the same shape: extract the existing detail screen's body (everything
below its `Scaffold`/`AppBar`) into a form widget taking a `mode`/`forceReadOnly`-equivalent
argument, host it via T027 from the list screen's row-tap/Edit/New call sites, apply T028's dirty
guard, and delete the two `GoRoute`s. The first (T029) is written in full detail since it sets the
pattern every later one follows; later entities cite it.

- [ ] T029 [US5] Convert **Labels** (smallest, no relations): extract
      `lib/features/catalog/presentation/label_detail_screen.dart`'s body into
      `LabelForm` (same file or a new `label_form.dart`), taking `labelId` and `forceReadOnly`.
      Update `lib/features/catalog/presentation/labels_list_screen.dart`'s row `onTap`, its Edit
      action, and its "New" button to call `showRecordSheet` (T027) instead of `context.push`.
      Apply T028's dirty guard using `LabelFormState` equality. Remove the `/labels/new` and
      `/labels/:labelId` `GoRoute`s from `lib/app/router/app_router.dart` (~lines 411–422) and add a
      redirect from both to `/labels`.
- [ ] T030 [P] [US5] Convert **Suppliers** following T029's pattern:
      `lib/features/catalog/presentation/supplier_detail_screen.dart` →
      `lib/features/catalog/presentation/suppliers_list_screen.dart`; remove `/suppliers/new` and
      `/suppliers/:supplierId` from `lib/app/router/app_router.dart` (~lines 400–410).
- [ ] T031 [P] [US5] Convert **Expenses**: `lib/features/catalog/presentation/expense_detail_screen.dart`
      → `lib/features/catalog/presentation/expenses_list_screen.dart`; remove `/expenses/new` and
      `/expenses/:expenseId` (~lines 457–467).
- [ ] T032 [P] [US5] Convert **Vehicles**: `lib/features/catalog/presentation/vehicle_detail_screen.dart`
      → `lib/features/catalog/presentation/vehicles_list_screen.dart`; remove `/vehicles/new` and
      `/vehicles/:vehicleId` (~lines 468–478).
- [ ] T033 [P] [US5] Convert **Vehicle Operators**:
      `lib/features/catalog/presentation/vehicle_operator_detail_screen.dart` →
      `lib/features/catalog/presentation/vehicle_operators_list_screen.dart`; remove
      `/vehicle-operators/new` and `/vehicle-operators/:vehicleOperatorId` (~lines 479–491).
- [ ] T034 [P] [US5] Convert **Price Lists**:
      `lib/features/pricing/presentation/price_list_detail_screen.dart` →
      `lib/features/pricing/presentation/price_lists_list_screen.dart`; remove `/price-lists/new`
      and `/price-lists/:priceListId` (~lines 378–388). Confirm `/pricing` (the separate pricing
      grid route) is untouched — it is not one of the 14.
- [ ] T035 [P] [US5] Convert **Exchange Rates**:
      `lib/features/pricing/presentation/exchange_rate_detail_screen.dart` →
      `lib/features/pricing/presentation/exchange_rates_list_screen.dart`; remove
      `/exchange-rates/new` and `/exchange-rates/:exchangeRateId` (~lines 389–399).
- [ ] T036 [P] [US5] Convert **Payment Method Options**:
      `lib/features/catalog/presentation/payment_method_option_detail_screen.dart` →
      `lib/features/catalog/presentation/payment_method_options_list_screen.dart`; remove
      `/payment-method-options/new` and `/payment-method-options/:paymentMethodOptionId`
      (~lines 546–555), and add a redirect that keeps the existing `PrivilegeGate` check at
      `app_router.dart:744` intact.
- [ ] T037 [US5] Convert **Employees** (owns a taxpayer-recipient relation via `CatalogEntityPicker`
      — verify that picker keeps working inside the 640dp panel per FR-035):
      `lib/features/catalog/presentation/employee_detail_screen.dart` →
      `lib/features/catalog/presentation/employees_list_screen.dart`; remove `/employees/new` and
      `/employees/:employeeId` (~lines 422–431).
- [ ] T038 [US5] Convert **Customers** (owns three `CatalogEntityPicker`s — taxpayer recipient,
      employee, price list; per the FR-035 correction, there is no inline address/contact creation
      to preserve, only these autocompletes):
      `lib/features/catalog/presentation/customer_detail_screen.dart` →
      `lib/features/catalog/presentation/customers_list_screen.dart`; remove `/customers/new` and
      `/customers/:customerId` (~lines 433–443).
- [ ] T039 [US5] Convert **Taxpayer Recipients**:
      `lib/features/catalog/presentation/taxpayer_recipient_detail_screen.dart` →
      `lib/features/catalog/presentation/taxpayer_recipients_list_screen.dart`; remove
      `/taxpayer-recipients/new` and `/taxpayer-recipients/:taxpayerRecipientId` (~lines 444–456).
- [ ] T040 [US5] Convert **Warehouses** (facility child — reached only from the Facilities screen,
      not a top-level list): extract
      `lib/features/catalog/presentation/warehouse_detail_screen.dart`'s body into a `WarehouseForm`
      taking `warehouseId`, `facilityId` (for create) and `forceReadOnly`. In
      `lib/features/catalog/presentation/facilities_list_screen.dart`'s `_childActions` for
      `warehouseActions` (~line 203), replace the three `context.push('$path/...')` closures with
      calls to `showRecordSheet`. Remove `/warehouses/new` and `/warehouses/:warehouseId`
      (~lines 492–508).
- [ ] T041 [US5] Convert **Points of Sale** the same way as T040:
      `lib/features/catalog/presentation/point_sale_detail_screen.dart`, wired through
      `facilities_list_screen.dart`'s `pointSaleActions` (~line 210). Remove `/points-of-sale/new`
      and `/points-of-sale/:pointSaleId` (~lines 522–534).
- [ ] T042 [US5] Convert **Cash Drawers** the same way as T040:
      `lib/features/catalog/presentation/cash_drawer_detail_screen.dart`, wired through
      `facilities_list_screen.dart`'s `cashDrawerActions` (~line 217). Remove `/cash-drawers/new`
      and `/cash-drawers/:cashDrawerId` (~lines 509–521).
- [ ] T043 [US5] Confirm Products, Facilities, Taxpayer Issuers, Users and User Profiles were not
      touched by T029–T042 and keep their existing `/products/*`, `/facilities/*`,
      `/taxpayer-issuers/*`, `/users/*`, `/user-profiles/*` routes and full-screen presentation
      unchanged (FR-036 regression guard).

### Constitution amendment for User Story 5

- [ ] T044 [US5] Amend `.specify/memory/constitution.md` §VI: re-express the row-click,
      read-only-label/edit-toggle, and delete-placement rules in terms of the record's own
      **surface** (full screen or the shared panel) rather than a route, and add a sentence naming
      which entities use which (panel: the 14 named in Verbatim Constraints; full screen: products,
      facilities, taxpayer issuers, users, user profiles, and anything else with nested child
      collections). Bump the version header **1.12.0 → 1.13.0** with a Sync Impact Report entry
      matching this feature's plan.md Constitution Check section. Land this in the same change as
      T029 (the first converted entity), per the project's stated practice of landing a rule with
      the code that satisfies it.

### Tests for User Story 5

- [ ] T045 [US5] Add a widget test in `test/widget/features/catalog/labels_list_screen_test.dart`
      (extending T017's file if it now exists, else create) covering the full US5 create → view →
      edit → delete round trip for Labels: the list's page/filter state survives every open/close,
      the reopened panel starts clean (guarding the "global singleton controller" risk from
      plan.md's Risks table), and a dirty edit prompts before a barrier-tap dismissal.
- [ ] T046 [P] [US5] Add an integration test (live mbe-api) in
      `test/integration/crud_panel_flow_test.dart` exercising the same create/view/edit/delete
      round trip end-to-end for at least Labels, Customers (picker-heavy) and Warehouses
      (facility-child path), per quickstart.md's "Records in a panel" section.
- [ ] T047 [P] [US5] Add a routing test (or extend the router's existing test file, if any) asserting
      that `/labels/new`, `/labels/1`, and the equivalent old paths for all 14 entities now redirect
      to their entity's list rather than 404ing or erroring (FR-030).

**Checkpoint**: US5 is independently shippable once Phase 2 has landed. All 14 entities operate
entirely from their list screens; 28 routes are gone; the constitution matches the shipped code.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final verification across the whole feature, not owned by any single story.

- [ ] T048 [P] Run `flutter analyze` and `flutter test` across the full suite; both clean (SC-009).
- [ ] T049 [P] Walk quickstart.md's full manual section end-to-end once, on a real run against a
      live mbe-api, confirming every numbered step in every user-story section.
- [ ] T050 Update `TODO.md`'s 2026-08-30 entry, marking each of the seven original bullets
      addressed by this feature as done (matching the file's existing `~~strikethrough~~`
      convention), since the entry that seeded this feature is still open there.

---

## Dependencies & Execution Order

- **Phase 1 (Setup)** → **Phase 2 (Foundational)**: sequential, blocks everything below.
- **Phase 2** → all of Phases 3–7: every story depends on T002/T003 (the outline/clip theme
  change) having landed, since it changes what every later golden and every panel looks like.
- **Phases 3, 4, 6**: fully independent of each other and may run in parallel once Phase 2 closes.
- **Phase 5** must precede or accompany Phase 6 — T020/T021 (facility styling) are Phase 5 tasks
  that Phase 6's test (T025) verifies; Phase 6 has no implementation tasks of its own.
- **Phase 7** depends only on Phase 2, not on Phases 3/4/5/6 — it may run in parallel with them,
  but T029 (first entity) must land before T030–T042 (parallelizable) and must carry T044 (the
  constitution amendment) with it.
- **Phase 8** runs last, after every story phase has reached its checkpoint.

### Parallel opportunities

- T020 and T021 (facility widgets) — different files, no shared dependency beyond T002.
- T010, T011, T012 (US1 tests) — different files.
- T016, T017 (US2 tests) — different files.
- T023, T024 (US3 tests) — different work (goldens vs. new widget test).
- T030–T036 (seven of the fourteen entity conversions with no relational picker) — once T029
  establishes the pattern, these seven touch disjoint file pairs and can proceed in parallel.
  T037–T042 are listed sequentially only because each carries its own relational or facility-child
  nuance worth a solo pass, not because of a file conflict — they may also run in parallel with
  each other and with T030–T036 if capacity allows.

## Implementation Strategy

**MVP = Phase 1 + Phase 2 + Phase 3 (User Story 1)**: the single most-repeated piece of friction,
landed with the smallest blast radius. Phase 4 (US2) is equally small and equally P1 — ship
alongside or immediately after.

**Incremental delivery**: Phases 3, 4, 5+6, and 7 are each independently shippable per plan.md's
sequencing (styling → search → default filter → panels is the recommended order, but 3/4/5/6 have
no ordering dependency among themselves — only Phase 7 has the Phase-2-only prerequisite noted
above). Ship each phase's checkpoint as its own increment rather than waiting for all seven items.
